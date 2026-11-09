"
I hold executable examples for GtBugbopReportTimeline, built on the offline insights fixture (GtBugbopExamples new insightsReportsGroup), plus a read-only live example (marked noTest).
"
Class {
	#name : 'GtBugbopReportTimelineExamples',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Examples',
	#package : 'Gt4Bugbop',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> bounties [
	<gtExample>
	<return: #Array>
	| timeline months bySeverity |
	timeline := self timeline.
	self assert: timeline bountyReports size equals: 3.
	self assert: timeline hasWeeklyBountyBuckets not.
	months := timeline bountyBuckets.
	self assert: (months collect: [ :each | each key monthIndex ]) asArray equals: #(8 9 10).
	self assert: (months collect: [ :each | timeline dollarsOf: each value ]) asArray equals: #(1500 750 0).
	self assert: (timeline bucketLabelFor: months first key) equals: 'Aug 2025'.
	bySeverity := timeline bountiesBySeverity.
	self assert: (bySeverity collect: #key) asArray equals: #('critical' 'high' 'medium').
	self assert: (timeline dollarStringOf: timeline bountyReports) equals: '$2,250'.
	^ months
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> brokenAxis [
	"Two reports 65 days apart are shown as two active periods with a collapsed quiet gap between them"
	<gtExample>
	<return: #GtBugbopReportTimeline>
	| reports timeline gaps first last |
	reports := self reports select: [ :each | #('i1' 'i12') includes: each id ].
	timeline := GtBugbopReportTimeline forReports: reports.
	self assert: timeline activeDateRanges size equals: 2.
	gaps := timeline axisGaps.
	self assert: gaps size equals: 1.
	self assert: gaps first value equals: '2 mo quiet'.
	first := timeline timeFractionOf: timeline datedReports first createdAt.
	last := timeline timeFractionOf: timeline datedReports last createdAt.
	self assert: first < gaps first key.
	self assert: gaps first key < last.
	^ timeline
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> calendar [
	<gtExample>
	<return: #Array>
	| timeline weeks spans |
	timeline := self timeline.
	weeks := timeline calendarWeeks.
	self assert: weeks size equals: 10.
	self assert: weeks first dayOfWeekName equals: #Monday.
	self assert: weeks first equals: timeline firstDate.
	self assert: timeline reportsByDay size equals: 14.
	self assert: (timeline reportsOn: timeline firstDate) size equals: 1.
	spans := timeline calendarMonthSpans.
	self assert: (spans collect: [ :each | each key monthIndex ]) asArray equals: #(8 9 10).
	self assert: (spans inject: 0 into: [ :sum :each | sum + each value ]) equals: 10.
	^ weeks
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> continuousAxis [
	"The fixture has no quiet period longer than the threshold: one axis segment, weekly ticks, no breaks"
	<gtExample>
	<return: #Array>
	| timeline ticks |
	timeline := self timeline.
	self assert: timeline activeDateRanges size equals: 1.
	self assert: timeline axisGaps isEmpty.
	ticks := timeline axisTicks.
	self assert: ticks size equals: 10.
	self assert: ticks first value equals: 'Aug 18, 2025'.
	self assert: ticks second value equals: 'Aug 25'.
	self assert: (ticks collect: #key) asArray equals: ((ticks collect: #key) asSortedCollection asArray).
	self assert: (ticks allSatisfy: [ :each | each key between: 0 and: 1 ]).
	^ ticks
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> cumulative [
	<gtExample>
	<return: #Array>
	| timeline submitted valid |
	timeline := self timeline.
	submitted := timeline cumulativeSubmitted.
	valid := timeline cumulativeValid.
	self assert: (submitted collect: [ :each | each at: #count ]) asArray equals: (1 to: 14) asArray.
	self assert: (valid collect: [ :each | each at: #count ]) asArray equals: #(1 1 1 2 3 3 3 4 5 5 5 5 5 5).
	self assert: (valid last at: #reports) size equals: 5.
	self assert: ((valid last at: #reports) allSatisfy: [ :each | each isValid ]).
	self assert: (timeline steppedPointsFrom: submitted) size equals: 27.
	^ { submitted. valid }
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> dotSpawnsReport [
	"Clicking a timeline dot spawns the report it represents"
	<gtExample>
	<return: #BlElement>
	| timeline report dot spawned click |
	timeline := self timeline.
	report := timeline datedReports first.
	dot := timeline newDotFor: report offset: 0.5.
	dot when: GtPhlowObjectToSpawn do: [ :anEvent | spawned := anEvent tool object ].
	click := BlClickEvent new.
	dot fireEvent: click.
	self assert: click isConsumed.
	self assert: spawned == report.
	self assert: dot width equals: 0.
	self assert: (timeline dotSizeFor: report) equals: 12 + (6 * 1.6).
	^ dot
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> emptyTimeline [
	<gtExample>
	<return: #GtBugbopReportTimeline>
	| timeline |
	timeline := GtBugbopReportTimeline forReports: GtBugbopReportsGroup new.
	self assert: timeline hasDates not.
	self assert: timeline calendarWeeks isEmpty.
	self assert: timeline monthlyBounties isEmpty.
	self assert: timeline busiestDay isNil.
	self assert: (timeline newTimelineElement isKindOf: BrFrame).
	self assert: (timeline newBountiesElement isKindOf: BrFrame).
	^ timeline
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> heatLevels [
	<gtExample>
	<return: #Array>
	| timeline levels |
	timeline := self timeline.
	levels := #(0 1 2 3 5 10) collect: [ :each | timeline heatLevelFor: each max: 10 ].
	self assert: levels equals: #(0 1 1 2 2 4).
	"sparse data stays light: a lone report on the busiest day is level 1, not 4"
	self assert: (timeline heatLevelFor: 1 max: 1) equals: 1.
	self assert: timeline heatColors size equals: 5.
	^ levels
]

{ #category : 'examples - live' }
GtBugbopReportTimelineExamples >> liveTimeline [
	"Read-only: built from the live Bugbop API (no writes)"
	<gtExample>
	<noTest>
	^ GtBugbopReportTimeline forReports: GtBugbopLiveExamples new reports
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> reports [
	<gtExample>
	<return: #GtBugbopReportsGroup>
	| reports |
	reports := GtBugbopExamples new insightsReportsGroup.
	self assert: reports size equals: 14.
	^ reports
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> severityLanes [
	<gtExample>
	<return: #Array>
	| lanes |
	lanes := self timeline timelineLanes.
	self assert: (lanes collect: #key) asArray equals: #('critical' 'high' 'medium' 'low').
	self assert: (lanes collect: [ :each | each value size ]) asArray equals: #(2 4 4 4).
	self assert: (lanes first value items collect: #id) asArray equals: #('i1' 'i12').
	^ lanes
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> statusLegend [
	"Each status has its own color in the domain palette, so each gets its own legend entry"
	<gtExample>
	<return: #Array>
	| legend |
	legend := self timeline statusLegendEntries.
	self assert: legend size equals: 7.
	self assert: legend first value equals: 'New'.
	self assert: legend last value equals: 'Not applicable'.
	self assert: (legend collect: #key) asSet size equals: 7.
	self assert: (legend detect: [ :each | each value = 'Duplicate' ]) key equals: (GtBugbopReport statusColorFor: 'duplicate').
	^ legend
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> timeline [
	<gtExample>
	<return: #GtBugbopReportTimeline>
	| timeline |
	timeline := GtBugbopReportTimeline forReports: self reports.
	self assert: timeline hasDates.
	self assert: timeline datedReports size equals: 14.
	self assert: timeline firstDate equals: (Date year: 2025 month: 8 day: 18) asDateAndTime asUTC asDate.
	self assert: timeline lastDate equals: (Date year: 2025 month: 10 day: 22) asDateAndTime asUTC asDate.
	self assert: timeline datedReports first id equals: 'i1'.
	self assert: timeline datedReports last id equals: 'i12'.
	^ timeline
]

{ #category : 'examples' }
GtBugbopReportTimelineExamples >> weeklyBounties [
	"When all bounties fall in one month the bars switch to weekly buckets"
	<gtExample>
	<return: #Array>
	| timeline weeks |
	timeline := GtBugbopReportTimeline forReports: (self reports select: [ :each | #('i4' 'i13' 'i5') includes: each id ]).
	self assert: timeline bountyReports size equals: 2.
	self assert: timeline hasWeeklyBountyBuckets.
	weeks := timeline bountyBuckets.
	self assert: weeks size equals: 5.
	self assert: (weeks collect: [ :each | timeline dollarsOf: each value ]) asArray equals: #(500 0 0 0 250).
	^ weeks
]
