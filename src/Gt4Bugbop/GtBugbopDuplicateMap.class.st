"
I analyse duplicate relations inside a GtBugbopReportsGroup.

I build clusters (GtBugbopDuplicateCluster) as connected components over confirmed (duplicateOfId) and suspected (suspectedDuplicateOfId) links whose both ends are in the group. Links pointing to reports outside the group are collected as outsideLinks (Associations report -> missing id).

Create me with:
  GtBugbopDuplicateMap forReports: aGtBugbopReportsGroup

Views: Duplicate graph, Clusters, Pending suspicions.
"
Class {
	#name : 'GtBugbopDuplicateMap',
	#superclass : 'Object',
	#instVars : [
		'reports',
		'clusters',
		'outsideLinks'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'instance creation' }
GtBugbopDuplicateMap class >> forReports: aGtBugbopReportsGroup [
	^ self new initializeWithReports: aGtBugbopReportsGroup
]

{ #category : 'private' }
GtBugbopDuplicateMap >> adjacencyFrom: anIndex [
	"Undirected adjacency between reports of this set; links to unknown ids go to outsideLinks"
	| adjacency |
	adjacency := IdentityDictionary new.
	reports items do: [ :each | 
		(self linkedIdsOf: each)
			do: [ :anId | self link: each toId: anId in: anIndex adjacency: adjacency ] ].
	^ adjacency
]

{ #category : 'ui - elements' }
GtBugbopDuplicateMap >> ageTextFor: aReport [
	^ aReport ageInDays ifNil: [ '' ] ifNotNil: [ :days | days printString , 'd' ]
]

{ #category : 'accessing' }
GtBugbopDuplicateMap >> clusterFor: aReport [
	^ clusters detect: [ :each | each includesReport: aReport ] ifNone: [ nil ]
]

{ #category : 'accessing' }
GtBugbopDuplicateMap >> clusteredReports [
	^ GtBugbopReportsGroup withAll: (clusters flatCollect: [ :each | each reports items ])
]

{ #category : 'accessing' }
GtBugbopDuplicateMap >> clusters [
	"Clusters of at least two linked reports, biggest and most severe first"
	^ clusters
]

{ #category : 'accessing' }
GtBugbopDuplicateMap >> clustersNeedingDecision [
	^ clusters select: [ :each | each hasUnresolvedSuspicions ]
]

{ #category : 'private' }
GtBugbopDuplicateMap >> componentFrom: aReport adjacency: anAdjacency visited: aVisitedSet [
	"Breadth-first walk collecting every report reachable from aReport"
	| queue component |
	queue := OrderedCollection with: aReport.
	component := OrderedCollection new.
	aVisitedSet add: aReport.
	[ queue isEmpty ] whileFalse: [ 
		| current |
		current := queue removeFirst.
		component add: current.
		((anAdjacency at: current) reject: [ :next | aVisitedSet includes: next ])
			do: [ :next | aVisitedSet add: next. queue add: next ] ].
	^ component
]

{ #category : 'private' }
GtBugbopDuplicateMap >> componentsOf: anAdjacency [
	| visited components |
	visited := IdentitySet new.
	components := OrderedCollection new.
	reports items do: [ :each | 
		((anAdjacency includesKey: each) and: [ (visited includes: each) not ])
			ifTrue: [ components add: (self componentFrom: each adjacency: anAdjacency visited: visited) ] ].
	^ components
]

{ #category : 'private' }
GtBugbopDuplicateMap >> computeClusters [
	| adjacency |
	adjacency := self adjacencyFrom: self reportsById.
	^ ((self componentsOf: adjacency)
		collect: [ :each | GtBugbopDuplicateCluster forReports: each ]) asArray
		sorted: [ :a :b | self isCluster: a before: b ]
]

{ #category : 'ui - painting' }
GtBugbopDuplicateMap >> graphColumnCount [
	"Two columns keep the graph readable when zoomed to fit an inspector pane"
	^ (clusters size min: 2) max: 1
]

{ #category : 'gt - extensions' }
GtBugbopDuplicateMap >> gtClustersFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Clusters';
		priority: 2;
		items: [ clusters ];
		column: 'Canonical report' text: [ :each | each title asRopedText bold ] weight: 1;
		column: 'Size' text: [ :each | each size ] width: 45;
		column: 'Confirmed' text: [ :each | each confirmedCount ] width: 72;
		column: 'Suspected' text: [ :each | self suspectedCountTextFor: each ] width: 72;
		column: 'Severities' stencil: [ :each | self newSeverityDotsFor: each ] width: 110;
		column: 'Statuses' text: [ :each | each statusSummaryText ] weight: 0.55;
		column: 'Decision' stencil: [ :each | self newDecisionTagFor: each ] width: 115;
		send: [ :each | each ]
]

{ #category : 'gt - extensions' }
GtBugbopDuplicateMap >> gtDuplicateGraphFor: aView [
	<gtView>
	clusters ifEmpty: [ 
		^ aView explicit
			title: 'Duplicate graph';
			priority: 1;
			stencil: [ self newEmptyStateLabel: 'No duplicate links between these reports' ] ].
	^ aView mondrian
		title: 'Duplicate graph';
		priority: 1;
		painting: [ :aMondrian | self paintGraphOn: aMondrian ]
]

{ #category : 'gt - extensions' }
GtBugbopDuplicateMap >> gtPendingSuspicionsFor: aView [
	<gtView>
	self pendingSuspicions items ifEmpty: [ 
		^ aView explicit
			title: 'Pending suspicions';
			priority: 3;
			stencil: [ self newEmptyStateLabel: 'No pending duplicate suspicions' ] ].
	^ aView columnedList
		title: 'Pending suspicions';
		priority: 3;
		items: [ self pendingSuspicionsBySeverity ];
		column: 'Severity' text: [ :each | GtBugbopReport severityText: each severity ] width: 75;
		column: 'Report' text: [ :each | each title ] weight: 1;
		column: 'Hunter' text: [ :each | each reporterName ifNil: [ '' ] ] width: 100;
		column: 'Status' text: [ :each | GtBugbopReport statusText: each status ] width: 90;
		column: 'Age' text: [ :each | self ageTextFor: each ] width: 60;
		column: 'Suspected duplicate of' text: [ :each | self suspectedTargetTextFor: each ] weight: 1;
		send: [ :each | each ]
]

{ #category : 'initialization' }
GtBugbopDuplicateMap >> initializeWithReports: aGtBugbopReportsGroup [
	reports := aGtBugbopReportsGroup.
	outsideLinks := OrderedCollection new.
	clusters := self computeClusters
]

{ #category : 'private' }
GtBugbopDuplicateMap >> isCluster: aCluster before: anotherCluster [
	"Bigger clusters first, then the most severe"
	aCluster size = anotherCluster size
		ifFalse: [ ^ aCluster size > anotherCluster size ].
	^ aCluster highestSeverityRank <= anotherCluster highestSeverityRank
]

{ #category : 'private' }
GtBugbopDuplicateMap >> link: aReport toId: anId in: anIndex adjacency: anAdjacency [
	| target |
	target := anIndex at: anId ifAbsent: [ ^ outsideLinks add: aReport -> anId ].
	(anAdjacency at: aReport ifAbsentPut: [ IdentitySet new ]) add: target.
	(anAdjacency at: target ifAbsentPut: [ IdentitySet new ]) add: aReport
]

{ #category : 'private' }
GtBugbopDuplicateMap >> linkedIdsOf: aReport [
	"Ids aReport points to, confirmed or suspected"
	^ ({ aReport duplicateOfId. aReport suspectedDuplicateOfId } reject: [ :each | each isNil ]) asSet
]

{ #category : 'ui - elements' }
GtBugbopDuplicateMap >> newCanvasElement [
	| aChildrenContainer |
	aChildrenContainer := BlElement new
		constraintsDo: [ :c | c horizontal fitContent. c vertical fitContent ].
	aChildrenContainer graph beChildrenContainer: #default.
	^ BrVerticalPane new
		fitContent;
		padding: (BlInsets all: 10);
		addChild: self newSummaryLabel;
		addChild: (GtBugbopDuplicateCluster newLegend hFitContent margin: (BlInsets top: 6 bottom: 4));
		addChild: aChildrenContainer
]

{ #category : 'ui - elements' }
GtBugbopDuplicateMap >> newDecisionTagFor: aCluster [
	| aFrame |
	aFrame := BrFrame new fitContent; padding: (BlInsets top: 3 bottom: 3).
	aCluster hasUnresolvedSuspicions ifFalse: [ 
		^ aFrame addChild: (GtBugbopDuplicateCluster newLabel: 'settled' size: 11 color: Color gray) ].
	^ aFrame addChild: (GtBugbopDuplicateCluster
		newTag: 'needs decision'
		color: GtBugbopDuplicateCluster suspectedEdgeColor)
]

{ #category : 'ui - elements' }
GtBugbopDuplicateMap >> newEmptyStateLabel: aString [
	^ BrFrame new
		matchParent;
		padding: (BlInsets all: 20);
		addChild: ((GtBugbopDuplicateCluster newLabel: aString size: 14 color: Color gray)
			constraintsDo: [ :c | c frame horizontal alignCenter. c frame vertical alignCenter ])
]

{ #category : 'ui - elements' }
GtBugbopDuplicateMap >> newSeverityDotsFor: aCluster [
	"One severity-colored dot per report, most severe first, canonical ringed"
	| aPane |
	aPane := BrHorizontalPane new fitContent; alignCenterLeft; padding: (BlInsets top: 4 bottom: 4).
	aCluster reportsBySeverity do: [ :each | 
		aPane addChild: ((GtBugbopDuplicateCluster newDotColored: each severityColor size: 11)
			border: (BlBorder paint: ((aCluster isCanonical: each) ifTrue: [ Color black ] ifFalse: [ Color transparent ]) width: 1.5)) ].
	^ aPane
]

{ #category : 'ui - elements' }
GtBugbopDuplicateMap >> newSummaryLabel [
	^ (GtBugbopDuplicateCluster newLabel: self summaryText size: 13 color: Color black)
		margin: (BlInsets left: 4)
]

{ #category : 'accessing' }
GtBugbopDuplicateMap >> outsideLinks [
	"Associations report -> id for duplicate links pointing to reports that are not in this set"
	^ outsideLinks
]

{ #category : 'ui - painting' }
GtBugbopDuplicateMap >> paintClustersOn: aMondrian [
	aMondrian nodes
		stencil: [ :aCluster | aCluster newCardElement ];
		with: clusters;
		forEach: [ :aCluster | aCluster paintReportsOn: aMondrian ].
	aMondrian layout custom: (BlGridLayout horizontal
		columnCount: self graphColumnCount;
		cellSpacing: 4)
]

{ #category : 'ui - painting' }
GtBugbopDuplicateMap >> paintGraphOn: aMondrian [
	"One canvas node (summary + legend) holding a grid of cluster cards, each laid out as a tree"
	aMondrian nodes
		stencil: [ :aMap | self newCanvasElement ];
		with: { self };
		forEach: [ :aMap | self paintClustersOn: aMondrian ].
	^ aMondrian
]

{ #category : 'accessing' }
GtBugbopDuplicateMap >> pendingSuspicions [
	"Active reports suspected to be duplicates but not confirmed yet"
	^ reports select: [ :each | 
		each isActive and: [ each duplicateOfId isNil and: [ each suspectedDuplicateOfId notNil ] ] ]
]

{ #category : 'accessing' }
GtBugbopDuplicateMap >> pendingSuspicionsBySeverity [
	^ self pendingSuspicions items asArray
		sorted: [ :a :b | a severityRank <= b severityRank ]
]

{ #category : 'printing' }
GtBugbopDuplicateMap >> printOn: aStream [
	aStream
		nextPutAll: 'Duplicate map: ';
		print: clusters size;
		nextPutAll: ' clusters, ';
		print: self pendingSuspicions size;
		nextPutAll: ' pending suspicions'
]

{ #category : 'accessing' }
GtBugbopDuplicateMap >> reportWithId: anId [
	^ reports items detect: [ :each | each id = anId ] ifNone: [ nil ]
]

{ #category : 'accessing' }
GtBugbopDuplicateMap >> reports [
	^ reports
]

{ #category : 'private' }
GtBugbopDuplicateMap >> reportsById [
	| index |
	index := Dictionary new.
	reports items do: [ :each | index at: each id put: each ].
	^ index
]

{ #category : 'ui - elements' }
GtBugbopDuplicateMap >> summaryText [
	| aText |
	aText := ('{1} duplicate clusters · {2} linked reports of {3}' format: { 
		clusters size. self clusteredReports items size. reports items size }) asRopedText.
	aText append: (('  ·  {1} need a decision' format: { self clustersNeedingDecision size }) asRopedText
		foreground: GtBugbopDuplicateCluster suspectedEdgeColor).
	outsideLinks ifNotEmpty: [ 
		aText append: (('  ·  {1} links outside this set' format: { outsideLinks size }) asRopedText
			foreground: Color gray) ].
	^ aText
]

{ #category : 'ui - elements' }
GtBugbopDuplicateMap >> suspectedCountTextFor: aCluster [
	aCluster suspectedCount isZero ifTrue: [ ^ '0' asRopedText foreground: Color gray ].
	^ aCluster suspectedCount printString asRopedText
		bold;
		foreground: GtBugbopDuplicateCluster suspectedEdgeColor
]

{ #category : 'ui - elements' }
GtBugbopDuplicateMap >> suspectedTargetTextFor: aReport [
	"The suspected original prefixed with its status, or a hint that it lies outside this set"
	| aTarget aText |
	aTarget := self reportWithId: aReport suspectedDuplicateOfId.
	aTarget ifNil: [ 
		^ ('outside this set (' , (aReport suspectedDuplicateOfId asString first: (8 min: aReport suspectedDuplicateOfId asString size)) , ')') asRopedText
			italic;
			foreground: Color gray ].
	aText := (aTarget status asString , '  ') asRopedText foreground: aTarget statusColor.
	^ aText append: ('→ ' , (aTarget title ifNil: [ aTarget id asString ])) asRopedText
]
