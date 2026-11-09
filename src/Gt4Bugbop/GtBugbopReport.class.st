"
I am a vulnerability report submitted to a Bugbop program. internalNotes, aiTriage and suspectedDuplicateOfId are only visible to program staff. Embedded report references (in notifications) only carry id, title and apiUrl; use #refreshed to fetch the full report.
"
Class {
	#name : 'GtBugbopReport',
	#superclass : 'GtBugbopEntity',
	#instVars : [
		'id',
		'title',
		'status',
		'severity',
		'scopeWarning',
		'description',
		'program',
		'user',
		'duplicateOfId',
		'suspectedDuplicateOfId',
		'commentsCount',
		'bountyTotalCents',
		'internalNotes',
		'aiTriage',
		'url',
		'apiUrl',
		'commentsUrl',
		'createdAt',
		'updatedAt'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'vocabulary' }
GtBugbopReport class >> activeStatuses [
	"Reports still needing attention from the program team or the hunter"
	^ #('new' 'open' 'needs_info')
]

{ #category : 'accessing' }
GtBugbopReport class >> serializationProperties [
	^ {
		#id -> #id.
		#title -> #title.
		#status -> #status.
		#severity -> #severity.
		#scope_warning -> #scopeWarning.
		#program -> #program.
		#user -> #user.
		#comments_count -> #commentsCount.
		#bounty_total_cents -> #bountyTotalCents.
		#duplicate_of_id -> #duplicateOfId.
		#suspected_duplicate_of_id -> #suspectedDuplicateOfId.
		#description -> #description.
		#internal_notes -> #internalNotes.
		#ai_triage -> #aiTriage.
		#created_at -> #createdAt.
		#updated_at -> #updatedAt.
		#url -> #url.
		#api_url -> #apiUrl.
		#comments_url -> #commentsUrl }
]

{ #category : 'vocabulary' }
GtBugbopReport class >> severities [
	"Most to least severe"
	^ #('critical' 'high' 'medium' 'low')
]

{ #category : 'vocabulary' }
GtBugbopReport class >> severityColorFor: aSeverity [
	aSeverity = 'critical' ifTrue: [ ^ Color fromHexString: 'B71C1C' ].
	aSeverity = 'high' ifTrue: [ ^ Color fromHexString: 'E65100' ].
	aSeverity = 'medium' ifTrue: [ ^ Color fromHexString: 'F9A825' ].
	aSeverity = 'low' ifTrue: [ ^ Color fromHexString: '1565C0' ].
	^ Color gray
]

{ #category : 'vocabulary' }
GtBugbopReport class >> severityRankOf: aSeverity [
	"1 for critical ... 4 for low, 5 for unknown"
	^ self severities indexOf: aSeverity ifAbsent: [ self severities size + 1 ]
]

{ #category : 'vocabulary' }
GtBugbopReport class >> severityText: aSeverity [
	^ (aSeverity ifNil: [ 'none' ]) asRopedText
		foreground: (self severityColorFor: aSeverity)
]

{ #category : 'vocabulary' }
GtBugbopReport class >> statusColorFor: aStatus [
	aStatus = 'new' ifTrue: [ ^ Color fromHexString: '6A1B9A' ].
	aStatus = 'open' ifTrue: [ ^ Color fromHexString: '1565C0' ].
	aStatus = 'needs_info' ifTrue: [ ^ Color fromHexString: 'EF6C00' ].
	aStatus = 'fixed' ifTrue: [ ^ Color fromHexString: '2E7D32' ].
	^ Color gray
]

{ #category : 'vocabulary' }
GtBugbopReport class >> statusText: aStatus [
	^ (aStatus ifNil: [ '' ]) asRopedText
		foreground: (self statusColorFor: aStatus)
]

{ #category : 'vocabulary' }
GtBugbopReport class >> statuses [
	"In workflow order"
	^ #('new' 'open' 'needs_info' 'fixed' 'wont_fix' 'duplicate' 'not_applicable')
]

{ #category : 'comparing' }
GtBugbopReport >> = anObject [
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ id = anObject id
]

{ #category : 'accessing' }
GtBugbopReport >> age [
	"Answer how long ago I was submitted"
	^ createdAt ifNotNil: [ DateAndTime now - createdAt ]
]

{ #category : 'accessing' }
GtBugbopReport >> ageString [
	| days |
	createdAt ifNil: [ ^ '' ].
	days := self age days.
	days >= 1 ifTrue: [ ^ days printString , 'd' ].
	^ self age hours printString , 'h'
]

{ #category : 'accessing' }
GtBugbopReport >> aiTriage [
	"Staff only: the AI triage write-up (Markdown)"
	^ aiTriage
]

{ #category : 'accessing' }
GtBugbopReport >> aiTriage: aString [
	aiTriage := aString
]

{ #category : 'accessing' }
GtBugbopReport >> apiUrl [
	^ apiUrl
]

{ #category : 'accessing' }
GtBugbopReport >> apiUrl: aString [
	apiUrl := aString
]

{ #category : 'accessing' }
GtBugbopReport >> bountyAmountString [
	^ (bountyTotalCents isNil or: [ bountyTotalCents isZero ])
		ifTrue: [ '' ]
		ifFalse: [ GtBugbopBountyRange amountStringFromCents: bountyTotalCents ]
]

{ #category : 'accessing' }
GtBugbopReport >> bountyTotalCents [
	^ bountyTotalCents
]

{ #category : 'accessing' }
GtBugbopReport >> bountyTotalCents: anInteger [
	bountyTotalCents := anInteger
]

{ #category : 'api' }
GtBugbopReport >> comments [
	^ self client commentsForReport: self
]

{ #category : 'accessing' }
GtBugbopReport >> commentsCount [
	^ commentsCount
]

{ #category : 'accessing' }
GtBugbopReport >> commentsCount: anInteger [
	commentsCount := anInteger
]

{ #category : 'accessing' }
GtBugbopReport >> commentsUrl [
	^ commentsUrl
]

{ #category : 'accessing' }
GtBugbopReport >> commentsUrl: aString [
	commentsUrl := aString
]

{ #category : 'accessing' }
GtBugbopReport >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
GtBugbopReport >> createdAt: aStringOrDateAndTime [
	createdAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopReport >> description [
	"Answer the report body (GitHub flavoured Markdown)"
	^ description
]

{ #category : 'accessing' }
GtBugbopReport >> description: aString [
	description := aString
]

{ #category : 'api' }
GtBugbopReport >> duplicateOf [
	^ duplicateOfId ifNotNil: [ :anId | self client reportAt: anId ]
]

{ #category : 'accessing' }
GtBugbopReport >> duplicateOfId [
	^ duplicateOfId
]

{ #category : 'accessing' }
GtBugbopReport >> duplicateOfId: aStringOrNil [
	duplicateOfId := aStringOrNil
]

{ #category : 'gt views' }
GtBugbopReport >> gtAiTriageFor: aView [
	<gtView>
	aiTriage isEmptyOrNil ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'AI triage';
		priority: 3;
		text: [ aiTriage asRopedText ]
]

{ #category : 'gt views' }
GtBugbopReport >> gtCommentsFor: aView [
	<gtView>
	(self client isNil or: [ commentsCount isNil or: [ commentsCount isZero ] ])
		ifTrue: [ ^ aView empty ].
	^ aView forward
		title: 'Comments (' , commentsCount printString , ')';
		priority: 5;
		object: [ self comments ];
		view: #gtConversationFor:
]

{ #category : 'gt views' }
GtBugbopReport >> gtDescriptionFor: aView [
	<gtView>
	description isEmptyOrNil ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'Description';
		priority: 2;
		text: [ description asRopedText ]
]

{ #category : 'gt views' }
GtBugbopReport >> gtInternalNotesFor: aView [
	<gtView>
	internalNotes isEmptyOrNil ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'Internal notes';
		priority: 4;
		text: [ internalNotes asRopedText ]
]

{ #category : 'gt views' }
GtBugbopReport >> gtOverviewFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Overview';
		priority: 1;
		items: [ self overviewRows ];
		column: 'Property' text: [ :each | each key ] width: 160;
		column: 'Value' text: [ :each | self overviewTextFor: each ];
		send: [ :each | self resolvedOverviewValue: each value ]
]

{ #category : 'testing' }
GtBugbopReport >> hasBounty [
	^ bountyTotalCents notNil and: [ bountyTotalCents > 0 ]
]

{ #category : 'comparing' }
GtBugbopReport >> hash [
	^ id hash
]

{ #category : 'accessing' }
GtBugbopReport >> id [
	^ id
]

{ #category : 'accessing' }
GtBugbopReport >> id: aString [
	id := aString
]

{ #category : 'accessing' }
GtBugbopReport >> internalNotes [
	"Staff only (Markdown)"
	^ internalNotes
]

{ #category : 'accessing' }
GtBugbopReport >> internalNotes: aString [
	internalNotes := aString
]

{ #category : 'testing' }
GtBugbopReport >> isActive [
	"Answer whether I still need attention (new, open or needs_info)"
	^ self class activeStatuses includes: status
]

{ #category : 'testing' }
GtBugbopReport >> isDuplicate [
	^ status = 'duplicate'
]

{ #category : 'testing' }
GtBugbopReport >> isReference [
	"Answer whether I am only an embedded reference (id, title, api url)"
	^ status isNil
]

{ #category : 'testing' }
GtBugbopReport >> isResolved [
	^ self isActive not
]

{ #category : 'testing' }
GtBugbopReport >> isValid [
	"Answer whether the report was accepted as a real issue"
	^ status = 'fixed' or: [ status = 'open' ]
]

{ #category : 'accessing' }
GtBugbopReport >> nestedEntities [
	^ { program. user } select: [ :each | each isKindOf: GtBugbopEntity ]
]

{ #category : 'gt views' }
GtBugbopReport >> overviewRows [
	^ {
		'Title' -> title.
		'Status' -> status.
		'Severity' -> severity.
		'Program' -> program.
		'Reporter' -> user.
		'Submitted' -> createdAt.
		'Updated' -> updatedAt.
		'Comments' -> commentsCount.
		'Bounty' -> self bountyAmountString.
		'Scope warning' -> scopeWarning.
		'Duplicate of' -> duplicateOfId.
		'Suspected duplicate of' -> suspectedDuplicateOfId } reject: [ :each | each value isNil or: [ each value = '' ] ]
]

{ #category : 'gt views' }
GtBugbopReport >> overviewTextFor: anAssociation [
	anAssociation key = 'Severity' ifTrue: [ ^ self class severityText: severity ].
	anAssociation key = 'Status' ifTrue: [ ^ self class statusText: status ].
	^ anAssociation value gtDisplayString
]

{ #category : 'printing' }
GtBugbopReport >> printOn: aStream [
	severity ifNotNil: [ aStream nextPut: $[; nextPutAll: severity; nextPutAll: '] ' ].
	aStream nextPutAll: (title ifNil: [ 'a Bugbop report' ]).
	status ifNotNil: [ aStream nextPutAll: ' ('; nextPutAll: status; nextPut: $) ]
]

{ #category : 'accessing' }
GtBugbopReport >> program [
	"Answer a GtBugbopProgram reference (id, name, urls); see GtBugbopProgram>>#refreshed"
	^ program
]

{ #category : 'accessing' }
GtBugbopReport >> program: aDictionaryOrProgram [
	program := self deserialize: aDictionaryOrProgram as: GtBugbopProgram
]

{ #category : 'api' }
GtBugbopReport >> refreshed [
	^ self client reportAt: self id
]

{ #category : 'accessing' }
GtBugbopReport >> reporterName [
	^ user ifNil: [ '' ] ifNotNil: [ :aUser | aUser username ]
]

{ #category : 'gt views' }
GtBugbopReport >> resolvedOverviewValue: anObject [
	"Embedded program references only carry id and name; spawn the full program instead"
	((anObject isKindOf: GtBugbopProgram) and: [ anObject isReference and: [ anObject client notNil ] ])
		ifTrue: [ ^ anObject refreshed ].
	^ anObject
]

{ #category : 'accessing' }
GtBugbopReport >> scopeWarning [
	"Answer whether the hunter submitted despite the AI scope check flagging it out of scope"
	^ scopeWarning
]

{ #category : 'accessing' }
GtBugbopReport >> scopeWarning: aBoolean [
	scopeWarning := aBoolean
]

{ #category : 'accessing' }
GtBugbopReport >> severity [
	"Answer low, medium, high, critical or nil"
	^ severity
]

{ #category : 'accessing' }
GtBugbopReport >> severity: aString [
	severity := aString
]

{ #category : 'accessing' }
GtBugbopReport >> severityRank [
	^ self class severityRankOf: severity
]

{ #category : 'accessing' }
GtBugbopReport >> status [
	"Answer new, open, needs_info, fixed, wont_fix, duplicate or not_applicable"
	^ status
]

{ #category : 'accessing' }
GtBugbopReport >> status: aString [
	status := aString
]

{ #category : 'api' }
GtBugbopReport >> suspectedDuplicateOf [
	^ suspectedDuplicateOfId ifNotNil: [ :anId | self client reportAt: anId ]
]

{ #category : 'accessing' }
GtBugbopReport >> suspectedDuplicateOfId [
	"Staff only: the report the AI thinks I duplicate"
	^ suspectedDuplicateOfId
]

{ #category : 'accessing' }
GtBugbopReport >> suspectedDuplicateOfId: aStringOrNil [
	suspectedDuplicateOfId := aStringOrNil
]

{ #category : 'accessing' }
GtBugbopReport >> title [
	^ title
]

{ #category : 'accessing' }
GtBugbopReport >> title: aString [
	title := aString
]

{ #category : 'accessing' }
GtBugbopReport >> updatedAt [
	^ updatedAt
]

{ #category : 'accessing' }
GtBugbopReport >> updatedAt: aStringOrDateAndTime [
	updatedAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopReport >> url [
	^ url
]

{ #category : 'accessing' }
GtBugbopReport >> url: aString [
	url := aString
]

{ #category : 'accessing' }
GtBugbopReport >> user [
	"Answer the reporter, a GtBugbopUser"
	^ user
]

{ #category : 'accessing' }
GtBugbopReport >> user: aDictionaryOrUser [
	user := self deserialize: aDictionaryOrUser as: GtBugbopUser
]

{ #category : 'accessing' }
GtBugbopReport >> webUrl [
	^ url
]
