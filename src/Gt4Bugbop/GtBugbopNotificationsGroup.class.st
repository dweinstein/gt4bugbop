Class {
	#name : 'GtBugbopNotificationsGroup',
	#superclass : 'GtBugbopGroup',
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopNotificationsGroup class >> itemClass [
	^ GtBugbopNotification
]

{ #category : 'gt views' }
GtBugbopNotificationsGroup >> gtByKindFor: aView [
	<gtView>
	^ aView columnedList
		title: 'By kind';
		priority: 2;
		items: [ ((self groupedBy: [ :each | each kindLabel ]) associations) sorted: [ :a :b | a value size > b value size ] ];
		column: 'Kind' text: [ :each | each key ];
		column: 'Count' text: [ :each | each value size ] width: 60;
		column: 'Unread' text: [ :each | each value unread size ] width: 60;
		send: [ :each | each value ]
]

{ #category : 'gt views' }
GtBugbopNotificationsGroup >> gtNotificationsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Notifications';
		priority: 1;
		items: [ self items ];
		column: '' text: [ :each | each isUnread ifTrue: [ '●' asRopedText foreground: (Color fromHexString: '1565C0') ] ifFalse: [ '' ] ] width: 20;
		column: 'When' text: [ :each | each createdAt ifNil: [ '' ] ifNotNil: [ :aTime | aTime asLocal printString first: 16 ] ] width: 130;
		column: 'Kind' text: [ :each | each kindLabel ] width: 170;
		column: 'About' text: [ :each | each subject ];
		column: 'Program' text: [ :each | each program ifNil: [ '' ] ifNotNil: [ :aProgram | aProgram name ] ] width: 160
]

{ #category : 'filtering' }
GtBugbopNotificationsGroup >> unread [
	^ self select: [ :each | each isUnread ]
]
