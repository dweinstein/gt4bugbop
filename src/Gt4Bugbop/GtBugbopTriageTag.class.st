"
I am a small colored tag used by the triage board: a short label (e.g. 'scope', 'AI: high', 'stale 40d'), the color that encodes its meaning, and a longer explanation shown as a tooltip.

I know how to render myself as a rounded pill via #newElement.
"
Class {
	#name : 'GtBugbopTriageTag',
	#superclass : 'Object',
	#instVars : [
		'label',
		'color',
		'explanation'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'instance creation' }
GtBugbopTriageTag class >> label: aString color: aColor explanation: anExplanation [
	^ self new
		label: aString;
		color: aColor;
		explanation: anExplanation;
		yourself
]

{ #category : 'accessing' }
GtBugbopTriageTag >> color [
	^ color ifNil: [ Color gray ]
]

{ #category : 'accessing' }
GtBugbopTriageTag >> color: aColor [
	color := aColor
]

{ #category : 'accessing' }
GtBugbopTriageTag >> explanation [
	^ explanation ifNil: [ label ]
]

{ #category : 'accessing' }
GtBugbopTriageTag >> explanation: aString [
	explanation := aString
]

{ #category : 'accessing' }
GtBugbopTriageTag >> label [
	^ label
]

{ #category : 'accessing' }
GtBugbopTriageTag >> label: aString [
	label := aString
]

{ #category : 'ui' }
GtBugbopTriageTag >> newElement [
	"A rounded pill: light solid tint, darkened text for contrast, tooltip with the explanation"
	^ BrLabel new
		text: label asString;
		aptitude: (BrGlamorousLabelAptitude new
				foreground: self textColor;
				fontSize: 10;
				bold)
				+ (BrGlamorousWithExplicitTooltipAptitude text: self explanation);
		background: self tintColor;
		border: (BlBorder paint: (self color mixed: 0.45 with: Color white) width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		padding: (BlInsets top: 1 left: 5 bottom: 1 right: 5)
]

{ #category : 'printing' }
GtBugbopTriageTag >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(; nextPutAll: label asString; nextPut: $)
]

{ #category : 'ui' }
GtBugbopTriageTag >> textColor [
	"Slightly darkened so light hues (e.g. medium yellow) stay readable"
	^ self color mixed: 0.75 with: Color black
]

{ #category : 'ui' }
GtBugbopTriageTag >> tintColor [
	^ self color mixed: 0.13 with: Color white
]
