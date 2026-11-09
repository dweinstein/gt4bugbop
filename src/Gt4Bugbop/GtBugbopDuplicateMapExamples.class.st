"
I hold examples for GtBugbopDuplicateMap and GtBugbopDuplicateCluster, built from the offline fixture GtBugbopExamples>>insightsReportsGroup. #liveMap builds the map from live (read-only) data and is not run as a test.
"
Class {
	#name : 'GtBugbopDuplicateMapExamples',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Examples',
	#package : 'Gt4Bugbop',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtBugbopDuplicateMapExamples >> confirmedCluster [
	"i2 and i3 are confirmed duplicates of the fixed i1; their identical suspicion is not counted twice"
	<gtExample>
	<return: #GtBugbopDuplicateCluster>
	| aCluster |
	aCluster := self duplicateMap clusters first.
	self assert: aCluster canonical id equals: 'i1'.
	self assert: aCluster confirmedCount equals: 2.
	self assert: aCluster suspectedCount equals: 0.
	self assert: aCluster hasUnresolvedSuspicions not.
	self assert: (aCluster confirmedEdges allSatisfy: [ :each | each value id = 'i1' ]).
	self assert: (aCluster roleOf: aCluster canonical) equals: 'canonical'.
	self assert: aCluster reportsInRoleOrder first id equals: 'i1'.
	^ aCluster
]

{ #category : 'examples' }
GtBugbopDuplicateMapExamples >> duplicateMap [
	<gtExample>
	<return: #GtBugbopDuplicateMap>
	| aMap |
	aMap := GtBugbopDuplicateMap forReports: self reportsGroup.
	self assert: aMap clusters size equals: 3.
	self assert: (aMap clusters collect: [ :each | each size ]) asArray equals: #(3 2 2).
	self assert: (aMap clusters collect: [ :each | each canonical id ]) asArray equals: #('i1' 'i4' 'i8').
	self assert: aMap clusteredReports items size equals: 7.
	self assert: aMap outsideLinks isEmpty.
	self assert: aMap clustersNeedingDecision size equals: 2.
	^ aMap
]

{ #category : 'examples' }
GtBugbopDuplicateMapExamples >> emptyMap [
	"Reports without any duplicate links give no clusters; views show a friendly empty state"
	<gtExample>
	<return: #GtBugbopDuplicateMap>
	| aMap |
	aMap := GtBugbopDuplicateMap forReports: (self reportsGroup select: [ :each | #('i6' 'i7' 'i10') includes: each id ]).
	self assert: aMap clusters isEmpty.
	self assert: aMap pendingSuspicions items isEmpty.
	self assert: aMap outsideLinks isEmpty.
	^ aMap
]

{ #category : 'examples' }
GtBugbopDuplicateMapExamples >> graphViewRenders [
	"The graph paints one node per clustered report plus the canvas and cluster cards"
	<gtExample>
	<return: #GtMondrian>
	| aMap aMondrian |
	aMap := self duplicateMap.
	aMondrian := aMap paintGraphOn: GtMondrian new.
	self assert: (aMondrian nodeAt: aMap ifAbsent: [ nil ]) notNil.
	self assert: (aMap clusteredReports items allSatisfy: [ :each | (aMondrian nodeAt: each ifAbsent: [ nil ]) notNil ]).
	^ aMondrian
]

{ #category : 'live' }
GtBugbopDuplicateMapExamples >> liveMap [
	"Read-only: fetches real reports from Bugbop"
	<gtExample>
	<noTest>
	^ GtBugbopDuplicateMap forReports: GtBugbopLiveExamples new reports
]

{ #category : 'examples' }
GtBugbopDuplicateMapExamples >> mapWithOutsideLinks [
	"Without the original i1, the links of i2 and i3 point outside the set and no SQLi cluster forms"
	<gtExample>
	<return: #GtBugbopDuplicateMap>
	| aMap |
	aMap := GtBugbopDuplicateMap forReports: (self reportsGroup reject: [ :each | each id = 'i1' ]).
	self assert: aMap outsideLinks size equals: 2.
	self assert: (aMap outsideLinks collect: [ :each | each value ]) asSet equals: #('i1') asSet.
	self assert: aMap clusters size equals: 2.
	self assert: (aMap clusters collect: [ :each | each canonical id ]) asSet equals: #('i4' 'i8') asSet.
	^ aMap
]

{ #category : 'examples' }
GtBugbopDuplicateMapExamples >> pendingSuspicions [
	<gtExample>
	<return: #GtBugbopReportsGroup>
	| aGroup |
	aGroup := self duplicateMap pendingSuspicions.
	self assert: (aGroup items collect: [ :each | each id ]) asSet equals: #('i5' 'i9') asSet.
	self assert: (aGroup items allSatisfy: [ :each | each isActive and: [ each duplicateOfId isNil ] ]).
	^ aGroup
]

{ #category : 'examples' }
GtBugbopDuplicateMapExamples >> reportsGroup [
	<gtExample>
	<return: #GtBugbopReportsGroup>
	| aGroup |
	aGroup := GtBugbopExamples new insightsReportsGroup.
	self assert: aGroup items size equals: 14.
	^ aGroup
]

{ #category : 'examples' }
GtBugbopDuplicateMapExamples >> suspectedCluster [
	"i5 is only suspected to duplicate the fixed i4"
	<gtExample>
	<return: #GtBugbopDuplicateCluster>
	| aCluster suspect |
	aCluster := self duplicateMap clusters detect: [ :each | each canonical id = 'i4' ].
	suspect := aCluster reports items detect: [ :each | each id = 'i5' ].
	self assert: aCluster confirmedCount equals: 0.
	self assert: aCluster suspectedCount equals: 1.
	self assert: aCluster hasUnresolvedSuspicions.
	self assert: (aCluster roleOf: suspect) equals: 'suspected'.
	self assert: (aCluster linkTargetOf: suspect) id equals: 'i4'.
	^ aCluster
]
