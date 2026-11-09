"
POST /notifications/mark_as_read. With no notifications given, marks everything read. Answers the number marked.
"
Class {
	#name : 'GtBugbopMarkNotificationsReadAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'notifications'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopMarkNotificationsReadAPICommand >> notifications: aCollectionOrNil [
	"Notifications or ids; nil marks everything read"
	notifications := aCollectionOrNil
]

{ #category : 'accessing' }
GtBugbopMarkNotificationsReadAPICommand >> perform [
	"Answer how many notifications were marked read. An empty selection marks nothing
	(only nil means 'mark everything'), and makes no request."
	(notifications notNil and: [ notifications isEmpty ]) ifTrue: [ ^ 0 ].
	^ self request result at: 'marked_read' ifAbsent: [ 0 ]
]

{ #category : 'accessing' }
GtBugbopMarkNotificationsReadAPICommand >> request [
	| entity |
	entity := Dictionary new.
	notifications ifNotNil: [ entity at: 'ids' put: (notifications collect: [ :each | self idFrom: each ]) asArray ].
	^ self client post: 'notifications/mark_as_read' withEntity: entity
]
