"
I am a time-oriented lens over a GtBugbopReportsGroup.

I answer questions about *when* things happened in a Bugbop program: when reports were submitted (by severity lane and status), which days were busiest, how the body of submitted and valid reports grew, and how bounty money was paid out month by month.

Create me with `GtBugbopReportTimeline forReports: aGtBugbopReportsGroup`.

Views: Timeline (severity swimlanes), Calendar (contribution heatmap), Cumulative (line chart), Bounties (monthly bar chart + severity breakdown). Every visual mark navigates to the report(s) it represents.

All dates are bucketed in UTC, as Bugbop timestamps are UTC.
"
Class {
	#name : 'GtBugbopReportTimeline',
	#superclass : 'Object',
	#instVars : [
		'reports'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'instance creation' }
GtBugbopReportTimeline class >> forReports: aGtBugbopReportsGroup [
	^ self new reports: aGtBugbopReportsGroup
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> activeDateRanges [
	"Answer Arrays {firstDate. lastDate} of submission days, split wherever the gap exceeds the threshold"
	| days ranges current |
	days := (self datedReports items collect: [ :each | self dateOf: each ]) asSet asSortedCollection asArray.
	ranges := OrderedCollection new.
	current := Array with: days first with: days first.
	days allButFirstDo: [ :each |
		(each - current last) asDays > self gapThresholdInDays
			ifTrue: [ ranges add: current. current := Array with: each with: each ]
			ifFalse: [ current at: 2 put: each ] ].
	ranges add: current.
	^ ranges
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> axisGaps [
	"Answer fraction -> label for every collapsed quiet period between active periods"
	| segments |
	segments := self axisSegments.
	^ (1 to: segments size - 1) collect: [ :index |
		| before after |
		before := segments at: index.
		after := segments at: index + 1.
		((before fourth + after third) / 2) -> (self gapLabelFrom: before second to: after first) ]
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> axisSegments [
	"Answer one Array {startDateAndTime. stopDateAndTime. fromFraction. toFraction} per active period; quiet periods between them are collapsed to gapWidth"
	| ranges weights usable cursor |
	ranges := self activeDateRanges collect: [ :each | self paddedRange: each ].
	weights := ranges collect: [ :each | (each last - each first) asDays max: 10 ].
	usable := 0.96 - (self gapWidth * (ranges size - 1)).
	cursor := 0.02.
	^ ranges withIndexCollect: [ :each :index |
		| width segment |
		width := usable * (weights at: index) / weights sum.
		segment := { each first asDateAndTime. each last asDateAndTime. cursor. cursor + width }.
		cursor := cursor + width + self gapWidth.
		segment ]
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> axisTicks [
	"Answer fraction -> label for every active period: weekly ticks for short periods, monthly otherwise. The first tick of each period carries the year."
	^ self axisSegments flatCollect: [ :each | self ticksFor: each ]
]

{ #category : 'accessing - bounties' }
GtBugbopReportTimeline >> bountiesBySeverity [
	"Answer severity -> bounty reports, most severe first, skipping severities without bounties"
	^ self bountyReports severityBreakdown
]

{ #category : 'ui - bounties' }
GtBugbopReportTimeline >> bountiesSubtitle [
	^ (self dollarStringOf: self bountyReports) , ' across ' , (self countString: self bountyReports size noun: 'rewarded report') , '  ·  bars group bounties by the ' , (self hasWeeklyBountyBuckets ifTrue: [ 'week' ] ifFalse: [ 'month' ]) , ' the report was submitted, stacked by severity  ·  click a segment or card to open its reports'
]

{ #category : 'accessing - bounties' }
GtBugbopReportTimeline >> bountyBuckets [
	"Answer bucket start Date -> bounty reports: per month, or per week when all bounties fall in one month"
	self hasWeeklyBountyBuckets ifTrue: [ ^ self weeklyBounties ].
	^ self monthlyBounties
]

{ #category : 'ui - bounties' }
GtBugbopReportTimeline >> bountyColor [
	^ GtBugbopReport statusColorFor: 'fixed'
]

{ #category : 'accessing - bounties' }
GtBugbopReportTimeline >> bountyReports [
	^ self datedReports select: [ :each | each hasBounty ]
]

{ #category : 'accessing - bounties' }
GtBugbopReportTimeline >> bucketLabelFor: aDate [
	"'Oct 12' for weekly buckets; 'Oct' for monthly ones, with the year on the first bucket and in January"
	self hasWeeklyBountyBuckets ifTrue: [ ^ self dayLabelFor: aDate ].
	aDate = self bountyBuckets first key ifTrue: [ ^ self monthLabelFor: aDate ].
	^ self monthTickLabelFor: aDate
]

{ #category : 'accessing - bounties' }
GtBugbopReportTimeline >> bucketTooltipNameFor: aDate [
	self hasWeeklyBountyBuckets ifTrue: [ ^ 'Week of ' , (self shortDateString: aDate) ].
	^ self monthLabelFor: aDate
]

{ #category : 'accessing - days' }
GtBugbopReportTimeline >> busiestDay [
	"Answer Date -> reports group for the day with most submissions (earliest on ties), or nil"
	| days |
	days := self reportsByDay associations sort: [ :a :b | a key <= b key ].
	days ifEmpty: [ ^ nil ].
	^ days detectMax: [ :each | each value size ]
]

{ #category : 'accessing - days' }
GtBugbopReportTimeline >> busiestWeekday [
	"Answer weekday name -> reports submitted on that weekday, for the weekday with most submissions"
	| byWeekday |
	byWeekday := self datedReports items groupedBy: [ :each | (self dateOf: each) dayOfWeekName ].
	^ (byWeekday associations detectMax: [ :each | each value size ])
		in: [ :best | best key -> (GtBugbopReportsGroup withAll: best value) ]
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> calendarMonthSpans [
	"Answer month-start Date -> number of week columns, grouping weeks by the month their Sunday falls in"
	| spans |
	spans := OrderedCollection new.
	self calendarWeeks do: [ :week |
		| month |
		month := self monthStartOf: (week addDays: 6).
		(spans notEmpty and: [ spans last key = month ])
			ifTrue: [ spans last value: spans last value + 1 ]
			ifFalse: [ spans add: month -> 1 ] ].
	^ spans
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> calendarSubtitle [
	^ (self shortDateString: self firstDate) , ' – ' , (self shortDateString: self lastDate) , '  ·  one column per week, darker = more submissions  ·  click a day to open its reports'
]

{ #category : 'accessing - days' }
GtBugbopReportTimeline >> calendarWeeks [
	"Monday of every week from the first to the last submission, oldest first"
	| week lastWeek weeks |
	self hasDates ifFalse: [ ^ #() ].
	week := self weekStartOf: self firstDate.
	lastWeek := self weekStartOf: self lastDate.
	weeks := OrderedCollection new.
	[ week <= lastWeek ] whileTrue: [
		weeks add: week.
		week := week addDays: 7 ].
	^ weeks asArray
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> cellPitch [
	"Cell size plus gap, in pixels: larger cells when only a few weeks are shown"
	| weeks |
	weeks := self calendarWeeks size.
	weeks <= 20 ifTrue: [ ^ 26 ].
	weeks <= 36 ifTrue: [ ^ 21 ].
	^ 17
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> closeTogetherClustersIn: aReportsGroup [
	"Split the (time-ordered) reports into runs submitted within 18 hours of the run's first report"
	| clusters |
	clusters := OrderedCollection new.
	(aReportsGroup items asSortedCollection: [ :a :b | a createdAt <= b createdAt ]) do: [ :each |
		(clusters isEmpty or: [ each createdAt - clusters last first createdAt > 18 hours ])
			ifTrue: [ clusters add: (OrderedCollection with: each) ]
			ifFalse: [ clusters last add: each ] ].
	^ clusters
]

{ #category : 'printing' }
GtBugbopReportTimeline >> countString: aNumber noun: aNoun [
	"'1 report', '3 reports'"
	aNumber = 1 ifTrue: [ ^ '1 ' , aNoun ].
	^ aNumber printString , ' ' , aNoun , 's'
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> cumulativeData [
	"Both running-total series as one plotter data set, stepped, grouped and coloured by series"
	^ (GtPlotterDataGroup new values: (self steppedPointsFrom: self cumulativeSubmitted) , (self steppedPointsFrom: self cumulativeValid))
		groupedBy: [ :each | each at: #series ]
		labelled: [ :aSeriesName | aSeriesName ]
		colored: [ :aSeriesName | self seriesColorFor: aSeriesName ]
]

{ #category : 'accessing - cumulative' }
GtBugbopReportTimeline >> cumulativeSeriesNamed: aName select: aBlock [
	"One point per submission day: #series, #date, #count (running total of matching reports) and #reports (those reports)"
	| running |
	running := OrderedCollection new.
	^ (self reportsByDay associations sort: [ :a :b | a key <= b key ]) collect: [ :each |
		running addAll: (each value items select: aBlock).
		Dictionary new
			at: #series put: aName;
			at: #date put: each key asDateAndTime;
			at: #count put: running size;
			at: #reports put: (GtBugbopReportsGroup withAll: running copy);
			yourself ]
]

{ #category : 'accessing - cumulative' }
GtBugbopReportTimeline >> cumulativeSubmitted [
	^ self cumulativeSeriesNamed: self submittedSeriesName select: [ :each | true ]
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> cumulativeSubtitle [
	| total valid |
	total := self datedReports size.
	valid := (self datedReports select: [ :each | each isValid ]) size.
	^ total printString , ' submitted, ' , valid printString , ' valid (' , (valid * 100 / total) rounded printString , '% signal)' , self cumulativeWindowNote , '  ·  click a point to open the reports counted up to that day'
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> cumulativeTooltipFor: aPoint [
	^ (aPoint at: #series) , ': ' , (aPoint at: #count) printString , ' by ' , (self shortDateString: (aPoint at: #date) asDate)
]

{ #category : 'accessing - cumulative' }
GtBugbopReportTimeline >> cumulativeValid [
	"Valid = accepted as a real issue (open or fixed)"
	^ self cumulativeSeriesNamed: self validSeriesName select: [ :each | each isValid ]
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> cumulativeWindowNote [
	| earlier |
	self activeDateRanges size = 1 ifTrue: [ ^ '' ].
	earlier := (self datedReports select: [ :each | each createdAt < self cumulativeWindowStart ]) size.
	^ '  ·  showing the latest active period from ' , (self shortDateString: self cumulativeWindowStart asDate) , ' (' , (self countString: earlier noun: 'earlier report') , ' included in the totals)'
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> cumulativeWindowStart [
	"The chart focuses on the latest active period (quiet gaps would squash it); earlier reports still count in the running totals"
	^ (self paddedRange: self activeDateRanges last) first asDateAndTime
]

{ #category : 'accessing - dates' }
GtBugbopReportTimeline >> dateOf: aReport [
	"The UTC calendar day a report was submitted on"
	^ aReport createdAt asUTC asDate
]

{ #category : 'accessing - dates' }
GtBugbopReportTimeline >> datedReports [
	"Reports that have a submission timestamp, oldest first"
	^ GtBugbopReportsGroup withAll: ((self reports items select: [ :each | each createdAt notNil ])
		asSortedCollection: [ :a :b | a createdAt <= b createdAt ]) asOrderedCollection
]

{ #category : 'printing' }
GtBugbopReportTimeline >> dayLabelFor: aDate [
	"e.g. 'Sep 8'"
	^ (aDate monthName first: 3) , ' ' , aDate dayOfMonth printString
]

{ #category : 'printing' }
GtBugbopReportTimeline >> dollarStringOf: aReportsGroup [
	"'$1,500' (cents dropped when whole)"
	^ (GtBugbopBountyRange amountStringFromCents: aReportsGroup bountyTotalCents) copyReplaceAll: '.00' with: ''
]

{ #category : 'accessing - bounties' }
GtBugbopReportTimeline >> dollarsOf: aReportsGroup [
	^ aReportsGroup bountyTotalCents / 100
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> dotSizeFor: aReport [
	"12px for no comments, growing to 28px at 10+ comments"
	^ 12 + (((aReport commentsCount ifNil: [ 0 ]) min: 10) * 1.6)
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> fanOffsetAt: anIndex of: aCount [
	aCount = 1 ifTrue: [ ^ 0.5 ].
	^ 0.25 + ((anIndex - 1) * 0.5 / (aCount - 1))
]

{ #category : 'accessing - dates' }
GtBugbopReportTimeline >> firstDate [
	^ self dateOf: self datedReports first
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> fractionOf: aDateAndTime in: aSegment [
	| start stop ratio |
	start := aSegment first.
	stop := aSegment second.
	ratio := ((aDateAndTime - start) asSeconds / (stop - start) asSeconds) asFloat.
	^ (aSegment third) + (ratio * ((aSegment fourth) - (aSegment third)))
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> gapLabelFrom: aStart to: aStop [
	"e.g. '10 mo quiet'"
	| days |
	days := (aStop - aStart) asDays.
	days >= 60 ifTrue: [ ^ (days / 30.4) rounded printString , ' mo quiet' ].
	^ (days / 7) rounded printString , ' wk quiet'
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> gapThresholdInDays [
	"Quiet periods longer than this are collapsed into an axis break"
	^ 45
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> gapWidth [
	"Fraction of the axis used by a collapsed quiet period"
	^ 0.05
]

{ #category : 'gt - views' }
GtBugbopReportTimeline >> gtBountiesFor: aView [
	<gtView>
	^ aView explicit
		title: 'Bounties';
		priority: 4;
		stencil: [ self newBountiesElement ]
]

{ #category : 'gt - views' }
GtBugbopReportTimeline >> gtCalendarFor: aView [
	<gtView>
	^ aView explicit
		title: 'Calendar';
		priority: 2;
		stencil: [ self newCalendarElement ]
]

{ #category : 'gt - views' }
GtBugbopReportTimeline >> gtCumulativeFor: aView [
	<gtView>
	^ aView explicit
		title: 'Cumulative';
		priority: 3;
		stencil: [ self newCumulativeElement ]
]

{ #category : 'gt - views' }
GtBugbopReportTimeline >> gtTimelineFor: aView [
	<gtView>
	^ aView explicit
		title: 'Timeline';
		priority: 1;
		stencil: [ self newTimelineElement ]
]

{ #category : 'accessing - dates' }
GtBugbopReportTimeline >> hasDates [
	^ self reports items anySatisfy: [ :each | each createdAt notNil ]
]

{ #category : 'accessing - bounties' }
GtBugbopReportTimeline >> hasWeeklyBountyBuckets [
	"When every bounty falls in a single month, monthly bars would show one bar; use weeks instead"
	^ ((self bountyReports items collect: [ :each | self monthStartOf: (self dateOf: each) ]) asSet size) <= 1
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> heatColors [
	"No submissions, then four increasing intensities"
	^ #('EBEDF0' '9BE9A8' '40C463' '30A14E' '216E39') collect: [ :each | Color fromHexString: each ]
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> heatLevelFor: aCount max: aMax [
	"0 for no submissions, otherwise 1..4 relative to the busiest day (treated as at least 4, so sparse data stays light)"
	aCount isZero ifTrue: [ ^ 0 ].
	^ ((aCount / (aMax max: 4) * 4) ceiling max: 1) min: 4
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> hiddenPointFrom: aPoint at: aDateAndTime [
	"A copy of aPoint moved to aDateAndTime, used only to shape the step line"
	^ aPoint copy
		at: #date put: aDateAndTime;
		at: #marker put: false;
		yourself
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> inkColor [
	^ Color fromHexString: '1F2937'
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> isChangeFrom: aPreviousPoint to: aPoint [
	"Whether the running total moved (a first non-zero point counts as a change)"
	aPreviousPoint ifNil: [ ^ (aPoint at: #count) > 0 ].
	^ (aPoint at: #count) ~= (aPreviousPoint at: #count)
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> laneLabelWidth [
	^ 120
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> laneOffsetsFor: aReportsGroup [
	"Answer report -> vertical position (0..1) in its lane: reports submitted close together are fanned out so they stay visible"
	| offsets |
	offsets := OrderedDictionary new.
	(self closeTogetherClustersIn: aReportsGroup) do: [ :cluster |
		cluster doWithIndex: [ :each :index |
			offsets at: each put: (self fanOffsetAt: index of: cluster size) ] ].
	^ offsets
]

{ #category : 'accessing - dates' }
GtBugbopReportTimeline >> lastDate [
	^ self dateOf: self datedReports last
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> makeElement: anElement spawn: anObject [
	"Clicking anElement opens anObject in the next inspector pane"
	anElement when: BlClickEvent do: [ :anEvent |
		anEvent consumed: true.
		anElement phlow spawnObject: anObject ].
	^ anElement
]

{ #category : 'printing' }
GtBugbopReportTimeline >> monthLabelFor: aDate [
	"e.g. 'Oct 2026'"
	^ (aDate monthName first: 3) , ' ' , aDate year printString
]

{ #category : 'accessing - dates' }
GtBugbopReportTimeline >> monthStartOf: aDate [
	^ aDate subtractDays: aDate dayOfMonth - 1
]

{ #category : 'printing' }
GtBugbopReportTimeline >> monthTickLabelFor: aDate [
	"'Sep', or 'Jan 2026' when a new year starts"
	aDate monthIndex = 1 ifTrue: [ ^ self monthLabelFor: aDate ].
	^ aDate monthName first: 3
]

{ #category : 'accessing - bounties' }
GtBugbopReportTimeline >> monthlyBounties [
	"Answer month start Date -> bounty reports submitted that month, for every month from the first to the last submission (empty months included)"
	| month lastMonth months bounties |
	self hasDates ifFalse: [ ^ #() ].
	bounties := self bountyReports.
	month := self monthStartOf: self firstDate.
	lastMonth := self monthStartOf: self lastDate.
	months := OrderedCollection new.
	[ month <= lastMonth ] whileTrue: [
		months add: month -> (self reportsIn: bounties duringMonth: month).
		month := self nextMonthStartAfter: month ].
	^ months asArray
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> monthlyTickDatesFrom: aStartDate to: aStopDate [
	"Month starts strictly inside the period"
	| tick ticks |
	tick := self nextMonthStartAfter: aStartDate.
	ticks := OrderedCollection new.
	[ tick < aStopDate ] whileTrue: [
		ticks add: tick.
		tick := self nextMonthStartAfter: tick ].
	^ ticks
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> mutedColor [
	^ Color fromHexString: '6B7280'
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> newBoldLabel: aString size: aFontSize color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			bold;
			fontSize: aFontSize;
			foreground: aColor);
		text: aString
]

{ #category : 'ui - bounties' }
GtBugbopReportTimeline >> newBountiesElement [
	self hasDates ifFalse: [ ^ self newEmptyStateElement ].
	self bountyReports ifEmpty: [ ^ self newNoBountiesElement ].
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 16);
		addChild: (self newHeaderTitle: 'Bounty payouts' subtitle: self bountiesSubtitle);
		addChild: self newSeverityShareBar;
		addChild: self newSeverityBountyCards;
		addChild: (self newBountyChart asElement
			constraintsDo: [ :c | c horizontal matchParent. c vertical exact: 380 ]);
		asScrollableElement
]

{ #category : 'ui - bounties' }
GtBugbopReportTimeline >> newBountyBarFor: aBucket [
	"A bar stacked by severity (most severe on top); each segment opens that bucket's reports of that severity"
	| bar |
	bar := BrVerticalPane new
		clipChildren: true;
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii new topLeft: 4; topRight: 4; bottomLeft: 0; bottomRight: 0; yourself)).
	bar addChildren: (aBucket value severityBreakdown collect: [ :each |
		self newBountySegmentFor: each in: aBucket ]).
	^ bar
]

{ #category : 'ui - bounties' }
GtBugbopReportTimeline >> newBountyChart [
	| buckets data maxDollars |
	buckets := self bountyBuckets.
	data := (GtPlotterDataGroup new values: buckets) labelled: [ :each | self bucketLabelFor: each key ].
	data := data background: [ :each | self bountyColor ].
	maxDollars := (buckets collect: [ :each | self dollarsOf: each value ]) max max: 1.
	^ GtPlotterVerticalBarChart new
		barElement: [ :aContext | self newBountyBarFor: aContext originalValue ];
		barHeightScale: (GtPlotterLinearScale new domainFrom: 0 to: maxDollars);
		barWidthScale: (GtPlotterConstantScale new constant: (buckets size <= 6 ifTrue: [ 84 ] ifFalse: [ 48 ]));
		barHeightData: [ :each | self dollarsOf: each value ];
		barLabelSpacing: 70;
		amountOfTicks: 4;
		tickLabelFormat: [ :aValue | '$' , aValue rounded printString ];
		with: data;
		yourself
]

{ #category : 'ui - bounties' }
GtBugbopReportTimeline >> newBountySegmentFor: aSeverityAssociation in: aBucket [
	| segment |
	segment := BlElement new
		background: (GtBugbopReport severityColorFor: aSeverityAssociation key);
		border: (BlBorder paint: Color white width: 0.5);
		aptitude: (BrGlamorousWithExplicitTooltipAptitude text: (self bucketTooltipNameFor: aBucket key) , '  ·  ' , (self severityLabelFor: aSeverityAssociation key) , ': ' , (self dollarStringOf: aSeverityAssociation value) , ' (' , (self countString: aSeverityAssociation value size noun: 'report') , ')');
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent.
			c linear weight: (self dollarsOf: aSeverityAssociation value) asFloat ].
	^ self makeElement: segment spawn: aSeverityAssociation value
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> newCalendarElement [
	| byDay |
	self hasDates ifFalse: [ ^ self newEmptyStateElement ].
	byDay := self reportsByDay.
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 16);
		addChild: (self newHeaderTitle: 'Submission calendar' subtitle: self calendarSubtitle);
		addChild: self newCalendarStats;
		addChild: self newCalendarMonthRow;
		addChild: (self newCalendarGridFor: byDay);
		addChild: self newCalendarLegend;
		asScrollableElement
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> newCalendarGridFor: aDictionary [
	| max grid |
	max := (aDictionary values collect: [ :each | each size ]) max.
	grid := BrHorizontalPane new fitContent.
	grid addChild: self newWeekdayLabels.
	grid addChildren: (self calendarWeeks collect: [ :week |
		BrVerticalPane new
			fitContent;
			addChildren: ((0 to: 6) collect: [ :offset |
				self newDayCellFor: (week addDays: offset) in: aDictionary max: max ]) ]).
	^ grid
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> newCalendarLegend [
	| legend |
	legend := BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets top: 10 right: 0 bottom: 0 left: self weekdayLabelWidth).
	legend addChild: ((self newLabel: 'Less' size: 10 color: self mutedColor) margin: (BlInsets right: 6)).
	legend addChildren: (self heatColors collect: [ :each |
		BlElement new size: 12 @ 12; margin: (BlInsets all: 1.5); background: each; geometry: (BlRoundedRectangleGeometry cornerRadius: 3) ]).
	legend addChild: ((self newLabel: 'More' size: 10 color: self mutedColor) margin: (BlInsets left: 6)).
	^ legend
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> newCalendarMonthRow [
	| spans |
	spans := self calendarMonthSpans.
	^ BrHorizontalPane new
		fitContent;
		margin: (BlInsets bottom: 2);
		addChild: (BlElement new size: self weekdayLabelWidth @ 1);
		addChildren: (spans withIndexCollect: [ :each :index |
			self newMonthLabelFor: each withYear: (index = 1 or: [ each key monthIndex = 1 ]) ])
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> newCalendarStats [
	| busiest weekday |
	busiest := self busiestDay.
	weekday := self busiestWeekday.
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 12);
		addChild: (self newStatCard: 'Reports' value: self datedReports size printString object: self datedReports);
		addChild: (self newStatCard: 'Active days' value: self reportsByDay size printString object: self reportsByDay);
		addChild: (self newStatCard: 'Busiest day' value: (self shortDateString: busiest key) , '  (' , busiest value size printString , ')' object: busiest value);
		addChild: (self newStatCard: 'Busiest weekday' value: weekday key , '  (' , weekday value size printString , ')' object: weekday value)
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> newCumulativeChart [
	^ GtPlotterLineChart new
		with: self cumulativeData;
		scaleX: GtPlotterTimeScale new;
		valueX: [ :each | each at: #date ];
		valueY: [ :each | each at: #count ];
		titleX: 'Submission date (UTC)';
		titleY: 'Reports, running total';
		ticksX: 6;
		ticksY: 5;
		minX: self cumulativeWindowStart;
		maxX: (self lastDate addDays: 2) asDateAndTime;
		minY: 0;
		maxY: (self datedReports size * 1.1) ceiling;
		labelFormatX: [ :aDateAndTime | self dayLabelFor: aDateAndTime asDate ];
		labelFormatY: [ :aNumber | aNumber rounded printString ];
		highlightPointsWhere: [ :each | each at: #marker ];
		pointStencil: [ :aContext | self newCumulativePointFor: aContext ]
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> newCumulativeElement [
	self hasDates ifFalse: [ ^ self newEmptyStateElement ].
	^ BrVerticalPane new
		matchParent;
		padding: (BlInsets all: 16);
		addChild: (self newHeaderTitle: 'Growth of the report backlog' subtitle: self cumulativeSubtitle);
		addChild: self newCumulativeLegend;
		addChild: (self newCumulativeChart asElement
			constraintsDo: [ :c | c horizontal matchParent. c vertical matchParent ])
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> newCumulativeLegend [
	^ BrHorizontalPane new
		fitContent;
		margin: (BlInsets bottom: 8);
		addChild: (self newLegendEntry: self submittedSeriesName color: (self seriesColorFor: self submittedSeriesName));
		addChild: (self newLegendEntry: self validSeriesName color: (self seriesColorFor: self validSeriesName))
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> newCumulativePointFor: aContext [
	| point |
	point := aContext originalValue.
	^ self
		makeElement: (BlElement new
			geometry: BlCircleGeometry new;
			size: 9 @ 9;
			background: (self seriesColorFor: (point at: #series));
			border: (BlBorder paint: Color white width: 1.5);
			aptitude: (BrGlamorousWithExplicitTooltipAptitude text: (self cumulativeTooltipFor: point)))
		spawn: (point at: #reports)
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> newDayCellFor: aDate in: aDictionary max: aMax [
	| dayReports cell |
	cell := BlElement new
		size: (self cellPitch - 3) asPoint;
		margin: (BlInsets all: 1.5);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3).
	(aDate between: self firstDate and: self lastDate) ifFalse: [ ^ cell ].
	dayReports := aDictionary at: aDate ifAbsent: [ GtBugbopReportsGroup new ].
	cell background: (self heatColors at: (self heatLevelFor: dayReports size max: aMax) + 1).
	cell aptitude: (BrGlamorousWithExplicitTooltipAptitude content: [ self newDayTooltipFor: aDate reports: dayReports ]).
	dayReports ifEmpty: [ ^ cell ].
	^ self makeElement: cell spawn: dayReports
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> newDayTooltipFor: aDate reports: aReportsGroup [
	| pane |
	pane := BrVerticalPane new
		fitContent;
		padding: (BlInsets all: 10);
		addChild: (self newBoldLabel: (aDate dayOfWeekName first: 3) , ' ' , (self shortDateString: aDate) size: 12 color: self inkColor);
		addChild: (self newLabel: (self countString: aReportsGroup size noun: 'report') size: 11 color: self mutedColor).
	pane addChildren: ((aReportsGroup items first: (aReportsGroup size min: 6)) collect: [ :each |
		(self newLegendEntry: (self shortTitleOf: each) color: each severityColor) margin: (BlInsets top: 4) ]).
	aReportsGroup size > 6 ifTrue: [
		pane addChild: (self newLabel: '+ ' , (aReportsGroup size - 6) printString , ' more' size: 11 color: self mutedColor) ].
	^ pane
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> newDotFor: aReport offset: aFraction [
	| dot |
	dot := BlElement new
		geometry: BlCircleGeometry new;
		size: (self dotSizeFor: aReport) asPoint;
		background: (aReport statusColor alpha: 0.85);
		border: (BlBorder paint: Color white width: 1.5);
		aptitude: (BrGlamorousWithExplicitTooltipAptitude content: [ self newTooltipFor: aReport ]);
		constraintsDo: [ :c |
			c frame horizontal alignCenterAt: (self timeFractionOf: aReport createdAt).
			c frame vertical alignCenterAt: aFraction ].
	^ self makeElement: dot spawn: aReport
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> newEmptyStateElement [
	^ BrFrame new
		matchParent;
		padding: (BlInsets all: 24);
		addChild: ((self newLabel: 'No dated reports yet - nothing to plot.' size: 14 color: self mutedColor)
			constraintsDo: [ :c | c frame horizontal alignCenter. c frame vertical alignCenter ])
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> newGapBandAt: aFraction [
	"A white break in the lane marking a collapsed quiet period"
	^ BlElement new
		background: Color white;
		border: (BlBorder paint: (Color fromHexString: 'D5D9E0') width: 1);
		constraintsDo: [ :c |
			c horizontal exact: 10.
			c vertical matchParent.
			c frame horizontal alignCenterAt: aFraction ]
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> newGridlineAt: aFraction [
	^ BlElement new
		background: (Color fromHexString: 'E2E5EA');
		constraintsDo: [ :c |
			c horizontal exact: 1.
			c vertical matchParent.
			c frame horizontal alignCenterAt: aFraction ]
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> newHeaderTitle: aTitle subtitle: aSubtitle [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 10);
		addChild: (self newBoldLabel: aTitle size: 15 color: self inkColor);
		addChild: ((self newLabel: aSubtitle size: 11 color: self mutedColor) margin: (BlInsets top: 2))
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> newLabel: aString size: aFontSize color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			fontSize: aFontSize;
			foreground: aColor);
		text: aString
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> newLaneFor: aSeverityAssociation [
	^ BrHorizontalPane new
		hMatchParent;
		vExact: 64;
		margin: (BlInsets bottom: 4);
		addChild: (self newLaneLabelFor: aSeverityAssociation);
		addChild: (self newLaneTrackFor: aSeverityAssociation value)
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> newLaneLabelFor: aSeverityAssociation [
	| color pane |
	color := GtBugbopReport severityColorFor: aSeverityAssociation key.
	pane := BrHorizontalPane new
		hExact: self laneLabelWidth;
		vMatchParent;
		alignCenterLeft;
		addChild: (BlElement new size: 4 @ 36; background: color; geometry: (BlRoundedRectangleGeometry cornerRadius: 2); margin: (BlInsets right: 8));
		addChild: (BrVerticalPane new fitContent;
			addChild: (self newBoldLabel: (self severityLabelFor: aSeverityAssociation key) size: 13 color: (self readableTextColorFor: color));
			addChild: (self newLabel: (self countString: aSeverityAssociation value size noun: 'report') size: 10 color: self mutedColor)).
	^ self makeElement: pane spawn: aSeverityAssociation value
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> newLaneTrackFor: aReportsGroup [
	| track |
	track := BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c | c horizontal matchParent. c vertical matchParent ];
		background: self trackColor;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6).
	track addChildren: (self axisTicks collect: [ :each | self newGridlineAt: each key ]).
	track addChildren: (self axisGaps collect: [ :each | self newGapBandAt: each key ]).
	(self laneOffsetsFor: aReportsGroup) keysAndValuesDo: [ :aReport :anOffset |
		track addChild: (self newDotFor: aReport offset: anOffset) ].
	^ track
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> newLegendEntry: aString color: aColor [
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets top: 0 right: 14 bottom: 4 left: 0);
		addChild: (self newSwatch: aColor size: 10);
		addChild: (self newLabel: aString size: 11 color: self inkColor)
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> newMonthLabelFor: aSpan [
	"Month name (with year when there is room) over its week columns; narrow spans stay blank to avoid clipping"
	| width text |
	width := aSpan value * self cellPitch.
	text := aSpan value >= 4 ifTrue: [ aSpan key ] ifFalse: [ aSpan key first: 3 ].
	aSpan value < 2 ifTrue: [ text := '' ].
	^ BrFrame new
		hExact: width;
		vExact: 18;
		addChild: (self newLabel: text size: 11 color: self inkColor)
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> newMonthLabelFor: aSpan withYear: aBoolean [
	"Month name over its week columns (with the year when asked and there is room); a one-week span stays blank to avoid clipping"
	| width text |
	width := aSpan value * self cellPitch.
	text := (aBoolean and: [ width >= 60 ])
		ifTrue: [ self monthLabelFor: aSpan key ]
		ifFalse: [ aSpan key monthName first: 3 ].
	width < 30 ifTrue: [ text := '' ].
	^ BrFrame new
		hExact: width;
		vExact: 18;
		addChild: (self newLabel: text size: 11 color: self inkColor)
]

{ #category : 'ui - bounties' }
GtBugbopReportTimeline >> newNoBountiesElement [
	^ BrFrame new
		matchParent;
		padding: (BlInsets all: 24);
		addChild: ((self newLabel: 'No bounties awarded yet.' size: 14 color: self mutedColor)
			constraintsDo: [ :c | c frame horizontal alignCenter. c frame vertical alignCenter ])
]

{ #category : 'ui - bounties' }
GtBugbopReportTimeline >> newSeverityBountyCardFor: aSeverityAssociation [
	| color card |
	color := GtBugbopReport severityColorFor: aSeverityAssociation key.
	card := BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		padding: (BlInsets top: 8 right: 14 bottom: 8 left: 10);
		margin: (BlInsets top: 0 right: 10 bottom: 6 left: 0);
		background: self trackColor;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		addChild: (BlElement new size: 4 @ 32; background: color; geometry: (BlRoundedRectangleGeometry cornerRadius: 2); margin: (BlInsets right: 8));
		addChild: (BrVerticalPane new fitContent;
			addChild: (self newBoldLabel: (self dollarStringOf: aSeverityAssociation value) size: 15 color: self inkColor);
			addChild: (self newLabel: (self severityLabelFor: aSeverityAssociation key) , '  ·  ' , (self countString: aSeverityAssociation value size noun: 'report') size: 10 color: self mutedColor)).
	^ self makeElement: card spawn: aSeverityAssociation value
]

{ #category : 'ui - bounties' }
GtBugbopReportTimeline >> newSeverityBountyCards [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 12);
		addChildren: (self bountiesBySeverity collect: [ :each | self newSeverityBountyCardFor: each ])
]

{ #category : 'ui - bounties' }
GtBugbopReportTimeline >> newSeverityShareBar [
	"A single bar split by each severity's share of the bounty dollars"
	| bar |
	bar := BrHorizontalPane new
		hMatchParent;
		vExact: 12;
		margin: (BlInsets bottom: 10);
		clipChildren: true;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6).
	bar addChildren: (self bountiesBySeverity collect: [ :each |
		self makeElement: (BlElement new
			background: (GtBugbopReport severityColorFor: each key);
			aptitude: (BrGlamorousWithExplicitTooltipAptitude text: (self severityLabelFor: each key) , ': ' , (self dollarStringOf: each value));
			constraintsDo: [ :c | c horizontal matchParent. c vertical matchParent. c linear weight: (self dollarsOf: each value) asFloat ])
		spawn: each value ]).
	^ bar
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> newStatCard: aTitle value: aValueString object: anObject [
	| card |
	card := BrVerticalPane new
		fitContent;
		padding: (BlInsets top: 8 right: 14 bottom: 8 left: 14);
		margin: (BlInsets top: 0 right: 10 bottom: 6 left: 0);
		background: self trackColor;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		addChild: (self newLabel: aTitle size: 10 color: self mutedColor);
		addChild: ((self newBoldLabel: aValueString size: 15 color: self inkColor) margin: (BlInsets top: 2)).
	^ self makeElement: card spawn: anObject
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> newStatusLegend [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		addChildren: (self statusLegendEntries collect: [ :each |
			self newLegendEntry: each value color: each key ])
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> newStatusSeverityRowFor: aReport [
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets top: 6);
		addChild: (self newLegendEntry: (self statusLabelFor: aReport status) color: aReport statusColor);
		addChild: (self newLegendEntry: (self severityLabelFor: aReport severity) color: aReport severityColor)
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> newSwatch: aColor size: aNumber [
	^ BlElement new
		geometry: BlCircleGeometry new;
		size: aNumber asPoint;
		background: aColor;
		margin: (BlInsets right: 5)
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> newTimelineAxis [
	| ticks |
	ticks := BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c | c horizontal matchParent. c vertical exact: 20 ].
	ticks addChildren: (self axisTicks collect: [ :each |
		(self newLabel: each value size: 11 color: self mutedColor)
			constraintsDo: [ :c | c frame horizontal alignCenterAt: each key ] ]).
	ticks addChildren: (self axisGaps collect: [ :each |
		(self newLabel: each value size: 10 color: (Color fromHexString: '9CA3AF'))
			constraintsDo: [ :c | c frame horizontal alignCenterAt: each key ] ]).
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets top: 2);
		addChild: (BlElement new size: self laneLabelWidth @ 1);
		addChild: ticks
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> newTimelineElement [
	self hasDates ifFalse: [ ^ self newEmptyStateElement ].
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 16);
		addChild: self newTimelineHeader;
		addChildren: (self timelineLanes collect: [ :each | self newLaneFor: each ]);
		addChild: self newTimelineAxis;
		asScrollableElement
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> newTimelineHeader [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 6);
		addChild: (self
			newHeaderTitle: 'Submissions by severity'
			subtitle: self datedReports size printString , ' reports  ·  ' , (self shortDateString: self firstDate) , ' – ' , (self shortDateString: self lastDate) , '  ·  dot colour = status, dot size = comments, click a dot to open the report');
		addChild: self newStatusLegend
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> newTooltipFor: aReport [
	^ BrVerticalPane new
		fitContent;
		padding: (BlInsets all: 10);
		addChild: (self newBoldLabel: (self shortTitleOf: aReport) size: 13 color: self inkColor);
		addChild: ((self newLabel: (self tooltipDetailsFor: aReport) size: 11 color: self mutedColor) margin: (BlInsets top: 4));
		addChild: (self newStatusSeverityRowFor: aReport)
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> newWeekdayLabels [
	^ BrVerticalPane new
		hExact: self weekdayLabelWidth;
		vFitContent;
		addChildren: (#('Mon' '' 'Wed' '' 'Fri' '' 'Sun') collect: [ :each |
			(self newLabel: each size: 10 color: self mutedColor) vExact: self cellPitch ])
]

{ #category : 'accessing - dates' }
GtBugbopReportTimeline >> nextMonthStartAfter: aDate [
	"First day of the month following the month of aDate"
	^ self monthStartOf: ((self monthStartOf: aDate) addDays: 32)
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> paddedRange: aRange [
	"Pad an active period by two days on each side (end exclusive) so dots do not sit on the edge"
	^ { aRange first subtractDays: 2. aRange last addDays: 3 }
]

{ #category : 'printing' }
GtBugbopReportTimeline >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' ('; print: self datedReports size; nextPutAll: ' dated reports'.
	self hasDates ifTrue: [
		aStream nextPutAll: ', '; nextPutAll: (self shortDateString: self firstDate); nextPutAll: ' - '; nextPutAll: (self shortDateString: self lastDate) ].
	aStream nextPut: $)
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> readableTextColorFor: aColor [
	"Light domain colours (medium amber) are too faint as text on white; darken them"
	aColor luminance > 0.55 ifTrue: [ ^ aColor muchDarker ].
	^ aColor
]

{ #category : 'accessing' }
GtBugbopReportTimeline >> reports [
	^ reports ifNil: [ reports := GtBugbopReportsGroup new ]
]

{ #category : 'accessing' }
GtBugbopReportTimeline >> reports: aGtBugbopReportsGroup [
	reports := aGtBugbopReportsGroup
]

{ #category : 'accessing - days' }
GtBugbopReportTimeline >> reportsByDay [
	"Answer a Dictionary UTC Date -> GtBugbopReportsGroup submitted that day"
	| byDay |
	byDay := Dictionary new.
	self datedReports do: [ :each |
		(byDay at: (self dateOf: each) ifAbsentPut: [ OrderedCollection new ]) add: each ].
	^ byDay collect: [ :each | GtBugbopReportsGroup withAll: each ]
]

{ #category : 'accessing - bounties' }
GtBugbopReportTimeline >> reportsIn: aReportsGroup duringMonth: aMonthStart [
	^ aReportsGroup select: [ :each | (self monthStartOf: (self dateOf: each)) = aMonthStart ]
]

{ #category : 'accessing - days' }
GtBugbopReportTimeline >> reportsOn: aDate [
	^ GtBugbopReportsGroup withAll: (self datedReports items select: [ :each | (self dateOf: each) = aDate ])
]

{ #category : 'accessing - cumulative' }
GtBugbopReportTimeline >> seriesColorFor: aSeriesName [
	aSeriesName = self validSeriesName ifTrue: [ ^ GtBugbopReport statusColorFor: 'fixed' ].
	^ GtBugbopReport statusColorFor: 'open'
]

{ #category : 'printing' }
GtBugbopReportTimeline >> severityLabelFor: aSeverity [
	"'critical' -> 'Critical'"
	| text |
	text := (GtBugbopReport severityText: aSeverity) asString.
	text ifEmpty: [ ^ 'Unrated' ].
	^ text first asUppercase asString , text allButFirst
]

{ #category : 'printing' }
GtBugbopReportTimeline >> shortDateString: aDate [
	"e.g. 'Oct 21, 2026'"
	^ (aDate monthName first: 3) , ' ' , aDate dayOfMonth printString , ', ' , aDate year printString
]

{ #category : 'printing' }
GtBugbopReportTimeline >> shortTitleOf: aReport [
	"Report title cut to fit a tooltip line"
	| title |
	title := aReport title ifNil: [ '(untitled)' ].
	title size <= 70 ifTrue: [ ^ title ].
	^ (title first: 67) , '...'
]

{ #category : 'printing' }
GtBugbopReportTimeline >> statusLabelFor: aStatus [
	"'needs_info' -> 'Needs info'"
	| text |
	text := (GtBugbopReport statusText: aStatus) asString copyReplaceAll: '_' with: ' '.
	text ifEmpty: [ ^ text ].
	^ text first asUppercase asString , text allButFirst
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> statusLegendEntries [
	"Answer Color -> label for the statuses present, merging statuses that share a colour, in workflow order"
	| present byColor |
	present := GtBugbopReport statuses select: [ :each | self datedReports items anySatisfy: [ :r | r status = each ] ].
	byColor := OrderedDictionary new.
	present do: [ :each |
		(byColor at: (GtBugbopReport statusColorFor: each) ifAbsentPut: [ OrderedCollection new ])
			add: (self statusLabelFor: each) ].
	^ byColor associations collect: [ :each | each key -> (' / ' join: each value) ]
]

{ #category : 'ui - cumulative' }
GtBugbopReportTimeline >> steppedPointsFrom: aSeries [
	"Turn daily running totals into a step line inside the chart window: hold the previous total until the day it changes (totals carried in from before the window start at its left edge). Only points where the total changes are markers (#marker -> true)."
	| points previous |
	points := OrderedCollection new.
	previous := nil.
	aSeries do: [ :each |
		(each at: #date) >= self cumulativeWindowStart ifTrue: [
			(previous notNil and: [ points isEmpty ])
				ifTrue: [ points add: (self hiddenPointFrom: previous at: self cumulativeWindowStart) ].
			previous ifNotNil: [ points add: (self hiddenPointFrom: previous at: (each at: #date)) ].
			points add: (each copy at: #marker put: (self isChangeFrom: previous to: each); yourself) ].
		previous := each ].
	^ points
]

{ #category : 'accessing - cumulative' }
GtBugbopReportTimeline >> submittedSeriesName [
	^ 'Submitted'
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> tickLabelFor: aDate first: isFirst weekly: isWeekly [
	"The first tick of each active period carries the year"
	isWeekly ifFalse: [
		^ isFirst ifTrue: [ self monthLabelFor: aDate ] ifFalse: [ self monthTickLabelFor: aDate ] ].
	isFirst ifTrue: [ ^ self shortDateString: aDate ].
	^ self dayLabelFor: aDate
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> ticksFor: aSegment [
	| first last dates |
	first := aSegment first asDate.
	last := aSegment second asDate.
	dates := (last - first) asDays <= 70
		ifTrue: [ self weeklyTickDatesFrom: first to: last ]
		ifFalse: [ self monthlyTickDatesFrom: first to: last ].
	^ dates withIndexCollect: [ :each :index |
		(self fractionOf: each asDateAndTime in: aSegment) -> (self tickLabelFor: each first: index = 1 weekly: (last - first) asDays <= 70) ]
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> timeFractionOf: aDateAndTime [
	"Horizontal position (0..1) of a moment on the (possibly broken) time axis"
	| segments segment |
	segments := self axisSegments.
	segment := segments
		detect: [ :each | aDateAndTime < (each at: 2) ]
		ifNone: [ segments last ].
	^ self fractionOf: aDateAndTime in: segment
]

{ #category : 'ui - timeline' }
GtBugbopReportTimeline >> timelineLanes [
	"Answer severity -> reports, critical first; an 'Unrated' lane (nil key) collects missing or non-standard severities, only when needed"
	| lanes unrated |
	lanes := GtBugbopReport severities collect: [ :each | each -> (self datedReports withSeverity: each) ].
	unrated := self datedReports reject: [ :each | GtBugbopReport severities includes: each severity ].
	unrated ifEmpty: [ ^ lanes ].
	^ lanes copyWith: nil -> unrated
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> tooltipDetailsFor: aReport [
	^ '#' , aReport id asString , '  ·  by ' , aReport reporterName , '  ·  ' , (self shortDateString: (self dateOf: aReport)) , '  ·  ' , aReport commentsCount asString , ' comments'
]

{ #category : 'ui - building blocks' }
GtBugbopReportTimeline >> trackColor [
	^ Color fromHexString: 'F4F5F7'
]

{ #category : 'accessing - cumulative' }
GtBugbopReportTimeline >> validSeriesName [
	^ 'Valid (open + fixed)'
]

{ #category : 'accessing - dates' }
GtBugbopReportTimeline >> weekStartOf: aDate [
	"Monday of the week containing aDate"
	^ aDate subtractDays: (aDate dayOfWeek - 2) \\ 7
]

{ #category : 'ui - calendar' }
GtBugbopReportTimeline >> weekdayLabelWidth [
	^ 34
]

{ #category : 'accessing - bounties' }
GtBugbopReportTimeline >> weeklyBounties [
	"Answer week start Date (Monday) -> bounty reports submitted that week, from the first to the last rewarded week (empty weeks included)"
	| bounties week lastWeek weeks |
	bounties := self bountyReports.
	bounties ifEmpty: [ ^ #() ].
	week := self weekStartOf: (self dateOf: bounties first).
	lastWeek := self weekStartOf: (self dateOf: bounties last).
	weeks := OrderedCollection new.
	[ week <= lastWeek ] whileTrue: [
		weeks add: week -> (bounties select: [ :each | (self weekStartOf: (self dateOf: each)) = week ]).
		week := week addDays: 7 ].
	^ weeks asArray
]

{ #category : 'accessing - axis' }
GtBugbopReportTimeline >> weeklyTickDatesFrom: aStartDate to: aStopDate [
	"Mondays strictly inside the period"
	| tick ticks |
	tick := (self weekStartOf: aStartDate) addDays: 7.
	ticks := OrderedCollection new.
	[ tick < aStopDate ] whileTrue: [
		ticks add: tick.
		tick := tick addDays: 7 ].
	^ ticks
]
