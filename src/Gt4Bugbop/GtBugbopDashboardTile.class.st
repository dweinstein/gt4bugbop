"
I am one metric tile on a GtBugbopDashboard: a caption (label), a headline value, an optional sub-caption (detail), an accent color and the domain object (target) that the tile spawns when clicked.

Create me with label:value:detail:color:target:.
"
Class {
	#name : 'GtBugbopDashboardTile',
	#superclass : 'Object',
	#instVars : [
		'label',
		'value',
		'detail',
		'color',
		'target'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'instance creation' }
GtBugbopDashboardTile class >> label: aLabel value: aValue detail: aDetail color: aColor target: aTarget [
	^ self new
		label: aLabel;
		value: aValue;
		detail: aDetail;
		color: aColor;
		target: aTarget;
		yourself
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> color [
	^ color ifNil: [ Color fromHexString: '546E7A' ]
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> color: aColor [
	color := aColor
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> detail [
	^ detail ifNil: [ '' ]
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> detail: aString [
	detail := aString
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> displayValue [
	"The headline text shown in large type"
	value ifNil: [ ^ '-' ].
	^ value isString
		ifTrue: [ value ]
		ifFalse: [ value gtDisplayString ]
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> label [
	^ label
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> label: aString [
	label := aString
]

{ #category : 'printing' }
GtBugbopDashboardTile >> printOn: aStream [
	aStream nextPutAll: self label; nextPutAll: ': '; nextPutAll: self displayValue
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> target [
	^ target
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> target: anObject [
	target := anObject
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> tooltipText [
	^ String streamContents: [ :aStream |
		aStream nextPutAll: self label; nextPutAll: ': '; nextPutAll: self displayValue.
		self detail ifNotEmpty: [ :aDetail | aStream nextPutAll: ' ('; nextPutAll: aDetail; nextPut: $) ].
		aStream nextPutAll: ' - click to inspect' ]
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> value [
	^ value
]

{ #category : 'accessing' }
GtBugbopDashboardTile >> value: anObject [
	value := anObject
]
