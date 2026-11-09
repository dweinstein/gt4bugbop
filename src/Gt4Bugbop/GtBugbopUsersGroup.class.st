Class {
	#name : 'GtBugbopUsersGroup',
	#superclass : 'GtBugbopGroup',
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopUsersGroup class >> itemClass [
	^ GtBugbopUser
]

{ #category : 'gt views' }
GtBugbopUsersGroup >> gtUsersFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Users';
		priority: 1;
		items: [ self items ];
		column: 'Username' text: [ :each | each username ];
		column: 'Strikes' text: [ :each | each strikesCount ifNil: [ '' ] ] width: 70;
		column: 'Bounties paid' text: [ :each | each bountiesPaidCount ifNil: [ '' ] ] width: 100;
		column: 'Joined' text: [ :each | each createdAt ifNil: [ '' ] ifNotNil: [ :aTime | aTime asDate ] ] width: 100
]
