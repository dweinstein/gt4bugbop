Class {
	#name : 'GtBugbopReportsGroup',
	#superclass : 'GtBugbopGroup',
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopReportsGroup class >> itemClass [
	^ GtBugbopReport
]

{ #category : 'filtering' }
GtBugbopReportsGroup >> active [
	"Reports that are new, open or waiting on info: the triage queue"
	^ self select: [ :each | each isActive ]
]

{ #category : 'gt views' }
GtBugbopReportsGroup >> barFor: aCount of: aTotal color: aColor [
	"A proportional bar element, at most 200 pixels wide"
	| width |
	width := aTotal isZero ifTrue: [ 0 ] ifFalse: [ (aCount / aTotal * 200) asFloat ].
	^ BlElement new
		background: aColor;
		height: 10;
		width: (width max: 1);
		margin: (BlInsets top: 4)
]

{ #category : 'aggregating' }
GtBugbopReportsGroup >> bountyAmountString [
	^ GtBugbopBountyRange amountStringFromCents: self bountyTotalCents
]

{ #category : 'aggregating' }
GtBugbopReportsGroup >> bountyTotalCents [
	^ self inject: 0 into: [ :sum :each | sum + (each bountyTotalCents ifNil: [ 0 ]) ]
]

{ #category : 'filtering' }
GtBugbopReportsGroup >> byReporter: aUserOrUsername [
	| aUsername |
	aUsername := aUserOrUsername isString
			ifTrue: [ aUserOrUsername ]
			ifFalse: [ aUserOrUsername username ].
	^ self select: [ :each | each reporterName = aUsername ]
]

{ #category : 'aggregating' }
GtBugbopReportsGroup >> countWithSeverity: aSeverity status: aStatus [
	^ self items count: [ :each | each severity = aSeverity and: [ each status = aStatus ] ]
]

{ #category : 'aggregating' }
GtBugbopReportsGroup >> countWithStatus: aStatus [
	^ self items count: [ :each | each status = aStatus ]
]

{ #category : 'gt views' }
GtBugbopReportsGroup >> gtActivityFor: aView [
	<gtView>
	| theWeeks busiest |
	theWeeks := self weeklyActivity reversed.
	busiest := theWeeks inject: 1 into: [ :max :week | max max: week value size ].
	^ aView columnedList
		title: 'Weekly activity';
		priority: 7;
		items: [ theWeeks ];
		column: 'Week of' text: [ :each | each key yyyymmdd ] width: 110;
		column: 'Reports' text: [ :each | each value size ] width: 70;
		column: '' stencil: [ :each | self barFor: each value size of: busiest color: (Color fromHexString: '1565C0') ] width: 220;
		send: [ :each | each value ]
]

{ #category : 'gt views' }
GtBugbopReportsGroup >> gtBySeverityFor: aView [
	<gtView>
	^ aView columnedList
		title: 'By severity';
		priority: 4;
		items: [ self severityBreakdown ];
		column: 'Severity' text: [ :each | GtBugbopReport severityText: each key ] width: 120;
		column: 'Reports' text: [ :each | each value size ] width: 70;
		column: 'Active' text: [ :each | each value active size ] width: 70;
		column: '' stencil: [ :each | self barFor: each value size of: self size color: (GtBugbopReport severityColorFor: each key) ] width: 220;
		send: [ :each | each value ]
]

{ #category : 'gt views' }
GtBugbopReportsGroup >> gtByStatusFor: aView [
	<gtView>
	^ aView columnedList
		title: 'By status';
		priority: 3;
		items: [ self statusBreakdown ];
		column: 'Status' text: [ :each | GtBugbopReport statusText: each key ] width: 120;
		column: 'Reports' text: [ :each | each value size ] width: 70;
		column: '' stencil: [ :each | self barFor: each value size of: self size color: (GtBugbopReport statusColorFor: each key) ] width: 220;
		send: [ :each | each value ]
]

{ #category : 'gt views' }
GtBugbopReportsGroup >> gtHuntersFor: aView [
	<gtView>
	^ aView forward
		title: 'Hunters';
		priority: 6;
		object: [ self hunterSummaries ];
		view: #gtHuntersFor:
]

{ #category : 'gt views' }
GtBugbopReportsGroup >> gtReportsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Reports';
		priority: 1;
		items: [ self items ];
		column: 'Severity' text: [ :each | GtBugbopReport severityText: each severity ] width: 70;
		column: 'Status' text: [ :each | GtBugbopReport statusText: each status ] width: 100;
		column: 'Title' text: [ :each | each title ];
		column: 'Reporter' text: [ :each | each reporterName ] width: 120;
		column: 'Age' text: [ :each | each ageString ] width: 50;
		column: 'Comments' text: [ :each | each commentsCount ifNil: [ '' ] ] width: 70;
		column: 'Bounty' text: [ :each | each bountyAmountString ] width: 90
]

{ #category : 'gt views' }
GtBugbopReportsGroup >> gtSeverityStatusMatrixFor: aView [
	<gtView>
	| aList |
	aList := aView columnedList
			title: 'Severity x status';
			priority: 5;
			items: [ self severityBreakdown ];
			column: 'Severity' text: [ :each | GtBugbopReport severityText: each key ] width: 90.
	GtBugbopReport statuses do: [ :aStatus | 
		aList
			column: aStatus
			text: [ :each | self matrixCellFor: (each value countWithStatus: aStatus) ]
			width: 85 ].
	^ aList
		column: 'Total' text: [ :each | each value size ] width: 60;
		send: [ :each | each value ]
]

{ #category : 'aggregating' }
GtBugbopReportsGroup >> hunterSummaries [
	"Answer one GtBugbopHunterSummary per reporter, most reports first"
	| byReporter |
	byReporter := self items groupedBy: [ :each | each reporterName ].
	^ (GtBugbopHunterSummariesGroup
		withAll: (byReporter values collect: [ :theReports | 
			GtBugbopHunterSummary
				user: theReports first user
				reports: (GtBugbopReportsGroup withAll: theReports asOrderedCollection) ]) asOrderedCollection)
		sortedByReportCount
]

{ #category : 'filtering' }
GtBugbopReportsGroup >> inProgram: aProgramOrId [
	| anId |
	anId := aProgramOrId isString ifTrue: [ aProgramOrId ] ifFalse: [ aProgramOrId id ].
	^ self select: [ :each | each program notNil and: [ each program id = anId ] ]
]

{ #category : 'filtering' }
GtBugbopReportsGroup >> matching: aSubstring [
	"Case-insensitive search over title and description"
	^ self select: [ :each | 
		((each title ifNil: [ '' ]) includesSubstring: aSubstring caseSensitive: false)
			or: [ (each description ifNil: [ '' ]) includesSubstring: aSubstring caseSensitive: false ] ]
]

{ #category : 'gt views' }
GtBugbopReportsGroup >> matrixCellFor: aCount [
	aCount isZero ifTrue: [ ^ '·' asRopedText foreground: Color lightGray ].
	^ aCount printString asRopedText bold
]

{ #category : 'aggregating' }
GtBugbopReportsGroup >> severityBreakdown [
	"Answer severity -> sub-group, most severe first; reports without severity come last"
	^ ((GtBugbopReport severities copyWith: nil)
		collect: [ :aSeverity | aSeverity -> (self withSeverity: aSeverity) ])
		reject: [ :each | each value isEmpty ]
]

{ #category : 'sorting' }
GtBugbopReportsGroup >> sortedBySeverity [
	"Most severe first, then newest first"
	^ self sorted: [ :a :b | 
		a severityRank = b severityRank
			ifTrue: [ (a createdAt ifNil: [ DateAndTime epoch ]) > (b createdAt ifNil: [ DateAndTime epoch ]) ]
			ifFalse: [ a severityRank < b severityRank ] ]
]

{ #category : 'aggregating' }
GtBugbopReportsGroup >> statusBreakdown [
	"Answer status -> sub-group, in workflow order, omitting empty statuses"
	^ (GtBugbopReport statuses collect: [ :aStatus | aStatus -> (self withStatus: aStatus) ])
		reject: [ :each | each value isEmpty ]
]

{ #category : 'private' }
GtBugbopReportsGroup >> weekStartOf: aDateAndTime [
	"Monday of the week, in UTC (Bugbop timestamps are UTC)"
	| aDate |
	aDate := aDateAndTime asUTC asDate.
	^ aDate subtractDays: (aDate dayOfWeek - 2) \\ 7
]

{ #category : 'aggregating' }
GtBugbopReportsGroup >> weeklyActivity [
	"Answer week start Date -> reports submitted that week, oldest first, including empty weeks"
	| byWeek dated firstWeek lastWeek weeks |
	dated := self items select: [ :each | each createdAt notNil ].
	dated ifEmpty: [ ^ #() ].
	byWeek := dated groupedBy: [ :each | self weekStartOf: each createdAt ].
	firstWeek := byWeek keys min.
	lastWeek := byWeek keys max.
	weeks := OrderedCollection new.
	[ firstWeek <= lastWeek ] whileTrue: [ 
		weeks add: firstWeek -> (GtBugbopReportsGroup withAll: (byWeek at: firstWeek ifAbsent: [ OrderedCollection new ]) asOrderedCollection).
		firstWeek := firstWeek addDays: 7 ].
	^ weeks
]

{ #category : 'filtering' }
GtBugbopReportsGroup >> withBounty [
	^ self select: [ :each | each hasBounty ]
]

{ #category : 'filtering' }
GtBugbopReportsGroup >> withSeverity: aSeverityOrNil [
	^ self select: [ :each | each severity = aSeverityOrNil ]
]

{ #category : 'filtering' }
GtBugbopReportsGroup >> withStatus: aStatus [
	^ self select: [ :each | each status = aStatus ]
]
