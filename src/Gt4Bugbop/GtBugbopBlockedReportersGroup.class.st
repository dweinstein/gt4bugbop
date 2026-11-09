Class {
	#name : 'GtBugbopBlockedReportersGroup',
	#superclass : 'GtBugbopGroup',
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopBlockedReportersGroup class >> itemClass [
	^ GtBugbopBlockedReporter
]

{ #category : 'gt views' }
GtBugbopBlockedReportersGroup >> gtBlockedReportersFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Blocked reporters';
		priority: 1;
		items: [ self items ];
		column: 'User' text: [ :each | each user ifNil: [ '' ] ifNotNil: [ :aUser | aUser username ] ];
		column: 'Blocked by' text: [ :each | each blockedBy ifNil: [ '' ] ifNotNil: [ :aUser | aUser username ] ] width: 140;
		column: 'When' text: [ :each | each createdAt ifNil: [ '' ] ifNotNil: [ :aTime | aTime asDate ] ] width: 100
]
