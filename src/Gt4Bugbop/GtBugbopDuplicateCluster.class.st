"
I am a connected group of Bugbop reports linked by duplicate relations: confirmed (report duplicateOfId) and suspected (report suspectedDuplicateOfId, not yet confirmed).

Each edge is an Association duplicateReport -> originalReport. My canonical report is the one the others point to, preferring valid/fixed reports.

I am built by GtBugbopDuplicateMap. Inspect my Graph and Reports views to compare the reports side by side and decide on pending suspicions.
"
Class {
	#name : 'GtBugbopDuplicateCluster',
	#superclass : 'Object',
	#instVars : [
		'reports',
		'canonical',
		'confirmedEdges',
		'suspectedEdges'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'ui - styling' }
GtBugbopDuplicateCluster class >> confirmedEdgeColor [
	^ Color gray: 0.3
]

{ #category : 'instance creation' }
GtBugbopDuplicateCluster class >> forReports: aCollection [
	"aCollection holds the reports of one connected component"
	^ self new initializeWithReports: aCollection
]

{ #category : 'testing' }
GtBugbopDuplicateCluster class >> hasUnconfirmedSuspicion: aReport [
	^ aReport suspectedDuplicateOfId notNil
		and: [ aReport suspectedDuplicateOfId ~= aReport duplicateOfId ]
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster class >> newArrowheadColored: aColor [
	^ BlArrowheadTriangle new
		scale: 3;
		background: aColor;
		border: (BlBorder paint: aColor width: 1)
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster class >> newConfirmedEdge [
	^ BlLineElement new
		border: (BlBorder paint: self confirmedEdgeColor width: 2);
		fromHead: (self newArrowheadColored: self confirmedEdgeColor)
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster class >> newDotColored: aColor size: aNumber [
	^ BlElement new
		geometry: BlCircleGeometry new;
		size: aNumber asPoint;
		background: aColor;
		margin: (BlInsets top: 2 right: 4 bottom: 2 left: 0)
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster class >> newLabel: aString size: aFontSize color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			fontSize: aFontSize;
			foreground: aColor);
		text: aString
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster class >> newLegend [
	"Explains edge styles, the canonical ring and severity fill colors"
	| legend |
	legend := BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 6 left: 10 bottom: 6 right: 10);
		background: (Color gray: 0.97);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6).
	legend
		addChild: (self newLegendLine: self newConfirmedEdge label: 'confirmed duplicate of');
		addChild: (self newLegendLine: self newSuspectedEdge label: 'suspected duplicate of');
		addChild: self newLegendCanonical.
	GtBugbopReport severities do: [ :each | legend addChild: (self newLegendSeverity: each) ].
	legend when: BlClickEvent do: [ :anEvent | anEvent consumed: true ].
	^ legend
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster class >> newLegendCanonical [
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets right: 18);
		addChild: (BlElement new
			geometry: BlCircleGeometry new;
			size: 14 @ 14;
			background: Color white;
			border: (BlBorder paint: Color darkGray width: 3.5);
			margin: (BlInsets right: 4));
		addChild: (self newLabel: 'canonical (thick ring = status color)' size: 11 color: Color darkGray)
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster class >> newLegendLine: aLineElement label: aString [
	"A short sample of an edge style followed by its meaning"
	| sample |
	sample := BlElement new
		size: 40 @ 14;
		margin: (BlInsets right: 6);
		addChild: (aLineElement
			fromAnchor: (BlAbsolutePositionAnchor position: 38 @ 7);
			toAnchor: (BlAbsolutePositionAnchor position: 2 @ 7)).
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets right: 18);
		addChild: sample;
		addChild: (self newLabel: aString size: 11 color: Color darkGray)
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster class >> newLegendSeverity: aSeverity [
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets right: 10);
		addChild: (self newDotColored: (GtBugbopReport severityColorFor: aSeverity) size: 10);
		addChild: (self newLabel: aSeverity size: 11 color: Color darkGray)
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster class >> newSuspectedEdge [
	^ BlLineElement new
		border: (BlBorder builder
			dashed;
			paint: self suspectedEdgeColor;
			width: 2;
			build);
		fromHead: (self newArrowheadColored: self suspectedEdgeColor)
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster class >> newTag: aString color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			fontSize: 10;
			bold;
			foreground: Color white);
		text: aString;
		background: aColor;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		padding: (BlInsets top: 1 left: 7 bottom: 1 right: 7)
]

{ #category : 'ui - styling' }
GtBugbopDuplicateCluster class >> nodeDiameterFor: aReport [
	"critical 36 ... low 18, unknown 14"
	^ #(36 30 24 18 14) at: aReport severityRank
]

{ #category : 'ui - styling' }
GtBugbopDuplicateCluster class >> shortTitleOf: aReport maxSize: aNumber [
	| aTitle |
	aTitle := (aReport title ifNil: [ aReport id asString ]) trimBoth.
	aTitle size <= aNumber ifTrue: [ ^ aTitle ].
	^ (aTitle first: aNumber - 1) trimRight , '…'
]

{ #category : 'ui - styling' }
GtBugbopDuplicateCluster class >> suspectedEdgeColor [
	^ Color r: 0.93 g: 0.55 b: 0.1
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> aiSeverityTextFor: aReport [
	"AI severity, flagged with a bold ! when it disagrees with the reported one"
	| aText |
	aReport aiSeverity ifNil: [ ^ 'n/a' asRopedText foreground: Color gray ].
	aText := GtBugbopReport severityText: aReport aiSeverity.
	aReport aiAgreesOnSeverity ifFalse: [ 
		aText append: ('  !' asRopedText bold; foreground: self class suspectedEdgeColor) ].
	^ aText
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> allEdges [
	^ confirmedEdges , suspectedEdges
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> canonical [
	^ canonical
]

{ #category : 'private' }
GtBugbopDuplicateCluster >> canonicalScoreOf: aReport [
	| score |
	score := (confirmedEdges count: [ :each | each value == aReport ]) * 20.
	score := score + ((suspectedEdges count: [ :each | each value == aReport ]) * 10).
	aReport isValid ifTrue: [ score := score + 100 ].
	aReport status = 'fixed' ifTrue: [ score := score + 50 ].
	aReport duplicateOfId ifNil: [ score := score + 30 ].
	^ score
]

{ #category : 'private' }
GtBugbopDuplicateCluster >> computeCanonical [
	"The report others point to, preferring valid/fixed originals; ties go to the oldest"
	^ reports items detectMax: [ :each | self canonicalScoreOf: each ]
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> confirmedCount [
	^ confirmedEdges size
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> confirmedEdges [
	"Associations duplicate -> original"
	^ confirmedEdges
]

{ #category : 'private' }
GtBugbopDuplicateCluster >> confirmedEdgesIn: anIndex [
	"Associations duplicate -> original for confirmed duplicates"
	^ (reports items
		select: [ :each | each duplicateOfId notNil and: [ anIndex includesKey: each duplicateOfId ] ])
		collect: [ :each | each -> (anIndex at: each duplicateOfId) ]
]

{ #category : 'gt - extensions' }
GtBugbopDuplicateCluster >> gtGraphFor: aView [
	<gtView>
	^ aView mondrian
		title: 'Graph';
		priority: 1;
		painting: [ :aMondrian | self paintStandaloneOn: aMondrian ]
]

{ #category : 'gt - extensions' }
GtBugbopDuplicateCluster >> gtReportsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Reports';
		priority: 2;
		items: [ self reportsInRoleOrder ];
		column: 'Role' stencil: [ :each | self newRoleTagFor: each ] width: 95;
		column: 'Title' text: [ :each | self titleTextFor: each ] weight: 1;
		column: 'Hunter' text: [ :each | each reporterName ifNil: [ '' ] ] width: 110;
		column: 'Created' text: [ :each | each createdAt ifNil: [ '' ] ifNotNil: [ :aDate | aDate asDate yyyymmdd ] ] width: 85;
		column: 'Severity' text: [ :each | GtBugbopReport severityText: each severity ] width: 70;
		column: 'AI severity' text: [ :each | self aiSeverityTextFor: each ] width: 85;
		column: 'Status' text: [ :each | GtBugbopReport statusText: each status ] width: 105;
		column: 'Points to' text: [ :each | self linkTextFor: each ] weight: 0.6
]

{ #category : 'private' }
GtBugbopDuplicateCluster >> hasUnconfirmedSuspicion: aReport [
	^ self class hasUnconfirmedSuspicion: aReport
]

{ #category : 'testing' }
GtBugbopDuplicateCluster >> hasUnresolvedSuspicions [
	^ suspectedEdges notEmpty
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> highestSeverityRank [
	^ (reports items collect: [ :each | each severityRank ]) min
]

{ #category : 'testing' }
GtBugbopDuplicateCluster >> includesReport: aReport [
	^ reports items includes: aReport
]

{ #category : 'initialization' }
GtBugbopDuplicateCluster >> initializeWithReports: aCollection [
	| index |
	reports := GtBugbopReportsGroup withAll: (self oldestFirst: aCollection).
	index := Dictionary new.
	reports items do: [ :each | index at: each id put: each ].
	confirmedEdges := self confirmedEdgesIn: index.
	suspectedEdges := self suspectedEdgesIn: index.
	canonical := self computeCanonical
]

{ #category : 'testing' }
GtBugbopDuplicateCluster >> isCanonical: aReport [
	^ canonical == aReport
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> linkTargetOf: aReport [
	"The report aReport points to inside this cluster, or nil"
	^ (self allEdges detect: [ :each | each key == aReport ] ifNone: [ nil ])
		ifNotNil: [ :anEdge | anEdge value ]
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> linkTextFor: aReport [
	| aTarget aText |
	aTarget := self linkTargetOf: aReport.
	aTarget ifNil: [ ^ '' asRopedText ].
	aText := ('→ ' , (aTarget title ifNil: [ aTarget id asString ])) asRopedText.
	^ (self roleOf: aReport) = 'suspected'
		ifTrue: [ aText foreground: self class suspectedEdgeColor ]
		ifFalse: [ aText foreground: Color gray ]
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> newCaptionFor: aReport [
	"Hunter and status under the title, status in its color"
	| aText |
	aText := ('@' , (aReport reporterName ifNil: [ '?' ]) , ' · ') asRopedText foreground: Color gray.
	aText append: (aReport status asString asRopedText foreground: aReport statusColor).
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 9);
		text: aText
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> newCardElement [
	"A white rounded card hosting the header and the mondrian children container for my reports"
	| aChildrenContainer |
	aChildrenContainer := BlElement new
		padding: (BlInsets top: 6 left: 4 bottom: 4 right: 4);
		constraintsDo: [ :c | c horizontal fitContent. c vertical fitContent ].
	aChildrenContainer graph beChildrenContainer: #default.
	^ BrVerticalPane new
		fitContent;
		padding: (BlInsets all: 12);
		margin: (BlInsets all: 8);
		background: Color white;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		border: (BlBorder paint: (canonical severityColor alpha: 0.45) width: 1.5);
		addChild: self newHeader;
		addChild: aChildrenContainer
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> newCircleFor: aReport [
	^ BlElement new
		geometry: BlCircleGeometry new;
		size: (self class nodeDiameterFor: aReport) asPoint;
		background: aReport severityColor;
		border: (BlBorder
			paint: aReport statusColor
			width: ((self isCanonical: aReport) ifTrue: [ 5 ] ifFalse: [ 2.5 ]))
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> newHeader [
	"Canonical title, counts and a decision tag when suspicions are still open"
	| aHeader aTitleRow |
	aTitleRow := BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		addChild: (self class newDotColored: canonical severityColor size: 10);
		addChild: ((self class
			newLabel: (self class shortTitleOf: canonical maxSize: 48)
			size: 12
			color: Color black) margin: (BlInsets right: 8)).
	self hasUnresolvedSuspicions ifTrue: [ 
		aTitleRow addChild: (self class newTag: 'needs decision' color: self class suspectedEdgeColor) ].
	aHeader := BrVerticalPane new fitContent; padding: (BlInsets bottom: 4).
	^ aHeader
		addChild: aTitleRow;
		addChild: (self newSummaryLabel margin: (BlInsets left: 14))
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> newNodeFor: aReport [
	"Severity-sized circle with status ring, then short title and caption; spawns the report on click"
	| aNode |
	aNode := BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		padding: (BlInsets top: 3 left: 2 bottom: 3 right: 2);
		addChild: ((self newCircleFor: aReport) margin: (BlInsets right: 7));
		addChild: (BrVerticalPane new
			fitContent;
			addChild: (self newTitleLabelFor: aReport);
			addChild: (self newCaptionFor: aReport)).
	aNode addAptitude: (BrGlamorousWithLabelTooltipAptitude new text: (self tooltipTextFor: aReport)).
	aNode when: BlClickEvent do: [ :anEvent | 
		anEvent consumed: true.
		aNode phlow spawnObject: aReport ].
	^ aNode
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> newRoleTagFor: aReport [
	| aRole |
	aRole := self roleOf: aReport.
	^ BrFrame new
		fitContent;
		padding: (BlInsets top: 3 bottom: 3);
		addChild: (self class newTag: aRole color: (self roleColorFor: aRole))
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> newSummaryLabel [
	| aText |
	aText := ('{1} reports · {2} confirmed' format: { self size. self confirmedCount }) asRopedText
		foreground: Color gray.
	self hasUnresolvedSuspicions ifTrue: [ 
		aText append: ((' · {1} suspected' format: { self suspectedCount }) asRopedText
			foreground: self class suspectedEdgeColor) ].
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 10);
		text: aText
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> newTitleLabelFor: aReport [
	| aText |
	aText := (self class shortTitleOf: aReport maxSize: 30) asRopedText
		glamorousRegularFont;
		fontSize: 11.
	(self isCanonical: aReport) ifTrue: [ aText bold ].
	^ BrLabel new
		aptitude: BrGlamorousLabelAptitude new;
		text: aText
]

{ #category : 'private' }
GtBugbopDuplicateCluster >> oldestFirst: aCollection [
	| epoch |
	epoch := DateAndTime epoch.
	^ aCollection asArray
		sorted: [ :a :b | (a createdAt ifNil: [ epoch ]) <= (b createdAt ifNil: [ epoch ]) ]
]

{ #category : 'ui - painting' }
GtBugbopDuplicateCluster >> paintReportsOn: aMondrian [
	"Nodes and edges of my reports; edges go original -> duplicate so the tree grows from the canonical report"
	aMondrian nodes
		stencil: [ :aReport | self newNodeFor: aReport ];
		with: reports items.
	aMondrian edges
		stencil: [ :anEdge | self class newConfirmedEdge ];
		fromRightCenter;
		toLeftCenter;
		connect: confirmedEdges from: [ :anEdge | anEdge value ] to: [ :anEdge | anEdge key ].
	aMondrian edges
		stencil: [ :anEdge | self class newSuspectedEdge ];
		fromRightCenter;
		toLeftCenter;
		connect: suspectedEdges from: [ :anEdge | anEdge value ] to: [ :anEdge | anEdge key ].
	aMondrian layout horizontalTree
		levelDistance: 60;
		nodeDistance: 12
]

{ #category : 'ui - painting' }
GtBugbopDuplicateCluster >> paintStandaloneOn: aMondrian [
	aMondrian nodes
		stencil: [ :aCluster | 
			BrVerticalPane new
				fitContent;
				addChild: (self class newLegend hFitContent);
				addChild: aCluster newCardElement ];
		with: { self };
		forEach: [ :aCluster | aCluster paintReportsOn: aMondrian ].
	^ aMondrian
]

{ #category : 'printing' }
GtBugbopDuplicateCluster >> printOn: aStream [
	aStream
		nextPutAll: 'Cluster: ';
		nextPutAll: self title;
		nextPutAll: ' (';
		print: self size;
		nextPutAll: ' reports)'
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> reports [
	^ reports
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> reportsBySeverity [
	^ reports items asArray sorted: [ :a :b | a severityRank <= b severityRank ]
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> reportsInRoleOrder [
	"Canonical first, then confirmed duplicates, suspected ones and other originals"
	| order |
	order := #('canonical' 'duplicate' 'suspected' 'original').
	^ reports items asArray
		sorted: [ :a :b | (order indexOf: (self roleOf: a)) <= (order indexOf: (self roleOf: b)) ]
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> roleColorFor: aRole [
	aRole = 'canonical' ifTrue: [ ^ Color gray: 0.25 ].
	aRole = 'suspected' ifTrue: [ ^ self class suspectedEdgeColor ].
	aRole = 'duplicate' ifTrue: [ ^ Color gray: 0.55 ].
	^ Color gray: 0.7
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> roleOf: aReport [
	(self isCanonical: aReport) ifTrue: [ ^ 'canonical' ].
	(confirmedEdges anySatisfy: [ :each | each key == aReport ]) ifTrue: [ ^ 'duplicate' ].
	(suspectedEdges anySatisfy: [ :each | each key == aReport ]) ifTrue: [ ^ 'suspected' ].
	^ 'original'
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> size [
	^ reports items size
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> statusSummaryText [
	| text |
	text := '' asRopedText.
	(reports items collect: [ :each | each status ]) asBag sortedCounts
		do: [ :each | 
			text append: ((each value asString , ' ' , each key printString , '   ') asRopedText
				foreground: (GtBugbopReport statusColorFor: each value)) ].
	^ text
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> suspectedCount [
	^ suspectedEdges size
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> suspectedEdges [
	"Associations suspect -> original, not yet confirmed"
	^ suspectedEdges
]

{ #category : 'private' }
GtBugbopDuplicateCluster >> suspectedEdgesIn: anIndex [
	"Associations suspect -> original for suspicions that are not (yet) confirmed"
	^ (reports items
		select: [ :each | (self hasUnconfirmedSuspicion: each) and: [ anIndex includesKey: each suspectedDuplicateOfId ] ])
		collect: [ :each | each -> (anIndex at: each suspectedDuplicateOfId) ]
]

{ #category : 'accessing' }
GtBugbopDuplicateCluster >> title [
	^ canonical title ifNil: [ canonical id asString ]
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> titleTextFor: aReport [
	| aText |
	aText := (aReport title ifNil: [ aReport id asString ]) asRopedText.
	(self isCanonical: aReport) ifTrue: [ aText bold ].
	^ aText
]

{ #category : 'ui - elements' }
GtBugbopDuplicateCluster >> tooltipTextFor: aReport [
	^ String streamContents: [ :aStream | 
		aStream
			nextPutAll: (aReport title ifNil: [ '' ]); cr;
			nextPutAll: 'Role: '; nextPutAll: (self roleOf: aReport); cr;
			nextPutAll: 'Severity: '; nextPutAll: (aReport severity ifNil: [ 'none' ]);
			nextPutAll: '  (AI: '; nextPutAll: (aReport aiSeverity ifNil: [ 'n/a' ]); nextPutAll: ')'; cr;
			nextPutAll: 'Status: '; nextPutAll: aReport status asString; cr;
			nextPutAll: 'Hunter: '; nextPutAll: (aReport reporterName ifNil: [ '?' ]); cr;
			nextPutAll: 'Reported: '; nextPutAll: (aReport createdAt ifNil: [ '?' ] ifNotNil: [ :aDate | aDate asDate yyyymmdd ]) ]
]
