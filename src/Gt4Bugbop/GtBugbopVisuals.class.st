"
I am a small class-side toolkit of Brick element builders shared by the Bugbop per-report visuals: pills, avatars, stat tiles, legends, section headers, relative-time formatting and click-to-spawn wiring.

I keep the visual vocabulary (colors, font sizes, corner radii, spacing) in one place so the report card, the conversation and the lifecycle timeline look like one system.
"
Class {
	#name : 'GtBugbopVisuals',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'elements' }
GtBugbopVisuals class >> avatarFor: aName color: aColor size: aNumber [
	"A colored circle with the initials of aName"
	^ BrFrame new
		exact: aNumber @ aNumber;
		geometry: BlCircleGeometry new;
		background: aColor;
		addChild: ((self boldLabel: (self initialsOf: aName) size: (aNumber * 0.4) rounded color: Color white)
			constraintsDo: [ :c | 
				c frame horizontal alignCenter.
				c frame vertical alignCenter ])
]

{ #category : 'text' }
GtBugbopVisuals class >> boldLabel: aString size: aNumber color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				glamorousRegularFontAndSize;
				fontSize: aNumber;
				bold;
				foreground: aColor);
		text: aString asString
]

{ #category : 'colors' }
GtBugbopVisuals class >> bountyColor [
	^ Color fromHexString: '2E7D32'
]

{ #category : 'colors' }
GtBugbopVisuals class >> bubbleColorForSide: aSide [
	aSide = #hunter ifTrue: [ ^ Color fromHexString: 'E6F4F1' ].
	aSide = #team ifTrue: [ ^ Color fromHexString: 'E8F1FC' ].
	aSide = #internal ifTrue: [ ^ Color fromHexString: 'FFF6E0' ].
	^ Color fromHexString: 'F3F4F6'
]

{ #category : 'elements' }
GtBugbopVisuals class >> card [
	"An empty white card container with a soft border"
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 16);
		margin: (BlInsets bottom: 12);
		background: self cardBackground;
		border: (BlBorder paint: self lineColor width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8)
]

{ #category : 'colors' }
GtBugbopVisuals class >> cardBackground [
	^ Color white
]

{ #category : 'colors' }
GtBugbopVisuals class >> colorForSide: aSide [
	aSide = #hunter ifTrue: [ ^ self hunterColor ].
	aSide = #team ifTrue: [ ^ self teamColor ].
	aSide = #internal ifTrue: [ ^ self internalColor ].
	^ self mutedColor
]

{ #category : 'formatting' }
GtBugbopVisuals class >> dateString: aDateAndTime [
	"e.g. Oct 21, 2026 17:54"
	| aLocal |
	aDateAndTime ifNil: [ ^ '' ].
	aLocal := aDateAndTime asLocal.
	^ String streamContents: [ :s | 
		s
			nextPutAll: aLocal monthAbbreviation;
			space;
			print: aLocal dayOfMonth;
			nextPutAll: ', ';
			print: aLocal year;
			space;
			nextPutAll: (aLocal hour printPaddedWith: $0 to: 2);
			nextPut: $:;
			nextPutAll: (aLocal minute printPaddedWith: $0 to: 2) ]
]

{ #category : 'elements' }
GtBugbopVisuals class >> dotColored: aColor size: aNumber [
	^ BlElement new
		size: aNumber @ aNumber;
		geometry: BlCircleGeometry new;
		background: aColor
]

{ #category : 'formatting' }
GtBugbopVisuals class >> durationString: aDuration [
	"Compact human duration: 3mo, 4d 6h, 5h 12m, 7m"
	| d |
	aDuration ifNil: [ ^ '' ].
	d := aDuration abs.
	d days >= 60 ifTrue: [ ^ (d days // 30) printString , 'mo' ].
	d days >= 7 ifTrue: [ ^ d days printString , 'd' ].
	d days >= 1 ifTrue: [ ^ d days printString , 'd ' , d hours printString , 'h' ].
	d hours >= 1 ifTrue: [ ^ d hours printString , 'h ' , d minutes printString , 'm' ].
	^ (d minutes max: 1) printString , 'm'
]

{ #category : 'text' }
GtBugbopVisuals class >> emptyLabel: aString [
	^ BrFrame new
		matchParent;
		padding: (BlInsets all: 30);
		addChild: ((self label: aString size: 14 color: self mutedColor)
			constraintsDo: [ :c | 
				c frame horizontal alignCenter.
				c frame vertical alignCenter ])
]

{ #category : 'formatting' }
GtBugbopVisuals class >> excerptOf: aString limit: anInteger [
	| aTrimmed |
	aString isEmptyOrNil ifTrue: [ ^ '' ].
	aTrimmed := aString trimBoth.
	aTrimmed size <= anInteger ifTrue: [ ^ aTrimmed ].
	^ (aTrimmed first: anInteger) trimRight , ' ...'
]

{ #category : 'colors' }
GtBugbopVisuals class >> hunterColor [
	^ Color fromHexString: '00897B'
]

{ #category : 'formatting' }
GtBugbopVisuals class >> initialsOf: aName [
	| letters |
	letters := (aName ifNil: [ '' ]) select: [ :each | each isAlphaNumeric ].
	letters ifEmpty: [ ^ '?' ].
	^ (letters first: (letters size min: 2)) asUppercase
]

{ #category : 'colors' }
GtBugbopVisuals class >> internalColor [
	^ Color fromHexString: '8D6E63'
]

{ #category : 'text' }
GtBugbopVisuals class >> joinTexts: aCollectionOfTexts [
	| aText |
	aText := '' asRopedText.
	aCollectionOfTexts
		do: [ :each | aText append: each ]
		separatedBy: [ aText append: String cr asRopedText ].
	^ aText
]

{ #category : 'text' }
GtBugbopVisuals class >> label: aString size: aNumber color: aColor [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				glamorousRegularFontAndSize;
				fontSize: aNumber;
				foreground: aColor);
		text: aString asString
]

{ #category : 'elements' }
GtBugbopVisuals class >> legendItem: aString color: aColor [
	^ BrHorizontalPane new
		fitContent;
		alignCenterLeft;
		margin: (BlInsets top: 0 left: 0 bottom: 4 right: 16);
		addChild: ((self dotColored: aColor size: 10) margin: (BlInsets right: 5));
		addChild: (self label: aString size: 11 color: self mutedColor)
]

{ #category : 'elements' }
GtBugbopVisuals class >> legendWith: aCollectionOfAssociations [
	"aCollectionOfAssociations maps label -> color"
	| aFlow |
	aFlow := BrHorizontalFlow new
			hMatchParent;
			vFitContent.
	aCollectionOfAssociations
		do: [ :each | aFlow addChild: (self legendItem: each key color: each value) ].
	^ aFlow
]

{ #category : 'colors' }
GtBugbopVisuals class >> lineColor [
	^ Color fromHexString: 'E5E7EB'
]

{ #category : 'interaction' }
GtBugbopVisuals class >> make: anElement spawn: aBlock [
	"Clicking anElement spawns the object answered by aBlock (nothing if it answers nil)"
	anElement
		when: BlClickEvent
		do: [ :anEvent | 
			anEvent consumed: true.
			aBlock value ifNotNil: [ :anObject | anElement phlow spawnObject: anObject ] ].
	^ anElement
]

{ #category : 'interaction' }
GtBugbopVisuals class >> make: anElement tooltip: aString [
	aString isEmptyOrNil ifTrue: [ ^ anElement ].
	anElement addAptitude: (BrGlamorousWithExplicitTooltipAptitude text: aString).
	^ anElement
]

{ #category : 'text' }
GtBugbopVisuals class >> markdownLiteText: aString [
	"Cheap markdown-ish styling: headings bold, fenced code in a monospaced font, the rest plain"
	| styledLines inCode |
	styledLines := OrderedCollection new.
	inCode := false.
	(aString ifNil: [ '' ]) trimBoth lines
		do: [ :aLine | 
			(aLine trimBoth beginsWith: '```')
				ifTrue: [ inCode := inCode not ]
				ifFalse: [ styledLines add: (self styledLine: aLine inCode: inCode) ] ].
	^ self joinTexts: styledLines
]

{ #category : 'text' }
GtBugbopVisuals class >> metaLabel: aString [
	^ self label: aString size: 12 color: self mutedColor
]

{ #category : 'colors' }
GtBugbopVisuals class >> mutedColor [
	^ Color fromHexString: '6B7280'
]

{ #category : 'elements' }
GtBugbopVisuals class >> outlinePillLabeled: aString color: aColor [
	"A tinted, outlined pill for secondary flags"
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				glamorousRegularFontAndSize;
				fontSize: 11;
				bold;
				foreground: aColor);
		text: aString asString;
		background: (aColor alpha: 0.1);
		border: (BlBorder paint: aColor width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		padding: (BlInsets top: 2 left: 9 bottom: 2 right: 9);
		margin: (BlInsets top: 0 left: 0 bottom: 6 right: 6)
]

{ #category : 'elements' }
GtBugbopVisuals class >> page [
	"The light gray backdrop all report visuals sit on"
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 16);
		background: self pageBackground
]

{ #category : 'colors' }
GtBugbopVisuals class >> pageBackground [
	^ Color fromHexString: 'F7F8FA'
]

{ #category : 'elements' }
GtBugbopVisuals class >> pillLabeled: aString color: aColor [
	"A solid rounded pill with white text"
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				glamorousRegularFontAndSize;
				fontSize: 11;
				bold;
				foreground: Color white);
		text: aString asString;
		background: aColor;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		padding: (BlInsets top: 3 left: 10 bottom: 3 right: 10);
		margin: (BlInsets top: 0 left: 0 bottom: 6 right: 6)
]

{ #category : 'text' }
GtBugbopVisuals class >> readOnlyText: aText [
	"A wrapping, read-only text block that grows with its content"
	^ BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		text: aText;
		beReadOnlyWithoutSelection;
		hMatchParent;
		vFitContent
]

{ #category : 'formatting' }
GtBugbopVisuals class >> readableMarkdown: aString [
	"Strip the noisiest markdown for compact previews: [text](url) links become text, emphasis markers, backslash escapes and &nbsp; go away. Headings and fences are kept for markdownLiteText:"
	| aText |
	aString isEmptyOrNil ifTrue: [ ^ '' ].
	aText := '\[[^]]*\]\([^)]*\)' asRegex
			copy: aString
			translatingMatchesUsing: [ :aMatch | (aMatch copyAfter: $[) copyUpTo: $] ].
	aText := aText copyReplaceAll: '&nbsp;' with: ' '.
	aText := aText copyReplaceAll: '\' with: ''.
	^ aText copyReplaceAll: '**' with: ''
]

{ #category : 'formatting' }
GtBugbopVisuals class >> relativeTimeFor: aDateAndTime [
	aDateAndTime ifNil: [ ^ '' ].
	^ (self durationString: DateAndTime now - aDateAndTime) , ' ago'
]

{ #category : 'elements' }
GtBugbopVisuals class >> scrollablePage: aPage [
	^ aPage asScrollableElement background: self pageBackground
]

{ #category : 'text' }
GtBugbopVisuals class >> sectionHeader: aString [
	^ (self boldLabel: aString asUppercase size: 10 color: self mutedColor)
		margin: (BlInsets bottom: 6)
]

{ #category : 'elements' }
GtBugbopVisuals class >> statTile: aValueString caption: aCaption color: aColor [
	"A small metric tile: a big colored value over a muted caption"
	^ BrVerticalPane new
		fitContent;
		padding: (BlInsets top: 10 left: 14 bottom: 10 right: 14);
		margin: (BlInsets top: 0 left: 0 bottom: 10 right: 10);
		background: self cardBackground;
		border: (BlBorder paint: self lineColor width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		addChild: (self boldLabel: aValueString size: 20 color: aColor);
		addChild: (self label: aCaption size: 11 color: self mutedColor)
]

{ #category : 'text' }
GtBugbopVisuals class >> styledLine: aLine inCode: aBoolean [
	aBoolean ifTrue: [ 
		^ aLine asRopedText
			glamorousCodeFont;
			fontSize: 12;
			foreground: (Color fromHexString: '374151');
			yourself ].
	(aLine beginsWith: '#') ifFalse: [ 
		^ aLine asRopedText
			fontSize: 13;
			yourself ].
	^ (aLine copyWithoutAll: '#') trimBoth asRopedText
		bold;
		fontSize: 15;
		yourself
]

{ #category : 'colors' }
GtBugbopVisuals class >> teamColor [
	^ Color fromHexString: '1E88E5'
]

{ #category : 'colors' }
GtBugbopVisuals class >> waitingColor [
	^ Color fromHexString: 'FFB300'
]
