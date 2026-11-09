"
I am the discussion around one {{gtClass:GtBugbopReport}}: its comments plus the knowledge of who the hunter is, so each comment can be attributed to the hunter side or the program team side.

I offer a chat-style 'Conversation' view and a 'Lifecycle' timeline (submission, comments by side, last update, time to first response). Comments are fetched lazily by {{gtMethod:GtBugbopConversation>>#fetched}}, which forward views call off the UI thread.

Without a report I fall back to treating the earliest commenter as the hunter.
"
Class {
	#name : 'GtBugbopConversation',
	#superclass : 'Object',
	#instVars : [
		'report',
		'comments',
		'hunterName'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'instance creation' }
GtBugbopConversation class >> forComments: aCommentsGroup [
	^ self new comments: aCommentsGroup
]

{ #category : 'instance creation' }
GtBugbopConversation class >> forReport: aReport [
	^ self new report: aReport
]

{ #category : 'instance creation' }
GtBugbopConversation class >> forReport: aReport comments: aCommentsGroup [
	^ self new
		report: aReport;
		comments: aCommentsGroup;
		yourself
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> activeSpan: events [
	"Seconds from the first event to the last one before now"
	events size < 3 ifTrue: [ ^ 0 ].
	^ ((events at: events size - 1) time - events first time) asSeconds
]

{ #category : 'building - conversation' }
GtBugbopConversation >> bodyTextFor: aComment [
	^ GtBugbopVisuals markdownLiteText: (GtBugbopVisuals
			excerptOf: (GtBugbopVisuals readableMarkdown: aComment content)
			limit: 2000)
]

{ #category : 'accessing' }
GtBugbopConversation >> comments [
	^ comments ifNil: [ comments := self fetchComments ]
]

{ #category : 'accessing' }
GtBugbopConversation >> comments: aCommentsGroup [
	comments := aCommentsGroup
]

{ #category : 'accessing' }
GtBugbopConversation >> commentsOnSide: aSide [
	^ self sortedComments select: [ :each | (self sideOf: each) = aSide ]
]

{ #category : 'private' }
GtBugbopConversation >> computeHunterName [
	self report ifNotNil: [ :aReport | ^ aReport reporterName ].
	self sortedComments ifEmpty: [ ^ '' ].
	^ self sortedComments first authorName
]

{ #category : 'private' }
GtBugbopConversation >> createdEvent [
	| aReport |
	aReport := self report ifNil: [ ^ nil ].
	aReport createdAt ifNil: [ ^ nil ].
	^ GtBugbopLifecycleEvent
		kind: #created
		time: aReport createdAt
		side: #hunter
		label: 'Submitted by ' , self hunterName
		target: aReport
]

{ #category : 'building - conversation' }
GtBugbopConversation >> emptyMessage [
	| aCount |
	aCount := report ifNil: [ 0 ] ifNotNil: [ :aReport | aReport commentsCount ifNil: [ 0 ] ].
	(aCount > 0 and: [ report client isNil ])
		ifTrue: [ ^ aCount printString , ' comments exist but this report is offline (no client to load them)' ].
	^ 'No comments yet'
]

{ #category : 'private' }
GtBugbopConversation >> eventForComment: aComment [
	^ GtBugbopLifecycleEvent
		kind: #comment
		time: (aComment createdAt ifNil: [ DateAndTime now ])
		side: (self sideOf: aComment)
		label: aComment authorName , ': ' , (GtBugbopVisuals excerptOf: aComment summary limit: 80)
		target: aComment
]

{ #category : 'private' }
GtBugbopConversation >> fetchComments [
	| aCount |
	report ifNil: [ ^ GtBugbopCommentsGroup new ].
	aCount := report commentsCount ifNil: [ 0 ].
	(report client isNil or: [ aCount isZero ]) ifTrue: [ ^ GtBugbopCommentsGroup new ].
	^ report comments
]

{ #category : 'accessing' }
GtBugbopConversation >> fetched [
	"Load the comments and the report and the hunter name; forward views call me off the UI thread"
	self comments.
	self hunterName.
	^ self
]

{ #category : 'accessing' }
GtBugbopConversation >> firstResponse [
	"The earliest comment not written by the hunter, or nil"
	^ self sortedComments detect: [ :each | (self sideOf: each) ~= #hunter ] ifNone: [ nil ]
]

{ #category : 'building - conversation' }
GtBugbopConversation >> gapBefore: aComment after: aPreviousComment [
	"Answer the silence before aComment when it lasted a day or more, else nil"
	| aGap |
	aPreviousComment ifNil: [ ^ nil ].
	(aComment createdAt isNil or: [ aPreviousComment createdAt isNil ]) ifTrue: [ ^ nil ].
	aGap := aComment createdAt - aPreviousComment createdAt.
	aGap < 1 day ifTrue: [ ^ nil ].
	^ aGap
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> gapColorAfter: anEvent side: aLaneSide [
	"On the report lane, the stretch before the first team response is highlighted as waiting time"
	aLaneSide = #axis ifFalse: [ ^ Color transparent ].
	(self isBeforeFirstResponse: anEvent) ifTrue: [ ^ GtBugbopVisuals waitingColor ].
	^ Color transparent
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> gapWeightsFor: events [
	"Elapsed seconds between consecutive events plus a small minimum so close markers stay apart. The idle tail up to now is capped at a third of the active span so old reports do not squash their history to the left."
	| raw anActiveSpan aTotal |
	raw := (1 to: events size - 1) collect: [ :i | ((events at: i + 1) time - (events at: i) time) asSeconds max: 0 ].
	anActiveSpan := self activeSpan: events.
	anActiveSpan > 0 ifTrue: [ raw at: raw size put: (raw last min: anActiveSpan / 3) ].
	aTotal := raw inject: 0 into: [ :sum :each | sum + each ].
	^ raw collect: [ :each | each + (aTotal * 0.01) + 1 ]
]

{ #category : 'views' }
GtBugbopConversation >> gtBubblesFor: aView [
	<gtView>
	^ aView explicit
		title: 'Conversation';
		priority: 1;
		stencil: [ self newConversationElement ]
]

{ #category : 'views' }
GtBugbopConversation >> gtCommentsListFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Comments';
		priority: 3;
		items: [ self sortedComments ];
		column: 'Side' icon: [ :each | GtBugbopVisuals dotColored: (GtBugbopVisuals colorForSide: (self sideOf: each)) size: 10 ] width: 40;
		column: 'When' text: [ :each | GtBugbopVisuals dateString: each createdAt ] width: 140;
		column: 'Author' text: [ :each | each authorName ] width: 120;
		column: 'Comment' text: [ :each | each summary ]
]

{ #category : 'views' }
GtBugbopConversation >> gtLifecycleFor: aView [
	<gtView>
	^ aView explicit
		title: 'Lifecycle';
		priority: 2;
		stencil: [ self newLifecycleElement ]
]

{ #category : 'testing' }
GtBugbopConversation >> hasUnloadedComments [
	"The report says it has comments but none could be loaded (offline report)"
	report ifNil: [ ^ false ].
	^ self sortedComments isEmpty and: [ (report commentsCount ifNil: [ 0 ]) > 0 ]
]

{ #category : 'accessing' }
GtBugbopConversation >> hunterComments [
	^ self commentsOnSide: #hunter
]

{ #category : 'accessing' }
GtBugbopConversation >> hunterName [
	"The reporter's username; without a report, the earliest commenter"
	^ hunterName ifNil: [ hunterName := self computeHunterName ]
]

{ #category : 'accessing' }
GtBugbopConversation >> hunterName: aString [
	hunterName := aString
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> idleTail: events [
	"The time between the last real event and now"
	events size < 2 ifTrue: [ ^ 0 seconds ].
	^ events last time - (events at: events size - 1) time
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> isBeforeFirstResponse: anEvent [
	| aResponse |
	aResponse := self firstResponse ifNil: [ ^ anEvent kind ~= #now ].
	^ anEvent time < aResponse createdAt
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> isTailCompressed: events [
	| anActiveSpan |
	anActiveSpan := self activeSpan: events.
	anActiveSpan isZero ifTrue: [ ^ false ].
	^ (self idleTail: events) asSeconds > (anActiveSpan / 3)
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> lane: aLaneSide shows: anEvent [
	aLaneSide = #axis ifTrue: [ ^ anEvent isComment not ].
	aLaneSide = #hunter ifTrue: [ ^ anEvent isComment and: [ anEvent side = #hunter ] ].
	^ anEvent isComment and: [ anEvent side ~= #hunter ]
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> laneLabelWidth [
	^ 70
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> laneThickness: aLaneSide [
	^ aLaneSide = #axis ifTrue: [ 6 ] ifFalse: [ 1 ]
]

{ #category : 'accessing' }
GtBugbopConversation >> lastActivityTime [
	| times |
	times := (self lifecycleEvents reject: [ :each | each kind = #now ]) collect: [ :each | each time ].
	times ifEmpty: [ ^ nil ].
	^ times max
]

{ #category : 'accessing' }
GtBugbopConversation >> lifecycleEvents [
	"Submission, comments, last update and now, oldest first"
	| events |
	events := OrderedCollection new.
	self createdEvent ifNotNil: [ :anEvent | events add: anEvent ].
	events addAll: (self sortedComments collect: [ :each | self eventForComment: each ]).
	self updatedEvent ifNotNil: [ :anEvent | events add: anEvent ].
	events add: self nowEvent.
	^ (events asSortedCollection: [ :a :b | a time <= b time ]) asArray
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> markerSlotSize [
	^ 16
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newAxisLabelsFor: events [
	| anIdle aRightText |
	anIdle := self idleTail: events.
	aRightText := 'now'.
	anIdle >= 1 day ifTrue: [ aRightText := aRightText , '  (idle ' , (GtBugbopVisuals durationString: anIdle) , ')' ].
	(self isTailCompressed: events) ifTrue: [ aRightText := aRightText , ' - idle tail compressed' ].
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets left: self laneLabelWidth);
		margin: (BlInsets top: 4);
		addChild: (GtBugbopVisuals metaLabel: (GtBugbopVisuals dateString: events first time));
		addChild: (BlElement new constraintsDo: [ :c | c horizontal matchParent. c vertical exact: 1 ]);
		addChild: (GtBugbopVisuals metaLabel: aRightText)
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newBaselineFor: aLaneSide [
	^ BlElement new
		background: (aLaneSide = #axis ifTrue: [ self settledColor ] ifFalse: [ GtBugbopVisuals lineColor ]);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical exact: (self laneThickness: aLaneSide).
			c frame vertical alignCenter ]
]

{ #category : 'building - conversation' }
GtBugbopConversation >> newBubbleFor: aComment side: aSide [
	| aBubble |
	aBubble := BrVerticalPane new
			hMatchParent;
			vFitContent;
			padding: (BlInsets top: 8 left: 14 bottom: 10 right: 14);
			background: (GtBugbopVisuals bubbleColorForSide: aSide);
			border: (BlBorder paint: ((GtBugbopVisuals colorForSide: aSide) alpha: 0.35) width: 1);
			geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
			addChild: (self newBubbleHeaderFor: aComment side: aSide);
			addChild: (GtBugbopVisuals readOnlyText: (self bodyTextFor: aComment)).
	GtBugbopVisuals make: aBubble tooltip: 'Click to inspect this comment'.
	^ GtBugbopVisuals make: aBubble spawn: [ aComment ]
]

{ #category : 'building - conversation' }
GtBugbopConversation >> newBubbleHeaderFor: aComment side: aSide [
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterLeft;
		margin: (BlInsets bottom: 4);
		addChild: (GtBugbopVisuals boldLabel: aComment authorName size: 13 color: (GtBugbopVisuals colorForSide: aSide));
		addChild: ((GtBugbopVisuals outlinePillLabeled: (self roleNameFor: aSide) color: (GtBugbopVisuals colorForSide: aSide))
			margin: (BlInsets left: 8));
		addChild: (BlElement new constraintsDo: [ :c | c horizontal matchParent. c vertical exact: 1 ]);
		addChild: ((GtBugbopVisuals metaLabel: (GtBugbopVisuals relativeTimeFor: aComment createdAt))
			in: [ :aLabel | GtBugbopVisuals make: aLabel tooltip: (GtBugbopVisuals dateString: aComment createdAt) ])
]

{ #category : 'building - conversation' }
GtBugbopConversation >> newBubbleRowFor: aComment [
	"Hunter on the left, program team on the right"
	| aSide anAvatar aBubble aRow |
	aSide := self sideOf: aComment.
	anAvatar := GtBugbopVisuals avatarFor: aComment authorName color: (GtBugbopVisuals colorForSide: aSide) size: 34.
	aBubble := self newBubbleFor: aComment side: aSide.
	aRow := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			margin: (BlInsets bottom: 12).
	aSide = #hunter ifTrue: [ 
		^ aRow addChildren: { anAvatar margin: (BlInsets right: 10). aBubble margin: (BlInsets right: 90) } ].
	^ aRow addChildren: { aBubble margin: (BlInsets left: 90). anAvatar margin: (BlInsets left: 10) }
]

{ #category : 'building - conversation' }
GtBugbopConversation >> newBubbleRows [
	"Bubble rows oldest first, with a separator wherever a day or more passed between comments"
	| rows previous |
	rows := OrderedCollection new.
	previous := nil.
	self sortedComments do: [ :each | 
		(self gapBefore: each after: previous) ifNotNil: [ :aGap | rows add: (self newGapSeparator: aGap) ].
		rows add: (self newBubbleRowFor: each).
		previous := each ].
	^ rows
]

{ #category : 'building - conversation' }
GtBugbopConversation >> newConversationElement [
	| aPage |
	self sortedComments ifEmpty: [ ^ GtBugbopVisuals emptyLabel: self emptyMessage ].
	aPage := GtBugbopVisuals page.
	aPage addChild: self newConversationHeader.
	aPage addChildren: self newBubbleRows.
	^ GtBugbopVisuals scrollablePage: aPage
]

{ #category : 'building - conversation' }
GtBugbopConversation >> newConversationHeader [
	| aCard |
	aCard := GtBugbopVisuals card.
	aCard addChild: self newStatTiles.
	aCard addChild: self newLegend.
	^ aCard
]

{ #category : 'building - common' }
GtBugbopConversation >> newFirstResponseTile [
	| aTile |
	aTile := GtBugbopVisuals
			statTile: (self timeToFirstResponse ifNil: [ 'none yet' ] ifNotNil: [ :aDuration | GtBugbopVisuals durationString: aDuration ])
			caption: 'to first team response'
			color: (Color fromHexString: 'E65100').
	self firstResponse ifNil: [ ^ aTile ].
	GtBugbopVisuals make: aTile tooltip: 'Click to inspect the first team response'.
	^ GtBugbopVisuals make: aTile spawn: [ self firstResponse ]
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newGapAfter: anEvent weight: aWeight side: aLaneSide [
	"Transparent except on the report lane, where waiting time before the first team response is painted"
	^ BlElement new
		background: (self gapColorAfter: anEvent side: aLaneSide);
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical exact: (self laneThickness: aLaneSide).
			c linear weight: aWeight asFloat ]
]

{ #category : 'building - conversation' }
GtBugbopConversation >> newGapSeparator: aDuration [
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenter;
		margin: (BlInsets top: 2 bottom: 12);
		addChild: self newHairline;
		addChild: ((GtBugbopVisuals label: (GtBugbopVisuals durationString: aDuration) , ' later' size: 11 color: GtBugbopVisuals mutedColor)
			margin: (BlInsets left: 10 right: 10));
		addChild: self newHairline
]

{ #category : 'building - conversation' }
GtBugbopConversation >> newHairline [
	^ BlElement new
		background: GtBugbopVisuals lineColor;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical exact: 1 ]
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newLaneLabeled: aString events: events side: aLaneSide [
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		alignCenterLeft;
		margin: (BlInsets top: 4 bottom: 4);
		addChild: ((GtBugbopVisuals boldLabel: aString size: 11 color: GtBugbopVisuals mutedColor)
			width: self laneLabelWidth);
		addChild: (self newTrackFor: events side: aLaneSide)
]

{ #category : 'building - common' }
GtBugbopConversation >> newLegend [
	^ GtBugbopVisuals legendWith: {
		'hunter (left)' -> GtBugbopVisuals hunterColor.
		'program team (right)' -> GtBugbopVisuals teamColor.
		'internal note' -> GtBugbopVisuals internalColor }
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newLifecycleElement [
	| aPage |
	self startTime ifNil: [ ^ GtBugbopVisuals emptyLabel: 'No dates to draw a lifecycle from' ].
	aPage := GtBugbopVisuals page.
	aPage addChild: (GtBugbopVisuals card addChild: self newLifecycleTiles).
	aPage addChild: self newTimelineCard.
	^ GtBugbopVisuals scrollablePage: aPage
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newLifecycleLegend [
	^ GtBugbopVisuals legendWith: {
		'hunter comment' -> GtBugbopVisuals hunterColor.
		'team comment' -> GtBugbopVisuals teamColor.
		'internal note' -> GtBugbopVisuals internalColor.
		'submitted' -> (Color fromHexString: '374151').
		'last update' -> (Color fromHexString: '9CA3AF').
		'waiting for first team response' -> GtBugbopVisuals waitingColor }
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newLifecycleTiles [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		addChild: self newFirstResponseTile;
		addChild: (GtBugbopVisuals statTile: (GtBugbopVisuals durationString: DateAndTime now - self startTime) caption: 'since submission' color: (Color fromHexString: '111827'));
		addChild: (GtBugbopVisuals statTile: (GtBugbopVisuals relativeTimeFor: self lastActivityTime) caption: 'last activity' color: (Color fromHexString: '374151'));
		addChild: (GtBugbopVisuals statTile: self hunterComments size printString caption: 'hunter comments' color: GtBugbopVisuals hunterColor);
		addChild: (GtBugbopVisuals statTile: self teamComments size printString caption: 'team comments' color: GtBugbopVisuals teamColor)
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newMarkerFor: anEvent [
	"The first team response gets a ring in the waiting color"
	| aMarker |
	aMarker := (GtBugbopVisuals dotColored: anEvent color size: (anEvent isComment ifTrue: [ 12 ] ifFalse: [ 14 ]))
			constraintsDo: [ :c | 
				c frame horizontal alignCenter.
				c frame vertical alignCenter ].
	anEvent kind = #updated ifTrue: [ aMarker border: (BlBorder paint: (Color fromHexString: '374151') width: 2) ].
	(anEvent isComment and: [ anEvent target == self firstResponse ])
		ifTrue: [ aMarker size: 16 @ 16; border: (BlBorder paint: GtBugbopVisuals waitingColor width: 3) ].
	^ aMarker
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newSlotFor: anEvent side: aLaneSide [
	| aSlot |
	aSlot := BrFrame new exact: self markerSlotSize @ 26.
	(aLaneSide = #axis and: [ (self isBeforeFirstResponse: anEvent) and: [ anEvent kind ~= #created ] ])
		ifTrue: [ aSlot addChild: (self newWaitingBarInSlot) ].
	(self lane: aLaneSide shows: anEvent) ifFalse: [ ^ aSlot ].
	aSlot addChild: (self newMarkerFor: anEvent).
	GtBugbopVisuals make: aSlot tooltip: anEvent tooltipText.
	^ GtBugbopVisuals make: aSlot spawn: [ anEvent target ]
]

{ #category : 'building - common' }
GtBugbopConversation >> newStatTiles [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		addChild: (GtBugbopVisuals statTile: self sortedComments size printString caption: 'comments' color: (Color fromHexString: '111827'));
		addChild: (GtBugbopVisuals statTile: self hunterComments size printString caption: 'by ' , self hunterName , ' (hunter)' color: GtBugbopVisuals hunterColor);
		addChild: (GtBugbopVisuals statTile: self teamComments size printString caption: 'by the program team' color: GtBugbopVisuals teamColor);
		addChild: (self newFirstResponseTile)
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newTimelineCard [
	| events aCard |
	events := self lifecycleEvents.
	aCard := GtBugbopVisuals card.
	aCard addChild: (GtBugbopVisuals sectionHeader: 'Timeline - from submission to now').
	aCard addChild: (self newLaneLabeled: 'Hunter' events: events side: #hunter).
	aCard addChild: (self newLaneLabeled: 'Report' events: events side: #axis).
	aCard addChild: (self newLaneLabeled: 'Team' events: events side: #team).
	aCard addChild: (self newAxisLabelsFor: events).
	self hasUnloadedComments ifTrue: [ 
		aCard addChild: ((GtBugbopVisuals metaLabel: self emptyMessage) margin: (BlInsets top: 8)) ].
	aCard addChild: (self newLifecycleLegend margin: (BlInsets top: 14)).
	^ aCard
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newTrackFor: events side: aLaneSide [
	"Fixed-width marker slots separated by gaps whose widths are proportional to elapsed time, over a full-width baseline"
	| aTrack weights |
	weights := self gapWeightsFor: events.
	aTrack := BrHorizontalPane new
			hMatchParent;
			vExact: 26;
			alignCenterLeft.
	events withIndexDo: [ :each :anIndex | 
		anIndex > 1 ifTrue: [ 
			aTrack addChild: (self newGapAfter: (events at: anIndex - 1) weight: (weights at: anIndex - 1) side: aLaneSide) ].
		aTrack addChild: (self newSlotFor: each side: aLaneSide) ].
	^ BrFrame new
		hMatchParent;
		vFitContent;
		addChild: (self newBaselineFor: aLaneSide);
		addChild: aTrack
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> newWaitingBarInSlot [
	"Slightly wider than the slot so it overlaps the neighbouring gaps without seams"
	^ BlElement new
		background: GtBugbopVisuals waitingColor;
		margin: (BlInsets top: 0 left: -1 bottom: 0 right: -1);
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical exact: 6.
			c frame vertical alignCenter ]
]

{ #category : 'private' }
GtBugbopConversation >> nowEvent [
	^ GtBugbopLifecycleEvent
		kind: #now
		time: DateAndTime now
		side: #system
		label: 'Now'
		target: self
]

{ #category : 'printing' }
GtBugbopConversation >> printOn: aStream [
	aStream
		nextPutAll: 'Conversation';
		nextPutAll: (comments ifNil: [ '' ] ifNotNil: [ :aGroup | ' (' , aGroup size printString , ' comments)' ])
]

{ #category : 'accessing' }
GtBugbopConversation >> report [
	"The report, resolved from the first comment when I was built from comments only"
	^ report ifNil: [ report := self resolveReport ]
]

{ #category : 'accessing' }
GtBugbopConversation >> report: aReport [
	report := aReport
]

{ #category : 'private' }
GtBugbopConversation >> resolveReport [
	| aComment |
	comments ifNil: [ ^ nil ].
	aComment := comments items detect: [ :each | each client notNil ] ifNone: [ ^ nil ].
	^ [ aComment report ] on: Error do: [ :anError | nil ]
]

{ #category : 'building - conversation' }
GtBugbopConversation >> roleNameFor: aSide [
	aSide = #hunter ifTrue: [ ^ 'hunter' ].
	aSide = #internal ifTrue: [ ^ 'internal note' ].
	^ 'program team'
]

{ #category : 'building - lifecycle' }
GtBugbopConversation >> settledColor [
	^ Color fromHexString: 'CBD5E1'
]

{ #category : 'accessing' }
GtBugbopConversation >> sideOf: aComment [
	"#hunter, #team or #internal"
	aComment isInternal ifTrue: [ ^ #internal ].
	aComment authorName = self hunterName ifTrue: [ ^ #hunter ].
	^ #team
]

{ #category : 'accessing' }
GtBugbopConversation >> sortedComments [
	"Oldest first"
	^ (self comments items asSortedCollection: [ :a :b | 
		(a createdAt ifNil: [ DateAndTime epoch ]) <= (b createdAt ifNil: [ DateAndTime epoch ]) ]) asArray
]

{ #category : 'accessing' }
GtBugbopConversation >> startTime [
	self report ifNotNil: [ :aReport | aReport createdAt ifNotNil: [ :aTime | ^ aTime ] ].
	self sortedComments ifEmpty: [ ^ nil ].
	^ self sortedComments first createdAt
]

{ #category : 'accessing' }
GtBugbopConversation >> teamComments [
	"Program team comments, including internal ones"
	^ self sortedComments reject: [ :each | (self sideOf: each) = #hunter ]
]

{ #category : 'accessing' }
GtBugbopConversation >> timeToFirstResponse [
	"Duration from submission to the first program team comment, or nil if the team has not answered"
	| aResponse |
	aResponse := self firstResponse ifNil: [ ^ nil ].
	self startTime ifNil: [ ^ nil ].
	^ aResponse createdAt - self startTime
]

{ #category : 'private' }
GtBugbopConversation >> updatedEvent [
	| aReport |
	aReport := self report ifNil: [ ^ nil ].
	aReport updatedAt ifNil: [ ^ nil ].
	aReport updatedAt = aReport createdAt ifTrue: [ ^ nil ].
	^ GtBugbopLifecycleEvent
		kind: #updated
		time: aReport updatedAt
		side: #system
		label: 'Last updated (status ' , (aReport status ifNil: [ '?' ]) , ')'
		target: aReport
]
