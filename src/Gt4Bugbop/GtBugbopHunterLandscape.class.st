"
I am a landscape of the bug hunters behind a group of Bugbop reports.

I answer *who* produces the volume and *who* produces the signal:
- 'Treemap' sizes each hunter by report count and colors them by signal ratio (fixed / resolved), red -> amber -> green, grey when nothing is resolved yet.
- 'Quadrant' plots volume against signal, bubble size = bounty earned, with guide lines splitting hunters into prolific & precise / sharpshooters / noisy / low impact.
- 'Severity profile' shows, per hunter, a stacked severity bar and a fixed vs rejected split.

Every mark is clickable and spawns the hunter summary (or the subset of reports) it represents.

Create me with: GtBugbopHunterLandscape forReports: aGtBugbopReportsGroup
"
Class {
	#name : 'GtBugbopHunterLandscape',
	#superclass : 'Object',
	#instVars : [
		'reports',
		'hunters'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'instance creation' }
GtBugbopHunterLandscape class >> forReports: aReportsGroup [
	^ self new reports: aReportsGroup
]

{ #category : 'ui - elements' }
GtBugbopHunterLandscape class >> makeSpawn: anElement object: anObject [
	"Clicking anElement spawns anObject in the next inspector pane"
	anElement
		when: BlClickEvent
		do: [ :anEvent | 
			anEvent consumed: true.
			anElement phlow spawnObject: anObject ].
	^ anElement
]

{ #category : 'palette' }
GtBugbopHunterLandscape class >> mutedTextColor [
	^ Color fromHexString: '757575'
]

{ #category : 'ui - elements' }
GtBugbopHunterLandscape class >> newCaption: aString [
	^ self newLabel: aString size: 11 color: self mutedTextColor
]

{ #category : 'ui - elements' }
GtBugbopHunterLandscape class >> newEmptyLabel: aString [
	^ (self newLabel: aString size: 14 color: self mutedTextColor)
		margin: (BlInsets all: 20)
]

{ #category : 'ui - elements' }
GtBugbopHunterLandscape class >> newHeading: aString size: aFontSize color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				bold;
				fontSize: aFontSize;
				foreground: aColor);
		text: aString
]

{ #category : 'ui - elements' }
GtBugbopHunterLandscape class >> newLabel: aString size: aFontSize color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				fontSize: aFontSize;
				foreground: aColor);
		text: aString
]

{ #category : 'ui - elements' }
GtBugbopHunterLandscape class >> newSeverityLegend [
	| legend |
	legend := BrHorizontalFlow new
			hMatchParent;
			vFitContent.
	GtBugbopReport severities
		do: [ :each | 
			legend
				addChild: (self
						newSwatch: (GtBugbopReport severityColorFor: each)
						label: (GtBugbopReport severityText: each) asString) ].
	^ legend
]

{ #category : 'ui - elements' }
GtBugbopHunterLandscape class >> newSeverityLegendCounting: aReportsGroup [
	"A severity legend whose entries show how many reports of aReportsGroup have that severity; entries spawn those reports"
	| legend |
	legend := BrHorizontalFlow new
			hMatchParent;
			vFitContent.
	GtBugbopReport severities
		do: [ :each | 
			| matching |
			matching := aReportsGroup withSeverity: each.
			legend
				addChild: (self
						makeSpawn: (self
								newSwatch: (GtBugbopReport severityColorFor: each)
								label: each , '  ' , matching size printString)
						object: matching) ].
	^ legend
]

{ #category : 'ui - elements' }
GtBugbopHunterLandscape class >> newSignalGradient [
	^ BlElement new
		size: 140 @ 12;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		margin: (BlInsets left: 5 right: 5);
		background: (BlLinearGradientPaint horizontal
				stops: {0 -> (self signalColorFor: 0).
						0.5 -> (self signalColorFor: 1 / 2).
						1 -> (self signalColorFor: 1)})
]

{ #category : 'ui - legends' }
GtBugbopHunterLandscape class >> newSignalLegend [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		addChild: (self newCaption: 'Signal (fixed / resolved):');
		addChild: (BrHorizontalPane new
				fitContent;
				alignCenterLeft;
				margin: (BlInsets left: 8 right: 14);
				addChild: (self newCaption: '0%');
				addChild: self newSignalGradient;
				addChild: (self newCaption: '100%'));
		addChild: (self newSwatch: (self signalColorFor: nil) label: 'fewer than ' , GtBugbopHunterSummary minimumSignalSample printString , ' resolved')
]

{ #category : 'ui - elements' }
GtBugbopHunterLandscape class >> newSwatch: aColor label: aString [
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets right: 14);
		addChild: (BlElement new
				size: 12 @ 12;
				background: aColor;
				geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
				margin: (BlInsets right: 5));
		addChild: (self newCaption: aString)
]

{ #category : 'palette' }
GtBugbopHunterLandscape class >> signalColorFor: aRatioOrNil [
	"Red (0%) -> amber (50%) -> green (100%); grey when nothing is resolved yet"
	| red amber green |
	aRatioOrNil ifNil: [ ^ Color fromHexString: '9E9E9E' ].
	red := Color fromHexString: 'C62828'.
	amber := Color fromHexString: 'F9A825'.
	green := Color fromHexString: '2E7D32'.
	aRatioOrNil < (1 / 2) ifTrue: [ ^ amber mixed: aRatioOrNil * 2 with: red ].
	^ green mixed: aRatioOrNil - (1 / 2) * 2 with: amber
]

{ #category : 'palette' }
GtBugbopHunterLandscape class >> textColorOn: aBackgroundColor [
	"Dark text on light backgrounds (amber), white otherwise"
	aBackgroundColor luminance > 0.55 ifTrue: [ ^ Color fromHexString: '212121' ].
	^ Color white
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> addBubblesOf: theHunters to: aCanvas [
	"Fan out hunters sharing a position; answer the bounds of the bubbles added"
	| center offset |
	center := self clusterCenterFor: theHunters.
	offset := self clusterOffsetFor: theHunters.
	^ theHunters
		withIndexCollect: [ :each :i | 
			| bubbleCenter radius |
			bubbleCenter := (center x - offset + (i - 1 * self clusterSpacing)) @ center y.
			radius := (self bubbleDiameterFor: each) / 2.
			aCanvas addChild: (self newBubbleFor: each at: bubbleCenter).
			(bubbleCenter - radius) corner: (bubbleCenter + radius) ]
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> addCluster: theHunters to: aCanvas [
	"Hunters sharing a position are fanned out horizontally and share one label"
	| center offset radius |
	center := (self xForCount: theHunters first reportCount) @ (self yForRatio: theHunters first signalRatio).
	offset := theHunters size - 1 / 2 * self clusterSpacing.
	radius := (theHunters inject: 0 into: [ :max :each | max max: (self bubbleDiameterFor: each) ]) / 2.
	theHunters
		withIndexDo: [ :each :i | 
			aCanvas
				addChild: (self newBubbleFor: each at: (center x - offset + (i - 1 * self clusterSpacing)) @ center y) ].
	aCanvas addChild: (self newClusterLabelFor: theHunters at: (center x + offset + radius + 6) @ (center y - 9))
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> addLabelOf: theHunters to: aCanvas avoiding: occupiedRectangles [
	| extent candidates position |
	extent := self estimatedLabelExtentFor: (self clusterLabelTextFor: theHunters).
	candidates := self labelCandidatesFor: theHunters extent: extent.
	position := candidates
			detect: [ :each | 
				| rect |
				rect := each extent: extent.
				(self quadrantPlotBounds containsRect: rect)
					and: [ occupiedRectangles noneSatisfy: [ :other | other intersects: rect ] ] ]
			ifNone: [ candidates first ].
	occupiedRectangles add: (position extent: extent).
	aCanvas addChild: (self newClusterLabelFor: theHunters at: position)
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> addQuadrantBubblesTo: aCanvas [
	"Bubbles first, then labels placed where they do not collide with bubbles or earlier labels"
	| clusters occupied |
	clusters := self quadrantClusters.
	occupied := OrderedCollection new.
	clusters do: [ :each | occupied addAll: (self addBubblesOf: each to: aCanvas) ].
	clusters do: [ :each | self addLabelOf: each to: aCanvas avoiding: occupied ]
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> addQuadrantGridTo: aCanvas [
	| b axis |
	b := self quadrantPlotBounds.
	axis := Color gray alpha: 0.6.
	aCanvas addChild: (self newLineFrom: b bottomLeft extent: b width @ 1 color: axis).
	aCanvas addChild: (self newLineFrom: b topLeft extent: 1 @ b height color: axis).
	#(0 25 50 75 100) do: [ :each | aCanvas addChild: (self newYTickLabel: each) ].
	self xTicks do: [ :each | aCanvas addChild: (self newXTickLabel: each) ].
	aCanvas addChild: ((self class newCaption: 'signal') relocate: (b left - 46) @ (b top - 20)).
	aCanvas addChild: ((self class newCaption: 'reports filed ->') relocate: (b right - 90) @ (b bottom + 24))
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> addQuadrantGuidesTo: aCanvas [
	| b x y guide |
	b := self quadrantPlotBounds.
	x := self xForCount: self volumeThreshold.
	y := self yForRatio: self signalThreshold.
	guide := Color gray alpha: 0.45.
	aCanvas addChild: (self newLineFrom: x @ b top extent: 1 @ b height color: guide).
	aCanvas addChild: (self newLineFrom: b left @ y extent: b width @ 1 color: guide).
	aCanvas
		addChild: ((self class
				newCaption: 'average ' , (self volumeThreshold printShowingDecimalPlaces: 1) , ' reports / hunter')
				relocate: (x + 4) @ (b top - 20))
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> addQuadrantRegionsTo: aCanvas [
	self quadrantRegions do: [ :each | aCanvas addChild: (self newQuadrantRegion: each) ]
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> bubbleDiameterFor: aHunter [
	"sqrt scale so bubble area tracks bounty; 14px when there is no bounty"
	| cents max |
	cents := aHunter reports bountyTotalCents.
	max := self maxBountyCents.
	(cents isZero or: [ max isZero ]) ifTrue: [ ^ 14 ].
	^ 16 + ((cents / max) sqrt * 26)
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> clusterCenterFor: theHunters [
	^ (self xForCount: theHunters first reportCount) @ (self yForRatio: theHunters first signalRatio)
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> clusterLabelTextFor: theHunters [
	^ ', ' join: (theHunters collect: [ :each | each username ])
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> clusterOffsetFor: theHunters [
	"Half the distance between the first and last bubble of a fanned-out cluster"
	^ theHunters size - 1 / 2 * self clusterSpacing
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> clusterRadiusFor: theHunters [
	^ (theHunters inject: 0 into: [ :max :each | max max: (self bubbleDiameterFor: each) ]) / 2
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> clusterSpacing [
	^ 20
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> estimatedLabelExtentFor: aString [
	"Approximate extent of a 12pt label, used for collision avoidance"
	^ (aString size * 6.8 + 6) @ 18
]

{ #category : 'gt - extensions' }
GtBugbopHunterLandscape >> gtQuadrantFor: aView [
	<gtView>
	^ aView explicit
		title: 'Quadrant';
		priority: 2;
		stencil: [ self newQuadrantPanel ]
]

{ #category : 'gt - extensions' }
GtBugbopHunterLandscape >> gtSeverityProfileFor: aView [
	<gtView>
	^ aView explicit
		title: 'Severity profile';
		priority: 3;
		stencil: [ self newSeverityProfilePanel ]
]

{ #category : 'gt - extensions' }
GtBugbopHunterLandscape >> gtTreemapFor: aView [
	<gtView>
	^ aView explicit
		title: 'Treemap';
		priority: 1;
		stencil: [ self newTreemapPanel ]
]

{ #category : 'ui - treemap' }
GtBugbopHunterLandscape >> hasRoomForDetails: aHunter [
	"Tiles holding at least 5% of all reports are large enough for larger type and detail lines"
	^ aHunter reportCount / (reports size max: 1) >= 0.05
]

{ #category : 'accessing' }
GtBugbopHunterLandscape >> hunterNamed: aUsername [
	^ self hunters detect: [ :each | each username = aUsername ] ifNone: [ nil ]
]

{ #category : 'accessing' }
GtBugbopHunterLandscape >> hunters [
	"Hunter summaries, most reports first"
	^ hunters ifNil: [ hunters := reports hunterSummaries ]
]

{ #category : 'quadrants' }
GtBugbopHunterLandscape >> huntersInQuadrant: aQuadrantName [
	^ self hunters select: [ :each | (self quadrantNameFor: each) = aQuadrantName ]
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> labelCandidatesFor: theHunters extent: anExtent [
	"Right, left, above, below the cluster"
	| center halfWidth radius |
	center := self clusterCenterFor: theHunters.
	radius := self clusterRadiusFor: theHunters.
	halfWidth := (self clusterOffsetFor: theHunters) + radius.
	^ {(center x + halfWidth + 6) @ (center y - 9).
		(center x - halfWidth - 6 - anExtent x) @ (center y - 9).
		(center x - (anExtent x / 2)) @ (center y - radius - anExtent y).
		(center x - (anExtent x / 2)) @ (center y + radius + 1)}
]

{ #category : 'accessing' }
GtBugbopHunterLandscape >> maxBountyCents [
	^ self hunters inject: 0 into: [ :max :each | max max: each reports bountyTotalCents ]
]

{ #category : 'accessing' }
GtBugbopHunterLandscape >> maxReportCount [
	^ self hunters inject: 0 into: [ :max :each | max max: each reportCount ]
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> newBubbleFor: aHunter at: aCenter [
	| diameter color bubble |
	diameter := self bubbleDiameterFor: aHunter.
	color := aHunter signalColor.
	bubble := BrFrame new
			size: diameter @ diameter;
			geometry: BlCircleGeometry new;
			background: (aHunter reports bountyTotalCents isZero
					ifTrue: [ Color white ]
					ifFalse: [ color alpha: 0.8 ]);
			border: (BlBorder paint: color width: 2);
			aptitude: (BrGlamorousWithLabelTooltipAptitude new text: (self tooltipFor: aHunter));
			relocate: aCenter - (diameter / 2).
	^ self class makeSpawn: bubble object: aHunter
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> newClusterLabelFor: theHunters at: aPoint [
	| label |
	label := (self class
			newLabel: (', ' join: (theHunters collect: [ :each | each username ]))
			size: 12
			color: (Color fromHexString: '212121'))
			relocate: aPoint.
	^ self class
		makeSpawn: label
		object: (theHunters size = 1
				ifTrue: [ theHunters first ]
				ifFalse: [ GtBugbopHunterSummariesGroup withAll: theHunters ])
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> newHunterChipFor: aHunter [
	| chip |
	chip := BrHorizontalPane new
			fitContent;
			padding: (BlInsets top: 2 left: 8 bottom: 2 right: 8);
			margin: (BlInsets top: 0 left: 0 bottom: 4 right: 6);
			geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
			background: (aHunter signalColor alpha: 0.2);
			aptitude: (BrGlamorousWithLabelTooltipAptitude new text: (self tooltipFor: aHunter));
			addChild: (self class
					newLabel: aHunter username , ' (' , aHunter reportCount printString , ')'
					size: 11
					color: (Color fromHexString: '424242')).
	^ self class makeSpawn: chip object: aHunter
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> newLineFrom: aPoint extent: anExtent color: aColor [
	^ BlElement new
		size: anExtent;
		background: aColor;
		preventMouseEvents;
		relocate: aPoint
]

{ #category : 'ui - severity profile' }
GtBugbopHunterLandscape >> newOutcomeBarFor: aHunter [
	| bar total |
	total := aHunter reportCount max: 1.
	bar := BrHorizontalPane new
			size: 80 @ 10;
			clipChildren: true;
			geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
			background: (Color gray alpha: 0.15).
	{aHunter fixedCount -> (self class signalColorFor: 1).
		aHunter rejectedCount -> (self class signalColorFor: 0)}
		do: [ :each | 
			bar
				addChild: (BlElement new
						size: (each key / total * 80) asFloat @ 10;
						background: each value) ].
	^ bar
		aptitude: (BrGlamorousWithLabelTooltipAptitude new
				text: aHunter fixedCount printString , ' fixed, ' , aHunter rejectedCount printString
						, ' rejected, ' , aHunter activeCount printString , ' still open')
]

{ #category : 'ui - severity profile' }
GtBugbopHunterLandscape >> newOutcomeSplitFor: aHunter [
	"A mini bar of fixed (green) vs rejected (red) out of all reports, plus the counts"
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets top: 3 bottom: 3);
		addChild: (self newOutcomeBarFor: aHunter);
		addChild: ((self class
				newCaption: aHunter fixedCount printString , ' / ' , aHunter rejectedCount printString)
				margin: (BlInsets left: 8))
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> newQuadrantCanvas [
	| canvas |
	canvas := BlElement new
			size: self quadrantPlotBounds corner + (190 @ 44);
			clipChildren: false.
	self addQuadrantRegionsTo: canvas.
	self addQuadrantGridTo: canvas.
	self addQuadrantGuidesTo: canvas.
	self addQuadrantBubblesTo: canvas.
	^ canvas
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> newQuadrantPanel [
	self hunters ifEmpty: [ ^ self class newEmptyLabel: 'No hunters yet - there are no reports in this group.' ].
	^ BrVerticalPane new
		matchParent;
		padding: (BlInsets all: 12);
		addChild: (self class newCaption: 'Volume vs signal  -  bubble size = bounty earned (hollow = none)  -  click a bubble, name or quadrant');
		addChild: (self class newSignalLegend margin: (BlInsets top: 6 bottom: 4));
		addChild: (self newQuadrantCanvas asScrollableElement
				constraintsDo: [ :c | 
					c horizontal matchParent.
					c vertical fitContent ]);
		addChild: self newUnresolvedStrip
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> newQuadrantRegion: anAssociation [
	"A tinted, clickable quadrant with its caption in the outer corner"
	| bounds tint region |
	bounds := anAssociation value second.
	tint := anAssociation value third.
	region := BrVerticalPane new
			size: bounds extent;
			padding: (BlInsets top: 8 left: 10 bottom: 8 right: 10);
			background: (tint mixed: 0.07 with: Color white);
			addChild: (self class newHeading: anAssociation key size: 13 color: tint);
			addChild: (self class newLabel: anAssociation value first size: 10 color: (tint alpha: 0.75)).
	bounds top > self quadrantOrigin y ifTrue: [ region alignBottomLeft ].
	region relocate: bounds origin.
	^ self class makeSpawn: region object: (self huntersInQuadrant: anAssociation key)
]

{ #category : 'ui - severity profile' }
GtBugbopHunterLandscape >> newSeverityBarFor: aHunter [
	^ (GtBugbopSeverityBarStencil new
		reports: aHunter reports;
		maxCount: self maxReportCount;
		maxWidth: self severityBarWidth;
		barHeight: 16) asElement
		margin: (BlInsets top: 3 bottom: 3)
]

{ #category : 'ui - severity profile' }
GtBugbopHunterLandscape >> newSeverityProfileLegend [
	^ self class newSeverityLegend
		addChild: ((self class newCaption: '|') margin: (BlInsets right: 14));
		addChild: (self class newSwatch: (self class signalColorFor: 1) label: 'fixed');
		addChild: (self class newSwatch: (self class signalColorFor: 0) label: 'rejected');
		addChild: (self class newSwatch: (Color gray alpha: 0.15) label: 'still open');
		yourself
]

{ #category : 'ui - severity profile' }
GtBugbopHunterLandscape >> newSeverityProfileList [
	^ GtPhlowColumnedListView new
		items: [ self hunters items ];
		column: 'Hunter' text: [ :each | each username asRopedText bold ] width: 150;
		column: 'By severity' stencil: [ :each | self newSeverityBarFor: each ] width: self severityBarWidth + 20;
		column: 'Total' text: [ :each | each reportCount ] width: 50;
		column: 'Fixed / rejected' stencil: [ :each | self newOutcomeSplitFor: each ] width: 170;
		column: 'Highest' text: [ :each | GtBugbopReport severityText: each highestSeverity ] width: 80;
		send: [ :each | each ];
		asElement
]

{ #category : 'ui - severity profile' }
GtBugbopHunterLandscape >> newSeverityProfilePanel [
	self hunters ifEmpty: [ ^ self class newEmptyLabel: 'No hunters yet - there are no reports in this group.' ].
	^ BrVerticalPane new
		matchParent;
		padding: (BlInsets top: 12 left: 12 bottom: 0 right: 12);
		addChild: (self class newCaption: 'Reports per hunter by severity, on a shared scale  -  click a segment for those reports, a row for the hunter');
		addChild: (self newSeverityProfileLegend margin: (BlInsets top: 6 bottom: 6));
		addChild: self newSeverityProfileList
]

{ #category : 'ui - treemap' }
GtBugbopHunterLandscape >> newTileLabel: aString size: aFontSize on: aBackgroundColor [
	"Lines of 14pt and above are headings and rendered bold"
	| aptitude |
	aptitude := BrGlamorousLabelAptitude new
			fontSize: aFontSize;
			foreground: (self class textColorOn: aBackgroundColor).
	aFontSize >= 14 ifTrue: [ aptitude bold ].
	^ BrLabel new
		aptitude: aptitude;
		text: aString;
		margin: (BlInsets bottom: 2)
]

{ #category : 'ui - treemap' }
GtBugbopHunterLandscape >> newTreemap [
	^ BlElement new
		layout: GtGraphTreemapLayout squarify;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ];
		addChildren: (self hunters collect: [ :each | self newTreemapTileFor: each ])
]

{ #category : 'ui - treemap' }
GtBugbopHunterLandscape >> newTreemapPanel [
	self hunters ifEmpty: [ ^ self class newEmptyLabel: 'No hunters yet - there are no reports in this group.' ].
	^ BrVerticalPane new
		matchParent;
		padding: (BlInsets all: 12);
		addChild: (self class newCaption: 'Area = reports filed  -  color = signal ratio  -  click a tile to open the hunter');
		addChild: (self class newSignalLegend margin: (BlInsets top: 6 bottom: 8));
		addChild: self newTreemap
]

{ #category : 'ui - treemap' }
GtBugbopHunterLandscape >> newTreemapTileFor: aHunter [
	| color tile |
	color := aHunter signalColor.
	tile := BrVerticalPane new
			background: color;
			geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
			padding: (BlInsets top: 8 left: 10 bottom: 6 right: 6);
			clipChildren: true;
			aptitude: (BrGlamorousWithLabelTooltipAptitude new text: (self tooltipFor: aHunter));
			constraintsDo: [ :c | 
				c horizontal matchParent.
				c vertical matchParent.
				c margin: (BlInsets all: 2).
				c treemap weight: aHunter reportCount ].
	(self tileLinesFor: aHunter)
		do: [ :each | tile addChild: (self newTileLabel: each value size: each key on: color) ].
	^ self class makeSpawn: tile object: aHunter
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> newUnresolvedStrip [
	| strip |
	strip := BrHorizontalFlow new
			hMatchParent;
			vFitContent;
			margin: (BlInsets top: 8).
	self unresolvedHunters ifEmpty: [ ^ strip ].
	strip addChild: ((self class newCaption: 'Awaiting resolution (no signal yet):') margin: (BlInsets right: 8)).
	self unresolvedHunters do: [ :each | strip addChild: (self newHunterChipFor: each) ].
	^ strip
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> newXTickLabel: aCount [
	^ BrHorizontalPane new
		size: 30 @ 16;
		alignCenter;
		addChild: (self class newCaption: aCount printString);
		relocate: ((self xForCount: aCount) - 15) @ (self quadrantPlotBounds bottom + 4)
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> newYTickLabel: aPercent [
	^ BrHorizontalPane new
		size: 40 @ 16;
		alignCenterRight;
		addChild: (self class newCaption: aPercent printString , '%');
		relocate: (self quadrantOrigin x - 46) @ ((self yForRatio: aPercent / 100) - 8)
]

{ #category : 'printing' }
GtBugbopHunterLandscape >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		print: self hunters size;
		nextPutAll: ' hunters, ';
		print: reports size;
		nextPutAll: ' reports)'
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> quadrantClusters [
	"Resolved hunters grouped by identical (reports, signal) position, ordered by position"
	^ ((self resolvedHunters items groupedBy: [ :each | each reportCount -> each signalRatio ])
		associations sorted: [ :a :b | 
			a key key < b key key
				or: [ a key key = b key key and: [ a key value <= b key value ] ] ])
		collect: [ :each | each value asArray ]
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> quadrantInset [
	"Inner padding (x @ y) keeping bubbles at the extremes inside the plot and clear of the quadrant captions"
	^ 30 @ 66
]

{ #category : 'quadrants' }
GtBugbopHunterLandscape >> quadrantNameFor: aHunter [
	| prolific precise |
	aHunter signalRatio ifNil: [ ^ 'Awaiting resolution' ].
	prolific := aHunter reportCount >= self volumeThreshold.
	precise := aHunter signalRatio >= self signalThreshold.
	^ self quadrantNameProlific: prolific precise: precise
]

{ #category : 'quadrants' }
GtBugbopHunterLandscape >> quadrantNameProlific: isProlific precise: isPrecise [
	(isProlific and: [ isPrecise ]) ifTrue: [ ^ 'Prolific & precise' ].
	isPrecise ifTrue: [ ^ 'Sharpshooters' ].
	isProlific ifTrue: [ ^ 'Noisy' ].
	^ 'Low impact'
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> quadrantOrigin [
	"Top-left corner of the plot area inside the canvas"
	^ 56 @ 30
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> quadrantPlotBounds [
	^ self quadrantOrigin extent: self quadrantPlotExtent
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> quadrantPlotExtent [
	^ 760 @ 460
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> quadrantRegions [
	"name -> { subtitle. bounds. tint }"
	| b split |
	b := self quadrantPlotBounds.
	split := (self xForCount: self volumeThreshold) @ (self yForRatio: self signalThreshold).
	^ {'Sharpshooters' -> {'few reports, mostly valid'. b origin corner: split. Color fromHexString: '1565C0'}.
		'Prolific & precise' -> {'many reports, mostly valid'. (split x @ b top) corner: (b right @ split y). Color fromHexString: '2E7D32'}.
		'Low impact' -> {'few reports, mostly rejected'. (b left @ split y) corner: (split x @ b bottom). Color fromHexString: '757575'}.
		'Noisy' -> {'many reports, mostly rejected'. split corner: b corner. Color fromHexString: 'C62828'}}
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> quadrantXMax [
	^ self maxReportCount + 1
]

{ #category : 'ui - treemap' }
GtBugbopHunterLandscape >> reportCountString: aCount [
	^ aCount printString , (aCount = 1 ifTrue: [ ' report' ] ifFalse: [ ' reports' ])
]

{ #category : 'accessing' }
GtBugbopHunterLandscape >> reports [
	^ reports
]

{ #category : 'accessing' }
GtBugbopHunterLandscape >> reports: aReportsGroup [
	reports := aReportsGroup.
	hunters := nil
]

{ #category : 'accessing' }
GtBugbopHunterLandscape >> resolvedHunters [
	"Hunters with at least one fixed or rejected report, i.e. with a signal ratio"
	^ self hunters select: [ :each | each signalRatio notNil ]
]

{ #category : 'ui - severity profile' }
GtBugbopHunterLandscape >> severityBarWidth [
	^ 320
]

{ #category : 'quadrants' }
GtBugbopHunterLandscape >> signalThreshold [
	^ 1 / 2
]

{ #category : 'ui - treemap' }
GtBugbopHunterLandscape >> tileLinesFor: aHunter [
	"fontSize -> text lines for a tile; larger type and detail lines on tiles with room for them"
	| lines roomy |
	roomy := self hasRoomForDetails: aHunter.
	lines := OrderedCollection new.
	lines add: (roomy ifTrue: [ 20 ] ifFalse: [ 14 ]) -> aHunter username.
	lines add: (roomy ifTrue: [ 13 ] ifFalse: [ 11 ]) -> (self reportCountString: aHunter reportCount).
	roomy ifFalse: [ ^ lines ].
	aHunter signalRatio ifNotNil: [ lines add: 13 -> (aHunter signalRatioString , ' signal') ].
	aHunter bountyAmountString ifNotEmpty: [ :s | lines add: 13 -> (s , ' bounty') ].
	^ lines
]

{ #category : 'ui - treemap' }
GtBugbopHunterLandscape >> tooltipFor: aHunter [
	^ String
		streamContents: [ :aStream | 
			aStream
				nextPutAll: aHunter username;
				nextPutAll: ' - ';
				nextPutAll: (self reportCountString: aHunter reportCount);
				nextPutAll: ', ';
				print: aHunter fixedCount;
				nextPutAll: ' fixed, ';
				print: aHunter rejectedCount;
				nextPutAll: ' rejected, signal ';
				nextPutAll: (aHunter signalRatioString ifEmpty: [ 'n/a' ]);
				nextPutAll: (aHunter bountyAmountString ifEmpty: [ '' ] ifNotEmpty: [ :s | ', bounty ' , s ]) ]
]

{ #category : 'accessing' }
GtBugbopHunterLandscape >> unresolvedHunters [
	^ self hunters select: [ :each | each signalRatio isNil ]
]

{ #category : 'quadrants' }
GtBugbopHunterLandscape >> volumeThreshold [
	"Mean number of reports per hunter; at or above it a hunter counts as high-volume"
	self hunters ifEmpty: [ ^ 0 ].
	^ reports size / self hunters size
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> xForCount: aNumber [
	| span |
	span := self quadrantPlotExtent x - (2 * self quadrantInset x).
	^ (self quadrantOrigin x + self quadrantInset x + (aNumber / self quadrantXMax * span)) asFloat
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> xTicks [
	| step |
	step := (self quadrantXMax / 8) ceiling max: 1.
	^ (0 to: self quadrantXMax by: step) asArray
]

{ #category : 'ui - quadrant' }
GtBugbopHunterLandscape >> yForRatio: aRatio [
	| span |
	span := self quadrantPlotExtent y - (2 * self quadrantInset y).
	^ (self quadrantOrigin y + self quadrantInset y + ((1 - aRatio) * span)) asFloat
]
