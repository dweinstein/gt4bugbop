"
I hold examples for {{gtClass:GtBugbopAiTriageReview}}. All tested examples use the offline fixture {{gtMethod:GtBugbopExamples>>#insightsReportsGroup}}; the live example is marked <noTest> and only reads data.
"
Class {
	#name : 'GtBugbopAiTriageReviewExamples',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Examples',
	#package : 'Gt4Bugbop',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtBugbopAiTriageReviewExamples >> agreementMatrixElement [
	<gtExample>
	<return: #BrVerticalPane>
	| anElement |
	anElement := self review newAgreementMatrixElement.
	self assert: anElement children size equals: 4.
	"header row + 4 severity rows, each 1 label + 5 cells"
	self assert: (anElement children at: 3) children size equals: 30.
	^ anElement
]

{ #category : 'examples' }
GtBugbopAiTriageReviewExamples >> agreementRate [
	<gtExample>
	<return: #GtBugbopAiTriageReview>
	| aReview |
	aReview := self review.
	self assert: aReview agreementRate equals: 9 / 13.
	self assert: aReview agreementPercentString equals: '69%'.
	self assert: aReview agreementCountString equals: '9 of 13 AI-rated reports (14 total)'.
	^ aReview
]

{ #category : 'examples' }
GtBugbopAiTriageReviewExamples >> disagreements [
	<gtExample>
	<return: #GtBugbopReportsGroup>
	| aReview aGroup distances |
	aReview := self review.
	aGroup := aReview disagreements.
	self assert: (aGroup items collect: #id) asSet equals: #('i2' 'i3' 'i5' 'i7') asSet.
	distances := aGroup items collect: [ :each | aReview severityDistance: each ].
	self assert: (distances asArray = (distances asSortedCollection: [ :a :b | a >= b ]) asArray).
	self assert: (aGroup items allSatisfy: [ :each | each aiSeverity ~= each severity ]).
	^ aGroup
]

{ #category : 'examples' }
GtBugbopAiTriageReviewExamples >> emptyReview [
	<gtExample>
	<return: #GtBugbopAiTriageReview>
	| aReview |
	aReview := GtBugbopAiTriageReview forReports: (GtBugbopReportsGroup withAll: #()).
	self assert: aReview agreementRate equals: 0.
	self assert: aReview agreementPercentString equals: '-'.
	self assert: aReview disagreements isEmpty.
	self assert: aReview triagedReports isEmpty.
	self assert: (aReview newAgreementMatrixElement isKindOf: BrLabel).
	^ aReview
]

{ #category : 'examples - live' }
GtBugbopAiTriageReviewExamples >> liveReview [
	"Read-only: built from the live Bugbop reports"
	<gtExample>
	<noTest>
	^ GtBugbopAiTriageReview forReports: GtBugbopLiveExamples new reports
]

{ #category : 'examples' }
GtBugbopAiTriageReviewExamples >> matrixCells [
	<gtExample>
	<return: #GtBugbopAiTriageReview>
	| aReview |
	aReview := self review.
	self assert: (aReview reportsAssigned: 'high' suggested: 'high') size equals: 3.
	self assert: (aReview reportsAssigned: 'high' suggested: 'critical') size equals: 1.
	self assert: (aReview reportsAssigned: 'medium' suggested: 'high') size equals: 2.
	self assert: (aReview reportsAssigned: 'low' suggested: nil) size equals: 1.
	self assert: (aReview reportsAssigned: 'critical' suggested: 'low') isEmpty.
	self assert: aReview maxCellCount equals: 3.
	self assert: aReview matrixColumns size equals: 5.
	^ aReview
]

{ #category : 'accessing' }
GtBugbopAiTriageReviewExamples >> reportsGroup [
	"Offline fixture: 14 reports, 13 with an AI severity, 4 disagreements"
	^ GtBugbopExamples new insightsReportsGroup
]

{ #category : 'examples' }
GtBugbopAiTriageReviewExamples >> review [
	<gtExample>
	<return: #GtBugbopAiTriageReview>
	| aReview |
	aReview := GtBugbopAiTriageReview forReports: self reportsGroup.
	self assert: aReview reports size equals: 14.
	self assert: aReview ratedReports size equals: 13.
	self assert: aReview unratedReports size equals: 1.
	self assert: (aReview unratedReports items collect: #id) asArray equals: #('i14').
	self assert: aReview agreements size equals: 9.
	^ aReview
]

{ #category : 'examples' }
GtBugbopAiTriageReviewExamples >> triagedReports [
	<gtExample>
	<return: #GtBugbopReportsGroup>
	| aReview aGroup ranks |
	aReview := self review.
	aGroup := aReview triagedReports.
	self assert: aGroup size equals: 13.
	self assert: aGroup items first aiSeverity equals: 'critical'.
	ranks := aGroup items collect: [ :each | GtBugbopReport severityRankOf: each aiSeverity ].
	self assert: ranks asArray equals: ranks asSortedCollection asArray.
	self assert: (aReview triageSummaryOf: aGroup items first) equals: 'Reasoning.'.
	^ aGroup
]

{ #category : 'examples' }
GtBugbopAiTriageReviewExamples >> underAndOverRated [
	<gtExample>
	<return: #GtBugbopAiTriageReview>
	| aReview anI2 |
	aReview := self review.
	self assert: aReview underRated size equals: 4.
	self assert: aReview overRated isEmpty.
	anI2 := aReview reports items detect: [ :each | each id = 'i2' ].
	self assert: (aReview aiLiftOf: anI2) equals: 1.
	self assert: (aReview severityDistance: anI2) equals: 1.
	^ aReview
]
