"
POST /access_requests/:id/approve. Notifies the hunter.
"
Class {
	#name : 'GtBugbopApproveAccessRequestAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'accessRequest',
		'acceptanceMessage'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopApproveAccessRequestAPICommand >> acceptanceMessage: aStringOrNil [
	"nil uses the program's access_acceptance_template"
	acceptanceMessage := aStringOrNil
]

{ #category : 'accessing' }
GtBugbopApproveAccessRequestAPICommand >> accessRequest: anAccessRequestOrId [
	accessRequest := anAccessRequestOrId
]

{ #category : 'accessing' }
GtBugbopApproveAccessRequestAPICommand >> request [
	| entity |
	entity := Dictionary new.
	acceptanceMessage ifNotNil: [ entity at: 'acceptance_message' put: acceptanceMessage ].
	^ self client
		post: 'access_requests/' , (self idFrom: accessRequest) , '/approve'
		withEntity: entity
]

{ #category : 'accessing' }
GtBugbopApproveAccessRequestAPICommand >> serializationClass [
	^ GtBugbopAccessRequest
]
