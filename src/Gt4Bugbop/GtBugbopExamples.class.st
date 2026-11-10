"
Offline examples: JSON parsing, pagination, error handling and rate limits using fixtures from https://bugbop.com/docs/api and a stub ZnClient. These run in automated sweeps.
"
Class {
	#name : 'GtBugbopExamples',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Examples',
	#package : 'Gt4Bugbop',
	#tag : 'Examples'
}

{ #category : 'examples - model' }
GtBugbopExamples >> accessRequest [
	<gtExample>
	<return: #GtBugbopAccessRequest>
	| aRequest |
	aRequest := GtBugbopAccessRequest from: self accessRequestJson.
	self assert: aRequest isPending.
	self assert: aRequest user username equals: 'hunter42'.
	self assert: aRequest user bountiesPaidCount equals: 3.
	self assert: aRequest user strikesCount equals: 0.
	^ aRequest
]

{ #category : 'fixtures' }
GtBugbopExamples >> accessRequestJson [
	^ STONJSON fromString: '{
  "id": "4e5f6a7b-8c9d-4e0f-9a1b-2c3d4e5f6a7b",
  "program": { "id": "1a2b3c4d", "name": "Web Security Program" },
  "url": "https://bugbop.com/programs/1a2b3c4d/program_access_requests/4e5f6a7b",
  "api_url": "https://bugbop.com/api/v1/access_requests/4e5f6a7b",
  "user": { "id": "3c4d5e6f", "username": "hunter42", "url": "https://bugbop.com/profile/hunter42", "created_at": "2025-06-01T09:00:00Z", "strikes_count": 0, "bounties_paid_count": 3 },
  "status": "pending",
  "message": "I''ve tested a lot of OAuth flows and would like to take a look at yours.",
  "rejection_reason": null,
  "acceptance_message": null,
  "created_at": "2025-10-20T02:00:00Z",
  "updated_at": "2025-10-21T04:00:00Z"
}'
]

{ #category : 'examples - model' }
GtBugbopExamples >> amountFormatting [
	<gtExample>
	<return: #Array>
	| amounts |
	amounts := #(0 5 99 100 125000 123456789) collect: [ :each | GtBugbopBountyRange amountStringFromCents: each ].
	self assert: amounts equals: #('$0.00' '$0.05' '$0.99' '$1.00' '$1,250.00' '$1,234,567.89').
	self assert: (GtBugbopBountyRange amountStringFromCents: nil) equals: ''.
	^ amounts
]

{ #category : 'examples - model' }
GtBugbopExamples >> comment [
	<gtExample>
	<return: #GtBugbopComment>
	| aComment |
	aComment := GtBugbopComment from: self commentJson.
	self assert: aComment authorName equals: 'programadmin'.
	self assert: aComment summary equals: 'Thanks, reproduced. Fix is in review.'.
	self assert: aComment reportId equals: '6f5e4d3c-2b1a-4c3d-9e8f-0a1b2c3d4e5f'.
	^ aComment
]

{ #category : 'fixtures' }
GtBugbopExamples >> commentJson [
	^ STONJSON fromString: '{
  "id": "3c4d5e6f-7a8b-4c9d-8e0f-1a2b3c4d5e6f",
  "report_id": "6f5e4d3c-2b1a-4c3d-9e8f-0a1b2c3d4e5f",
  "user": { "id": "2b3c4d5e-0000-4000-8000-000000000000", "username": "programadmin", "url": "https://bugbop.com/profile/programadmin", "created_at": "2024-01-01T00:00:00Z" },
  "content": "Thanks, reproduced. Fix is in review.",
  "metadata": {},
  "program": { "id": "1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d", "name": "Web Security Program" },
  "url": "https://bugbop.com/programs/1a2b3c4d/reports/6f5e4d3c#comment-3c4d5e6f",
  "api_url": "https://bugbop.com/api/v1/comments/3c4d5e6f-7a8b-4c9d-8e0f-1a2b3c4d5e6f",
  "report_url": "https://bugbop.com/api/v1/reports/6f5e4d3c-2b1a-4c3d-9e8f-0a1b2c3d4e5f",
  "created_at": "2025-10-04T14:10:02Z",
  "updated_at": "2025-10-04T14:10:02Z"
}'
]

{ #category : 'examples - http' }
GtBugbopExamples >> emptyErrorBodyIsHandled [
	"A non-JSON / empty error body must still produce a GtBugbopError (the reason we avoid forJsonREST)"
	<gtExample>
	<return: #GtBugbopError>
	| aClient anError |
	aClient := self stubClientResponding: [ :aRequest | ZnResponse statusCode: 404 ].
	anError := [ aClient reportAt: 'missing'. nil ] on: GtBugbopError do: [ :ex | ex return: ex ].
	self assert: anError isNotFound.
	self assert: anError apiMessage isNil.
	self assert: (anError messageText includesSubstring: '404').
	^ anError
]

{ #category : 'examples - explorer' }
GtBugbopExamples >> explorer [
	"An explorer over canned data; no network"
	<gtExample>
	<return: #GtBugbopExplorer>
	| anExplorer aClient |
	aClient := self stubClientResponding: [ :aRequest | self jsonResponse: #() code: 200 headers: Dictionary new ].
	anExplorer := GtBugbopExplorer new
			client: aClient;
			user: (GtBugbopUser new username: 'triager1');
			programs: (GtBugbopProgramsGroup from: { self programJson });
			reports: self reportsGroup;
			notifications: (GtBugbopNotificationsGroup from: { self notificationJson });
			yourself.
	self assert: anExplorer triageQueue size equals: 2.
	self assert: anExplorer triageQueue first severity equals: 'critical'.
	self assert: anExplorer hunters size equals: 2.
	self assert: anExplorer metrics size > 5.
	self assert: aClient history isEmpty.
	^ anExplorer
]

{ #category : 'examples - insights' }
GtBugbopExamples >> explorerInsights [
	"Every insight listed by the explorer builds from the explorer's reports, and hunters with too few resolved reports stay neutral"
	<gtExample>
	<return: #GtBugbopExplorer>
	| anExplorer aHunter |
	anExplorer := self explorer.
	anExplorer reports: self insightsReportsGroup.
	self assert: anExplorer insights size equals: 6.
	anExplorer insights do: [ :each | self assert: (anExplorer perform: each third) notNil ].
	self assert: anExplorer triageBoard class equals: GtBugbopTriageBoard.
	aHunter := anExplorer reports hunterSummaries items detect: [ :each | each username = 'carol' ].
	self assert: aHunter hasSignificantSignal not.
	self assert: aHunter signalColor equals: (GtBugbopHunterLandscape signalColorFor: nil).
	^ anExplorer
]

{ #category : 'examples - security' }
GtBugbopExamples >> historyMasksToken [
	"The token goes on the wire but never into the inspectable request history"
	<gtExample>
	<return: #GtBugbopRequestResponse>
	| aClient anExchange |
	aClient := self stubClientResponding: [ :aRequest | 
		self assert: (aRequest headers at: 'Authorization') equals: 'Bearer bugbop_pat_example'.
		self jsonResponse: (Dictionary with: 'id' -> 'u1' with: 'username' -> 'maverick') code: 200 headers: Dictionary new ].
	aClient currentUser.
	anExchange := aClient history first.
	self assert: (anExchange request headers at: 'Authorization') equals: 'Bearer ***'.
	self assert: (anExchange request printString includesSubstring: 'bugbop_pat_example') not.
	^ anExchange
]

{ #category : 'examples - groups' }
GtBugbopExamples >> hunterSummaries [
	<gtExample>
	<return: #GtBugbopHunterSummariesGroup>
	| theSummaries alice bob |
	theSummaries := self reportsGroup hunterSummaries.
	self assert: theSummaries size equals: 2.
	alice := theSummaries detect: [ :each | each username = 'alice' ].
	bob := theSummaries detect: [ :each | each username = 'bob' ].
	self assert: alice reportCount equals: 2.
	self assert: alice fixedCount equals: 1.
	self assert: alice signalRatioString equals: '100%'.
	self assert: alice highestSeverity equals: 'critical'.
	self assert: alice bountyAmountString equals: '$250.00'.
	self assert: bob rejectedCount equals: 1.
	self assert: bob signalRatioString equals: '0%'.
	^ theSummaries
]

{ #category : 'examples - insights' }
GtBugbopExamples >> insightsReportJsonWithId: anId title: aTitle status: aStatus severity: aSeverity aiSeverity: anAiSeverity reporter: aUsername bountyCents: anInteger createdAt: anIsoString duplicateOf: aDuplicateId suspectedDuplicateOf: aSuspectedId scopeWarning: aBoolean comments: aCount [
	^ (self reportJsonWithId: anId title: aTitle status: aStatus severity: aSeverity reporter: aUsername bountyCents: anInteger createdAt: anIsoString)
		at: 'ai_triage' put: (anAiSeverity ifNotNil: [ '### Severity: ' , anAiSeverity capitalized , String lf , String lf , 'Reasoning.' ]);
		at: 'duplicate_of_id' put: aDuplicateId;
		at: 'suspected_duplicate_of_id' put: aSuspectedId;
		at: 'scope_warning' put: aBoolean;
		at: 'comments_count' put: aCount;
		at: 'updated_at' put: anIsoString;
		yourself
]

{ #category : 'examples - insights' }
GtBugbopExamples >> insightsReportsGroup [
	"A 14-report fixture spanning 8 weeks, with confirmed and suspected duplicate chains, AI severity disagreements, scope warnings and bounties. Shared by the insight examples."
	<gtExample>
	<return: #GtBugbopReportsGroup>
	| aGroup rows |
	rows := #(
		#('i1' 'SQL injection in search' 'fixed' 'critical' 'critical' 'alice' 150000 '2025-08-18T09:00:00Z' nil nil false 6)
		#('i2' 'SQLi via search param (again)' 'duplicate' 'high' 'critical' 'carol' 0 '2025-08-20T12:00:00Z' 'i1' 'i1' false 2)
		#('i3' 'Search box SQL error leak' 'duplicate' 'medium' 'high' 'dave' 0 '2025-08-25T15:00:00Z' 'i1' 'i1' false 1)
		#('i4' 'Stored XSS in profile bio' 'fixed' 'high' 'high' 'bob' 50000 '2025-09-01T10:00:00Z' nil nil false 4)
		#('i5' 'XSS in bio field' 'open' 'medium' 'high' 'erin' 0 '2025-09-03T08:00:00Z' nil 'i4' false 1)
		#('i6' 'Missing HSTS header' 'not_applicable' 'low' 'low' 'frank' 0 '2025-09-08T11:00:00Z' nil nil true 0)
		#('i7' 'Staging tenant exposed' 'new' 'low' 'medium' 'frank' 0 '2025-10-20T09:00:00Z' nil nil true 0)
		#('i8' 'IDOR on invoices' 'open' 'high' 'high' 'alice' 0 '2025-09-22T14:00:00Z' nil nil false 9)
		#('i9' 'Invoice IDOR via export' 'new' 'high' 'high' 'carol' 0 '2025-10-21T16:00:00Z' nil 'i8' false 0)
		#('i10' 'Rate limit bypass on login' 'needs_info' 'medium' 'medium' 'bob' 0 '2025-10-01T07:00:00Z' nil nil false 3)
		#('i11' 'Clickjacking on settings' 'wont_fix' 'low' 'low' 'dave' 0 '2025-09-15T13:00:00Z' nil nil false 1)
		#('i12' 'RCE via image upload' 'new' 'critical' 'critical' 'alice' 0 '2025-10-22T18:00:00Z' nil nil false 2)
		#('i13' 'Subdomain takeover' 'fixed' 'medium' 'medium' 'erin' 25000 '2025-09-29T10:00:00Z' nil nil false 5)
		#('i14' 'Out-of-scope CDN bucket' 'not_applicable' 'low' nil 'frank' 0 '2025-10-06T12:00:00Z' nil nil true 0)).
	aGroup := GtBugbopReportsGroup from: (rows collect: [ :r |
		self insightsReportJsonWithId: (r at: 1) title: (r at: 2) status: (r at: 3) severity: (r at: 4) aiSeverity: (r at: 5) reporter: (r at: 6) bountyCents: (r at: 7) createdAt: (r at: 8) duplicateOf: (r at: 9) suspectedDuplicateOf: (r at: 10) scopeWarning: (r at: 11) comments: (r at: 12) ]).
	self assert: aGroup size equals: 14.
	self assert: (aGroup items detect: [ :e | e id = 'i3' ]) aiSeverity equals: 'high'.
	self assert: (aGroup items detect: [ :e | e id = 'i3' ]) aiAgreesOnSeverity not.
	self assert: (aGroup items detect: [ :e | e id = 'i14' ]) aiSeverity isNil.
	self assert: (aGroup items select: #hasScopeWarning) size equals: 3.
	self assert: (aGroup items select: #isSuspectedDuplicate) size equals: 4.
	^ aGroup
]

{ #category : 'fixtures' }
GtBugbopExamples >> jsonResponse: aCollection code: anInteger headers: aDictionary [
	"A canned ZnResponse with a JSON body"
	| aResponse |
	aResponse := ZnResponse statusCode: anInteger.
	aCollection ifNotNil: [ aResponse entity: (ZnEntity json: (STONJSON toString: aCollection)) ].
	aDictionary keysAndValuesDo: [ :aName :aValue | aResponse headers at: aName put: aValue ].
	^ aResponse
]

{ #category : 'examples - http' }
GtBugbopExamples >> limitStopsPagination [
	<gtExample>
	<return: #GtBugbopReportsGroup>
	| aClient theReports |
	aClient := self stubClientResponding: [ :aRequest | 
		self
			jsonResponse: ((1 to: 3) collect: [ :i | self reportJsonWithId: i printString title: 'R' status: 'new' severity: 'low' reporter: 'x' bountyCents: 0 createdAt: '2025-10-01T00:00:00Z' ])
			code: 200
			headers: { 'Link' -> '<https://bugbop.com/api/v1/reports?page=2>; rel="next"' } asDictionary ].
	theReports := GtBugbopListReportsAPICommand new
			client: aClient;
			limit: 2;
			perform.
	self assert: theReports size equals: 2.
	self assert: aClient history size equals: 1.
	self assert: (aClient history first url queryAt: 'per_page') equals: '2'.
	^ theReports
]

{ #category : 'examples - http' }
GtBugbopExamples >> linkHeaderParsing [
	<gtExample>
	<return: #Dictionary>
	| links |
	links := GtBugbopRequestResponse parseLinkHeader: '<https://bugbop.com/api/v1/reports?page=2&per_page=30&status=new,open>; rel="next", <https://bugbop.com/api/v1/reports?page=1&per_page=30>; rel="first", <https://bugbop.com/api/v1/reports?page=7&per_page=30>; rel="last"'.
	self assert: links keys asSet equals: #('next' 'first' 'last') asSet.
	self assert: ((links at: 'next') queryAt: 'page') equals: '2'.
	self assert: ((links at: 'next') queryAt: 'status') equals: 'new,open'.
	self assert: ((links at: 'last') queryAt: 'page') equals: '7'.
	self assert: (GtBugbopRequestResponse parseLinkHeader: '') isEmpty.
	^ links
]

{ #category : 'examples - security' }
GtBugbopExamples >> markingEmptySelectionReadDoesNothing [
	"An empty selection must not turn into 'mark everything read'"
	<gtExample>
	<return: #SmallInteger>
	| aClient marked |
	aClient := self stubClientResponding: [ :aRequest | self error: 'must not be called' ].
	marked := aClient markNotificationsRead: #().
	self assert: marked equals: 0.
	self assert: aClient history isEmpty.
	^ marked
]

{ #category : 'examples - model' }
GtBugbopExamples >> notification [
	<gtExample>
	<return: #GtBugbopNotification>
	| aNotification |
	aNotification := GtBugbopNotification from: self notificationJson.
	self assert: aNotification isUnread.
	self assert: aNotification kindLabel equals: 'report created'.
	self assert: aNotification subject equals: 'Stored XSS in profile bio'.
	self assert: aNotification report isReference.
	self assert: aNotification program name equals: 'Web Security Program'.
	^ aNotification
]

{ #category : 'fixtures' }
GtBugbopExamples >> notificationJson [
	^ STONJSON fromString: '{
  "id": "e1f2a3b4-0000-4000-8000-000000000000",
  "kind": "report_created",
  "read": false,
  "data": { "program_id": "1a2b3c4d", "report_id": "6f5e4d3c", "title": "Stored XSS in profile bio", "severity": "high", "status": "new" },
  "url": "https://bugbop.com/notifications/e1f2a3b4/goto",
  "created_at": "2025-10-03T09:32:53Z",
  "program": { "id": "1a2b3c4d", "name": "Web Security Program" },
  "report": { "id": "6f5e4d3c", "title": "Stored XSS in profile bio", "api_url": "https://bugbop.com/api/v1/reports/6f5e4d3c" }
}'
]

{ #category : 'examples - model' }
GtBugbopExamples >> notificationWithNullTitle [
	<gtExample>
	<return: #GtBugbopNotification>
	| aJson aNotification |
	aJson := self notificationJson.
	aJson removeKey: 'report'.
	(aJson at: 'data') at: 'title' put: nil.
	aNotification := GtBugbopNotification from: aJson.
	self assert: aNotification subject equals: 'Web Security Program'.
	self assert: (aNotification printString includesSubstring: 'report created').
	^ aNotification
]

{ #category : 'examples - http' }
GtBugbopExamples >> paginatedClient [
	"Two pages linked with rel=next are fetched and merged, and rate limit headers are tracked"
	<gtExample>
	<return: #GtBugbopClient>
	| aClient theReports |
	aClient := self stubClientResponding: [ :aRequest | 
		(aRequest url queryAt: 'page' ifAbsent: [ '1' ]) = '1'
			ifTrue: [ self
				jsonResponse: { self reportJsonWithId: 'a' title: 'A' status: 'new' severity: 'low' reporter: 'x' bountyCents: 0 createdAt: '2025-10-01T00:00:00Z' }
				code: 200
				headers: { 'Link' -> '<https://bugbop.com/api/v1/reports?page=2&per_page=100>; rel="next"'. 'X-Total-Count' -> '2'. 'X-RateLimit-Limit' -> '1000'. 'X-RateLimit-Remaining' -> '999'. 'X-RateLimit-Reset' -> '1760151600'. 'X-RateLimit-Resource' -> 'read' } asDictionary ]
			ifFalse: [ self
				jsonResponse: { self reportJsonWithId: 'b' title: 'B' status: 'open' severity: 'high' reporter: 'y' bountyCents: 0 createdAt: '2025-10-02T00:00:00Z' }
				code: 200
				headers: { 'X-RateLimit-Limit' -> '1000'. 'X-RateLimit-Remaining' -> '998'. 'X-RateLimit-Resource' -> 'read' } asDictionary ] ].
	theReports := aClient reports.
	self assert: (theReports collect: #id) asArray equals: #('a' 'b').
	self assert: theReports client == aClient.
	self assert: theReports first client == aClient.
	self assert: aClient history size equals: 2.
	self assert: aClient history first totalCount equals: 2.
	self assert: ((aClient history first url queryAt: 'per_page') = '100').
	self assert: aClient rateLimit remaining equals: 998.
	self assert: aClient rateLimit resource equals: 'read'.
	^ aClient
]

{ #category : 'examples - http' }
GtBugbopExamples >> postSendsJsonEntity [
	<gtExample>
	<return: #Dictionary>
	| aClient sentBody sentAuthorization |
	aClient := self stubClientResponding: [ :aRequest | 
		sentBody := STONJSON fromString: aRequest entity contents.
		sentAuthorization := aRequest headers at: 'Authorization'.
		self jsonResponse: self commentJson code: 201 headers: Dictionary new ].
	aClient addComment: 'Thanks, reproduced.' toReport: '6f5e4d3c'.
	self assert: sentBody equals: (Dictionary with: 'content' -> 'Thanks, reproduced.').
	self assert: sentAuthorization equals: 'Bearer bugbop_pat_example'.
	self assert: aClient history first url path equals: 'api/v1/reports/6f5e4d3c/comments'.
	^ sentBody
]

{ #category : 'examples - model' }
GtBugbopExamples >> program [
	<gtExample>
	<return: #GtBugbopProgram>
	| aProgram |
	aProgram := GtBugbopProgram from: self programJson.
	self assert: aProgram name equals: 'Web Security Program'.
	self assert: aProgram isCashProgram.
	self assert: aProgram isStaff.
	self assert: aProgram canTriage.
	self assert: aProgram canManageWebhooks not.
	self assert: aProgram isReference not.
	self assert: (aProgram bountyRanges collect: #severity) asArray equals: #('critical' 'high' 'medium' 'low').
	self assert: aProgram bountyRanges first maxAmountString equals: '$1,000.00'.
	^ aProgram
]

{ #category : 'fixtures' }
GtBugbopExamples >> programJson [
	"The program object from https://bugbop.com/docs/api"
	^ STONJSON fromString: '{
  "id": "1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d",
  "name": "Web Security Program",
  "site": "https://app.example.com",
  "visibility": "private",
  "bounty_type": "cash",
  "bounty_paused": false,
  "ai_triage": true,
  "require_kyc": false,
  "description": "Everything under *.example.com is in scope...",
  "bounty_ranges": {
    "critical": { "min_cents": 50000, "max_cents": 100000 },
    "high": { "min_cents": 25000, "max_cents": 50000 },
    "medium": { "min_cents": 10000, "max_cents": 25000 },
    "low": { "min_cents": 5000, "max_cents": 10000 }
  },
  "role": "triager",
  "url": "https://bugbop.com/programs/1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d",
  "api_url": "https://bugbop.com/api/v1/programs/1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d",
  "reports_url": "https://bugbop.com/api/v1/programs/1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d/reports",
  "created_at": "2024-06-01T00:00:00Z",
  "updated_at": "2025-09-30T11:20:41Z"
}'
]

{ #category : 'examples - http' }
GtBugbopExamples >> rateLimitedGetIsRetriedOnce [
	<gtExample>
	<return: #GtBugbopClient>
	| aClient calls aUser |
	calls := 0.
	aClient := self stubClientResponding: [ :aRequest | 
		calls := calls + 1.
		calls = 1
			ifTrue: [ self jsonResponse: (Dictionary with: 'message' -> 'Rate limited') code: 429 headers: { 'Retry-After' -> '0' } asDictionary ]
			ifFalse: [ self jsonResponse: (Dictionary with: 'id' -> 'u1' with: 'username' -> 'maverick') code: 200 headers: Dictionary new ] ].
	aUser := aClient currentUser.
	self assert: aUser username equals: 'maverick'.
	self assert: calls equals: 2.
	self assert: (aClient history collect: #statusCode) asArray equals: #(429 200).
	^ aClient
]

{ #category : 'examples - http' }
GtBugbopExamples >> rateLimitedWriteIsNotRetried [
	"Writes may have side effects (emails, webhooks), so a 429 on POST is surfaced, not retried"
	<gtExample>
	<return: #GtBugbopError>
	| aClient anError |
	aClient := self stubClientResponding: [ :aRequest | 
		self jsonResponse: (Dictionary with: 'message' -> 'Rate limited') code: 429 headers: { 'Retry-After' -> '0' } asDictionary ].
	anError := [ aClient addComment: 'hi' toReport: 'r1'. nil ] on: GtBugbopError do: [ :ex | ex return: ex ].
	self assert: anError isRateLimited.
	self assert: aClient history size equals: 1.
	^ anError
]

{ #category : 'examples - model' }
GtBugbopExamples >> report [
	<gtExample>
	<return: #GtBugbopReport>
	| aReport |
	aReport := GtBugbopReport from: self reportJson.
	self assert: aReport title equals: 'Stored XSS in profile bio'.
	self assert: aReport status equals: 'open'.
	self assert: aReport severity equals: 'high'.
	self assert: aReport severityRank equals: 2.
	self assert: aReport isActive.
	self assert: aReport commentsCount equals: 3.
	self assert: aReport bountyAmountString equals: '$250.00'.
	self assert: aReport createdAt equals: (DateAndTime fromString: '2025-10-03T09:32:53Z').
	self assert: (aReport program isKindOf: GtBugbopProgram).
	self assert: aReport program name equals: 'Web Security Program'.
	self assert: aReport program isReference.
	self assert: aReport user username equals: 'maverick'.
	self assert: aReport duplicateOfId isNil.
	self assert: aReport internalNotes notNil.
	self assert: (aReport rawData at: 'id') equals: aReport id.
	^ aReport
]

{ #category : 'examples - http' }
GtBugbopExamples >> reportFilters [
	"Filters become comma separated query parameters"
	<gtExample>
	<return: #ZnUrl>
	| aClient aUrl |
	aClient := self stubClientResponding: [ :aRequest | self jsonResponse: #() code: 200 headers: Dictionary new ].
	aClient
		reportsWithStatuses: #('new' 'open')
		severities: #('high' 'critical')
		since: (DateAndTime fromString: '2025-10-01T00:00:00Z').
	aUrl := aClient history first url.
	self assert: aUrl path equals: 'api/v1/reports'.
	self assert: (aUrl queryAt: 'status') equals: 'new,open'.
	self assert: (aUrl queryAt: 'severity') equals: 'high,critical'.
	self assert: ((aUrl queryAt: 'since') beginsWith: '2025-10-01T00:00:00').
	^ aUrl
]

{ #category : 'fixtures' }
GtBugbopExamples >> reportJson [
	"The report object from https://bugbop.com/docs/api"
	^ STONJSON fromString: '{
  "id": "6f5e4d3c-2b1a-4c3d-9e8f-0a1b2c3d4e5f",
  "title": "Stored XSS in profile bio",
  "status": "open",
  "severity": "high",
  "scope_warning": false,
  "description": "## Steps\n\n1. Set your bio to `<img src=x onerror=alert(1)>`\n2. View the public profile",
  "program": { "id": "1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d", "name": "Web Security Program", "url": "https://bugbop.com/programs/1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d", "api_url": "https://bugbop.com/api/v1/programs/1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d" },
  "user": { "id": "9f8e7d6c-5b4a-4f3e-8d2c-1b0a9f8e7d6c", "username": "maverick", "url": "https://bugbop.com/profile/maverick", "created_at": "2024-11-02T08:12:00Z" },
  "duplicate_of_id": null,
  "comments_count": 3,
  "bounty_total_cents": 25000,
  "url": "https://bugbop.com/programs/1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d/reports/6f5e4d3c-2b1a-4c3d-9e8f-0a1b2c3d4e5f",
  "api_url": "https://bugbop.com/api/v1/reports/6f5e4d3c-2b1a-4c3d-9e8f-0a1b2c3d4e5f",
  "comments_url": "https://bugbop.com/api/v1/reports/6f5e4d3c-2b1a-4c3d-9e8f-0a1b2c3d4e5f/comments",
  "created_at": "2025-10-03T09:32:53Z",
  "updated_at": "2025-10-04T14:10:02Z",
  "suspected_duplicate_of_id": null,
  "internal_notes": "Reproduced on staging, fix in PR #412",
  "ai_triage": "### Severity: High\n\n..."
}'
]

{ #category : 'fixtures' }
GtBugbopExamples >> reportJsonWithId: anId title: aTitle status: aStatus severity: aSeverity reporter: aUsername bountyCents: anInteger createdAt: anIsoString [
	| aDictionary |
	aDictionary := self reportJson copy.
	aDictionary
		at: 'id' put: anId;
		at: 'title' put: aTitle;
		at: 'status' put: aStatus;
		at: 'severity' put: aSeverity;
		at: 'bounty_total_cents' put: anInteger;
		at: 'created_at' put: anIsoString;
		at: 'user' put: (Dictionary new at: 'id' put: aUsername , '-id'; at: 'username' put: aUsername; yourself).
	^ aDictionary
]

{ #category : 'examples - groups' }
GtBugbopExamples >> reportsGroup [
	<gtExample>
	<return: #GtBugbopReportsGroup>
	| aGroup |
	aGroup := GtBugbopReportsGroup from: {
		self reportJsonWithId: 'r1' title: 'RCE in uploader' status: 'new' severity: 'critical' reporter: 'alice' bountyCents: 0 createdAt: '2025-10-06T10:00:00Z'.
		self reportJsonWithId: 'r2' title: 'Stored XSS' status: 'fixed' severity: 'high' reporter: 'alice' bountyCents: 25000 createdAt: '2025-09-29T10:00:00Z'.
		self reportJsonWithId: 'r3' title: 'Missing header' status: 'not_applicable' severity: 'low' reporter: 'bob' bountyCents: 0 createdAt: '2025-09-15T10:00:00Z'.
		self reportJsonWithId: 'r4' title: 'Open redirect' status: 'needs_info' severity: 'medium' reporter: 'bob' bountyCents: 0 createdAt: '2025-10-07T10:00:00Z' }.
	self assert: aGroup size equals: 4.
	self assert: aGroup active size equals: 2.
	self assert: (aGroup active isKindOf: GtBugbopReportsGroup).
	self assert: (aGroup withStatus: 'fixed') size equals: 1.
	self assert: aGroup bountyAmountString equals: '$250.00'.
	self assert: (aGroup sortedBySeverity collect: #id) asArray equals: #('r1' 'r2' 'r4' 'r3').
	self assert: ((aGroup byReporter: 'bob') collect: #id) asSet equals: #('r3' 'r4') asSet.
	self assert: (aGroup matching: 'xss') size equals: 1.
	self assert: (aGroup countWithSeverity: 'critical' status: 'new') equals: 1.
	self assert: (aGroup statusBreakdown collect: #key) asArray equals: #('new' 'needs_info' 'fixed' 'not_applicable').
	^ aGroup
]

{ #category : 'examples - docs' }
GtBugbopExamples >> screenshots [
	"The README screenshots render offline examples only, at their declared size"
	<gtExample>
	<return: #GtBugbopScreenshots>
	| aSet aForm |
	aSet := GtBugbopScreenshots default.
	self assert: aSet shots size equals: 12.
	self assert: (aSet shots collect: #fileName) asSet size equals: 12.
	self assert: (aSet shots noneSatisfy: [ :each | each exampleMethod hasPragmaNamed: #noTest ]).
	aForm := (aSet named: 'report-card.png') asForm.
	self assert: aForm extent equals: (aSet named: 'report-card.png') extent.
	^ aSet
]

{ #category : 'fixtures' }
GtBugbopExamples >> stubClientResponding: aBlock [
	"A GtBugbopClient whose requests are answered by aBlock (ZnRequest -> ZnResponse), never the network"
	^ GtBugbopClient new
		apiKey: 'bugbop_pat_example';
		clientBuilder: (GtBugbopClientStubBuilder new responder: aBlock);
		yourself
]

{ #category : 'examples - security' }
GtBugbopExamples >> tokenNeverSentToOtherHosts [
	<gtExample>
	<return: #Error>
	| aClient anError |
	aClient := self stubClientResponding: [ :aRequest | self error: 'must not be called' ].
	anError := [ aClient getUrl: 'https://evil.example.com/api/v1/reports?page=2'. nil ]
			on: Error
			do: [ :ex | ex return: ex ].
	self assert: (anError messageText includesSubstring: 'Refusing').
	self assert: aClient history isEmpty.
	self assert: (aClient isBugbopUrl: 'https://bugbop.com/api/v1/reports?page=2' asZnUrl).
	self assert: (aClient isBugbopUrl: 'http://bugbop.com/api/v1/reports' asZnUrl) not.
	self assert: GtBugbopClientZincBuilder new create followRedirects not.
	^ anError
]

{ #category : 'examples - http' }
GtBugbopExamples >> unauthorizedErrorHasHint [
	<gtExample>
	<return: #GtBugbopError>
	| aClient anError |
	aClient := self stubClientResponding: [ :aRequest | 
		self jsonResponse: (Dictionary with: 'message' -> 'Bad credentials') code: 401 headers: Dictionary new ].
	anError := [ aClient currentUser. nil ] on: GtBugbopError do: [ :ex | ex return: ex ].
	self assert: anError isUnauthorized.
	self assert: (anError messageText includesSubstring: 'bugbop-api-key.txt').
	^ anError
]

{ #category : 'examples - http' }
GtBugbopExamples >> validationError [
	"A 422 is signalled as a GtBugbopError carrying Bugbop's field errors"
	<gtExample>
	<return: #GtBugbopError>
	| aClient anError |
	aClient := self stubClientResponding: [ :aRequest | 
		self
			jsonResponse: (STONJSON fromString: '{"message": "Validation failed", "errors": [{"field": "duplicate_of_id", "code": "invalid", "message": "Duplicate of must be selected when marking as duplicate"}]}')
			code: 422
			headers: Dictionary new ].
	anError := [ aClient updateReport: 'r1' status: 'duplicate'. nil ]
			on: GtBugbopError
			do: [ :ex | ex return: ex ].
	self assert: anError notNil.
	self assert: anError statusCode equals: 422.
	self assert: anError apiMessage equals: 'Validation failed'.
	self assert: anError fieldErrors size equals: 1.
	self assert: (anError messageText includesSubstring: 'Duplicate of must be selected').
	self assert: aClient history first method equals: #PATCH.
	^ anError
]

{ #category : 'examples - model' }
GtBugbopExamples >> webhookHidesSecretFromDetails [
	<gtExample>
	<return: #GtBugbopWebhook>
	| aWebhook |
	aWebhook := GtBugbopWebhook from: self webhookJson.
	self assert: aWebhook events size equals: 3.
	self assert: aWebhook secret notNil.
	self assert: (aWebhook detailRows noneSatisfy: [ :each | each key = 'secret' ]).
	^ aWebhook
]

{ #category : 'fixtures' }
GtBugbopExamples >> webhookJson [
	^ STONJSON fromString: '{
  "id": "7a8b9c0d-1e2f-4a3b-8c4d-5e6f7a8b9c0d",
  "program_id": "1a2b3c4d",
  "url": "https://hooks.example.com/bugbop",
  "description": "Jira sync",
  "events": ["report.created", "report.updated", "comment.created"],
  "settings_url": "https://bugbop.com/programs/1a2b3c4d/program_webhooks/7a8b9c0d",
  "api_url": "https://bugbop.com/api/v1/webhooks/7a8b9c0d",
  "ping_url": "https://bugbop.com/api/v1/webhooks/7a8b9c0d/ping",
  "created_at": "2025-10-11T02:00:00Z",
  "updated_at": "2025-10-11T02:00:00Z",
  "secret": "4f1c-not-a-real-secret-e9"
}'
]

{ #category : 'examples - security' }
GtBugbopExamples >> webhookSecretNotInRawData [
	<gtExample>
	<return: #GtBugbopWebhook>
	| aWebhook |
	aWebhook := self webhookHidesSecretFromDetails.
	self assert: (aWebhook rawData includesKey: 'secret') not.
	self assert: aWebhook secret notNil.
	self assert: (self webhookJson includesKey: 'secret').
	^ aWebhook
]

{ #category : 'examples - groups' }
GtBugbopExamples >> weeklyActivity [
	<gtExample>
	<return: #OrderedCollection>
	| theWeeks |
	theWeeks := self reportsGroup weeklyActivity.
	"Mondays 2025-09-15, -22, -29, 10-06; the week of the 22nd is empty but still listed"
	self
		assert: (theWeeks collect: [ :each | each key yyyymmdd ]) asArray
		equals: #('2025-09-15' '2025-09-22' '2025-09-29' '2025-10-06').
	self assert: (theWeeks collect: [ :each | each value size ]) asArray equals: #(1 0 1 2).
	^ theWeeks
]
