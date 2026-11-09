"
I am a triage board over a GtBugbopReportsGroup.

I answer triage questions: which reports sit in which workflow column, how old active reports are relative to SLA thresholds (7 and 30 days), and which active reports need attention and why.

Ages are computed relative to #asOf (defaults to now), so offline fixtures stay deterministic.

Views: Board (kanban), Aging (SLA bars), Attention (reasoned worklist). Every visual mark spawns the report(s) it represents.

Create with: GtBugbopTriageBoard forReports: aGtBugbopReportsGroup
"
Class {
	#name : 'GtBugbopTriageBoard',
	#superclass : 'Object',
	#instVars : [
		'reports',
		'asOf'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'constants' }
GtBugbopTriageBoard class >> boardStatuses [
	"Kanban column order: the active workflow first, then the resolved outcomes"
	^ #('new' 'needs_info' 'open' 'fixed' 'wont_fix' 'duplicate' 'not_applicable')
]

{ #category : 'instance creation' }
GtBugbopTriageBoard class >> forReports: aGtBugbopReportsGroup [
	^ self new reports: aGtBugbopReportsGroup
]

{ #category : 'instance creation' }
GtBugbopTriageBoard class >> forReports: aGtBugbopReportsGroup asOf: aDateAndTime [
	"Measure ages relative to aDateAndTime instead of now (used by offline examples)"
	^ (self forReports: aGtBugbopReportsGroup) asOf: aDateAndTime
]

{ #category : 'constants' }
GtBugbopTriageBoard class >> slaBreachDays [
	^ 30
]

{ #category : 'constants' }
GtBugbopTriageBoard class >> slaWarningDays [
	^ 7
]

{ #category : 'constants' }
GtBugbopTriageBoard class >> staleDays [
	"Active reports older than this need attention"
	^ 14
]

{ #category : 'querying' }
GtBugbopTriageBoard >> activeReports [
	"Active reports, oldest first"
	^ self reports active asArray sort: [ :a :b | (self ageInDaysOf: a) >= (self ageInDaysOf: b) ]
]

{ #category : 'aging' }
GtBugbopTriageBoard >> ageInDaysOf: aReport [
	"Whole days between submission and #asOf; 0 when unknown"
	aReport createdAt ifNil: [ ^ 0 ].
	^ ((self asOf - aReport createdAt) days) max: 0
]

{ #category : 'aging' }
GtBugbopTriageBoard >> ageLabelOf: aReport [
	aReport createdAt ifNil: [ ^ '?' ].
	^ (self ageInDaysOf: aReport) printString , 'd'
]

{ #category : 'ui - attention' }
GtBugbopTriageBoard >> ageTextOf: aReport [
	^ (self ageLabelOf: aReport) asRopedText
		bold;
		foreground: (self slaColorForDays: (self ageInDaysOf: aReport));
		yourself
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> agingLabelWidth [
	^ 250
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> agingScaleDays [
	"Days represented by the full track: the oldest active report (at least the breach threshold) plus headroom"
	| oldest |
	oldest := self activeReports
			inject: self class slaBreachDays
			into: [ :max :each | max max: (self ageInDaysOf: each) ].
	^ (oldest * 1.08) ceiling
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> agingTooltipFor: aReport [
	^ aReport title , String cr , aReport severity asString , ' · ' , aReport status asString , ' · @'
		, aReport reporterName , ' · ' , (self ageInDaysOf: aReport) printString , ' days old'
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> agingTrackWidth [
	^ 560
]

{ #category : 'tags' }
GtBugbopTriageBoard >> aiColor [
	^ Color fromHexString: '00838F'
]

{ #category : 'tags' }
GtBugbopTriageBoard >> aiDisagreementTagFor: aReport [
	aReport aiAgreesOnSeverity ifTrue: [ ^ nil ].
	^ GtBugbopTriageTag
		label: 'AI: ' , aReport aiSeverity
		color: self aiColor
		explanation: 'AI triage suggests ' , aReport aiSeverity , ' but the report is rated ' , aReport severity asString
]

{ #category : 'accessing' }
GtBugbopTriageBoard >> asOf [
	"The moment ages are measured against"
	^ asOf ifNil: [ DateAndTime now ]
]

{ #category : 'accessing' }
GtBugbopTriageBoard >> asOf: aDateAndTime [
	asOf := aDateAndTime
]

{ #category : 'querying' }
GtBugbopTriageBoard >> attentionReasonsFor: aReport [
	"Tags explaining why an active report needs attention"
	^ (OrderedCollection new
		add: (self untriagedReasonFor: aReport);
		add: (self staleReasonFor: aReport);
		add: (self awaitingHunterReasonFor: aReport);
		add: (self aiDisagreementTagFor: aReport);
		yourself) reject: [ :each | each isNil ]
]

{ #category : 'querying' }
GtBugbopTriageBoard >> attentionReports [
	"Active reports with at least one attention reason; most reasons first, then by severity"
	^ (self activeReports select: [ :each | self needsAttention: each ]) sort: [ :a :b | 
		| reasonsA reasonsB |
		reasonsA := (self attentionReasonsFor: a) size.
		reasonsB := (self attentionReasonsFor: b) size.
		reasonsA = reasonsB
			ifTrue: [ a severityRank <= b severityRank ]
			ifFalse: [ reasonsA > reasonsB ] ]
]

{ #category : 'tags' }
GtBugbopTriageBoard >> awaitingHunterReasonFor: aReport [
	| days |
	aReport status = 'needs_info' ifFalse: [ ^ nil ].
	days := self ageInDaysOf: aReport.
	days > self class slaWarningDays ifFalse: [ ^ nil ].
	^ GtBugbopTriageTag
		label: 'waiting on hunter'
		color: (GtBugbopReport statusColorFor: 'needs_info')
		explanation: 'Needs info for more than ' , self class slaWarningDays printString , ' days: chase the hunter or close it'
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> bountyColor [
	^ Color fromHexString: '2E7D32'
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> breachBandColor [
	^ Color fromHexString: 'C62828'
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> breachBandTint [
	^ Color fromHexString: 'FFEBEE'
]

{ #category : 'tags' }
GtBugbopTriageBoard >> cardFlagsFor: aReport [
	"Warning badges shown on a board card"
	^ { self scopeTagFor: aReport. self suspectedDuplicateTagFor: aReport. self aiDisagreementTagFor: aReport }
		reject: [ :each | each isNil ]
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> columnWidthFor: aStatus [
	^ (self isCompactStatus: aStatus) ifTrue: [ 190 ] ifFalse: [ 270 ]
]

{ #category : 'querying' }
GtBugbopTriageBoard >> columns [
	"status -> reports, one per board column"
	^ self class boardStatuses collect: [ :aStatus | aStatus -> (self reportsWithStatus: aStatus) ]
]

{ #category : 'views' }
GtBugbopTriageBoard >> gtAgingFor: aView [
	<gtView>
	^ aView explicit
		title: 'Aging';
		priority: 2;
		stencil: [ self newAgingElement ]
]

{ #category : 'views' }
GtBugbopTriageBoard >> gtAttentionFor: aView [
	<gtView>
	self attentionReports ifEmpty: [ 
		^ aView explicit
			title: 'Attention';
			priority: 3;
			stencil: [ self newEmptyLabel: 'Nothing needs attention right now' ] ].
	^ aView columnedList
		title: 'Attention';
		priority: 3;
		items: [ self attentionReports ];
		column: 'Severity' stencil: [ :each | self newSeverityChipFor: each ] width: 80;
		column: 'Title' text: [ :each | each title ] weight: 1;
		column: 'Status' text: [ :each | each status asRopedText foreground: each statusColor; yourself ] width: 90;
		column: 'Hunter' text: [ :each | '@' , each reporterName ] width: 140;
		column: 'Age' text: [ :each | self ageTextOf: each ] width: 50;
		column: 'Why' stencil: [ :each | self newReasonsElementFor: each ] weight: 1;
		send: [ :each | each ]
]

{ #category : 'views' }
GtBugbopTriageBoard >> gtBoardFor: aView [
	<gtView>
	^ aView explicit
		title: 'Board';
		priority: 1;
		stencil: [ self newBoardElement ]
]

{ #category : 'actions' }
GtBugbopTriageBoard >> gtSpawnAttentionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons inspect;
		tooltip: 'Inspect the reports that need attention';
		priority: 10;
		action: [ :aButton | aButton phlow spawnObject: (GtBugbopReportsGroup withAll: self attentionReports) ]
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> inkColor [
	^ Color fromHexString: '172B4D'
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> isCompactStatus: aStatus [
	"Resolved columns get narrower, one-line cards"
	^ (GtBugbopReport activeStatuses includes: aStatus) not
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> lineColor [
	^ Color fromHexString: 'DFE1E6'
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> mutedColor [
	^ Color fromHexString: '6B778C'
]

{ #category : 'querying' }
GtBugbopTriageBoard >> needsAttention: aReport [
	^ aReport isActive and: [ (self attentionReasonsFor: aReport) notEmpty ]
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newAgeBadgeFor: aReport [
	"Age pill tinted by SLA (neutral / amber past 7d / red past 30d)"
	^ (GtBugbopTriageTag
		label: (self ageLabelOf: aReport)
		color: (self slaColorForDays: (self ageInDaysOf: aReport))
		explanation: 'Submitted ' , (self ageInDaysOf: aReport) printString , ' days ago') newElement
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> newAgingAxisFor: aScale [
	"Tick labels aligned with the track: 0, the SLA thresholds and the scale end"
	| anAxis |
	anAxis := BlElement new
			size: self agingTrackWidth + 40 @ 16;
			margin: (BlInsets left: self agingLabelWidth).
	{ 0. self class slaWarningDays. self class slaBreachDays. aScale }
		do: [ :days | 
			anAxis addChild: ((self newLabel: days printString , 'd' size: 10 color: self mutedColor)
					relocate: ((self xForDays: days scale: aScale) - 6 max: 0) @ 0) ].
	^ anAxis
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> newAgingElement [
	| aScale theRows |
	self activeReports ifEmpty: [ ^ self newEmptyLabel: 'No active reports: nothing is aging' ].
	aScale := self agingScaleDays.
	theRows := BrVerticalPane new
			hMatchParent;
			vFitContent.
	self activeReports do: [ :each | theRows addChild: (self newAgingRowFor: each scale: aScale) ].
	^ BrVerticalPane new
		matchParent;
		padding: (BlInsets top: 10 left: 12 bottom: 0 right: 12);
		addChild: self newAgingLegend;
		addChild: (self newAgingAxisFor: aScale);
		addChild: (theRows asScrollableElement
				constraintsDo: [ :c | 
					c horizontal matchParent.
					c vertical matchParent ])
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> newAgingLegend [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 10);
		addChild: ((self newBoldLabel: self activeReports size printString , ' active reports, oldest first' size: 12 color: self inkColor) margin: (BlInsets right: 20));
		addChildren: self newSeverityLegendItems;
		addChild: (self newBandLegendItem: 'over ' , self class slaWarningDays printString , 'd: getting old' tint: self warningBandTint line: self warningBandColor);
		addChild: (self newBandLegendItem: 'over ' , self class slaBreachDays printString , 'd: SLA breached' tint: self breachBandTint line: self breachBandColor)
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> newAgingRowFor: aReport scale: aScale [
	"Title | SLA track with the age bar | age; the whole row spawns the report"
	| aRow |
	aRow := BrHorizontalPane new
			hMatchParent;
			height: 26;
			alignCenterLeft;
			aptitude: (BrGlamorousWithExplicitTooltipAptitude text: (self agingTooltipFor: aReport));
			addChild: ((self newLabel: (self truncate: aReport title to: 36) size: 12 color: self inkColor)
					width: self agingLabelWidth);
			addChild: (self newAgingTrackFor: aReport scale: aScale);
			addChild: ((self newBoldLabel: (self ageLabelOf: aReport) size: 11 color: (self slaColorForDays: (self ageInDaysOf: aReport)))
					margin: (BlInsets left: 8)).
	^ self whenClicked: aRow spawn: aReport
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> newAgingTrackFor: aReport scale: aScale [
	"SLA bands and guide lines drawn behind the severity-colored age bar"
	| aTrack |
	aTrack := BlElement new size: self agingTrackWidth @ 26.
	aTrack addChildren: (self newSlaBandsForScale: aScale).
	aTrack addChild: (BlElement new
			size: ((self xForDays: (self ageInDaysOf: aReport) scale: aScale) max: 3) @ 14;
			relocate: 0 @ 6;
			geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii new topLeft: 0; bottomLeft: 0; topRight: 4; bottomRight: 4));
			background: aReport severityColor).
	^ aTrack
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> newBandFrom: aStartX to: anEndX color: aColor [
	^ BlElement new
		size: ((anEndX - aStartX) max: 1) @ 26;
		relocate: aStartX @ 0;
		background: aColor
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> newBandLegendItem: aString tint: aTint line: aLineColor [
	| anItem |
	anItem := self newLegendItem: aString color: aTint.
	anItem children first border: (BlBorder paint: aLineColor width: 1).
	^ anItem
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newBoardElement [
	| aBoard |
	self reports ifEmpty: [ ^ self newEmptyLabel: 'No reports to triage' ].
	aBoard := BrHorizontalPane new
			hFitContent;
			vMatchParent;
			cellSpacing: 10;
			padding: (BlInsets all: 10).
	self class boardStatuses do: [ :aStatus | aBoard addChild: (self newColumnFor: aStatus) ].
	^ BrVerticalPane new
		matchParent;
		addChild: self newBoardHeader;
		addChild: (aBoard asScrollableElement
				constraintsDo: [ :c | 
					c horizontal matchParent.
					c vertical matchParent ])
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newBoardHeader [
	"Summary line plus the legend for stripes and badges"
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 8 left: 12 bottom: 0 right: 12);
		addChild: ((self newBoldLabel: self summaryText size: 12 color: self inkColor)
				margin: (BlInsets right: 20));
		addChildren: self newSeverityLegendItems;
		addChild: ((self newLabel: 'badges: hover for details' size: 11 color: self mutedColor) margin: (BlInsets left: 8))
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> newBoldLabel: aString size: aFontSize color: aColor [
	^ (self newLabel: aString size: aFontSize color: aColor)
		text: (aString asString asRopedText bold; yourself);
		yourself
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newCardFor: aReport [
	"Full card: title (two lines max), hunter / bounty / age, warning badges"
	| aBody |
	aBody := BrVerticalPane new
			hMatchParent;
			vFitContent;
			cellSpacing: 4;
			padding: (BlInsets top: 6 left: 8 bottom: 7 right: 8).
	(self titleLinesOf: aReport title maxChars: 32)
		do: [ :aLine | aBody addChild: (self newLabel: aLine size: 12 color: self inkColor) ].
	aBody addChild: (self newCardMetaRowFor: aReport).
	(self cardFlagsFor: aReport)
		ifNotEmpty: [ :theFlags | aBody addChild: (self newFlagsRowFor: theFlags) ].
	^ (self newCardShellFor: aReport) addChild: aBody; yourself
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newCardFor: aReport status: aStatus [
	^ (self isCompactStatus: aStatus)
		ifTrue: [ self newCompactCardFor: aReport ]
		ifFalse: [ self newCardFor: aReport ]
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newCardMetaRowFor: aReport [
	"@hunter on the left; bounty and age badge on the right"
	| aRow |
	aRow := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenterLeft.
	aRow addChild: (self newLabel: '@' , aReport reporterName size: 11 color: self mutedColor).
	aRow addChild: self newSpacer.
	aReport hasBounty ifTrue: [ 
		aRow addChild: ((self newBoldLabel: (self shortBountyOf: aReport) size: 11 color: self bountyColor) margin: (BlInsets right: 6)) ].
	^ aRow addChild: (self newAgeBadgeFor: aReport); yourself
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newCardShellFor: aReport [
	"White rounded card with the severity stripe on the left; clicking spawns the report"
	| aCard |
	aCard := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			background: Color white;
			geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
			border: (BlBorder paint: self lineColor width: 1);
			clipChildren: true;
			addChild: (BlElement new
					width: 5;
					constraintsDo: [ :c | c vertical matchParent ];
					background: aReport severityColor).
	^ self whenClicked: aCard spawn: aReport
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newCardsPaneFor: theReports status: aStatus [
	| aPane |
	theReports ifEmpty: [ ^ self newLabel: 'empty' size: 11 color: self mutedColor ].
	aPane := BrVerticalPane new
			hMatchParent;
			vFitContent;
			cellSpacing: 6.
	theReports do: [ :each | aPane addChild: (self newCardFor: each status: aStatus) ].
	^ aPane asScrollableElement
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ]
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newColumnFor: aStatus [
	| theReports |
	theReports := self reportsWithStatus: aStatus.
	^ BrVerticalPane new
		width: (self columnWidthFor: aStatus);
		vMatchParent;
		padding: (BlInsets all: 8);
		background: (Color fromHexString: 'F4F5F7');
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		addChild: (self newColumnHeaderFor: aStatus reports: theReports);
		addChild: (self newCardsPaneFor: theReports status: aStatus)
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newColumnHeaderFor: aStatus reports: theReports [
	"Status dot, name and count pill; clicking spawns the column's reports"
	| aColor aHeader |
	aColor := GtBugbopReport statusColorFor: aStatus.
	aHeader := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenterLeft;
			cellSpacing: 6;
			margin: (BlInsets bottom: 8);
			addChild: ((self newSwatch: aColor) geometry: BlCircleGeometry new);
			addChild: (self newBoldLabel: (self statusLabelFor: aStatus) size: 13 color: aColor);
			addChild: (self newCountPill: theReports size color: aColor).
	^ self whenClicked: aHeader spawn: (GtBugbopReportsGroup withAll: theReports)
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newCompactCardFor: aReport [
	"One-line card for resolved columns: title and bounty"
	| aBody |
	aBody := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenterLeft;
			cellSpacing: 4;
			padding: (BlInsets top: 4 left: 6 bottom: 4 right: 6);
			addChild: (self newLabel: (self truncate: aReport title to: (aReport hasBounty ifTrue: [ 19 ] ifFalse: [ 26 ])) size: 11 color: self inkColor);
			addChild: self newSpacer.
	aReport hasBounty ifTrue: [ 
		aBody addChild: (self newBoldLabel: (self shortBountyOf: aReport) size: 10 color: self bountyColor) ].
	^ (self newCardShellFor: aReport) addChild: aBody; yourself
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newCountPill: aNumber color: aColor [
	^ (self newBoldLabel: aNumber printString size: 10 color: Color white)
		background: aColor;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		padding: (BlInsets top: 1 left: 7 bottom: 1 right: 7)
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> newEmptyLabel: aString [
	"Friendly centered message used instead of an empty view"
	^ BrFrame new
		matchParent;
		padding: (BlInsets all: 20);
		addChild: ((self newLabel: aString size: 14 color: self mutedColor)
				constraintsDo: [ :c | 
					c frame horizontal alignCenter.
					c frame vertical alignCenter ])
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> newFlagsRowFor: theTags [
	| aRow |
	aRow := BrHorizontalFlow new
			hMatchParent;
			vFitContent.
	theTags do: [ :each | aRow addChild: (each newElement margin: (BlInsets top: 2 right: 4)) ].
	^ aRow
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> newLabel: aString size: aFontSize color: aColor [
	^ BrLabel new
		text: aString asString;
		aptitude: (BrGlamorousLabelAptitude new
				glamorousRegularFont;
				fontSize: aFontSize;
				foreground: aColor)
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> newLegendItem: aString color: aColor [
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		cellSpacing: 4;
		margin: (BlInsets right: 12);
		addChild: (self newSwatch: aColor);
		addChild: (self newLabel: aString size: 11 color: self mutedColor)
]

{ #category : 'ui - attention' }
GtBugbopTriageBoard >> newReasonsElementFor: aReport [
	| aRow |
	aRow := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			alignCenterLeft;
			cellSpacing: 4.
	(self attentionReasonsFor: aReport) do: [ :each | aRow addChild: each newElement ].
	^ aRow
]

{ #category : 'ui - attention' }
GtBugbopTriageBoard >> newSeverityChipFor: aReport [
	^ (GtBugbopTriageTag
		label: aReport severity asString
		color: aReport severityColor
		explanation: 'Assigned severity: ' , aReport severity asString) newElement
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> newSeverityLegend [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		addChildren: self newSeverityLegendItems
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> newSeverityLegendItems [
	"One swatch per severity, most severe first"
	^ GtBugbopReport severities collect: [ :each | 
		self newLegendItem: each color: (GtBugbopReport severityColorFor: each) ]
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> newSlaBandsForScale: aScale [
	"Tinted warning/breach bands plus thin guide lines at the thresholds and the zero axis"
	| xWarn xBreach |
	xWarn := self xForDays: self class slaWarningDays scale: aScale.
	xBreach := self xForDays: self class slaBreachDays scale: aScale.
	^ { 
		self newBandFrom: xWarn to: xBreach color: self warningBandTint.
		self newBandFrom: xBreach to: self agingTrackWidth color: self breachBandTint.
		self newBandFrom: 0 to: 1 color: (self mutedColor alpha: 0.6).
		self newBandFrom: xWarn to: xWarn + 1 color: (self warningBandColor alpha: 0.5).
		self newBandFrom: xBreach to: xBreach + 1 color: (self breachBandColor alpha: 0.5) }
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> newSpacer [
	^ BlElement new
		height: 1;
		constraintsDo: [ :c | c horizontal matchParent ]
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> newSwatch: aColor [
	^ BlElement new
		size: 10 @ 10;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 2);
		background: aColor
]

{ #category : 'printing' }
GtBugbopTriageBoard >> printOn: aStream [
	aStream
		nextPutAll: 'Triage board (';
		print: self activeReports size;
		nextPutAll: ' active, ';
		print: self attentionReports size;
		nextPutAll: ' need attention)'
]

{ #category : 'accessing' }
GtBugbopTriageBoard >> reports [
	^ reports ifNil: [ reports := GtBugbopReportsGroup new ]
]

{ #category : 'accessing' }
GtBugbopTriageBoard >> reports: aGtBugbopReportsGroup [
	reports := aGtBugbopReportsGroup
]

{ #category : 'querying' }
GtBugbopTriageBoard >> reportsWithStatus: aStatus [
	"The cards of one board column, in triage order"
	^ self sortedForTriage: (self reports withStatus: aStatus)
]

{ #category : 'tags' }
GtBugbopTriageBoard >> scopeTagFor: aReport [
	aReport hasScopeWarning ifFalse: [ ^ nil ].
	^ GtBugbopTriageTag
		label: 'scope'
		color: (Color fromHexString: 'C62828')
		explanation: 'Scope warning: the target may be outside the program scope'
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> shortBountyOf: aReport [
	"'$1,500.00' -> '$1,500'"
	^ aReport bountyAmountString copyReplaceAll: '.00' with: ''
]

{ #category : 'aging' }
GtBugbopTriageBoard >> slaColorForDays: aNumber [
	"Neutral within the warning window, amber when getting old, red past the breach threshold"
	aNumber >= self class slaBreachDays ifTrue: [ ^ Color fromHexString: 'C62828' ].
	aNumber >= self class slaWarningDays ifTrue: [ ^ Color fromHexString: 'EF6C00' ].
	^ Color fromHexString: '546E7A'
]

{ #category : 'querying' }
GtBugbopTriageBoard >> sortedForTriage: aCollection [
	"Most severe first, then oldest first"
	^ aCollection asArray sort: [ :a :b | 
		a severityRank = b severityRank
			ifTrue: [ (self ageInDaysOf: a) >= (self ageInDaysOf: b) ]
			ifFalse: [ a severityRank < b severityRank ] ]
]

{ #category : 'tags' }
GtBugbopTriageBoard >> staleReasonFor: aReport [
	| days |
	days := self ageInDaysOf: aReport.
	days > self class staleDays ifFalse: [ ^ nil ].
	^ GtBugbopTriageTag
		label: 'stale ' , days printString , 'd'
		color: (self slaColorForDays: days)
		explanation: 'Open for ' , days printString , ' days (more than ' , self class staleDays printString , ')'
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> statusLabelFor: aStatus [
	"Human-readable status name, e.g. 'needs_info' -> 'Needs info'"
	aStatus ifNil: [ ^ 'Unknown' ].
	^ (aStatus copyReplaceAll: '_' with: ' ') capitalized
]

{ #category : 'ui - board' }
GtBugbopTriageBoard >> summaryText [
	^ self activeReports size printString , ' active  ·  '
		, self attentionReports size printString , ' need attention  ·  '
		, self reports size printString , ' total'
]

{ #category : 'tags' }
GtBugbopTriageBoard >> suspectedDuplicateTagFor: aReport [
	aReport isSuspectedDuplicate ifFalse: [ ^ nil ].
	^ GtBugbopTriageTag
		label: 'dup?'
		color: (Color fromHexString: '6D4C41')
		explanation: 'Suspected duplicate of report ' , aReport suspectedDuplicateOfId asString
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> takeWordsFrom: aWordStream maxChars: aNumber [
	"Consume words from aWordStream while they fit on a line of aNumber characters"
	^ String streamContents: [ :s | 
		[ aWordStream atEnd not
			and: [ s position isZero or: [ s position + 1 + aWordStream peek size <= aNumber ] ] ]
			whileTrue: [ 
				s position isZero ifFalse: [ s space ].
				s nextPutAll: (self truncate: aWordStream next to: aNumber) ] ]
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> titleLinesOf: aString maxChars: aNumber [
	"Word-wrap aString into at most two lines of aNumber characters; ellipsis when it does not fit"
	| words first rest |
	words := (aString ifNil: [ '' ]) substrings readStream.
	first := self takeWordsFrom: words maxChars: aNumber.
	rest := Character space join: words upToEnd.
	rest ifEmpty: [ ^ { first } ].
	^ { first. self truncate: rest to: aNumber }
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> truncate: aString to: aNumber [
	aString size <= aNumber ifTrue: [ ^ aString ].
	^ (aString first: aNumber - 1) trimRight , '…'
]

{ #category : 'tags' }
GtBugbopTriageBoard >> untriagedReasonFor: aReport [
	"Critical or high severity still sitting in 'new'"
	aReport status = 'new' ifFalse: [ ^ nil ].
	aReport severityRank > 2 ifTrue: [ ^ nil ].
	^ GtBugbopTriageTag
		label: aReport severity , ' untriaged'
		color: aReport severityColor
		explanation: 'A ' , aReport severity , ' severity report has not been triaged yet'
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> warningBandColor [
	^ Color fromHexString: 'EF6C00'
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> warningBandTint [
	^ Color fromHexString: 'FFF3E0'
]

{ #category : 'ui - helpers' }
GtBugbopTriageBoard >> whenClicked: anElement spawn: anObject [
	"Make anElement navigate to anObject, GT style"
	anElement
		when: BlClickEvent
		do: [ :anEvent | 
			anEvent consumed: true.
			anElement phlow spawnObject: anObject ].
	^ anElement
]

{ #category : 'ui - aging' }
GtBugbopTriageBoard >> xForDays: aNumber scale: aScaleDays [
	^ ((aNumber min: aScaleDays) / aScaleDays * self agingTrackWidth) asFloat
]
