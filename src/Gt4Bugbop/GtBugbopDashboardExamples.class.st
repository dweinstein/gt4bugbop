"
I hold examples for GtBugbopDashboard and GtBugbopDashboardTile. Tested examples use only the offline fixtures from GtBugbopExamples; liveDashboard is marked <noTest> and reads live data only.
"
Class {
	#name : 'GtBugbopDashboardExamples',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Examples',
	#package : 'Gt4Bugbop',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtBugbopDashboardExamples >> activeSeveritySegments [
	<gtExample>
	<return: #Array>
	| aDashboard theSegments |
	aDashboard := self dashboard.
	theSegments := aDashboard activeSeveritySegments.
	self assert: (theSegments collect: [ :each | each value ]) asArray equals: #(1 2 2 1).
	self assert: (theSegments allSatisfy: [ :each | each target items allSatisfy: [ :aReport | aReport isActive ] ]).
	self assert: aDashboard activeSeverityMix size equals: 4.
	^ theSegments
]

{ #category : 'examples' }
GtBugbopDashboardExamples >> dashboard [
	<gtExample>
	<return: #GtBugbopDashboard>
	| aDashboard |
	aDashboard := GtBugbopDashboard forExplorer: self explorer.
	self assert: aDashboard reports size equals: 14.
	self assert: aDashboard activeReports size equals: 6.
	self assert: aDashboard triageQueue size equals: 6.
	self assert: aDashboard criticalAndHighActive size equals: 3.
	"Only active, unconfirmed suspicions - the same set as the duplicate map's pending suspicions"
	self assert: (aDashboard suspectedDuplicates collect: #id) asArray equals: #('i5' 'i9').
	self assert: aDashboard suspectedDuplicates size equals: (GtBugbopDuplicateMap forReports: aDashboard reports) pendingSuspicions size.
	self assert: aDashboard scopeWarnings size equals: 3.
	self assert: aDashboard aiDisagreements size equals: 4.
	self assert: aDashboard hunters size equals: 6.
	self assert: aDashboard unreadNotifications size equals: 1.
	^ aDashboard
]

{ #category : 'examples' }
GtBugbopDashboardExamples >> dashboardElement [
	"The dashboard renders header, tile flow and two mix sections"
	<gtExample>
	<return: #BlElement>
	| anElement aPane |
	anElement := self dashboard newDashboardElement.
	aPane := anElement children first.
	self assert: aPane children size equals: 4.
	self assert: (aPane children at: 2) children size equals: 12.
	^ anElement
]

{ #category : 'examples' }
GtBugbopDashboardExamples >> emptyDashboard [
	"No reports: zero tiles, no median, friendly empty states instead of errors"
	<gtExample>
	<return: #GtBugbopDashboard>
	| anExplorer aDashboard |
	anExplorer := GtBugbopExamples new explorer.
	anExplorer reports: GtBugbopReportsGroup new.
	aDashboard := GtBugbopDashboard forExplorer: anExplorer.
	self assert: aDashboard medianActiveAgeInDays isNil.
	self assert: aDashboard medianAgeTile displayValue equals: '-'.
	self assert: aDashboard severitySegments isEmpty.
	self assert: aDashboard statusSegments isEmpty.
	self assert: (aDashboard newSeverityChartElement isKindOf: BrLabel).
	self assert: aDashboard newDashboardElement notNil.
	^ aDashboard
]

{ #category : 'examples' }
GtBugbopDashboardExamples >> explorer [
	"The offline explorer, loaded with the richer insights fixture (14 reports)"
	<gtExample>
	<return: #GtBugbopExplorer>
	| anExplorer |
	anExplorer := GtBugbopExamples new explorer.
	anExplorer reports: GtBugbopExamples new insightsReportsGroup.
	self assert: anExplorer reports size equals: 14.
	^ anExplorer
]

{ #category : 'examples - live' }
GtBugbopDashboardExamples >> liveDashboard [
	"Read-only dashboard over live Bugbop data (network access, no writes)"
	<gtExample>
	<noTest>
	<return: #GtBugbopDashboard>
	^ GtBugbopDashboard forExplorer: GtBugbopLiveExamples new explorer
]

{ #category : 'examples' }
GtBugbopDashboardExamples >> medianActiveAge [
	"The median lies between the youngest and oldest active report and the oldest-first group starts with the oldest"
	<gtExample>
	<return: #SmallInteger>
	| aDashboard aMedian theAges |
	aDashboard := self dashboard.
	aMedian := aDashboard medianActiveAgeInDays.
	theAges := aDashboard activeReports items collect: [ :each | each ageInDays ].
	self assert: aMedian >= theAges min.
	self assert: aMedian <= theAges max.
	self assert: aDashboard activeByAge size equals: 6.
	self assert: aDashboard activeByAge items first ageInDays equals: theAges max.
	^ aMedian
]

{ #category : 'examples' }
GtBugbopDashboardExamples >> severitySegments [
	"Segments for all reports, most severe first, covering every report"
	<gtExample>
	<return: #Array>
	| theSegments |
	theSegments := self dashboard severitySegments.
	self assert: (theSegments collect: [ :each | each label ]) asArray equals: #('Critical' 'High' 'Medium' 'Low').
	self assert: (theSegments collect: [ :each | each value ]) asArray equals: #(2 4 4 4).
	self assert: (theSegments collect: [ :each | each detail ]) asArray equals: #('14%' '29%' '29%' '29%').
	self assert: theSegments first color equals: (GtBugbopReport severityColorFor: 'critical').
	^ theSegments
]

{ #category : 'examples' }
GtBugbopDashboardExamples >> statusSegments [
	"Segments in workflow order with distinct colors for every status"
	<gtExample>
	<return: #Array>
	| theSegments |
	theSegments := self dashboard statusSegments.
	self assert: (theSegments collect: [ :each | each label ]) asArray equals: #('New' 'Open' 'Needs info' 'Fixed' 'Wont fix' 'Duplicate' 'Not applicable').
	self assert: (theSegments inject: 0 into: [ :aSum :each | aSum + each value ]) equals: 14.
	self assert: (theSegments collect: [ :each | each color ]) asSet size equals: 7.
	^ theSegments
]

{ #category : 'examples' }
GtBugbopDashboardExamples >> tile [
	<gtExample>
	<return: #GtBugbopDashboardTile>
	| aTile |
	aTile := GtBugbopDashboardTile
			label: 'Fixed'
			value: 3
			detail: '21% of all reports'
			color: Color green
			target: #(1 2 3).
	self assert: aTile displayValue equals: '3'.
	self assert: aTile printString equals: 'Fixed: 3'.
	self assert: (aTile tooltipText includesSubstring: '21% of all reports').
	self assert: (GtBugbopDashboardTile new value: nil) displayValue equals: '-'.
	^ aTile
]

{ #category : 'examples' }
GtBugbopDashboardExamples >> tiles [
	"Twelve tiles; every numeric tile's value matches the size of the group it spawns"
	<gtExample>
	<return: #Array>
	| theTiles |
	theTiles := self dashboard tiles.
	self assert: theTiles size equals: 12.
	self assert: (theTiles collect: [ :each | each label ]) first equals: 'Reports'.
	self assert: (theTiles detect: [ :each | each label = 'Bounties paid' ]) value equals: '$2,250.00'.
	self assert: (theTiles detect: [ :each | each label = 'Critical + high active' ]) detail equals: '1 critical, 2 high'.
	(theTiles select: [ :each | each value isInteger ])
		do: [ :each | self assert: each value equals: each target size ].
	self assert: (theTiles allSatisfy: [ :each | each target notNil ]).
	^ theTiles
]
