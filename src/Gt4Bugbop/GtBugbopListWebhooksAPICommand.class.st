"
GET /programs/:program_id/webhooks (needs the webhooks scope)
"
Class {
	#name : 'GtBugbopListWebhooksAPICommand',
	#superclass : 'GtBugbopListAPICommand',
	#instVars : [
		'program'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopListWebhooksAPICommand >> path [
	^ 'programs/' , (self idFrom: program) , '/webhooks'
]

{ #category : 'accessing' }
GtBugbopListWebhooksAPICommand >> program: aProgramOrId [
	program := aProgramOrId
]

{ #category : 'accessing' }
GtBugbopListWebhooksAPICommand >> serializationClass [
	^ GtBugbopWebhooksGroup
]
