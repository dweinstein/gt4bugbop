Class {
	#name : 'GtBugbopAccessRequestsGroup',
	#superclass : 'GtBugbopGroup',
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopAccessRequestsGroup class >> itemClass [
	^ GtBugbopAccessRequest
]

{ #category : 'gt views' }
GtBugbopAccessRequestsGroup >> gtAccessRequestsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Access requests';
		priority: 1;
		items: [ self items ];
		column: 'Status' text: [ :each | each status ] width: 80;
		column: 'Hunter' text: [ :each | each user ifNil: [ '' ] ifNotNil: [ :aUser | aUser username ] ] width: 120;
		column: 'Strikes' text: [ :each | each user ifNil: [ '' ] ifNotNil: [ :aUser | aUser strikesCount ifNil: [ '' ] ] ] width: 60;
		column: 'Paid' text: [ :each | each user ifNil: [ '' ] ifNotNil: [ :aUser | aUser bountiesPaidCount ifNil: [ '' ] ] ] width: 50;
		column: 'Message' text: [ :each | each message ifNil: [ '' ] ];
		column: 'Requested' text: [ :each | each createdAt ifNil: [ '' ] ifNotNil: [ :aTime | aTime asDate ] ] width: 100
]

{ #category : 'filtering' }
GtBugbopAccessRequestsGroup >> pending [
	^ self select: [ :each | each isPending ]
]
