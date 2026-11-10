"
I hold examples for the per-report visuals: {{gtClass:GtBugbopReportCard}}, {{gtClass:GtBugbopConversation}} and {{gtClass:GtBugbopLifecycleEvent}}. Tested examples only use offline fixtures; the live examples are marked noTest and are read-only.
"
Class {
	#name : 'GtBugbopReportVisualsExamples',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Examples',
	#package : 'Gt4Bugbop',
	#tag : 'Examples'
}

{ #category : 'examples - card' }
GtBugbopReportVisualsExamples >> bountyCard [
	"A fixed critical report with a bounty and AI agreement: only severity and status pills"
	<gtExample>
	<return: #GtBugbopReportCard>
	| aCard |
	aCard := (self insightsReportWithId: 'i1') card.
	self assert: aCard pillLabels equals: #('CRITICAL' 'fixed').
	self assert: aCard report bountyAmountString equals: '$1,500.00'.
	self assert: (aCard asElement isKindOf: BlElement).
	^ aCard
]

{ #category : 'fixtures' }
GtBugbopReportVisualsExamples >> commentJsonBy: aUsername at: anIsoString content: aString internal: aBoolean [
	| aJson |
	aJson := GtBugbopExamples new commentJson.
	aJson at: 'id' put: aUsername , '-' , anIsoString.
	aJson at: 'created_at' put: anIsoString.
	aJson at: 'updated_at' put: anIsoString.
	aJson at: 'content' put: aString.
	(aJson at: 'user') at: 'username' put: aUsername.
	aBoolean ifTrue: [ aJson at: 'metadata' put: (Dictionary new at: 'internal' put: true; yourself) ].
	^ aJson
]

{ #category : 'examples - model' }
GtBugbopReportVisualsExamples >> comments [
	"Four comments on the offline XSS report: hunter, team, hunter, internal team note"
	<gtExample>
	<return: #GtBugbopCommentsGroup>
	| aGroup |
	aGroup := GtBugbopCommentsGroup withAll: ({
		self commentJsonBy: 'maverick' at: '2025-10-03T10:00:00Z' content: 'Adding a short PoC video.' , String lf , String lf , '```' , String lf , '<img src=x onerror=alert(1)>' , String lf , '```' internal: false.
		self commentJsonBy: 'programadmin' at: '2025-10-04T14:10:02Z' content: 'Thanks, reproduced. Fix is in review.' internal: false.
		self commentJsonBy: 'maverick' at: '2025-10-06T09:00:00Z' content: 'Great, thanks for the quick turnaround!' internal: false.
		self commentJsonBy: 'programadmin' at: '2025-10-06T10:00:00Z' content: 'Bounty approved by security lead.' internal: true }
			collect: [ :each | GtBugbopComment from: each ]).
	self assert: aGroup size equals: 4.
	self assert: (aGroup items select: #isInternal) size equals: 1.
	^ aGroup
]

{ #category : 'examples - card' }
GtBugbopReportVisualsExamples >> confirmedDuplicateCard [
	"A confirmed duplicate hides the redundant 'suspected duplicate' pill for the same report"
	<gtExample>
	<return: #GtBugbopReportCard>
	| aCard |
	aCard := (self insightsReportWithId: 'i2') card.
	self assert: aCard pillLabels equals: #('HIGH' 'duplicate' 'AI: critical' 'duplicate of i1').
	^ aCard
]

{ #category : 'examples - model' }
GtBugbopReportVisualsExamples >> conversation [
	<gtExample>
	<return: #GtBugbopConversation>
	| aConversation |
	aConversation := GtBugbopConversation forReport: GtBugbopExamples new report comments: self comments.
	self assert: aConversation hunterName equals: 'maverick'.
	self assert: aConversation hunterComments size equals: 2.
	self assert: aConversation teamComments size equals: 2.
	self assert: (aConversation commentsOnSide: #internal) size equals: 1.
	self assert: aConversation firstResponse authorName equals: 'programadmin'.
	self assert: aConversation firstResponse isInternal not.
	self
		assert: aConversation timeToFirstResponse
		equals: (Duration days: 1 hours: 4 minutes: 37 seconds: 9).
	self assert: (aConversation sortedComments collect: #authorName) asArray equals: #('maverick' 'programadmin' 'maverick' 'programadmin').
	^ aConversation
]

{ #category : 'examples - visuals' }
GtBugbopReportVisualsExamples >> conversationElement [
	"Four bubbles plus two 'later' separators (two silences of a day or more)"
	<gtExample>
	<return: #BlElement>
	| aConversation anElement |
	aConversation := self conversation.
	anElement := aConversation newConversationElement.
	self assert: (anElement isKindOf: BlElement).
	self assert: aConversation newBubbleRows size equals: 6.
	^ anElement
]

{ #category : 'examples - model' }
GtBugbopReportVisualsExamples >> conversationFromCommentsOnly [
	"Without a report, the earliest commenter is taken as the hunter and the clock starts at the first comment"
	<gtExample>
	<return: #GtBugbopConversation>
	| aConversation |
	aConversation := (GtBugbopConversation forComments: self comments) fetched.
	self assert: aConversation report isNil.
	self assert: aConversation hunterName equals: 'maverick'.
	self assert: aConversation startTime equals: (DateAndTime fromString: '2025-10-03T10:00:00Z').
	self assert: aConversation lifecycleEvents first isComment.
	self assert: aConversation timeToFirstResponse equals: (Duration days: 1 hours: 4 minutes: 10 seconds: 2).
	^ aConversation
]

{ #category : 'examples - card' }
GtBugbopReportVisualsExamples >> descriptionExcerpt [
	<gtExample>
	<return: #GtBugbopReportCard>
	| aReport aCard |
	aReport := GtBugbopExamples new report.
	aReport description: (String new: 1000 withAll: $a).
	aCard := aReport card.
	self assert: aCard descriptionExcerpt size equals: 604.
	self assert: (aCard descriptionExcerpt endsWith: ' ...').
	^ aCard
]

{ #category : 'examples - visuals' }
GtBugbopReportVisualsExamples >> formatting [
	<gtExample>
	<return: #Array>
	| durations |
	durations := {
		GtBugbopVisuals durationString: (Duration days: 1 hours: 4 minutes: 37 seconds: 9).
		GtBugbopVisuals durationString: (Duration days: 0 hours: 5 minutes: 12 seconds: 0).
		GtBugbopVisuals durationString: 10 days.
		GtBugbopVisuals durationString: 400 days }.
	self assert: durations equals: #('1d 4h' '5h 12m' '10d' '13mo').
	"Handles with digits keep them: the first two characters, upper-cased"
	self assert: (GtBugbopVisuals initialsOf: 'z3r0c00l') equals: 'Z3'.
	self assert: (GtBugbopVisuals initialsOf: '') equals: '?'.
	self assert: (GtBugbopVisuals excerptOf: 'short' limit: 600) equals: 'short'.
	^ durations
]

{ #category : 'fixtures' }
GtBugbopReportVisualsExamples >> insightsReportWithId: anId [
	^ GtBugbopExamples new insightsReportsGroup items detect: [ :each | each id = anId ]
]

{ #category : 'examples - visuals' }
GtBugbopReportVisualsExamples >> lifecycleElement [
	<gtExample>
	<return: #BlElement>
	| anElement |
	anElement := self conversation newLifecycleElement.
	self assert: (anElement isKindOf: BlElement).
	^ anElement
]

{ #category : 'examples - model' }
GtBugbopReportVisualsExamples >> lifecycleEvents [
	<gtExample>
	<return: #Array>
	| events |
	events := self conversation lifecycleEvents.
	self assert: events size equals: 7.
	self assert: events first kind equals: #created.
	self assert: events first target title equals: 'Stored XSS in profile bio'.
	self assert: events last kind equals: #now.
	self assert: (events select: #isComment) size equals: 4.
	self assert: (events select: [ :each | each kind = #updated ]) size equals: 1.
	self assert: (events collect: #time) asArray equals: ((events collect: #time) asSortedCollection asArray).
	self assert: ((events select: #isComment) collect: #side) asArray equals: #(#hunter #team #hunter #internal).
	^ events
]

{ #category : 'examples - live' }
GtBugbopReportVisualsExamples >> liveConversation [
	"Read-only: the most discussed real report's conversation, comments fetched"
	<gtExample>
	<noTest>
	<return: #GtBugbopConversation>
	^ GtBugbopLiveExamples new mostDiscussedReport conversation fetched
]

{ #category : 'examples - live' }
GtBugbopReportVisualsExamples >> liveReportCard [
	"Read-only: the most discussed real report as a card"
	<gtExample>
	<noTest>
	<return: #GtBugbopReportCard>
	^ GtBugbopLiveExamples new mostDiscussedReport card
]

{ #category : 'examples - model' }
GtBugbopReportVisualsExamples >> offlineConversationWithoutComments [
	"An offline report with a comment count but no client: the conversation is empty and says why"
	<gtExample>
	<return: #GtBugbopConversation>
	| aReport aConversation |
	aReport := self insightsReportWithId: 'i8'.
	aConversation := aReport conversation fetched.
	self assert: aConversation sortedComments isEmpty.
	self assert: aConversation firstResponse isNil.
	self assert: aConversation timeToFirstResponse isNil.
	self assert: (aConversation emptyMessage includesSubstring: 'offline').
	self assert: (aConversation lifecycleEvents collect: #kind) asArray equals: #(#created #now).
	^ aConversation
]

{ #category : 'examples - visuals' }
GtBugbopReportVisualsExamples >> readableMarkdown [
	"Links collapse to their text; escaped and plain bold markers disappear"
	<gtExample>
	<return: #ByteString>
	| aString |
	aString := GtBugbopVisuals readableMarkdown: 'See [the docs](https://x.example/a) \*\*now\*\*&nbsp;please **bold**'.
	self assert: aString equals: 'See the docs now please bold'.
	self assert: (GtBugbopVisuals markdownLiteText: '## Steps' , String cr , 'one') asString equals: 'Steps' , String cr , 'one'.
	^ aString
]

{ #category : 'examples - card' }
GtBugbopReportVisualsExamples >> scopeWarningCard [
	<gtExample>
	<return: #GtBugbopReportCard>
	| aCard |
	aCard := (self insightsReportWithId: 'i7') card.
	self assert: aCard pillLabels equals: #('LOW' 'new' 'AI: medium' 'scope warning').
	^ aCard
]

{ #category : 'examples - card' }
GtBugbopReportVisualsExamples >> suspectedDuplicateCard [
	<gtExample>
	<return: #GtBugbopReportCard>
	| aCard |
	aCard := (self insightsReportWithId: 'i5') card.
	self assert: aCard pillLabels equals: #('MEDIUM' 'open' 'AI: high' 'suspected duplicate of i4').
	self assert: (aCard linkedReportAt: 'i4') equals: 'i4'.
	^ aCard
]

{ #category : 'examples - model' }
GtBugbopReportVisualsExamples >> tailCompression [
	"The 2025 fixture has been idle for over a year, so the tail to now is capped at a third of the 3-day active span"
	<gtExample>
	<return: #Array>
	| aConversation events weights |
	aConversation := self conversation.
	events := aConversation lifecycleEvents.
	weights := aConversation gapWeightsFor: events.
	self assert: weights size equals: events size - 1.
	self assert: (aConversation isTailCompressed: events).
	self
		assert: (aConversation activeSpan: events)
		equals: ((DateAndTime fromString: '2025-10-06T10:00:00Z') - (DateAndTime fromString: '2025-10-03T09:32:53Z')) asSeconds.
	self assert: weights last < ((weights inject: 0 into: [ :a :b | a + b ]) / 2).
	self assert: (aConversation isBeforeFirstResponse: events first).
	self assert: (aConversation isBeforeFirstResponse: events last) not.
	^ weights asArray
]
