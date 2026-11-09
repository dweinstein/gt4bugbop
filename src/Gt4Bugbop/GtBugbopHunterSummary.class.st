"
I summarise one hunter's reports: counts by status and severity, and bounties awarded.
"
Class {
	#name : 'GtBugbopHunterSummary',
	#superclass : 'Object',
	#instVars : [
		'user',
		'reports'
	],
	#category : 'Gt4Bugbop-Explorer',
	#package : 'Gt4Bugbop',
	#tag : 'Explorer'
}

{ #category : 'instance creation' }
GtBugbopHunterSummary class >> user: aUser reports: aReportsGroup [
	^ self new
		user: aUser;
		reports: aReportsGroup;
		yourself
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> activeCount [
	^ reports active size
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> bountyAmountString [
	^ reports bountyTotalCents isZero
		ifTrue: [ '' ]
		ifFalse: [ reports bountyAmountString ]
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> client [
	^ reports client
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> client: aClient [
	"Reports already carry their client"
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> fixedCount [
	^ reports countWithStatus: 'fixed'
]

{ #category : 'gt views' }
GtBugbopHunterSummary >> gtBySeverityFor: aView [
	<gtView>
	^ aView forward
		title: 'By severity';
		priority: 2;
		object: [ reports ];
		view: #gtBySeverityFor:
]

{ #category : 'gt views' }
GtBugbopHunterSummary >> gtReportsFor: aView [
	<gtView>
	^ aView forward
		title: 'Reports';
		priority: 1;
		object: [ reports ];
		view: #gtReportsFor:
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> highestSeverity [
	^ (reports items detectMin: [ :each | each severityRank ]) ifNotNil: [ :aReport | aReport severity ]
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> lastReportedAt [
	^ (reports items collect: [ :each | each createdAt ] thenReject: [ :each | each isNil ])
		ifEmpty: [ nil ]
		ifNotEmpty: [ :theTimes | theTimes max ]
]

{ #category : 'printing' }
GtBugbopHunterSummary >> printOn: aStream [
	aStream
		nextPutAll: self username;
		nextPutAll: ' (';
		print: self reportCount;
		nextPutAll: ' reports)'
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> rejectedCount [
	"Duplicates, not applicable and won't fix"
	^ reports items count: [ :each | #('duplicate' 'not_applicable' 'wont_fix') includes: each status ]
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> reportCount [
	^ reports size
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> reports [
	^ reports
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> reports: aReportsGroup [
	reports := aReportsGroup
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> signalRatio [
	"Answer the fraction of resolved reports that were valid, or nil if none resolved"
	| resolved |
	resolved := self fixedCount + self rejectedCount.
	resolved isZero ifTrue: [ ^ nil ].
	^ self fixedCount / resolved
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> signalRatioString [
	^ self signalRatio
		ifNil: [ '' ]
		ifNotNil: [ :aRatio | (aRatio * 100) rounded printString , '%' ]
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> user [
	^ user
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> user: aUser [
	user := aUser
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> username [
	^ user ifNil: [ '(unknown)' ] ifNotNil: [ :aUser | aUser username ]
]
