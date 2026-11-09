"
Examples for GtBugbopHunterLandscape, GtBugbopSeverityBarStencil and the hunter Profile view, built on the offline insights fixture (GtBugbopExamples new insightsReportsGroup). #liveLandscape uses live read-only data and is not run as a test.
"
Class {
	#name : 'GtBugbopHunterLandscapeExamples',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Examples',
	#package : 'Gt4Bugbop',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtBugbopHunterLandscapeExamples >> bubbleSizes [
	<gtExample>
	<return: #GtBugbopHunterLandscape>
	| landscape |
	landscape := self landscape.
	self assert: (landscape bubbleDiameterFor: (landscape hunterNamed: 'frank')) equals: 14.
	self assert: (landscape bubbleDiameterFor: (landscape hunterNamed: 'alice')) equals: 42.
	self
		assert: (landscape bubbleDiameterFor: (landscape hunterNamed: 'bob'))
			< (landscape bubbleDiameterFor: (landscape hunterNamed: 'alice')).
	^ landscape
]

{ #category : 'examples' }
GtBugbopHunterLandscapeExamples >> emptyLandscape [
	<gtExample>
	<return: #GtBugbopHunterLandscape>
	| landscape |
	landscape := GtBugbopHunterLandscape forReports: (GtBugbopReportsGroup withAll: #()).
	self assert: landscape hunters isEmpty.
	self assert: landscape volumeThreshold equals: 0.
	self assert: (landscape newTreemapPanel isKindOf: BrLabel).
	self assert: (landscape newQuadrantPanel isKindOf: BrLabel).
	self assert: (landscape newSeverityProfilePanel isKindOf: BrLabel).
	^ landscape
]

{ #category : 'examples' }
GtBugbopHunterLandscapeExamples >> hunterProfile [
	<gtExample>
	<return: #GtBugbopHunterSummary>
	| frank |
	frank := self landscape hunterNamed: 'frank'.
	self assert: frank initials equals: 'FR'.
	self assert: frank rejectedReports size equals: 2.
	self assert: frank profileStats size equals: 6.
	self assert: (frank profileStats collect: [ :each | each second ]) asArray equals: #('3' '0' '2' '1' '0%' '$0').
	self assert: (frank profileSubtitle includesSubstring: 'highest severity low').
	^ frank
]

{ #category : 'examples' }
GtBugbopHunterLandscapeExamples >> landscape [
	<gtExample>
	<return: #GtBugbopHunterLandscape>
	| landscape |
	landscape := GtBugbopHunterLandscape forReports: self reports.
	self assert: landscape hunters size equals: 6.
	self assert: landscape hunters first reportCount equals: 3.
	self assert: landscape maxReportCount equals: 3.
	self assert: landscape maxBountyCents equals: 150000.
	self assert: landscape volumeThreshold equals: 7 / 3.
	self assert: landscape unresolvedHunters isEmpty.
	^ landscape
]

{ #category : 'examples - live' }
GtBugbopHunterLandscapeExamples >> liveLandscape [
	"Read-only: fetches live reports from the Bugbop API"
	<gtExample>
	<noTest>
	^ GtBugbopHunterLandscape forReports: GtBugbopLiveExamples new reports
]

{ #category : 'examples' }
GtBugbopHunterLandscapeExamples >> quadrantClusters [
	<gtExample>
	<return: #Array>
	| clusters |
	clusters := self landscape quadrantClusters.
	self assert: clusters size equals: 4.
	self
		assert: (clusters collect: [ :each | each size ]) asArray
		equals: #(2 2 1 1).
	self
		assert: (clusters first collect: [ :each | each username ]) asSet
		equals: #('dave' 'carol') asSet.
	self assert: clusters last first username equals: 'alice'.
	^ clusters
]

{ #category : 'examples' }
GtBugbopHunterLandscapeExamples >> quadrants [
	<gtExample>
	<return: #GtBugbopHunterLandscape>
	| landscape |
	landscape := self landscape.
	self assert: (landscape quadrantNameFor: (landscape hunterNamed: 'alice')) equals: 'Prolific & precise'.
	self assert: (landscape quadrantNameFor: (landscape hunterNamed: 'frank')) equals: 'Noisy'.
	self assert: (landscape quadrantNameFor: (landscape hunterNamed: 'erin')) equals: 'Sharpshooters'.
	self assert: (landscape quadrantNameFor: (landscape hunterNamed: 'dave')) equals: 'Low impact'.
	self
		assert: ((landscape huntersInQuadrant: 'Sharpshooters') collect: [ :each | each username ]) asSet
		equals: #('erin' 'bob') asSet.
	self assert: (landscape huntersInQuadrant: 'Low impact') size equals: 2.
	^ landscape
]

{ #category : 'examples' }
GtBugbopHunterLandscapeExamples >> reports [
	<gtExample>
	<return: #GtBugbopReportsGroup>
	| reports |
	reports := GtBugbopExamples new insightsReportsGroup.
	self assert: reports size equals: 14.
	^ reports
]

{ #category : 'examples' }
GtBugbopHunterLandscapeExamples >> severityBar [
	<gtExample>
	<return: #BrHorizontalPane>
	| alice stencil bar |
	alice := self landscape hunterNamed: 'alice'.
	stencil := GtBugbopSeverityBarStencil new
			reports: alice reports;
			maxCount: 3;
			maxWidth: 300.
	self
		assert: (stencil severityGroups collect: [ :each | each key -> each value size ]) asArray
		equals: {'critical' -> 2. 'high' -> 1}.
	bar := stencil asElement.
	self assert: bar childrenCount equals: 2.
	self assert: (bar children collect: [ :each | each constraints horizontal resizer size ]) asArray equals: #(200.0 100.0).
	^ bar
]

{ #category : 'examples' }
GtBugbopHunterLandscapeExamples >> signalColors [
	<gtExample>
	<return: #Array>
	| colors |
	colors := {nil. 0. 1 / 2. 1} collect: [ :each | GtBugbopHunterLandscape signalColorFor: each ].
	self assert: colors first equals: (Color fromHexString: '9E9E9E').
	self assert: colors second equals: (Color fromHexString: 'C62828').
	self assert: colors third equals: (Color fromHexString: 'F9A825').
	self assert: colors fourth equals: (Color fromHexString: '2E7D32').
	self assert: (GtBugbopHunterLandscape textColorOn: colors third) equals: (Color fromHexString: '212121').
	self assert: (GtBugbopHunterLandscape textColorOn: colors second) equals: Color white.
	^ colors
]

{ #category : 'examples' }
GtBugbopHunterLandscapeExamples >> treemapTiles [
	<gtExample>
	<return: #BlElement>
	| landscape treemap |
	landscape := self landscape.
	treemap := landscape newTreemap.
	self assert: treemap childrenCount equals: 6.
	self
		assert: (treemap children collect: [ :each | each constraints treemap weight ]) asArray
		equals: #(3 3 2 2 2 2).
	self assert: (landscape tileLinesFor: (landscape hunterNamed: 'alice')) size equals: 4.
	^ treemap
]
