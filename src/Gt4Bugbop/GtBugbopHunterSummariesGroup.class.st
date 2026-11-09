Class {
	#name : 'GtBugbopHunterSummariesGroup',
	#superclass : 'GtBugbopGroup',
	#category : 'Gt4Bugbop-Explorer',
	#package : 'Gt4Bugbop',
	#tag : 'Explorer'
}

{ #category : 'accessing' }
GtBugbopHunterSummariesGroup class >> itemClass [
	^ GtBugbopHunterSummary
]

{ #category : 'gt views' }
GtBugbopHunterSummariesGroup >> gtHuntersFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Hunters';
		priority: 1;
		items: [ self items ];
		column: 'Hunter' text: [ :each | each username ];
		column: 'Reports' text: [ :each | each reportCount ] width: 60;
		column: 'Active' text: [ :each | each activeCount ] width: 55;
		column: 'Fixed' text: [ :each | each fixedCount ] width: 50;
		column: 'Rejected' text: [ :each | each rejectedCount ] width: 65;
		column: 'Signal' text: [ :each | each signalRatioString ] width: 55;
		column: 'Top severity' text: [ :each | GtBugbopReport severityText: each highestSeverity ] width: 90;
		column: 'Bounties' text: [ :each | each bountyAmountString ] width: 90;
		column: 'Last report' text: [ :each | each lastReportedAt ifNil: [ '' ] ifNotNil: [ :aTime | aTime asDate yyyymmdd ] ] width: 90
]

{ #category : 'sorting' }
GtBugbopHunterSummariesGroup >> sortedByReportCount [
	^ self sorted: [ :a :b | a reportCount > b reportCount ]
]
