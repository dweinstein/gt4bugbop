"
I render a {{gtClass:GtBugbopReport}} as a header card: a large title, a row of colored pills (severity, status, AI disagreement, scope warning, duplicate links), the hunter and program, relative times, comment count, the bounty badge and a description excerpt.

Every pill or label that stands for a domain object is clickable and spawns it. Build me with {{gtMethod:GtBugbopReportCard class>>#forReport:}} and render with {{gtMethod:GtBugbopReportCard>>#asElement}}.
"
Class {
	#name : 'GtBugbopReportCard',
	#superclass : 'Object',
	#instVars : [
		'report'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'instance creation' }
GtBugbopReportCard class >> forReport: aReport [
	^ self new report: aReport
]

{ #category : 'converting' }
GtBugbopReportCard >> asElement [
	^ (GtBugbopVisuals page
		addChild: self newHeaderCard;
		addChild: self newDescriptionCard;
		asScrollableElement)
		background: GtBugbopVisuals pageBackground
]

{ #category : 'accessing' }
GtBugbopReportCard >> descriptionExcerpt [
	^ GtBugbopVisuals excerptOf: (GtBugbopVisuals readableMarkdown: report description) limit: 600
]

{ #category : 'views' }
GtBugbopReportCard >> gtCardFor: aView [
	<gtView>
	report ifNil: [ ^ aView empty ].
	^ aView explicit
		title: 'Card';
		priority: 1;
		stencil: [ self asElement ]
]

{ #category : 'accessing' }
GtBugbopReportCard >> linkedReportAt: anId [
	"Resolve a related report through the client, or answer the bare id when offline"
	report client ifNil: [ ^ anId ].
	^ [ report client reportAt: anId ] on: Error do: [ :anError | anId ]
]

{ #category : 'building - pills' }
GtBugbopReportCard >> newAiPill [
	"Only when Bugbop's AI triage disagrees with the program's severity"
	| aPill |
	report aiSeverity ifNil: [ ^ nil ].
	report aiAgreesOnSeverity ifTrue: [ ^ nil ].
	aPill := GtBugbopVisuals
			outlinePillLabeled: 'AI: ' , report aiSeverity
			color: (GtBugbopReport severityColorFor: report aiSeverity).
	GtBugbopVisuals make: aPill tooltip: 'Bugbop AI triage suggests ' , report aiSeverity , ' (program says ' , (report severity ifNil: [ 'none' ]) , '). Click to read the triage.'.
	^ GtBugbopVisuals make: aPill spawn: [ report aiTriage ]
]

{ #category : 'building' }
GtBugbopReportCard >> newBountyBadge [
	| aBadge |
	aBadge := BrVerticalPane new
			fitContent;
			alignCenter;
			padding: (BlInsets top: 6 left: 14 bottom: 6 right: 14);
			background: (GtBugbopVisuals bountyColor alpha: 0.12);
			border: (BlBorder paint: GtBugbopVisuals bountyColor width: 1);
			geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
			addChild: (GtBugbopVisuals boldLabel: report bountyAmountString size: 18 color: GtBugbopVisuals bountyColor);
			addChild: (GtBugbopVisuals label: 'bounty' size: 10 color: GtBugbopVisuals bountyColor).
	^ GtBugbopVisuals make: aBadge tooltip: 'Total bounty awarded for this report'
]

{ #category : 'building' }
GtBugbopReportCard >> newCommentsLink [
	| aCount aLabel |
	aCount := report commentsCount ifNil: [ 0 ].
	aLabel := GtBugbopVisuals
			boldLabel: aCount printString , (aCount = 1 ifTrue: [ ' comment' ] ifFalse: [ ' comments' ])
			size: 12
			color: GtBugbopVisuals teamColor.
	GtBugbopVisuals make: aLabel tooltip: 'Click to open the conversation'.
	^ GtBugbopVisuals make: aLabel spawn: [ GtBugbopConversation forReport: report ]
]

{ #category : 'building' }
GtBugbopReportCard >> newDescriptionCard [
	| aCard |
	aCard := GtBugbopVisuals card.
	aCard addChild: (GtBugbopVisuals sectionHeader: 'Description').
	report description isEmptyOrNil
		ifTrue: [ ^ aCard addChild: (GtBugbopVisuals metaLabel: 'No description provided.') ].
	aCard addChild: (GtBugbopVisuals readOnlyText: (GtBugbopVisuals markdownLiteText: self descriptionExcerpt)).
	aCard addChild: self newReadMoreLink.
	^ aCard
]

{ #category : 'building - pills' }
GtBugbopReportCard >> newDuplicatePill [
	| anId aPill |
	anId := report duplicateOfId ifNil: [ ^ nil ].
	aPill := GtBugbopVisuals
			pillLabeled: 'duplicate of ' , (self shortId: anId)
			color: (Color fromHexString: '546E7A').
	GtBugbopVisuals make: aPill tooltip: 'Closed as a duplicate of report ' , anId , '. Click to open it.'.
	^ GtBugbopVisuals make: aPill spawn: [ self linkedReportAt: anId ]
]

{ #category : 'building' }
GtBugbopReportCard >> newHeaderCard [
	"A white card with a severity-colored accent stripe on the left"
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 12);
		background: GtBugbopVisuals cardBackground;
		border: (BlBorder paint: GtBugbopVisuals lineColor width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		clipChildren: true;
		addChild: (BlElement new
			width: 6;
			constraintsDo: [ :c | c vertical matchParent ];
			background: report severityColor);
		addChild: self newHeaderContent
]

{ #category : 'building' }
GtBugbopReportCard >> newHeaderContent [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 16 left: 18 bottom: 14 right: 18);
		addChild: self newTitleRow;
		addChild: self newPillsRow;
		addChild: self newPeopleRow;
		addChild: self newTimesRow
]

{ #category : 'building' }
GtBugbopReportCard >> newHunterLink [
	^ self
		newLink: (report reporterName ifEmpty: [ 'unknown hunter' ])
		color: GtBugbopVisuals hunterColor
		spawn: [ report user ]
		tooltip: 'Click to inspect the hunter'
]

{ #category : 'building' }
GtBugbopReportCard >> newLink: aString color: aColor spawn: aBlock tooltip: aTooltip [
	| aLabel |
	aLabel := GtBugbopVisuals boldLabel: aString size: 13 color: aColor.
	GtBugbopVisuals make: aLabel tooltip: aTooltip.
	^ GtBugbopVisuals make: aLabel spawn: aBlock
]

{ #category : 'building' }
GtBugbopReportCard >> newPeopleRow [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 6);
		addChild: ((GtBugbopVisuals avatarFor: report reporterName color: GtBugbopVisuals hunterColor size: 24)
			margin: (BlInsets right: 8));
		addChild: (GtBugbopVisuals label: 'reported by ' size: 13 color: GtBugbopVisuals mutedColor);
		addChild: self newHunterLink;
		addChild: (GtBugbopVisuals label: '  in  ' size: 13 color: GtBugbopVisuals mutedColor);
		addChild: self newProgramLink
]

{ #category : 'building' }
GtBugbopReportCard >> newPills [
	^ (OrderedCollection new
		add: self newSeverityPill;
		add: self newStatusPill;
		add: self newAiPill;
		add: self newScopeWarningPill;
		add: self newDuplicatePill;
		add: self newSuspectedDuplicatePill;
		yourself) reject: [ :each | each isNil ]
]

{ #category : 'building' }
GtBugbopReportCard >> newPillsRow [
	^ BrHorizontalFlow new
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 8);
		addChildren: self newPills
]

{ #category : 'building' }
GtBugbopReportCard >> newProgramLink [
	^ self
		newLink: (report program ifNil: [ 'unknown program' ] ifNotNil: [ :aProgram | aProgram name ifNil: [ 'program' ] ])
		color: GtBugbopVisuals teamColor
		spawn: [ report program ifNotNil: [ :aProgram | report resolvedOverviewValue: aProgram ] ]
		tooltip: 'Click to inspect the program'
]

{ #category : 'building' }
GtBugbopReportCard >> newReadMoreLink [
	| aLabel |
	aLabel := (GtBugbopVisuals boldLabel: 'Open full description' size: 12 color: GtBugbopVisuals teamColor)
			margin: (BlInsets top: 8).
	^ GtBugbopVisuals make: aLabel spawn: [ report description ]
]

{ #category : 'building - pills' }
GtBugbopReportCard >> newScopeWarningPill [
	report hasScopeWarning ifFalse: [ ^ nil ].
	^ GtBugbopVisuals
		make: (GtBugbopVisuals outlinePillLabeled: 'scope warning' color: (Color fromHexString: 'C62828'))
		tooltip: 'Bugbop flagged this report as possibly out of the program scope'
]

{ #category : 'building - pills' }
GtBugbopReportCard >> newSeverityPill [
	^ GtBugbopVisuals
		make: (GtBugbopVisuals pillLabeled: (report severity ifNil: [ 'no severity' ]) asUppercase color: report severityColor)
		tooltip: 'Severity set by the program: ' , (report severity ifNil: [ 'none' ])
]

{ #category : 'building - pills' }
GtBugbopReportCard >> newStatusPill [
	^ GtBugbopVisuals
		make: (GtBugbopVisuals pillLabeled: self statusText color: report statusColor)
		tooltip: 'Status: ' , self statusText
]

{ #category : 'building - pills' }
GtBugbopReportCard >> newSuspectedDuplicatePill [
	"Only when the suspicion is not already a confirmed duplicate of the same report"
	| anId aPill |
	anId := report suspectedDuplicateOfId ifNil: [ ^ nil ].
	anId = report duplicateOfId ifTrue: [ ^ nil ].
	aPill := GtBugbopVisuals
			outlinePillLabeled: 'suspected duplicate of ' , (self shortId: anId)
			color: (Color fromHexString: '7B1FA2').
	GtBugbopVisuals make: aPill tooltip: 'Bugbop suspects a duplicate of report ' , anId , '. Click to compare.'.
	^ GtBugbopVisuals make: aPill spawn: [ self linkedReportAt: anId ]
]

{ #category : 'building' }
GtBugbopReportCard >> newTimeLabel: aCaption at: aDateAndTime [
	| aLabel |
	aLabel := (GtBugbopVisuals metaLabel: aCaption , ' ' , (GtBugbopVisuals relativeTimeFor: aDateAndTime))
			margin: (BlInsets right: 18).
	^ GtBugbopVisuals make: aLabel tooltip: (GtBugbopVisuals dateString: aDateAndTime)
]

{ #category : 'building' }
GtBugbopReportCard >> newTimesRow [
	| aRow |
	aRow := BrHorizontalFlow new
			hMatchParent;
			vFitContent.
	aRow addChild: (self newTimeLabel: 'submitted' at: report createdAt).
	report updatedAt = report createdAt
		ifFalse: [ aRow addChild: (self newTimeLabel: 'updated' at: report updatedAt) ].
	^ aRow addChild: self newCommentsLink
]

{ #category : 'building' }
GtBugbopReportCard >> newTitle [
	^ (GtBugbopVisuals
		readOnlyText: ((report title ifNil: [ '(untitled report)' ]) asRopedText
				fontSize: 20;
				bold;
				foreground: (Color fromHexString: '111827')))
		margin: (BlInsets right: 12)
]

{ #category : 'building' }
GtBugbopReportCard >> newTitleRow [
	| aRow |
	aRow := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			margin: (BlInsets bottom: 10).
	aRow addChild: self newTitle.
	report hasBounty ifTrue: [ aRow addChild: self newBountyBadge ].
	^ aRow
]

{ #category : 'accessing' }
GtBugbopReportCard >> pillLabels [
	"The labels of the pills shown under the title, in order; used by examples"
	^ (self newPills collect: [ :each | each text asString ]) asArray
]

{ #category : 'accessing' }
GtBugbopReportCard >> report [
	^ report
]

{ #category : 'accessing' }
GtBugbopReportCard >> report: aReport [
	report := aReport
]

{ #category : 'accessing' }
GtBugbopReportCard >> shortId: anId [
	^ anId asString first: (anId asString size min: 8)
]

{ #category : 'accessing' }
GtBugbopReportCard >> statusText [
	^ (report status ifNil: [ 'unknown' ]) copyReplaceAll: '_' with: ' '
]
