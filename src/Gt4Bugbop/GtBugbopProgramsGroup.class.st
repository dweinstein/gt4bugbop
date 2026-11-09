Class {
	#name : 'GtBugbopProgramsGroup',
	#superclass : 'GtBugbopGroup',
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopProgramsGroup class >> itemClass [
	^ GtBugbopProgram
]

{ #category : 'gt views' }
GtBugbopProgramsGroup >> gtProgramsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Programs';
		priority: 1;
		items: [ self items ];
		column: 'Name' text: [ :each | each name ];
		column: 'My role' text: [ :each | each role ifNil: [ '' ] ] width: 80;
		column: 'Visibility' text: [ :each | each visibility ifNil: [ '' ] ] width: 80;
		column: 'Bounty' text: [ :each | each bountyType ifNil: [ '' ] ] width: 70;
		column: 'AI triage' text: [ :each | (each aiTriage = true) ifTrue: [ 'yes' ] ifFalse: [ '' ] ] width: 70;
		column: 'Site' text: [ :each | each site ifNil: [ '' ] ]
]

{ #category : 'filtering' }
GtBugbopProgramsGroup >> staffPrograms [
	"Programs where I am on the team"
	^ self select: [ :each | each isStaff ]
]
