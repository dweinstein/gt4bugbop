"
I hold examples for GtBugbopTriageBoard built from the offline insights fixture (GtBugbopExamples>>#insightsReportsGroup) at a fixed reference date, plus a read-only live example marked <noTest>.
"
Class {
	#name : 'GtBugbopTriageBoardExamples',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Examples',
	#package : 'Gt4Bugbop',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtBugbopTriageBoardExamples >> agingOldestFirst [
	<gtExample>
	<return: #GtBugbopTriageBoard>
	| aBoard |
	aBoard := self offlineBoard.
	self assert: (self idsOf: aBoard activeReports) equals: #('i5' 'i8' 'i10' 'i7' 'i9' 'i12').
	self assert: aBoard agingScaleDays equals: 59.
	self assert: (aBoard slaColorForDays: 54) equals: aBoard breachBandColor.
	self assert: (aBoard slaColorForDays: 26) equals: aBoard warningBandColor.
	^ aBoard
]

{ #category : 'examples' }
GtBugbopTriageBoardExamples >> attentionWithReasons [
	<gtExample>
	<return: #GtBugbopTriageBoard>
	| aBoard theIds |
	aBoard := self offlineBoard.
	theIds := self idsOf: aBoard attentionReports.
	self assert: theIds size equals: 6.
	self assert: (theIds first: 2) asSet equals: #('i5' 'i10') asSet.
	self assert: (theIds at: 3) equals: 'i12'.
	self assert: theIds last equals: 'i7'.
	self
		assert: ((aBoard attentionReasonsFor: (self report: 'i10' in: aBoard)) collect: [ :each | each label ]) asArray
		equals: #('stale 26d' 'waiting on hunter').
	self
		assert: ((aBoard attentionReasonsFor: (self report: 'i12' in: aBoard)) collect: [ :each | each label ]) asArray
		equals: #('critical untriaged').
	^ aBoard
]

{ #category : 'examples' }
GtBugbopTriageBoardExamples >> boardColumns [
	<gtExample>
	<return: #GtBugbopTriageBoard>
	| aBoard theColumns |
	aBoard := self offlineBoard.
	theColumns := aBoard columns.
	self assert: (theColumns collect: [ :each | each key ]) asArray equals: GtBugbopTriageBoard boardStatuses.
	self assert: (self idsOf: (aBoard reportsWithStatus: 'new')) equals: #('i12' 'i9' 'i7').
	self assert: (self idsOf: (aBoard reportsWithStatus: 'open')) equals: #('i8' 'i5').
	self assert: (aBoard reportsWithStatus: 'fixed') size equals: 3.
	self assert: (aBoard reportsWithStatus: 'duplicate') size equals: 2.
	self assert: (theColumns inject: 0 into: [ :sum :each | sum + each value size ]) equals: 14.
	^ aBoard
]

{ #category : 'examples' }
GtBugbopTriageBoardExamples >> cardFlags [
	<gtExample>
	<return: #GtBugbopTriageBoard>
	| aBoard |
	aBoard := self offlineBoard.
	self
		assert: ((aBoard cardFlagsFor: (self report: 'i7' in: aBoard)) collect: [ :each | each label ]) asArray
		equals: #('scope' 'AI: medium').
	self
		assert: ((aBoard cardFlagsFor: (self report: 'i5' in: aBoard)) collect: [ :each | each label ]) asArray
		equals: #('dup?' 'AI: high').
	self assert: (aBoard cardFlagsFor: (self report: 'i12' in: aBoard)) isEmpty.
	^ aBoard
]

{ #category : 'examples' }
GtBugbopTriageBoardExamples >> emptyBoard [
	<gtExample>
	<return: #GtBugbopTriageBoard>
	| aBoard |
	aBoard := GtBugbopTriageBoard forReports: GtBugbopReportsGroup new asOf: self referenceTime.
	self assert: aBoard activeReports isEmpty.
	self assert: aBoard attentionReports isEmpty.
	self assert: (aBoard columns allSatisfy: [ :each | each value isEmpty ]).
	self assert: aBoard newBoardElement notNil.
	self assert: aBoard newAgingElement notNil.
	^ aBoard
]

{ #category : 'accessing' }
GtBugbopTriageBoardExamples >> idsOf: aCollection [
	^ (aCollection collect: [ :each | each id ]) asArray
]

{ #category : 'examples - live' }
GtBugbopTriageBoardExamples >> liveBoard [
	"Read-only: fetches the real reports from the Bugbop API, never writes"
	<gtExample>
	<noTest>
	<return: #GtBugbopTriageBoard>
	^ GtBugbopTriageBoard forReports: GtBugbopLiveExamples new reports
]

{ #category : 'examples' }
GtBugbopTriageBoardExamples >> offlineBoard [
	<gtExample>
	<return: #GtBugbopTriageBoard>
	| aBoard |
	aBoard := GtBugbopTriageBoard
			forReports: GtBugbopExamples new insightsReportsGroup
			asOf: self referenceTime.
	self assert: aBoard reports size equals: 14.
	self assert: aBoard activeReports size equals: 6.
	self assert: (aBoard ageInDaysOf: (self report: 'i5' in: aBoard)) equals: 54.
	self assert: (aBoard ageLabelOf: (self report: 'i12' in: aBoard)) equals: '4d'.
	^ aBoard
]

{ #category : 'accessing' }
GtBugbopTriageBoardExamples >> referenceTime [
	"A fixed 'now' a few days after the newest offline fixture report"
	^ DateAndTime fromString: '2025-10-27T12:00:00+00:00'
]

{ #category : 'accessing' }
GtBugbopTriageBoardExamples >> report: anId in: aBoard [
	^ aBoard reports detect: [ :each | each id = anId ]
]

{ #category : 'examples' }
GtBugbopTriageBoardExamples >> titleWrapping [
	<gtExample>
	<return: #Array>
	| theLines |
	theLines := GtBugbopTriageBoard new
			titleLinesOf: 'Unvalidated OAuth Parameter Forwarding/Injection on the authorize endpoint of the tenant'
			maxChars: 32.
	self assert: theLines size equals: 2.
	self assert: (theLines allSatisfy: [ :each | each size <= 32 ]).
	self assert: (theLines last endsWith: '…').
	self assert: (GtBugbopTriageBoard new titleLinesOf: 'Short title' maxChars: 32) equals: #('Short title').
	^ theLines
]
