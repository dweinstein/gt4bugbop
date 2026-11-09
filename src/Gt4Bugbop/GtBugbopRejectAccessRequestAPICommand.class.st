"
POST /access_requests/:id/reject (rejection reason required). Notifies the hunter.
"
Class {
	#name : 'GtBugbopRejectAccessRequestAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'accessRequest',
		'rejectionReason'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopRejectAccessRequestAPICommand >> accessRequest: anAccessRequestOrId [
	accessRequest := anAccessRequestOrId
]

{ #category : 'accessing' }
GtBugbopRejectAccessRequestAPICommand >> rejectionReason: aString [
	rejectionReason := aString
]

{ #category : 'accessing' }
GtBugbopRejectAccessRequestAPICommand >> request [
	rejectionReason isEmptyOrNil ifTrue: [ self error: 'Bugbop requires a rejection reason' ].
	^ self client
		post: 'access_requests/' , (self idFrom: accessRequest) , '/reject'
		withEntity: (Dictionary with: 'rejection_reason' -> rejectionReason)
]

{ #category : 'accessing' }
GtBugbopRejectAccessRequestAPICommand >> serializationClass [
	^ GtBugbopAccessRequest
]
