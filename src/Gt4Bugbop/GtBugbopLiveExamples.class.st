"
Examples that call the live Bugbop API with the key in ~/.secrets/bugbop-api-key.txt. Marked <noTest> so automated sweeps skip them. They only perform reads.
"
Class {
	#name : 'GtBugbopLiveExamples',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Examples',
	#package : 'Gt4Bugbop',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtBugbopLiveExamples >> activeReports [
	<gtExample>
	<noTest>
	<return: #GtBugbopReportsGroup>
	| theReports |
	theReports := self client activeReports.
	self assert: (theReports allSatisfy: [ :each | each isActive ]).
	^ theReports
]

{ #category : 'examples' }
GtBugbopLiveExamples >> client [
	<gtExample>
	<noTest>
	<return: #GtBugbopClient>
	| aClient |
	aClient := GtBugbopClient withApiKeyFromFile.
	self assert: aClient apiKey notEmpty description: 'Put a Bugbop token in ~/.secrets/bugbop-api-key.txt'.
	^ aClient
]

{ #category : 'examples' }
GtBugbopLiveExamples >> currentUser [
	<gtExample>
	<noTest>
	<return: #GtBugbopUser>
	| aUser |
	aUser := self client currentUser.
	self assert: aUser username notEmpty.
	^ aUser
]

{ #category : 'examples' }
GtBugbopLiveExamples >> explorer [
	"The high-level entry point: overview, triage queue, severity x status, hunters, activity"
	<gtExample>
	<noTest>
	<return: #GtBugbopExplorer>
	^ GtBugbopExplorer withApiKeyFromFile
]

{ #category : 'examples' }
GtBugbopLiveExamples >> firstStaffProgram [
	<gtExample>
	<noTest>
	<return: #GtBugbopProgram>
	| aProgram |
	aProgram := self programs staffPrograms first refreshed.
	self assert: aProgram isReference not.
	^ aProgram
]

{ #category : 'examples' }
GtBugbopLiveExamples >> mostDiscussedReport [
	<gtExample>
	<noTest>
	<return: #GtBugbopReport>
	^ self reports detectMax: [ :each | each commentsCount ifNil: [ 0 ] ]
]

{ #category : 'examples' }
GtBugbopLiveExamples >> mostDiscussedReportComments [
	<gtExample>
	<noTest>
	<return: #GtBugbopCommentsGroup>
	| aReport theComments |
	aReport := self mostDiscussedReport.
	theComments := aReport comments.
	self assert: theComments size equals: aReport commentsCount.
	^ theComments
]

{ #category : 'examples' }
GtBugbopLiveExamples >> notifications [
	<gtExample>
	<noTest>
	<return: #GtBugbopNotificationsGroup>
	^ self client notifications
]

{ #category : 'examples' }
GtBugbopLiveExamples >> programs [
	<gtExample>
	<noTest>
	<return: #GtBugbopProgramsGroup>
	^ self client programs
]

{ #category : 'examples' }
GtBugbopLiveExamples >> reports [
	<gtExample>
	<noTest>
	<return: #GtBugbopReportsGroup>
	^ self client reports
]
