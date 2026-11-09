"
I am a client for the Bugbop REST API (https://bugbop.com/docs/api).

I follow the shape of the GT HTTP clients in gt4llm (e.g. GtLOpenAIClient): I hold the base URL, API key, a client builder that creates configured ZnClients, and a request history. Every endpoint is a GtBugbopAPICommand that I instantiate and perform; results are GtBugbopEntity / GtBugbopGroup objects that know me as their client.

I additionally handle Bugbop specifics: Link-header pagination (getAll:withParams:limit:), X-RateLimit-* tracking (rateLimit), automatic single retry on 429 for GETs when Retry-After is short, and structured errors (GtBugbopError).

The API key is read from ~/.secrets/bugbop-api-key.txt:

	GtBugbopClient withApiKeyFromFile
"
Class {
	#name : 'GtBugbopClient',
	#superclass : 'Object',
	#instVars : [
		'baseUrl',
		'apiKey',
		'history',
		'clientBuilder',
		'rateLimit',
		'maxRetryWait'
	],
	#classVars : [
		'ApiKeyFile'
	],
	#category : 'Gt4Bugbop-Client',
	#package : 'Gt4Bugbop',
	#tag : 'Client'
}

{ #category : 'accessing' }
GtBugbopClient class >> apiKeyFile [
	^ ApiKeyFile ifNil: [ ApiKeyFile := self defaultApiKeyFile ]
]

{ #category : 'accessing' }
GtBugbopClient class >> apiKeyFile: aFileReference [
	ApiKeyFile := aFileReference
]

{ #category : 'accessing' }
GtBugbopClient class >> apiKeyFileContents [
	^ self apiKeyFile exists
		ifTrue: [ self apiKeyFile contents trimBoth ]
		ifFalse: [ '' ]
]

{ #category : 'accessing' }
GtBugbopClient class >> defaultApiKeyFile [
	^ FileLocator home / '.secrets' / 'bugbop-api-key.txt'
]

{ #category : 'class initialization' }
GtBugbopClient class >> initialize [
	ApiKeyFile := self defaultApiKeyFile
]

{ #category : 'instance creation' }
GtBugbopClient class >> withApiKeyFromFile [
	^ self new apiKey: self apiKeyFileContents
]

{ #category : 'api - programs' }
GtBugbopClient >> accessRequestsForProgram: aProgramOrId [
	^ self accessRequestsForProgram: aProgramOrId withStatuses: nil
]

{ #category : 'api - programs' }
GtBugbopClient >> accessRequestsForProgram: aProgramOrId withStatuses: aCollectionOrNil [
	^ GtBugbopListAccessRequestsAPICommand new
		client: self;
		program: aProgramOrId;
		statuses: aCollectionOrNil;
		perform
]

{ #category : 'api - reports' }
GtBugbopClient >> activeReports [
	"Reports that are new, open or waiting on info"
	^ self
		reportsWithStatuses: GtBugbopReport activeStatuses
		severities: nil
		since: nil
]

{ #category : 'api - comments' }
GtBugbopClient >> addComment: aMarkdownString toReport: aReportOrId [
	"Posts a comment; the hunter is notified"
	^ GtBugbopCreateCommentAPICommand new
		client: self;
		report: aReportOrId;
		content: aMarkdownString;
		perform
]

{ #category : 'accessing' }
GtBugbopClient >> apiKey [
	^ apiKey
]

{ #category : 'accessing' }
GtBugbopClient >> apiKey: aString [
	apiKey := aString
]

{ #category : 'api - programs' }
GtBugbopClient >> approveAccessRequest: anAccessRequestOrId message: aStringOrNil [
	^ GtBugbopApproveAccessRequestAPICommand new
		client: self;
		accessRequest: anAccessRequestOrId;
		acceptanceMessage: aStringOrNil;
		perform
]

{ #category : 'accessing' }
GtBugbopClient >> baseUrl [
	^ baseUrl
]

{ #category : 'accessing' }
GtBugbopClient >> baseUrl: aZnUrlOrString [
	baseUrl := aZnUrlOrString asZnUrl
]

{ #category : 'api - programs' }
GtBugbopClient >> blockReporterOf: aReportOrId inProgram: aProgramOrId [
	^ GtBugbopBlockReporterAPICommand new
		client: self;
		program: aProgramOrId;
		report: aReportOrId;
		perform
]

{ #category : 'api - programs' }
GtBugbopClient >> blockUsername: aString inProgram: aProgramOrId [
	^ GtBugbopBlockReporterAPICommand new
		client: self;
		program: aProgramOrId;
		username: aString;
		perform
]

{ #category : 'api - programs' }
GtBugbopClient >> blockedReportersForProgram: aProgramOrId [
	^ GtBugbopListBlockedReportersAPICommand new
		client: self;
		program: aProgramOrId;
		perform
]

{ #category : 'private - http' }
GtBugbopClient >> checkForErrors: aRequestResponse [
	aRequestResponse isSuccess ifTrue: [ ^ aRequestResponse ].
	^ (GtBugbopError fromRequestResponse: aRequestResponse) signal
]

{ #category : 'accessing' }
GtBugbopClient >> clientBuilder [
	^ clientBuilder
]

{ #category : 'accessing' }
GtBugbopClient >> clientBuilder: aClientBuilder [
	clientBuilder := aClientBuilder
]

{ #category : 'api - reports' }
GtBugbopClient >> closeReport: aReportOrId asDuplicateOf: anOriginalReportOrIdOrNil [
	"nil uses the duplicate the AI suspected"
	^ GtBugbopCloseReportAsDuplicateAPICommand new
		client: self;
		report: aReportOrId;
		original: anOriginalReportOrIdOrNil;
		perform
]

{ #category : 'api - comments' }
GtBugbopClient >> commentAt: aCommentOrId [
	^ GtBugbopGetCommentAPICommand new
		client: self;
		comment: aCommentOrId;
		perform
]

{ #category : 'api - comments' }
GtBugbopClient >> commentsForReport: aReportOrId [
	"Oldest first"
	^ GtBugbopListCommentsAPICommand new
		client: self;
		report: aReportOrId;
		perform
]

{ #category : 'gt views' }
GtBugbopClient >> connectionRows [
	"Never show the API key itself"
	^ {
		'Base URL' -> baseUrl.
		'API key' -> (apiKey isEmptyOrNil ifTrue: [ 'missing' ] ifFalse: [ 'set (' , self class apiKeyFile fullName , ')' ]).
		'Rate limit' -> rateLimit.
		'Requests made' -> history size.
		'Max retry wait' -> maxRetryWait }
]

{ #category : 'api - user' }
GtBugbopClient >> currentUser [
	"Who the token belongs to; handy for checking the token works"
	^ GtBugbopGetUserAPICommand new
		client: self;
		perform
]

{ #category : 'initialization' }
GtBugbopClient >> defaultBaseUrl [
	^ 'https://bugbop.com/api/v1' asZnUrl
]

{ #category : 'accessing' }
GtBugbopClient >> defaultPageSize [
	"Bugbop accepts 1..100 per page"
	^ 100
]

{ #category : 'http' }
GtBugbopClient >> delete: aPath [
	<return: #GtBugbopRequestResponse>
	^ self
		execute: #DELETE
		url: (self urlForPath: aPath)
		params: #()
		entity: nil
]

{ #category : 'private - http' }
GtBugbopClient >> execute: aMethod url: aZnUrl params: aListOfAssocs entity: anObjectOrNil [
	"Send the request; a GET that hits a short per-minute rate limit is retried once after Retry-After"
	| requestResponse |
	requestResponse := self send: aMethod url: aZnUrl params: aListOfAssocs entity: anObjectOrNil.
	(self shouldRetry: requestResponse method: aMethod)
		ifFalse: [ ^ self checkForErrors: requestResponse ].
	requestResponse retryAfter wait.
	^ self checkForErrors: (self send: aMethod url: aZnUrl params: aListOfAssocs entity: anObjectOrNil)
]

{ #category : 'accessing' }
GtBugbopClient >> explorer [
	^ GtBugbopExplorer new client: self
]

{ #category : 'http' }
GtBugbopClient >> get: aPath [
	<return: #GtBugbopRequestResponse>
	^ self get: aPath withParams: #()
]

{ #category : 'http' }
GtBugbopClient >> get: aPath withParams: aListOfAssocs [
	<return: #GtBugbopRequestResponse>
	^ self
		execute: #GET
		url: (self urlForPath: aPath)
		params: aListOfAssocs
		entity: nil
]

{ #category : 'http' }
GtBugbopClient >> getAll: aPath withParams: aListOfAssocs limit: aMaxCountOrNil [
	"Follow Link rel=next until exhausted, or until aMaxCountOrNil items were fetched.
	Answer an Array of JSON dictionaries."
	| items requestResponse |
	items := OrderedCollection new.
	requestResponse := self
			get: aPath
			withParams: (self params: aListOfAssocs withPageSizeFor: aMaxCountOrNil).
	[ items addAll: requestResponse result.
	(self hasFetched: items size enoughFor: aMaxCountOrNil) not
		and: [ requestResponse nextPageUrl notNil ] ]
		whileTrue: [ requestResponse := self getUrl: requestResponse nextPageUrl ].
	^ (items first: (aMaxCountOrNil ifNil: [ items size ] ifNotNil: [ :max | max min: items size ])) asArray
]

{ #category : 'http' }
GtBugbopClient >> getUrl: anAbsoluteUrl [
	"GET an absolute URL handed out by the API, e.g. a Link rel=next or an api_url.
	Refuse other hosts so the bearer token never leaves bugbop.com."
	<return: #GtBugbopRequestResponse>
	| aUrl |
	aUrl := anAbsoluteUrl asZnUrl.
	(self isBugbopUrl: aUrl)
		ifFalse: [ ^ self error: 'Refusing to send the Bugbop token to ' , aUrl printString ].
	^ self
		execute: #GET
		url: aUrl
		params: #()
		entity: nil
]

{ #category : 'gt views' }
GtBugbopClient >> gtCallsFor: aView [
	<gtView>
	^ aView forward
		title: 'Calls';
		priority: 10;
		object: [ history ];
		view: #gtCallsFor:
]

{ #category : 'gt views' }
GtBugbopClient >> gtConnectionFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Connection';
		priority: 1;
		items: [ self connectionRows ];
		column: 'Property' text: [ :each | each key ] width: 140;
		column: 'Value' text: [ :each | each value gtDisplayString ];
		send: [ :each | each value ];
		actionUpdateButton
]

{ #category : 'gt actions' }
GtBugbopClient >> gtExplorerActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons inspect;
		label: 'Explore';
		tooltip: 'Open the high-level Bugbop explorer';
		priority: 1;
		action: [ :aButton | aButton phlow spawnObject: self explorer ]
]

{ #category : 'gt views' }
GtBugbopClient >> gtNotificationsFor: aView [
	<gtView>
	^ aView forward
		title: 'Notifications';
		priority: 4;
		object: [ self notifications ];
		view: #gtNotificationsFor:
]

{ #category : 'gt views' }
GtBugbopClient >> gtProgramsFor: aView [
	<gtView>
	^ aView forward
		title: 'Programs';
		priority: 2;
		object: [ self programs ];
		view: #gtProgramsFor:
]

{ #category : 'gt views' }
GtBugbopClient >> gtReportsFor: aView [
	<gtView>
	^ aView forward
		title: 'Reports';
		priority: 3;
		object: [ self reports ];
		view: #gtReportsFor:
]

{ #category : 'private - http' }
GtBugbopClient >> hasFetched: aCount enoughFor: aMaxCountOrNil [
	^ aMaxCountOrNil notNil and: [ aCount >= aMaxCountOrNil ]
]

{ #category : 'accessing' }
GtBugbopClient >> history [
	^ history
]

{ #category : 'api - programs' }
GtBugbopClient >> huntersForProgram: aProgramOrId [
	^ GtBugbopListProgramHuntersAPICommand new
		client: self;
		program: aProgramOrId;
		perform
]

{ #category : 'private - http' }
GtBugbopClient >> idFrom: anEntityOrId [
	^ anEntityOrId isString
		ifTrue: [ anEntityOrId ]
		ifFalse: [ anEntityOrId id ]
]

{ #category : 'initialization' }
GtBugbopClient >> initialize [
	super initialize.
	history := GtBugbopRequestHistory new.
	clientBuilder := GtBugbopClientZincBuilder new.
	rateLimit := GtBugbopRateLimit new.
	maxRetryWait := 60 seconds.
	self baseUrl: self defaultBaseUrl
]

{ #category : 'private - http' }
GtBugbopClient >> initializeClient [
	^ clientBuilder
		apiKey: apiKey;
		create
]

{ #category : 'private - http' }
GtBugbopClient >> isBugbopUrl: aZnUrl [
	^ aZnUrl scheme = self baseUrl scheme
		and: [ aZnUrl host = self baseUrl host
		and: [ aZnUrl portOrDefault = self baseUrl portOrDefault ] ]
]

{ #category : 'initialization' }
GtBugbopClient >> loadApiKeyFromFile [
	self apiKey: self class apiKeyFileContents
]

{ #category : 'api - notifications' }
GtBugbopClient >> markNotificationsRead: aCollectionOrNil [
	"nil marks everything read. Answers the number marked."
	^ GtBugbopMarkNotificationsReadAPICommand new
		client: self;
		notifications: aCollectionOrNil;
		perform
]

{ #category : 'private - http' }
GtBugbopClient >> maskedCopyOf: aZnRequest [
	| aCopy |
	aCopy := aZnRequest copy.
	aCopy headers: aZnRequest headers copy.
	(aCopy headers includesKey: 'Authorization')
		ifTrue: [ aCopy headers at: 'Authorization' put: 'Bearer ***' ].
	^ aCopy
]

{ #category : 'accessing' }
GtBugbopClient >> maxRetryWait [
	"Answer the longest Retry-After a GET will automatically wait out once before failing"
	^ maxRetryWait
]

{ #category : 'accessing' }
GtBugbopClient >> maxRetryWait: aDuration [
	maxRetryWait := aDuration
]

{ #category : 'api - notifications' }
GtBugbopClient >> notifications [
	"Newest first"
	^ GtBugbopListNotificationsAPICommand new
		client: self;
		perform
]

{ #category : 'private - http' }
GtBugbopClient >> params: aListOfAssocs withPageSizeFor: aMaxCountOrNil [
	| pageSize |
	pageSize := aMaxCountOrNil
			ifNil: [ self defaultPageSize ]
			ifNotNil: [ :max | (max max: 1) min: self defaultPageSize ].
	^ (aListOfAssocs reject: [ :each | each key = 'per_page' ]) asOrderedCollection
		add: 'per_page' -> pageSize;
		yourself
]

{ #category : 'http' }
GtBugbopClient >> patch: aPath withEntity: aDictionary [
	<return: #GtBugbopRequestResponse>
	^ self
		execute: #PATCH
		url: (self urlForPath: aPath)
		params: #()
		entity: aDictionary
]

{ #category : 'api - webhooks' }
GtBugbopClient >> pingWebhook: aWebhookOrId [
	^ GtBugbopPingWebhookAPICommand new
		client: self;
		webhook: aWebhookOrId;
		perform
]

{ #category : 'http' }
GtBugbopClient >> post: aPath withEntity: aDictionaryOrNil [
	<return: #GtBugbopRequestResponse>
	^ self
		execute: #POST
		url: (self urlForPath: aPath)
		params: #()
		entity: aDictionaryOrNil
]

{ #category : 'copying' }
GtBugbopClient >> postCopy [
	super postCopy.
	history := GtBugbopRequestHistory withAll: history items copy
]

{ #category : 'printing' }
GtBugbopClient >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		print: self baseUrl;
		nextPutAll: ')'
]

{ #category : 'api - programs' }
GtBugbopClient >> programAt: aProgramOrId [
	^ GtBugbopGetProgramAPICommand new
		client: self;
		program: aProgramOrId;
		perform
]

{ #category : 'api - programs' }
GtBugbopClient >> programs [
	"My programs plus public and restricted ones"
	^ GtBugbopListProgramsAPICommand new
		client: self;
		perform
]

{ #category : 'accessing' }
GtBugbopClient >> rateLimit [
	^ rateLimit
]

{ #category : 'private - http' }
GtBugbopClient >> recordRequestResponseFrom: aClient [
	"History keeps a copy of the request with the token masked, so no view can show it"
	| requestResponse |
	requestResponse := GtBugbopRequestResponse
			request: (self maskedCopyOf: aClient request)
			response: aClient response.
	rateLimit updateFromResponse: aClient response.
	history add: requestResponse.
	^ requestResponse
]

{ #category : 'api - programs' }
GtBugbopClient >> rejectAccessRequest: anAccessRequestOrId reason: aString [
	^ GtBugbopRejectAccessRequestAPICommand new
		client: self;
		accessRequest: anAccessRequestOrId;
		rejectionReason: aString;
		perform
]

{ #category : 'api - reports' }
GtBugbopClient >> reportAt: aReportOrId [
	^ GtBugbopGetReportAPICommand new
		client: self;
		report: aReportOrId;
		perform
]

{ #category : 'api - reports' }
GtBugbopClient >> reportSubmissionAt: aSubmissionOrId [
	^ GtBugbopGetReportSubmissionAPICommand new
		client: self;
		submission: aSubmissionOrId;
		perform
]

{ #category : 'api - reports' }
GtBugbopClient >> reports [
	"All my own reports plus every report in programs where I am staff, newest first"
	^ GtBugbopListReportsAPICommand new
		client: self;
		perform
]

{ #category : 'api - reports' }
GtBugbopClient >> reportsForProgram: aProgramOrId [
	^ GtBugbopListReportsAPICommand new
		client: self;
		program: aProgramOrId;
		perform
]

{ #category : 'api - reports' }
GtBugbopClient >> reportsUpdatedSince: aDateAndTime [
	"For incremental syncs"
	^ self reportsWithStatuses: nil severities: nil since: aDateAndTime
]

{ #category : 'api - reports' }
GtBugbopClient >> reportsWithStatuses: aStatusCollectionOrNil severities: aSeverityCollectionOrNil since: aDateAndTimeOrNil [
	^ GtBugbopListReportsAPICommand new
		client: self;
		statuses: aStatusCollectionOrNil;
		severities: aSeverityCollectionOrNil;
		since: aDateAndTimeOrNil;
		perform
]

{ #category : 'private - http' }
GtBugbopClient >> send: aMethod url: aZnUrl params: aListOfAssocs entity: anObjectOrNil [
	| aClient |
	aClient := self initializeClient.
	aClient
		url: aZnUrl;
		method: aMethod.
	aListOfAssocs do: [ :aPair | aClient queryAt: aPair key put: aPair value asString ].
	anObjectOrNil ifNotNil: [ aClient entity: (ZnEntity json: (STONJSON toString: anObjectOrNil)) ].
	[ aClient execute ] ensure: [ aClient close ].
	^ self recordRequestResponseFrom: aClient
]

{ #category : 'private - http' }
GtBugbopClient >> shouldRetry: aRequestResponse method: aMethod [
	aMethod = #GET ifFalse: [ ^ false ].
	aRequestResponse isRateLimited ifFalse: [ ^ false ].
	^ aRequestResponse retryAfter <= self maxRetryWait
]

{ #category : 'api - programs' }
GtBugbopClient >> unblockReporter: aBlockedReporterOrId [
	^ GtBugbopUnblockReporterAPICommand new
		client: self;
		blockedReporter: aBlockedReporterOrId;
		perform
]

{ #category : 'api - notifications' }
GtBugbopClient >> unreadNotifications [
	^ GtBugbopListNotificationsAPICommand new
		client: self;
		unreadOnly: true;
		perform
]

{ #category : 'api - reports' }
GtBugbopClient >> updateReport: aReportOrId fields: aDictionary [
	"PATCH only the given JSON fields, e.g. status, severity, duplicate_of_id, internal_notes"
	^ GtBugbopUpdateReportAPICommand new
		client: self;
		report: aReportOrId;
		fields: aDictionary;
		perform
]

{ #category : 'api - reports' }
GtBugbopClient >> updateReport: aReportOrId internalNotes: aMarkdownString [
	^ self updateReport: aReportOrId fields: (Dictionary with: 'internal_notes' -> aMarkdownString)
]

{ #category : 'api - reports' }
GtBugbopClient >> updateReport: aReportOrId severity: aSeverity [
	^ self updateReport: aReportOrId fields: (Dictionary with: 'severity' -> aSeverity)
]

{ #category : 'api - reports' }
GtBugbopClient >> updateReport: aReportOrId status: aStatus [
	^ self updateReport: aReportOrId fields: (Dictionary with: 'status' -> aStatus)
]

{ #category : 'private - http' }
GtBugbopClient >> urlForPath: aPath [
	"aPath is relative to the base URL, e.g. 'reports' or 'reports/<id>/comments'"
	^ self baseUrl copy
		addPathSegments: (aPath substrings: '/');
		yourself
]

{ #category : 'api - webhooks' }
GtBugbopClient >> webhooksForProgram: aProgramOrId [
	"Needs a token with the webhooks scope"
	^ GtBugbopListWebhooksAPICommand new
		client: self;
		program: aProgramOrId;
		perform
]
