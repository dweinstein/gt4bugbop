"
I am the high-level entry point for exploring your Bugbop data in GT.

	GtBugbopExplorer withApiKeyFromFile

I fetch and cache your account, programs, reports and notifications, and offer overview, triage, severity/status, hunter and activity views over them. Use the refresh action (or #refresh) to drop the cache.
"
Class {
	#name : 'GtBugbopExplorer',
	#superclass : 'Object',
	#instVars : [
		'client',
		'user',
		'programs',
		'reports',
		'notifications',
		'fetchedAt'
	],
	#category : 'Gt4Bugbop-Explorer',
	#package : 'Gt4Bugbop',
	#tag : 'Explorer'
}

{ #category : 'instance creation' }
GtBugbopExplorer class >> withApiKeyFromFile [
	^ self new client: GtBugbopClient withApiKeyFromFile
]

{ #category : 'accessing' }
GtBugbopExplorer >> client [
	^ client
]

{ #category : 'accessing' }
GtBugbopExplorer >> client: aClient [
	client := aClient
]

{ #category : 'accessing' }
GtBugbopExplorer >> fetchedAt [
	^ fetchedAt
]

{ #category : 'gt views' }
GtBugbopExplorer >> gtActivityFor: aView [
	<gtView>
	^ aView forward
		title: 'Weekly activity';
		priority: 6;
		object: [ self reports ];
		view: #gtActivityFor:
]

{ #category : 'gt views' }
GtBugbopExplorer >> gtCallsFor: aView [
	<gtView>
	client ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'API calls';
		priority: 20;
		object: [ client history ];
		view: #gtCallsFor:
]

{ #category : 'gt views' }
GtBugbopExplorer >> gtHuntersFor: aView [
	<gtView>
	^ aView forward
		title: 'Hunters';
		priority: 5;
		object: [ self hunters ];
		view: #gtHuntersFor:
]

{ #category : 'gt views' }
GtBugbopExplorer >> gtNotificationsFor: aView [
	<gtView>
	^ aView forward
		title: 'Notifications';
		priority: 8;
		object: [ self notifications ];
		view: #gtNotificationsFor:
]

{ #category : 'gt actions' }
GtBugbopExplorer >> gtOpenBugbopActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons link;
		tooltip: 'Open bugbop.com';
		priority: 2;
		action: [ WebBrowser openOn: 'https://bugbop.com' ]
]

{ #category : 'gt views' }
GtBugbopExplorer >> gtOverviewFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Overview';
		priority: 1;
		items: [ self metrics ];
		column: 'Metric' text: [ :each | each label ] width: 260;
		column: 'Value' text: [ :each | each value gtDisplayString asRopedText bold ];
		send: [ :each | each target ]
]

{ #category : 'gt views' }
GtBugbopExplorer >> gtProgramsFor: aView [
	<gtView>
	^ aView forward
		title: 'Programs';
		priority: 7;
		object: [ self programs ];
		view: #gtProgramsFor:
]

{ #category : 'gt actions' }
GtBugbopExplorer >> gtRefreshActionFor: anAction [
	<gtAction>
	client ifNil: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons refresh;
		tooltip: 'Refetch from Bugbop';
		priority: 1;
		action: [ :aButton | 
			self refresh.
			aButton phlow fireViewUpdateWish ]
]

{ #category : 'gt views' }
GtBugbopExplorer >> gtReportsFor: aView [
	<gtView>
	^ aView forward
		title: 'All reports';
		priority: 3;
		object: [ self reports ];
		view: #gtReportsFor:
]

{ #category : 'gt views' }
GtBugbopExplorer >> gtSeverityStatusMatrixFor: aView [
	<gtView>
	^ aView forward
		title: 'Severity x status';
		priority: 4;
		object: [ self reports ];
		view: #gtSeverityStatusMatrixFor:
]

{ #category : 'gt views' }
GtBugbopExplorer >> gtTriageQueueFor: aView [
	<gtView>
	^ aView forward
		title: 'Triage queue';
		priority: 2;
		object: [ self triageQueue ];
		view: #gtReportsFor:
]

{ #category : 'accessing' }
GtBugbopExplorer >> hunters [
	^ self reports hunterSummaries
]

{ #category : 'accessing' }
GtBugbopExplorer >> metrics [
	| active |
	active := self reports active.
	^ {
		GtBugbopMetric label: 'Signed in as' value: self user target: self user.
		GtBugbopMetric label: 'Programs on my team' value: self staffPrograms size target: self staffPrograms.
		GtBugbopMetric label: 'Reports' value: self reports size target: self reports.
		GtBugbopMetric label: 'Triage queue (new/open/needs info)' value: active size target: self triageQueue.
		GtBugbopMetric label: '  new' value: (self reports countWithStatus: 'new') target: (self reports withStatus: 'new').
		GtBugbopMetric label: '  critical + high active' value: (active items count: [ :each | each severityRank <= 2 ]) target: (active select: [ :each | each severityRank <= 2 ]).
		GtBugbopMetric label: 'Fixed' value: (self reports countWithStatus: 'fixed') target: (self reports withStatus: 'fixed').
		GtBugbopMetric label: 'Bounties awarded' value: self reports bountyAmountString target: self reports withBounty.
		GtBugbopMetric label: 'Hunters' value: self hunters size target: self hunters.
		GtBugbopMetric label: 'Unread notifications' value: self notifications unread size target: self notifications unread.
		GtBugbopMetric label: 'API rate limit' value: client rateLimit target: client }
]

{ #category : 'accessing' }
GtBugbopExplorer >> notifications [
	^ notifications ifNil: [ notifications := client notifications ]
]

{ #category : 'accessing' }
GtBugbopExplorer >> notifications: aNotificationsGroup [
	notifications := aNotificationsGroup
]

{ #category : 'printing' }
GtBugbopExplorer >> printOn: aStream [
	aStream nextPutAll: 'Bugbop explorer'.
	fetchedAt ifNotNil: [ aStream nextPutAll: ' (fetched '; print: fetchedAt asLocal asTime; nextPut: $) ]
]

{ #category : 'accessing' }
GtBugbopExplorer >> programs [
	^ programs ifNil: [ programs := client programs ]
]

{ #category : 'accessing' }
GtBugbopExplorer >> programs: aProgramsGroup [
	programs := aProgramsGroup
]

{ #category : 'actions' }
GtBugbopExplorer >> refresh [
	"Drop cached data; the next access refetches it"
	user := nil.
	programs := nil.
	reports := nil.
	notifications := nil.
	fetchedAt := nil
]

{ #category : 'accessing' }
GtBugbopExplorer >> reports [
	^ reports ifNil: [ 
		fetchedAt := DateAndTime now.
		reports := client reports ]
]

{ #category : 'accessing' }
GtBugbopExplorer >> reports: aReportsGroup [
	reports := aReportsGroup
]

{ #category : 'accessing' }
GtBugbopExplorer >> staffPrograms [
	^ self programs staffPrograms
]

{ #category : 'accessing' }
GtBugbopExplorer >> triageQueue [
	"Active reports, most severe and then newest first"
	^ self reports active sortedBySeverity
]

{ #category : 'accessing' }
GtBugbopExplorer >> user [
	^ user ifNil: [ user := client currentUser ]
]

{ #category : 'accessing' }
GtBugbopExplorer >> user: aUser [
	user := aUser
]
