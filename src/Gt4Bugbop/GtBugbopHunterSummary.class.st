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

{ #category : 'accessing' }
GtBugbopHunterSummary class >> minimumSignalSample [
	"Fewer resolved reports than this are too few to color a hunter as precise or noisy"
	^ 3
]

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

{ #category : 'gt - profile' }
GtBugbopHunterSummary >> gtProfileFor: aView [
	<gtView>
	^ aView explicit
		title: 'Profile';
		priority: 0;
		stencil: [ self newProfileCard ]
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

{ #category : 'testing' }
GtBugbopHunterSummary >> hasSignificantSignal [
	^ self resolvedCount >= self class minimumSignalSample
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> highestSeverity [
	^ (reports items detectMin: [ :each | each severityRank ]) ifNotNil: [ :aReport | aReport severity ]
]

{ #category : 'gt - profile' }
GtBugbopHunterSummary >> initials [
	| letters |
	letters := self username select: [ :each | each isLetter or: [ each isDigit ] ].
	letters ifEmpty: [ ^ '?' ].
	^ (letters first: (letters size min: 2)) asUppercase
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> lastReportedAt [
	^ (reports items collect: [ :each | each createdAt ] thenReject: [ :each | each isNil ])
		ifEmpty: [ nil ]
		ifNotEmpty: [ :theTimes | theTimes max ]
]

{ #category : 'ui - profile' }
GtBugbopHunterSummary >> newProfileAvatar [
	| color avatar |
	color := self signalColor.
	avatar := BrFrame new
			size: 60 @ 60;
			geometry: BlCircleGeometry new;
			background: color;
			border: (BlBorder paint: (color mixed: 0.35 with: Color white) width: 4);
			aptitude: (BrGlamorousWithLabelTooltipAptitude new text: 'Colored by signal ratio (grey until 3 reports are resolved) - click for all reports');
			addChild: ((GtBugbopHunterLandscape
					newHeading: self initials
					size: 20
					color: (GtBugbopHunterLandscape textColorOn: color))
					constraintsDo: [ :c | 
						c frame horizontal alignCenter.
						c frame vertical alignCenter ]).
	^ GtBugbopHunterLandscape makeSpawn: avatar object: reports
]

{ #category : 'gt - profile' }
GtBugbopHunterSummary >> newProfileCard [
	^ BrVerticalPane new
		matchParent;
		padding: (BlInsets all: 16);
		addChild: self newProfileHeader;
		addChild: self newProfileStats;
		addChild: ((GtBugbopHunterLandscape newCaption: 'Reports by severity - click a segment to open them')
				margin: (BlInsets top: 18 left: 0 bottom: 6 right: 0));
		addChild: self newProfileSeverityBar;
		addChild: ((GtBugbopHunterLandscape newSeverityLegendCounting: reports) margin: (BlInsets top: 8))
]

{ #category : 'gt - profile' }
GtBugbopHunterSummary >> newProfileHeader [
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterLeft;
		addChild: self newProfileAvatar;
		addChild: (BrVerticalPane new
				fitContent;
				margin: (BlInsets left: 14);
				addChild: (GtBugbopHunterLandscape
						newHeading: self username
						size: 22
						color: (Color fromHexString: '212121'));
				addChild: (GtBugbopHunterLandscape newCaption: self profileSubtitle))
]

{ #category : 'gt - profile' }
GtBugbopHunterSummary >> newProfileSeverityBar [
	^ (GtBugbopSeverityBarStencil new
		reports: reports;
		maxCount: self reportCount;
		maxWidth: 460;
		barHeight: 24) asElement
]

{ #category : 'gt - profile' }
GtBugbopHunterSummary >> newProfileStats [
	| flow |
	flow := BrHorizontalFlow new
			hMatchParent;
			vFitContent;
			margin: (BlInsets top: 18).
	self profileStats do: [ :each | flow addChild: (self newStatTileFor: each) ].
	^ flow
]

{ #category : 'gt - profile' }
GtBugbopHunterSummary >> newStatTileFor: aStat [
	| tile |
	tile := BrVerticalPane new
			size: 116 @ 66;
			alignCenterLeft;
			padding: (BlInsets top: 10 left: 12 bottom: 10 right: 8);
			margin: (BlInsets top: 0 left: 0 bottom: 10 right: 10);
			geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
			background: (aStat third mixed: 0.09 with: Color white);
			border: (BlBorder paint: (aStat third mixed: 0.3 with: Color white) width: 1);
			aptitude: (BrGlamorousWithLabelTooltipAptitude new text: 'Click to open ' , aStat first , ' reports');
			addChild: (GtBugbopHunterLandscape newHeading: aStat second size: 20 color: aStat third);
			addChild: (GtBugbopHunterLandscape newCaption: aStat first).
	^ GtBugbopHunterLandscape makeSpawn: tile object: aStat fourth
]

{ #category : 'printing' }
GtBugbopHunterSummary >> printOn: aStream [
	aStream
		nextPutAll: self username;
		nextPutAll: ' (';
		print: self reportCount;
		nextPutAll: ' reports)'
]

{ #category : 'ui - profile' }
GtBugbopHunterSummary >> profileStats [
	"{ caption. value. color. object to spawn }"
	^ {{'reports'. self reportCount printString. Color fromHexString: '424242'. reports}.
		{'fixed'. self fixedCount printString. GtBugbopHunterLandscape signalColorFor: 1. reports withStatus: 'fixed'}.
		{'rejected'. self rejectedCount printString. GtBugbopHunterLandscape signalColorFor: 0. self rejectedReports}.
		{'still open'. self activeCount printString. Color fromHexString: '1565C0'. reports active}.
		{'signal'. self signalRatioString ifEmpty: [ 'n/a' ]. self signalColor. reports}.
		{'bounty'. self bountyAmountString ifEmpty: [ '$0' ]. Color fromHexString: '6A1B9A'. reports select: [ :each | each hasBounty ]}}
]

{ #category : 'gt - profile' }
GtBugbopHunterSummary >> profileSubtitle [
	| parts |
	parts := OrderedCollection new.
	parts add: (self reportCount printString , (self reportCount = 1 ifTrue: [ ' report' ] ifFalse: [ ' reports' ])).
	self highestSeverity ifNotNil: [ :aSeverity | parts add: 'highest severity ' , aSeverity ].
	self lastReportedAt ifNotNil: [ :aTime | parts add: 'last report ' , aTime asDate yyyymmdd ].
	^ '  -  ' join: parts
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> rejectedCount [
	"Duplicates, not applicable and won't fix"
	^ reports items count: [ :each | #('duplicate' 'not_applicable' 'wont_fix') includes: each status ]
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> rejectedReports [
	"Duplicates, not applicable and won't fix"
	^ reports select: [ :each | #('duplicate' 'not_applicable' 'wont_fix') includes: each status ]
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
GtBugbopHunterSummary >> resolvedCount [
	^ self fixedCount + self rejectedCount
]

{ #category : 'accessing' }
GtBugbopHunterSummary >> signalColor [
	"Signal color, neutral grey until enough reports are resolved to judge"
	self hasSignificantSignal ifFalse: [ ^ GtBugbopHunterLandscape signalColorFor: nil ].
	^ GtBugbopHunterLandscape signalColorFor: self signalRatio
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
