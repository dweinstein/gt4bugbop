"
GET /notifications (newest first), optionally unread=true
"
Class {
	#name : 'GtBugbopListNotificationsAPICommand',
	#superclass : 'GtBugbopListAPICommand',
	#instVars : [
		'unreadOnly'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopListNotificationsAPICommand >> path [
	^ 'notifications'
]

{ #category : 'accessing' }
GtBugbopListNotificationsAPICommand >> queryParameters [
	unreadOnly == true ifFalse: [ ^ #() ].
	^ { 'unread' -> 'true' }
]

{ #category : 'accessing' }
GtBugbopListNotificationsAPICommand >> serializationClass [
	^ GtBugbopNotificationsGroup
]

{ #category : 'accessing' }
GtBugbopListNotificationsAPICommand >> unreadOnly: aBoolean [
	unreadOnly := aBoolean
]
