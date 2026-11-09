"
I am a Bugbop bug bounty program. When embedded in another object (a report, comment, notification) only id, name, url and apiUrl are present; use #refreshed to fetch the full program.
"
Class {
	#name : 'GtBugbopProgram',
	#superclass : 'GtBugbopEntity',
	#instVars : [
		'id',
		'name',
		'site',
		'visibility',
		'bountyType',
		'bountyPaused',
		'aiTriage',
		'requireKyc',
		'description',
		'bountyRanges',
		'role',
		'url',
		'apiUrl',
		'reportsUrl',
		'webhooksUrl',
		'accessAcceptanceTemplate',
		'createdAt',
		'updatedAt'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopProgram class >> serializationProperties [
	^ {
		#id -> #id.
		#name -> #name.
		#site -> #site.
		#visibility -> #visibility.
		#bounty_type -> #bountyType.
		#bounty_paused -> #bountyPaused.
		#ai_triage -> #aiTriage.
		#require_kyc -> #requireKyc.
		#role -> #role.
		#description -> #description.
		#bounty_ranges -> #bountyRanges.
		#access_acceptance_template -> #accessAcceptanceTemplate.
		#created_at -> #createdAt.
		#updated_at -> #updatedAt.
		#url -> #url.
		#api_url -> #apiUrl.
		#reports_url -> #reportsUrl.
		#webhooks_url -> #webhooksUrl }
]

{ #category : 'accessing' }
GtBugbopProgram class >> staffRoles [
	^ #('owner' 'admin' 'triager' 'viewer')
]

{ #category : 'comparing' }
GtBugbopProgram >> = anObject [
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ id = anObject id
]

{ #category : 'accessing' }
GtBugbopProgram >> accessAcceptanceTemplate [
	^ accessAcceptanceTemplate
]

{ #category : 'accessing' }
GtBugbopProgram >> accessAcceptanceTemplate: aString [
	accessAcceptanceTemplate := aString
]

{ #category : 'api' }
GtBugbopProgram >> accessRequests [
	^ self client accessRequestsForProgram: self
]

{ #category : 'accessing' }
GtBugbopProgram >> aiTriage [
	^ aiTriage
]

{ #category : 'accessing' }
GtBugbopProgram >> aiTriage: aBoolean [
	aiTriage := aBoolean
]

{ #category : 'accessing' }
GtBugbopProgram >> apiUrl [
	^ apiUrl
]

{ #category : 'accessing' }
GtBugbopProgram >> apiUrl: aString [
	apiUrl := aString
]

{ #category : 'api' }
GtBugbopProgram >> blockedReporters [
	^ self client blockedReportersForProgram: self
]

{ #category : 'accessing' }
GtBugbopProgram >> bountyPaused [
	^ bountyPaused
]

{ #category : 'accessing' }
GtBugbopProgram >> bountyPaused: aBoolean [
	bountyPaused := aBoolean
]

{ #category : 'accessing' }
GtBugbopProgram >> bountyRanges [
	"Answer a collection of GtBugbopBountyRange, ordered critical to low (empty unless a cash program)"
	^ bountyRanges ifNil: [ #() ]
]

{ #category : 'accessing' }
GtBugbopProgram >> bountyRanges: aDictionaryOrCollection [
	aDictionaryOrCollection isDictionary ifFalse: [ ^ bountyRanges := aDictionaryOrCollection ].
	bountyRanges := (GtBugbopReport severities
			select: [ :aSeverity | aDictionaryOrCollection includesKey: aSeverity ])
			collect: [ :aSeverity | 
				GtBugbopBountyRange
					severity: aSeverity
					from: (aDictionaryOrCollection at: aSeverity) ]
]

{ #category : 'accessing' }
GtBugbopProgram >> bountyType [
	^ bountyType
]

{ #category : 'accessing' }
GtBugbopProgram >> bountyType: aString [
	bountyType := aString
]

{ #category : 'testing' }
GtBugbopProgram >> canManageWebhooks [
	^ webhooksUrl notNil
]

{ #category : 'testing' }
GtBugbopProgram >> canTriage [
	^ #('owner' 'admin' 'triager') includes: role
]

{ #category : 'accessing' }
GtBugbopProgram >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
GtBugbopProgram >> createdAt: aStringOrDateAndTime [
	createdAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopProgram >> description [
	"Answer the program description (Markdown)"
	^ description
]

{ #category : 'accessing' }
GtBugbopProgram >> description: aString [
	description := aString
]

{ #category : 'gt views' }
GtBugbopProgram >> gtAccessRequestsFor: aView [
	<gtView>
	self client ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Access requests';
		priority: 6;
		object: [ self accessRequests ];
		view: #gtAccessRequestsFor:
]

{ #category : 'gt views' }
GtBugbopProgram >> gtBlockedReportersFor: aView [
	<gtView>
	(self client isNil or: [ self canTriage not ]) ifTrue: [ ^ aView empty ].
	^ aView forward
		title: 'Blocked reporters';
		priority: 7;
		object: [ self blockedReporters ];
		view: #gtBlockedReportersFor:
]

{ #category : 'gt views' }
GtBugbopProgram >> gtBountyRangesFor: aView [
	<gtView>
	self bountyRanges ifEmpty: [ ^ aView empty ].
	^ aView columnedList
		title: 'Bounty ranges';
		priority: 3;
		items: [ self bountyRanges ];
		column: 'Severity' text: [ :each | GtBugbopReport severityText: each severity ] width: 100;
		column: 'Min' text: [ :each | each minAmountString ] width: 100;
		column: 'Max' text: [ :each | each maxAmountString ] width: 100
]

{ #category : 'gt views' }
GtBugbopProgram >> gtDescriptionFor: aView [
	<gtView>
	description isEmptyOrNil ifTrue: [ ^ aView empty ].
	^ aView textEditor
		title: 'Description';
		priority: 2;
		text: [ description asRopedText ]
]

{ #category : 'gt views' }
GtBugbopProgram >> gtHuntersFor: aView [
	<gtView>
	(self client isNil or: [ self isStaff not ]) ifTrue: [ ^ aView empty ].
	^ aView forward
		title: 'Hunters';
		priority: 5;
		object: [ self hunters ];
		view: #gtUsersFor:
]

{ #category : 'gt actions' }
GtBugbopProgram >> gtLoadFullProgramActionFor: anAction [
	<gtAction>
	(self isReference and: [ self client notNil ]) ifFalse: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons refresh;
		label: 'Load full program';
		tooltip: 'This is an embedded reference; fetch all details, reports and team views';
		priority: 1;
		action: [ :aButton | aButton phlow spawnObject: self refreshed ]
]

{ #category : 'gt views' }
GtBugbopProgram >> gtOverviewFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Overview';
		priority: 1;
		items: [ self overviewRows ];
		column: 'Property' text: [ :each | each key ] width: 160;
		column: 'Value' text: [ :each | each value gtDisplayString ];
		send: [ :each | each value ]
]

{ #category : 'gt views' }
GtBugbopProgram >> gtReportsFor: aView [
	<gtView>
	self client ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Reports';
		priority: 4;
		object: [ self reports ];
		view: #gtReportsFor:
]

{ #category : 'gt views' }
GtBugbopProgram >> gtWebhooksFor: aView [
	<gtView>
	(self client isNil or: [ self canManageWebhooks not ]) ifTrue: [ ^ aView empty ].
	^ aView forward
		title: 'Webhooks';
		priority: 8;
		object: [ self webhooks ];
		view: #gtWebhooksFor:
]

{ #category : 'comparing' }
GtBugbopProgram >> hash [
	^ id hash
]

{ #category : 'api' }
GtBugbopProgram >> hunters [
	^ self client huntersForProgram: self
]

{ #category : 'accessing' }
GtBugbopProgram >> id [
	^ id
]

{ #category : 'accessing' }
GtBugbopProgram >> id: aString [
	id := aString
]

{ #category : 'testing' }
GtBugbopProgram >> isCashProgram [
	^ bountyType = 'cash'
]

{ #category : 'testing' }
GtBugbopProgram >> isReference [
	"Answer whether I am only an embedded reference (id, name, urls) and lack full details"
	^ createdAt isNil
]

{ #category : 'testing' }
GtBugbopProgram >> isStaff [
	"Answer whether I am on the program team (and can see all its reports)"
	^ self class staffRoles includes: role
]

{ #category : 'accessing' }
GtBugbopProgram >> name [
	^ name
]

{ #category : 'accessing' }
GtBugbopProgram >> name: aString [
	name := aString
]

{ #category : 'gt views' }
GtBugbopProgram >> overviewRows [
	^ {
		'Name' -> name.
		'Site' -> site.
		'My role' -> role.
		'Visibility' -> visibility.
		'Bounty type' -> bountyType.
		'Bounties paused' -> bountyPaused.
		'AI triage' -> aiTriage.
		'Requires KYC' -> requireKyc.
		'Created' -> createdAt.
		'Updated' -> updatedAt } reject: [ :each | each value isNil ]
]

{ #category : 'printing' }
GtBugbopProgram >> printOn: aStream [
	aStream nextPutAll: (name ifNil: [ 'a Bugbop program' ])
]

{ #category : 'api' }
GtBugbopProgram >> refreshed [
	"Answer a freshly fetched copy of me with all details"
	^ self client programAt: self id
]

{ #category : 'api' }
GtBugbopProgram >> reports [
	^ self client reportsForProgram: self
]

{ #category : 'accessing' }
GtBugbopProgram >> reportsUrl [
	^ reportsUrl
]

{ #category : 'accessing' }
GtBugbopProgram >> reportsUrl: aString [
	reportsUrl := aString
]

{ #category : 'accessing' }
GtBugbopProgram >> requireKyc [
	^ requireKyc
]

{ #category : 'accessing' }
GtBugbopProgram >> requireKyc: aBoolean [
	requireKyc := aBoolean
]

{ #category : 'accessing' }
GtBugbopProgram >> role [
	"Answer my role on the program (owner, admin, triager, viewer, hunter) or nil"
	^ role
]

{ #category : 'accessing' }
GtBugbopProgram >> role: aStringOrNil [
	role := aStringOrNil
]

{ #category : 'accessing' }
GtBugbopProgram >> site [
	^ site
]

{ #category : 'accessing' }
GtBugbopProgram >> site: aString [
	site := aString
]

{ #category : 'accessing' }
GtBugbopProgram >> updatedAt [
	^ updatedAt
]

{ #category : 'accessing' }
GtBugbopProgram >> updatedAt: aStringOrDateAndTime [
	updatedAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopProgram >> url [
	^ url
]

{ #category : 'accessing' }
GtBugbopProgram >> url: aString [
	url := aString
]

{ #category : 'accessing' }
GtBugbopProgram >> visibility [
	"Answer public, restricted or private"
	^ visibility
]

{ #category : 'accessing' }
GtBugbopProgram >> visibility: aString [
	visibility := aString
]

{ #category : 'accessing' }
GtBugbopProgram >> webUrl [
	^ url
]

{ #category : 'api' }
GtBugbopProgram >> webhooks [
	^ self client webhooksForProgram: self
]

{ #category : 'accessing' }
GtBugbopProgram >> webhooksUrl [
	"Only present if I can manage webhooks"
	^ webhooksUrl
]

{ #category : 'accessing' }
GtBugbopProgram >> webhooksUrl: aString [
	webhooksUrl := aString
]
