"
I review how Bugbop's AI triage compares with the severity staff actually assigned.

For each report I compare {{gtMethod:GtBugbopReport>>#aiSeverity}} (AI-suggested) with {{gtMethod:GtBugbopReport>>#severity}} (assigned). I answer the agreement rate, the disagreements sorted by how far apart the two are, and groups of reports the AI rated higher (possible under-rating) or lower (possible over-rating).

Create me with `GtBugbopAiTriageReview forReports: aGtBugbopReportsGroup`.

Views: an agreement (confusion) matrix, a disagreements list with assigned -> AI severity pills, and a skimmable list of AI triage summaries.
"
Class {
	#name : 'GtBugbopAiTriageReview',
	#superclass : 'Object',
	#instVars : [
		'reports'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'instance creation' }
GtBugbopAiTriageReview class >> forReports: aGtBugbopReportsGroup [
	^ self new reports: aGtBugbopReportsGroup
]

{ #category : 'ui - colors' }
GtBugbopAiTriageReview >> agreeColor [
	^ Color fromHexString: '2E7D32'
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> agreementCountString [
	^ self agreements size printString , ' of ' , self ratedReports size printString
		, ' AI-rated reports (' , reports size printString , ' total)'
]

{ #category : 'computing' }
GtBugbopAiTriageReview >> agreementPercentString [
	self ratedReports ifEmpty: [ ^ '-' ].
	^ (self agreementRate * 100) rounded printString , '%'
]

{ #category : 'computing' }
GtBugbopAiTriageReview >> agreementRate [
	"Fraction (0..1) of AI-rated reports whose assigned severity matches the AI"
	| rated |
	rated := self ratedReports size.
	rated isZero ifTrue: [ ^ 0 ].
	^ self agreements size / rated
]

{ #category : 'ui - colors' }
GtBugbopAiTriageReview >> agreementRateColor [
	self agreementRate >= (3/4) ifTrue: [ ^ self agreeColor ].
	self agreementRate >= (1/2) ifTrue: [ ^ self nearMissColor ].
	^ self farMissColor
]

{ #category : 'accessing' }
GtBugbopAiTriageReview >> agreements [
	^ self ratedReports select: [ :each | each aiSeverity = each severity ]
]

{ #category : 'computing' }
GtBugbopAiTriageReview >> aiLiftOf: aReport [
	"How many severity levels the AI places this report above the assigned one.
	Positive: AI more severe (possible under-rating). Negative: AI less severe. 0 without a suggestion."
	aReport aiSeverity ifNil: [ ^ 0 ].
	^ (GtBugbopReport severityRankOf: aReport severity)
		- (GtBugbopReport severityRankOf: aReport aiSeverity)
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> cellBackgroundFor: aColor count: aCount max: aMax [
	"A tint of aColor blended towards white; populated cells get stronger with their count.
	Empty cells stay neutral, except the diagonal which keeps a faint green guide line"
	aCount isZero ifFalse: [ ^ aColor mixed: (self cellIntensityFor: aCount max: aMax) with: Color white ].
	aColor = self agreeColor ifTrue: [ ^ aColor mixed: 0.1 with: Color white ].
	^ Color fromHexString: 'F5F5F5'
]

{ #category : 'ui - colors' }
GtBugbopAiTriageReview >> cellColorForAssigned: aSeverity suggested: anAiSeverityOrNil [
	"Green on the diagonal, orange one level off, red further off, grey without AI"
	| distance |
	anAiSeverityOrNil ifNil: [ ^ self noneColor ].
	distance := ((GtBugbopReport severityRankOf: aSeverity)
			- (GtBugbopReport severityRankOf: anAiSeverityOrNil)) abs.
	distance isZero ifTrue: [ ^ self agreeColor ].
	distance = 1 ifTrue: [ ^ self nearMissColor ].
	^ self farMissColor
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> cellIntensityFor: aCount max: aMax [
	"Share of the cell color (vs white): 0.35..1 for populated cells"
	aCount isZero ifTrue: [ ^ 0 ].
	^ (0.35 + (0.65 * aCount / aMax)) asFloat
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> cellSize [
	^ 84 @ 68
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> cellTooltipFor: aGroup assigned: aSeverity suggested: anAiSeverityOrNil [
	^ String streamContents: [ :aStream | 
		aStream
			print: aGroup size;
			nextPutAll: (aGroup size = 1 ifTrue: [ ' report' ] ifFalse: [ ' reports' ]);
			nextPutAll: ': assigned ';
			nextPutAll: aSeverity;
			nextPutAll: ', AI suggested ';
			nextPutAll: (anAiSeverityOrNil ifNil: [ 'nothing' ]) ]
]

{ #category : 'accessing' }
GtBugbopAiTriageReview >> disagreements [
	"Rated reports where the AI disagrees, the widest gaps first"
	| aList |
	aList := (self ratedReports reject: [ :each | each aiSeverity = each severity ]) items
			asSortedCollection: [ :a :b | (self severityDistance: a) >= (self severityDistance: b) ].
	^ reports species withAll: aList asArray
]

{ #category : 'ui - colors' }
GtBugbopAiTriageReview >> farMissColor [
	^ Color fromHexString: 'C62828'
]

{ #category : 'ui - views' }
GtBugbopAiTriageReview >> gtAgreementMatrixFor: aView [
	<gtView>
	reports ifNil: [ ^ aView empty ].
	^ aView explicit
		title: 'Agreement matrix';
		priority: 1;
		stencil: [ self newAgreementMatrixElement asScrollableElement ]
]

{ #category : 'ui - views' }
GtBugbopAiTriageReview >> gtAiTriageFor: aView [
	<gtView>
	reports ifNil: [ ^ aView empty ].
	self triagedReports ifEmpty: [ 
		^ aView explicit
			title: 'AI triage';
			priority: 3;
			stencil: [ self newEmptyStateLabel: 'No AI triage write-ups available.' ] ].
	^ aView columnedList
		title: 'AI triage';
		priority: 3;
		items: [ self triagedReports items ];
		column: 'AI' stencil: [ :each | (self newSeverityPill: each aiSeverity) margin: (BlInsets top: 6) ] width: 90;
		column: 'Report and AI summary' stencil: [ :each | self newTriageCellFor: each ] weight: 1;
		column: 'Match' text: [ :each | self matchTextFor: each ] width: 140;
		column: 'Scope' text: [ :each | self scopeTextFor: each ] width: 100;
		send: [ :each | each ]
]

{ #category : 'ui - views' }
GtBugbopAiTriageReview >> gtDisagreementsFor: aView [
	<gtView>
	reports ifNil: [ ^ aView empty ].
	self disagreements ifEmpty: [ 
		^ aView explicit
			title: 'Disagreements';
			priority: 2;
			stencil: [ self newEmptyStateLabel: 'No disagreements: the AI agrees with every assigned severity.' ] ].
	^ aView columnedList
		title: 'Disagreements';
		priority: 2;
		items: [ self disagreements items ];
		column: 'Assigned → AI suggested' stencil: [ :each | self newSeverityShiftFor: each ] width: 290;
		column: 'Report' text: [ :each | each title ] weight: 1;
		column: 'Hunter' text: [ :each | each reporterName ifNil: [ '' ] ] width: 110;
		column: 'Status' text: [ :each | GtBugbopReport statusText: each status ] width: 110;
		send: [ :each | each ]
]

{ #category : 'ui - actions' }
GtBugbopAiTriageReview >> gtUnderRatedActionFor: anAction [
	<gtAction>
	reports ifNil: [ ^ anAction noAction ].
	^ anAction button
		label: 'AI higher';
		tooltip: 'Inspect reports the AI rated more severe than assigned (possible under-rating)';
		priority: 10;
		action: [ :aButton | aButton phlow spawnObject: self underRated ]
]

{ #category : 'ui - elements' }
GtBugbopAiTriageReview >> makeClickable: anElement spawning: aBlock [
	"Clicking the element spawns the object answered by aBlock"
	anElement when: BlClickEvent do: [ :anEvent | 
		anEvent consumed: true.
		anElement phlow spawnObject: aBlock value ].
	^ anElement
]

{ #category : 'ui - triage' }
GtBugbopAiTriageReview >> matchTextFor: aReport [
	aReport aiSeverity ifNil: [ ^ '' asRopedText ].
	aReport aiSeverity = aReport severity
		ifTrue: [ ^ '✓ agrees' asRopedText foreground: self agreeColor ].
	^ ('≠ assigned ' , aReport severity) asRopedText foreground: self nearMissColor
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> matrixColumns [
	"AI-suggested severities, plus nil for reports without a suggestion"
	^ GtBugbopReport severities copyWith: nil
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> maxCellCount [
	| counts |
	counts := GtBugbopReport severities
			flatCollect: [ :aSeverity | 
				self matrixColumns
					collect: [ :anAi | (self reportsAssigned: aSeverity suggested: anAi) size ] ].
	^ counts inject: 1 into: [ :max :each | max max: each ]
]

{ #category : 'ui - colors' }
GtBugbopAiTriageReview >> mutedColor [
	^ Color fromHexString: '616161'
]

{ #category : 'ui - colors' }
GtBugbopAiTriageReview >> nearMissColor [
	^ Color fromHexString: 'EF6C00'
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newAgreementHeader [
	| aRate aText |
	aRate := (self newBoldLabel: self agreementPercentString size: 60 color: self agreementRateColor)
			margin: (BlInsets right: 20).
	aText := BrVerticalPane new
			fitContent;
			addChild: (self newBoldLabel: 'AI and staff agree on severity' size: 18 color: Color black);
			addChild: (self newLabel: self agreementCountString size: 13 color: self mutedColor);
			addChild: self newSummaryChips.
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets bottom: 24);
		addChild: (self makeClickable: aRate spawning: [ self agreements ]);
		addChild: aText
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newAgreementMatrixElement [
	reports ifEmpty: [ ^ self newEmptyStateLabel: 'No reports to review.' ].
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 20);
		addChild: self newAgreementHeader;
		addChild: self newColumnAxisTitle;
		addChild: self newMatrixGrid;
		addChild: self newLegend
]

{ #category : 'ui - elements' }
GtBugbopAiTriageReview >> newBoldLabel: aString size: aFontSize color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				glamorousRegularFont;
				bold;
				fontSize: aFontSize;
				foreground: aColor);
		text: aString
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newChip: aString color: aColor spawning: aBlock [
	| aChip |
	aChip := (self newBoldLabel: aString size: 12 color: aColor)
			background: (aColor mixed: 0.12 with: Color white);
			border: (BlBorder paint: (aColor mixed: 0.35 with: Color white) width: 1);
			geometry: (BlRoundedRectangleGeometry cornerRadius: 11);
			padding: (BlInsets top: 3 left: 10 bottom: 3 right: 10);
			margin: (BlInsets right: 6).
	^ self makeClickable: aChip spawning: aBlock
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newColumnAxisTitle [
	"'AI suggested' centered above the matrix columns"
	^ BrHorizontalPane new
		fitContent;
		padding: (BlInsets left: self rowHeaderWidth);
		addChild: ((self newHeaderCell: (self newBoldLabel: 'AI suggested →' size: 12 color: self mutedColor) width: (self cellSize x + 6) * self matrixColumns size) height: 22)
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newColumnHeaderFor: anAiSeverityOrNil [
	^ (self
		newHeaderCell: (self newSeverityPill: anAiSeverityOrNil)
		width: self cellSize x + 6) height: 30
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newCountLabel: aCount color: aColor intensity: anIntensity [
	| aLabel |
	aLabel := aCount isZero
			ifTrue: [ self newLabel: '0' size: 14 color: (Color fromHexString: 'BDBDBD') ]
			ifFalse: [ self
					newBoldLabel: aCount printString
					size: 26
					color: (anIntensity > 0.6 ifTrue: [ Color white ] ifFalse: [ aColor muchDarker ]) ].
	^ aLabel
		constraintsDo: [ :c | 
			c frame horizontal alignCenter.
			c frame vertical alignCenter ]
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newEmptyStateLabel: aString [
	^ (self newLabel: aString size: 14 color: self mutedColor)
		padding: (BlInsets all: 20)
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newHeaderCell: anElement width: aWidth [
	"A fixed-size frame centering anElement, used for row and column headers"
	^ BrFrame new
		size: aWidth @ (self cellSize y + 6);
		addChild: (anElement
				constraintsDo: [ :c | 
					c frame horizontal alignCenter.
					c frame vertical alignCenter ])
]

{ #category : 'ui - elements' }
GtBugbopAiTriageReview >> newLabel: aString size: aFontSize color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				glamorousRegularFont;
				fontSize: aFontSize;
				foreground: aColor);
		text: aString
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newLegend [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		margin: (BlInsets top: 16);
		addChild: (self newLegendItem: 'Agree' color: self agreeColor);
		addChild: (self newLegendItem: 'Off by 1 level' color: self nearMissColor);
		addChild: (self newLegendItem: 'Off by 2+ levels' color: self farMissColor);
		addChild: (self newLegendItem: 'No AI suggestion' color: self noneColor);
		addChild: (self newLabel: 'Left of the diagonal: AI rated higher. Stronger color = more reports. Click a cell to open its reports.' size: 12 color: self mutedColor)
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newLegendItem: aString color: aColor [
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets top: 0 left: 0 bottom: 4 right: 16);
		addChild: (BlElement new
				size: 14 @ 14;
				margin: (BlInsets right: 6);
				geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
				background: aColor);
		addChild: (self newLabel: aString size: 12 color: self mutedColor)
]

{ #category : 'ui - disagreements' }
GtBugbopAiTriageReview >> newLiftIndicatorFor: aReport [
	"Up arrow when the AI rates higher (possible under-rating), down arrow when lower"
	| aLift |
	aLift := self aiLiftOf: aReport.
	aLift > 0 ifTrue: [
		^ self newChip: '▲ +' , aLift printString , ' AI higher' color: self farMissColor spawning: [ aReport ] ].
	^ self newChip: '▼ ' , aLift printString , ' AI lower' color: (Color fromHexString: '1565C0') spawning: [ aReport ]
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newMatrixCellAssigned: aSeverity suggested: anAiSeverityOrNil max: aMax [
	| aGroup aColor aCell |
	aGroup := self reportsAssigned: aSeverity suggested: anAiSeverityOrNil.
	aColor := self cellColorForAssigned: aSeverity suggested: anAiSeverityOrNil.
	aCell := BrFrame new
			size: self cellSize;
			margin: (BlInsets all: 3);
			geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
			background: (self cellBackgroundFor: aColor count: aGroup size max: aMax);
			aptitude: (BrGlamorousWithLabelTooltipAptitude new
					text: (self cellTooltipFor: aGroup assigned: aSeverity suggested: anAiSeverityOrNil));
			addChild: (self newCountLabel: aGroup size color: aColor intensity: (self cellIntensityFor: aGroup size max: aMax)).
	aGroup ifEmpty: [ ^ aCell ].
	^ self makeClickable: aCell spawning: [ aGroup ]
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newMatrixGrid [
	| aGrid aMax |
	aMax := self maxCellCount.
	aGrid := BlElement new
			layout: (BlGridLayout new columnCount: self matrixColumns size + 1);
			constraintsDo: [ :c | 
				c horizontal fitContent.
				c vertical fitContent ].
	aGrid addChild: ((self newHeaderCell: (self newBoldLabel: 'Assigned ↓' size: 12 color: self mutedColor) width: self rowHeaderWidth) height: 30).
	self matrixColumns do: [ :anAi | aGrid addChild: (self newColumnHeaderFor: anAi) ].
	GtBugbopReport severities do: [ :aSeverity | 
		aGrid addChild: (self newRowHeaderFor: aSeverity).
		self matrixColumns do: [ :anAi | 
			aGrid addChild: (self newMatrixCellAssigned: aSeverity suggested: anAi max: aMax) ] ].
	^ aGrid
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newRowHeaderFor: aSeverity [
	| aGroup |
	aGroup := reports withSeverity: aSeverity.
	^ self
		makeClickable: (self newHeaderCell: (self newSeverityPill: aSeverity) width: self rowHeaderWidth)
		spawning: [ aGroup ]
]

{ #category : 'ui - elements' }
GtBugbopAiTriageReview >> newSeverityPill: aSeverityOrNil [
	"A rounded, colored severity badge; 'none' in grey when there is no severity"
	^ (self newBoldLabel: (aSeverityOrNil ifNil: [ 'none' ]) size: 12 color: Color white)
		background: (self pillColorFor: aSeverityOrNil);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		padding: (BlInsets top: 2 left: 10 bottom: 2 right: 10)
]

{ #category : 'ui - disagreements' }
GtBugbopAiTriageReview >> newSeverityShiftFor: aReport [
	"assigned pill -> AI pill, followed by the direction indicator"
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		padding: (BlInsets top: 3 bottom: 3);
		addChild: (self newSeverityPill: aReport severity);
		addChild: ((self newBoldLabel: '→' size: 14 color: self mutedColor) margin: (BlInsets left: 6 right: 6));
		addChild: (self newSeverityPill: aReport aiSeverity);
		addChild: ((self newLiftIndicatorFor: aReport) margin: (BlInsets left: 12))
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> newSummaryChips [
	^ BrHorizontalPane new
		fitContent;
		margin: (BlInsets top: 8);
		addChild: (self newChip: '▲ ' , self underRated size printString , ' AI rated higher' color: self farMissColor spawning: [ self underRated ]);
		addChild: (self newChip: '▼ ' , self overRated size printString , ' AI rated lower' color: (Color fromHexString: '1565C0') spawning: [ self overRated ]);
		addChild: (self newChip: self unratedReports size printString , ' without AI rating' color: self noneColor spawning: [ self unratedReports ])
]

{ #category : 'ui - triage' }
GtBugbopAiTriageReview >> newTriageCellFor: aReport [
	"Report title in bold over the first line of the AI write-up"
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 4 bottom: 4);
		addChild: (self newBoldLabel: (self truncated: aReport title to: 110) size: 13 color: Color black);
		addChild: (self newLabel: (self truncated: (self triageSummaryOf: aReport) to: 160) size: 12 color: self mutedColor)
]

{ #category : 'ui - colors' }
GtBugbopAiTriageReview >> noneColor [
	^ Color fromHexString: '78909C'
]

{ #category : 'accessing' }
GtBugbopAiTriageReview >> overRated [
	"The AI considers these less severe than assigned: possible over-rating"
	^ self disagreements select: [ :each | (self aiLiftOf: each) < 0 ]
]

{ #category : 'ui - elements' }
GtBugbopAiTriageReview >> pillColorFor: aSeverityOrNil [
	aSeverityOrNil ifNil: [ ^ self noneColor ].
	^ GtBugbopReport severityColorFor: aSeverityOrNil
]

{ #category : 'printing' }
GtBugbopAiTriageReview >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: self agreementPercentString;
		nextPutAll: ' agreement on ';
		print: self ratedReports size;
		nextPutAll: ' rated reports)'
]

{ #category : 'accessing' }
GtBugbopAiTriageReview >> ratedReports [
	"Reports for which the AI suggested a severity"
	^ reports select: [ :each | each aiSeverity notNil ]
]

{ #category : 'accessing' }
GtBugbopAiTriageReview >> reports [
	^ reports
]

{ #category : 'accessing' }
GtBugbopAiTriageReview >> reports: aGtBugbopReportsGroup [
	reports := aGtBugbopReportsGroup
]

{ #category : 'accessing' }
GtBugbopAiTriageReview >> reportsAssigned: aSeverity suggested: anAiSeverityOrNil [
	"The reports in one cell of the agreement matrix"
	^ reports select: [ :each | 
		each severity = aSeverity and: [ each aiSeverity = anAiSeverityOrNil ] ]
]

{ #category : 'ui - matrix' }
GtBugbopAiTriageReview >> rowHeaderWidth [
	^ 96
]

{ #category : 'ui - triage' }
GtBugbopAiTriageReview >> scopeTextFor: aReport [
	| aVerdict |
	aVerdict := self scopeVerdictOf: aReport.
	aVerdict ifNil: [ ^ '–' asRopedText foreground: self noneColor ].
	aVerdict = 'yes' ifTrue: [ ^ 'in scope' asRopedText foreground: self agreeColor ].
	^ 'out of scope' asRopedText foreground: self farMissColor
]

{ #category : 'computing' }
GtBugbopAiTriageReview >> scopeVerdictOf: aReport [
	"'yes' / 'no' from the AI triage '### In Scope ...: X' heading, or nil"
	| aLine |
	aReport aiTriage ifNil: [ ^ nil ].
	aLine := aReport aiTriage lines
			detect: [ :each | each trimBoth asLowercase beginsWith: '### in scope' ]
			ifNone: [ ^ nil ].
	^ (aLine copyAfterLast: $:) trimBoth asLowercase ifEmpty: [ nil ]
]

{ #category : 'computing' }
GtBugbopAiTriageReview >> severityDistance: aReport [
	"Number of severity levels between assigned and AI-suggested severity"
	^ (self aiLiftOf: aReport) abs
]

{ #category : 'computing' }
GtBugbopAiTriageReview >> triageSummaryOf: aReport [
	"The first prose line of the AI triage (skipping headings and blank lines), without Markdown emphasis"
	| aLine |
	aReport aiTriage ifNil: [ ^ '' ].
	aLine := aReport aiTriage lines
			detect: [ :each | each trimBoth notEmpty and: [ (each trimBoth beginsWith: '#') not ] ]
			ifNone: [ ^ '' ].
	^ ((aLine copyReplaceAll: '**' with: '') copyReplaceAll: '\' with: '') trimBoth
]

{ #category : 'accessing' }
GtBugbopAiTriageReview >> triagedReports [
	"Reports that carry an AI triage write-up, most severe AI suggestion first"
	| aList |
	aList := (reports select: [ :each | each aiTriage notNil ]) items
			asSortedCollection: [ :a :b | 
				(GtBugbopReport severityRankOf: a aiSeverity) <= (GtBugbopReport severityRankOf: b aiSeverity) ].
	^ reports species withAll: aList asArray
]

{ #category : 'ui - triage' }
GtBugbopAiTriageReview >> truncated: aString to: aSize [
	aString ifNil: [ ^ '' ].
	aString size <= aSize ifTrue: [ ^ aString ].
	^ (aString first: aSize) trimRight , '…'
]

{ #category : 'accessing' }
GtBugbopAiTriageReview >> underRated [
	"The AI considers these more severe than assigned: possible under-rating"
	^ self disagreements select: [ :each | (self aiLiftOf: each) > 0 ]
]

{ #category : 'accessing' }
GtBugbopAiTriageReview >> unratedReports [
	"Reports without an AI severity suggestion"
	^ reports select: [ :each | each aiSeverity isNil ]
]
