"
GET /programs/:program_id/access_requests with optional status filter
"
Class {
	#name : 'GtBugbopListAccessRequestsAPICommand',
	#superclass : 'GtBugbopListAPICommand',
	#instVars : [
		'program',
		'statuses'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopListAccessRequestsAPICommand >> path [
	^ 'programs/' , (self idFrom: program) , '/access_requests'
]

{ #category : 'accessing' }
GtBugbopListAccessRequestsAPICommand >> program: aProgramOrId [
	program := aProgramOrId
]

{ #category : 'accessing' }
GtBugbopListAccessRequestsAPICommand >> queryParameters [
	statuses isEmptyOrNil ifTrue: [ ^ #() ].
	^ { 'status' -> (self commaList: statuses) }
]

{ #category : 'accessing' }
GtBugbopListAccessRequestsAPICommand >> serializationClass [
	^ GtBugbopAccessRequestsGroup
]

{ #category : 'accessing' }
GtBugbopListAccessRequestsAPICommand >> statuses: aCollectionOrNil [
	"Any of pending, approved, rejected"
	statuses := aCollectionOrNil
]
