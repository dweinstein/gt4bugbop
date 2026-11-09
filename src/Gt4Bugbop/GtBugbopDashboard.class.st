"
I am a visual dashboard over a GtBugbopExplorer. I derive headline metric tiles (GtBugbopDashboardTile) and severity/status mixes from the explorer's reports, notifications and user, and render them as clickable cards, stacked proportion bars and a severity bar chart. Every visual mark spawns the reports group or object it represents.

Create me with: GtBugbopDashboard forExplorer: anExplorer
"
Class {
	#name : 'GtBugbopDashboard',
	#superclass : 'Object',
	#instVars : [
		'explorer'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'instance creation' }
GtBugbopDashboard class >> forExplorer: anExplorer [
	^ self new explorer: anExplorer
]

{ #category : 'accessing' }
GtBugbopDashboard >> activeByAge [
	"Active reports, oldest first"
	^ GtBugbopReportsGroup withAll: (self activeReports items asSortedCollection: [ :a :b | a ageInDays >= b ageInDays ]) asArray
]

{ #category : 'accessing' }
GtBugbopDashboard >> activeReports [
	^ self reports active
]

{ #category : 'accessing' }
GtBugbopDashboard >> activeSeverityMix [
	^ self severityMixOf: self activeReports
]

{ #category : 'mixes' }
GtBugbopDashboard >> activeSeveritySegments [
	^ self
		segmentsFor: self activeSeverityMix
		color: [ :aSeverity | GtBugbopReport severityColorFor: aSeverity ]
]

{ #category : 'accessing' }
GtBugbopDashboard >> aiDisagreements [
	"Reports where the AI-suggested severity differs from the assigned one"
	^ self reports select: [ :each | each aiAgreesOnSeverity not ]
]

{ #category : 'tiles' }
GtBugbopDashboard >> aiDisagreementsTile [
	^ self
		tileLabel: 'AI severity disagreements'
		value: self aiDisagreements size
		detail: 'AI vs assigned severity'
		color: 'AD1457'
		target: self aiDisagreements
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> borderColor [
	^ Color fromHexString: 'DADDE3'
]

{ #category : 'tiles' }
GtBugbopDashboard >> bountiesTile [
	| aRewarded |
	aRewarded := self reports withBounty.
	^ self
		tileLabel: 'Bounties paid'
		value: self reports bountyAmountString
		detail: aRewarded size printString , ' reports rewarded'
		color: '00897B'
		target: aRewarded
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> canvasColor [
	^ Color fromHexString: 'F4F5F7'
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> captionColor [
	^ Color fromHexString: '6B7280'
]

{ #category : 'accessing' }
GtBugbopDashboard >> criticalAndHighActive [
	^ self activeReports select: [ :each | each severityRank <= 2 ]
]

{ #category : 'tiles' }
GtBugbopDashboard >> criticalHighTile [
	| aGroup |
	aGroup := self criticalAndHighActive.
	^ self
		tileLabel: 'Critical + high active'
		value: aGroup size
		detail: (aGroup withSeverity: 'critical') size printString , ' critical, ' , (aGroup withSeverity: 'high') size printString , ' high'
		color: 'B71C1C'
		target: aGroup sortedBySeverity
]

{ #category : 'accessing' }
GtBugbopDashboard >> explorer [
	^ explorer
]

{ #category : 'accessing' }
GtBugbopDashboard >> explorer: anExplorer [
	explorer := anExplorer
]

{ #category : 'tiles' }
GtBugbopDashboard >> fixedTile [
	| aFixed |
	aFixed := self reports withStatus: 'fixed'.
	^ self
		tileLabel: 'Fixed'
		value: aFixed size
		detail: (self percentOf: aFixed size in: self reports size) , ' of all reports'
		color: '2E7D32'
		target: aFixed
]

{ #category : 'views' }
GtBugbopDashboard >> gtDashboardFor: aView [
	<gtView>
	explorer ifNil: [ ^ aView empty ].
	^ aView explicit
		title: 'Dashboard';
		priority: 1;
		stencil: [ self newDashboardElement ]
]

{ #category : 'views' }
GtBugbopDashboard >> gtExplorerFor: aView [
	<gtView>
	explorer ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Explorer';
		priority: 10;
		object: [ explorer ];
		view: #gtOverviewFor:
]

{ #category : 'views' }
GtBugbopDashboard >> gtSeverityMixFor: aView [
	<gtView>
	explorer ifNil: [ ^ aView empty ].
	^ aView explicit
		title: 'Severity mix';
		priority: 2;
		stencil: [ self newSeverityChartElement ]
]

{ #category : 'views' }
GtBugbopDashboard >> gtTilesFor: aView [
	<gtView>
	explorer ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Metrics';
		priority: 3;
		items: [ self tiles ];
		column: '' stencil: [ :each | self newDotColored: each color ] width: 24;
		column: 'Metric' text: [ :each | each label ] width: 200;
		column: 'Value' text: [ :each | each displayValue asRopedText bold ] width: 110;
		column: 'Detail' text: [ :each | each detail asRopedText foreground: Color gray ];
		send: [ :each | each target ]
]

{ #category : 'ui - tiles' }
GtBugbopDashboard >> hoverAptitudeColored: aColor [
	^ BrStyleCommonAptitude new
		default: [ :aStyle | aStyle border: (BlBorder paint: self borderColor width: 1) ];
		hovered: [ :aStyle | aStyle border: (BlBorder paint: aColor width: 1.5) ]
]

{ #category : 'mixes' }
GtBugbopDashboard >> humanize: aKey [
	"'needs_info' -> 'Needs info'; nil -> 'Unrated'"
	aKey ifNil: [ ^ 'Unrated' ].
	^ (aKey copyReplaceAll: '_' with: ' ') capitalized
]

{ #category : 'accessing' }
GtBugbopDashboard >> hunters [
	^ self reports hunterSummaries
]

{ #category : 'tiles' }
GtBugbopDashboard >> huntersTile [
	^ self
		tileLabel: 'Hunters'
		value: self hunters size
		detail: 'distinct reporters'
		color: '5E35B1'
		target: self hunters
]

{ #category : 'accessing' }
GtBugbopDashboard >> medianActiveAgeInDays [
	"Median age in whole days of active reports, nil when there are none"
	| ages middle |
	ages := (self activeReports items collect: [ :each | each ageInDays ]) asSortedCollection asArray.
	ages ifEmpty: [ ^ nil ].
	middle := ages size + 1 // 2.
	ages size odd ifTrue: [ ^ ages at: middle ].
	^ ((ages at: middle) + (ages at: middle + 1) / 2) rounded
]

{ #category : 'tiles' }
GtBugbopDashboard >> medianAgeTile [
	^ self
		tileLabel: 'Median age (active)'
		value: (self medianActiveAgeInDays ifNotNil: [ :aDays | aDays printString , 'd' ])
		detail: 'oldest first on click'
		color: '546E7A'
		target: self activeByAge
]

{ #category : 'ui - tiles' }
GtBugbopDashboard >> newAccentBarColored: aColor [
	^ BlElement new
		background: aColor;
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii new topLeft: 6; bottomLeft: 6; topRight: 0; bottomRight: 0; yourself));
		constraintsDo: [ :c | 
			c horizontal exact: 5.
			c vertical matchParent ]
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> newBoldLabel: aString size: aFontSize color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				bold;
				fontSize: aFontSize;
				foreground: aColor);
		text: aString
]

{ #category : 'ui - severity chart' }
GtBugbopDashboard >> newChartBarFor: aSeverityAndGroup [
	| aBar aCount |
	aCount := aSeverityAndGroup value size.
	aBar := BrFrame new
			geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
			padding: (BlInsets left: 8 right: 8);
			aptitude: (BrGlamorousWithLabelTooltipAptitude new
					text: (self humanize: aSeverityAndGroup key) , ': ' , aCount printString , ' active - click to inspect').
	aCount isZero ifFalse: [ aBar addChild: (self newChartBarLabelFor: aSeverityAndGroup) ].
	^ self spawnOnClick: aBar object: aSeverityAndGroup value
]

{ #category : 'ui - severity chart' }
GtBugbopDashboard >> newChartBarLabelFor: aSeverityAndGroup [
	^ (self
		newBoldLabel: aSeverityAndGroup value size printString
		size: 12
		color: (self textColorOn: (GtBugbopReport severityColorFor: aSeverityAndGroup key)))
		constraintsDo: [ :c | 
			c frame horizontal alignRight.
			c frame vertical alignCenter ]
]

{ #category : 'ui - dashboard' }
GtBugbopDashboard >> newDashboardElement [
	^ (BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 16 left: 20 bottom: 20 right: 8);
		addChild: self newHeaderElement;
		addChild: self newTilesElement;
		addChild: (self newMixSectionTitled: 'Severity mix - all ' , self reports size printString , ' reports' segments: self severitySegments);
		addChild: (self newMixSectionTitled: 'Status mix - all ' , self reports size printString , ' reports' segments: self statusSegments);
		yourself) asScrollableElement
		background: self canvasColor;
		yourself
]

{ #category : 'ui - mixes' }
GtBugbopDashboard >> newDotColored: aColor [
	^ BlElement new
		geometry: BlCircleGeometry new;
		background: aColor;
		size: 10 @ 10
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> newEmptyLabel: aString [
	^ (self newLabel: aString size: 13 color: self captionColor)
		margin: (BlInsets all: 20)
]

{ #category : 'ui - header' }
GtBugbopDashboard >> newHeaderElement [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 14);
		addChild: (self newBoldLabel: 'Bugbop triage dashboard' size: 20 color: (Color fromHexString: '111827'));
		addChild: ((self newLabel: self subtitleText size: 12 color: self captionColor) margin: (BlInsets top: 2));
		addChild: (self newHintLabel: 'Click any tile, bar segment or legend entry to drill into those reports')
]

{ #category : 'ui - tiles' }
GtBugbopDashboard >> newHeadlineFor: aTile [
	| aText |
	aText := aTile displayValue.
	^ (self
		newBoldLabel: aText
		size: (aText size > 7 ifTrue: [ 21 ] ifFalse: [ 28 ])
		color: (Color fromHexString: '111827'))
		margin: (BlInsets top: 2 bottom: 2);
		vExact: 38
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> newHintLabel: aString [
	^ (self newLabel: aString size: 11 color: (Color fromHexString: '9CA3AF'))
		margin: (BlInsets top: 2)
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> newLabel: aString size: aFontSize color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				fontSize: aFontSize;
				foreground: aColor);
		text: aString
]

{ #category : 'ui - mixes' }
GtBugbopDashboard >> newLegendFor: aSegments [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		margin: (BlInsets top: 8);
		addChildren: (aSegments collect: [ :each | self newLegendItemFor: each ])
]

{ #category : 'ui - mixes' }
GtBugbopDashboard >> newLegendItemFor: aSegment [
	| anItem |
	anItem := BrHorizontalPane new
			fitContent;
			alignCenterLeft;
			margin: (BlInsets top: 2 left: 0 bottom: 2 right: 18);
			aptitude: (self tooltipAptitudeFor: aSegment);
			addChild: (self newDotColored: aSegment color);
			addChild: ((self newLabel: aSegment label size: 12 color: (Color fromHexString: '374151')) margin: (BlInsets left: 6));
			addChild: ((self newLabel: aSegment value printString , ' (' , aSegment detail , ')' size: 12 color: self captionColor) margin: (BlInsets left: 5)).
	^ self spawnOnClick: anItem object: aSegment target
]

{ #category : 'ui - mixes' }
GtBugbopDashboard >> newMixSectionTitled: aTitle segments: aSegments [
	| aSection |
	aSection := BrVerticalPane new
			hMatchParent;
			vFitContent;
			padding: (BlInsets right: 12);
			addChild: (self newSectionTitle: aTitle).
	aSegments ifEmpty: [ ^ aSection addChild: (self newEmptyLabel: 'No reports yet'); yourself ].
	^ aSection
		addChild: (self newStackedBarFor: aSegments);
		addChild: (self newLegendFor: aSegments);
		yourself
]

{ #category : 'tiles' }
GtBugbopDashboard >> newReportsTile [
	^ self
		tileLabel: 'New (untriaged)'
		value: (self reports countWithStatus: 'new')
		detail: 'awaiting a first look'
		color: '6A1B9A'
		target: (self reports withStatus: 'new')
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> newSectionTitle: aString [
	^ (self newBoldLabel: aString size: 13 color: (Color fromHexString: '374151'))
		margin: (BlInsets top: 18 bottom: 8)
]

{ #category : 'ui - mixes' }
GtBugbopDashboard >> newSegmentElementFor: aSegment [
	| aFrame |
	aFrame := BrFrame new
			vMatchParent;
			hMatchParent;
			background: aSegment color;
			margin: (BlInsets right: 1);
			aptitude: (self tooltipAptitudeFor: aSegment);
			constraintsDo: [ :c | c linear weight: aSegment value ];
			addChild: ((self newBoldLabel: aSegment value printString size: 12 color: (self textColorOn: aSegment color))
					constraintsDo: [ :c | 
						c frame horizontal alignCenter.
						c frame vertical alignCenter ]).
	^ self spawnOnClick: aFrame object: aSegment target
]

{ #category : 'ui - severity chart' }
GtBugbopDashboard >> newSeverityBarChart [
	| theData aMax |
	theData := (GtPlotterDataGroup new values: self activeSeverityMix)
			labelled: [ :each | self humanize: each key ].
	theData := theData background: [ :each | GtBugbopReport severityColorFor: each key ].
	aMax := (self activeSeverityMix inject: 1 into: [ :aMaximum :each | aMaximum max: each value size ]).
	^ GtPlotterHorizontalBarChart new
		barLabelSpacing: 80;
		barGap: 10;
		barWidthScale: (GtPlotterLinearScale new domainFrom: 0 to: aMax);
		barWidthData: [ :each | each value size ];
		barElement: [ :aContext | self newChartBarFor: aContext originalValue ];
		amountOfTicks: (aMax min: 5);
		with: theData
]

{ #category : 'ui - severity chart' }
GtBugbopDashboard >> newSeverityChartElement [
	self activeReports isEmpty ifTrue: [ ^ self newEmptyLabel: 'No active reports - the triage queue is clear' ].
	^ BrVerticalPane new
		matchParent;
		padding: (BlInsets top: 4 left: 20 bottom: 16 right: 20);
		background: Color white;
		addChild: (self newSectionTitle: 'Active reports by severity (' , self activeReports size printString , ')');
		addChild: (self newHintLabel: 'Click a bar or legend entry to inspect those reports');
		addChild: (self newSeverityBarChart asElement constraintsDo: [ :c | c horizontal matchParent. c vertical exact: 220 ]);
		addChild: (self newLegendFor: self activeSeveritySegments)
]

{ #category : 'ui - mixes' }
GtBugbopDashboard >> newStackedBarFor: aSegments [
	^ BrHorizontalPane new
		hMatchParent;
		vExact: 32;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		clipChildren: true;
		background: self borderColor;
		addChildren: (aSegments collect: [ :each | self newSegmentElementFor: each ])
]

{ #category : 'ui - tiles' }
GtBugbopDashboard >> newTileBodyFor: aTile [
	^ BrVerticalPane new
		matchParent;
		padding: (BlInsets top: 10 left: 12 bottom: 8 right: 8);
		addChild: (self newLabel: aTile label size: 11 color: self captionColor);
		addChild: (self newHeadlineFor: aTile);
		addChild: (self newLabel: aTile detail size: 10 color: aTile color)
]

{ #category : 'ui - tiles' }
GtBugbopDashboard >> newTileElementFor: aTile [
	| aCard |
	aCard := BrHorizontalPane new
			exact: 178 @ 96;
			margin: (BlInsets top: 0 left: 0 bottom: 12 right: 12);
			background: Color white;
			geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
			aptitude: (self hoverAptitudeColored: aTile color) + (self tooltipAptitudeFor: aTile);
			addChild: (self newAccentBarColored: aTile color);
			addChild: (self newTileBodyFor: aTile).
	^ self spawnOnClick: aCard object: aTile target
]

{ #category : 'ui - tiles' }
GtBugbopDashboard >> newTilesElement [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		addChildren: (self tiles collect: [ :each | self newTileElementFor: each ])
]

{ #category : 'tiles' }
GtBugbopDashboard >> notificationsTile [
	| aTotal |
	aTotal := explorer notifications ifNil: [ 0 ] ifNotNil: [ :aGroup | aGroup size ].
	^ self
		tileLabel: 'Unread notifications'
		value: self unreadNotifications size
		detail: 'of ' , aTotal printString , ' notifications'
		color: '0277BD'
		target: self unreadNotifications
]

{ #category : 'private' }
GtBugbopDashboard >> percentOf: aCount in: aTotal [
	aTotal isZero ifTrue: [ ^ '0%' ].
	^ (aCount * 100 / aTotal) rounded printString , '%'
]

{ #category : 'printing' }
GtBugbopDashboard >> printOn: aStream [
	aStream nextPutAll: 'Bugbop dashboard ('; print: self reports size; nextPutAll: ' reports, '; print: self activeReports size; nextPutAll: ' active)'
]

{ #category : 'accessing' }
GtBugbopDashboard >> reports [
	^ explorer reports ifNil: [ GtBugbopReportsGroup new ]
]

{ #category : 'tiles' }
GtBugbopDashboard >> reportsTile [
	^ self
		tileLabel: 'Reports'
		value: self reports size
		detail: self activeReports size printString , ' active, ' , (self reports size - self activeReports size) printString , ' closed'
		color: '455A64'
		target: self reports
]

{ #category : 'accessing' }
GtBugbopDashboard >> scopeWarnings [
	^ self reports select: [ :each | each hasScopeWarning ]
]

{ #category : 'tiles' }
GtBugbopDashboard >> scopeWarningsTile [
	^ self
		tileLabel: 'Scope warnings'
		value: self scopeWarnings size
		detail: 'possibly out of scope'
		color: 'EF6C00'
		target: self scopeWarnings
]

{ #category : 'mixes' }
GtBugbopDashboard >> segmentsFor: aBreakdown color: aColorBlock [
	"One tile per non-empty breakdown entry: label, count, share, color and sub-group"
	| aTotal |
	aTotal := aBreakdown inject: 0 into: [ :aSum :each | aSum + each value size ].
	^ (aBreakdown reject: [ :each | each value isEmpty ])
		collect: [ :each | 
			GtBugbopDashboardTile
				label: (self humanize: each key)
				value: each value size
				detail: (self percentOf: each value size in: aTotal)
				color: (aColorBlock value: each key)
				target: each value ]
]

{ #category : 'accessing' }
GtBugbopDashboard >> severityMix [
	^ self reports severityBreakdown
]

{ #category : 'accessing' }
GtBugbopDashboard >> severityMixOf: aReportsGroup [
	"severity -> sub-group for every known severity (including empty ones), most severe first"
	^ GtBugbopReport severities collect: [ :aSeverity | aSeverity -> (aReportsGroup withSeverity: aSeverity) ]
]

{ #category : 'mixes' }
GtBugbopDashboard >> severitySegments [
	^ self
		segmentsFor: self severityMix
		color: [ :aSeverity | GtBugbopReport severityColorFor: aSeverity ]
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> spawnOnClick: anElement object: anObject [
	"Make anElement navigate to anObject when clicked"
	anElement
		when: BlClickEvent
		do: [ :anEvent | 
			anEvent consumed: true.
			anElement phlow spawnObject: anObject ].
	^ anElement
]

{ #category : 'accessing' }
GtBugbopDashboard >> statusColorFor: aStatus [
	^ GtBugbopReport statusColorFor: aStatus
]

{ #category : 'accessing' }
GtBugbopDashboard >> statusMix [
	^ self reports statusBreakdown
]

{ #category : 'mixes' }
GtBugbopDashboard >> statusSegments [
	^ self
		segmentsFor: self statusMix
		color: [ :aStatus | self statusColorFor: aStatus ]
]

{ #category : 'ui - header' }
GtBugbopDashboard >> subtitleText [
	^ String streamContents: [ :aStream | 
		explorer user ifNotNil: [ :aUser | aStream nextPutAll: 'Signed in as '; nextPutAll: aUser username asString; nextPutAll: '  |  ' ].
		aStream print: self reports size; nextPutAll: ' reports, '; print: self activeReports size; nextPutAll: ' active'.
		explorer fetchedAt ifNotNil: [ :aTime | aStream nextPutAll: '  |  fetched '; nextPutAll: (self timeTextFor: aTime) ] ]
]

{ #category : 'accessing' }
GtBugbopDashboard >> suspectedDuplicates [
	"Active reports flagged as possible duplicates that have not been confirmed yet (same rule as GtBugbopDuplicateMap>>#pendingSuspicions)"
	^ self reports select: [ :each |
		each isActive and: [ each duplicateOfId isNil and: [ each isSuspectedDuplicate ] ] ]
]

{ #category : 'tiles' }
GtBugbopDashboard >> suspectedDuplicatesTile [
	^ self
		tileLabel: 'Suspected duplicates'
		value: self suspectedDuplicates size
		detail: 'active, awaiting a decision'
		color: '8D6E63'
		target: self suspectedDuplicates
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> textColorOn: aBackgroundColor [
	"Dark text on light fills, white text on dark fills"
	aBackgroundColor luminance > 0.6 ifTrue: [ ^ Color fromHexString: '263238' ].
	^ Color white
]

{ #category : 'tiles' }
GtBugbopDashboard >> tileLabel: aLabel value: aValue detail: aDetail color: aHexString target: aTarget [
	^ GtBugbopDashboardTile
		label: aLabel
		value: aValue
		detail: aDetail
		color: (Color fromHexString: aHexString)
		target: aTarget
]

{ #category : 'tiles' }
GtBugbopDashboard >> tiles [
	"The headline metric tiles, in reading order"
	^ {
		self reportsTile.
		self triageQueueTile.
		self newReportsTile.
		self criticalHighTile.
		self fixedTile.
		self bountiesTile.
		self huntersTile.
		self notificationsTile.
		self suspectedDuplicatesTile.
		self scopeWarningsTile.
		self aiDisagreementsTile.
		self medianAgeTile }
]

{ #category : 'ui - header' }
GtBugbopDashboard >> timeTextFor: aDateAndTime [
	^ aDateAndTime asDate yyyymmdd , ' ' , (aDateAndTime asTime print24 first: 5)
]

{ #category : 'ui - basic' }
GtBugbopDashboard >> tooltipAptitudeFor: aTile [
	^ BrGlamorousWithLabelTooltipAptitude new text: aTile tooltipText
]

{ #category : 'accessing' }
GtBugbopDashboard >> triageQueue [
	^ explorer triageQueue
]

{ #category : 'tiles' }
GtBugbopDashboard >> triageQueueTile [
	^ self
		tileLabel: 'Triage queue'
		value: self triageQueue size
		detail: 'new, open, needs info'
		color: '1565C0'
		target: self triageQueue
]

{ #category : 'accessing' }
GtBugbopDashboard >> unreadNotifications [
	^ explorer notifications
		ifNil: [ #() ]
		ifNotNil: [ :aGroup | aGroup unread ]
]
