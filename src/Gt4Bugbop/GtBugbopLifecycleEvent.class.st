"
I am one point on a report's lifecycle: the submission, a comment, the last update or now.

I know my time, which side of the conversation produced me (#hunter, #team or #system), a human label and the domain object I stand for (a report or a comment), so a timeline marker can spawn it.
"
Class {
	#name : 'GtBugbopLifecycleEvent',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'time',
		'side',
		'label',
		'target'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'instance creation' }
GtBugbopLifecycleEvent class >> kind: aSymbol time: aDateAndTime side: aSide label: aString target: anObject [
	^ self new
		kind: aSymbol;
		time: aDateAndTime;
		side: aSide;
		label: aString;
		target: anObject;
		yourself
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> color [
	kind = #created ifTrue: [ ^ Color fromHexString: '374151' ].
	kind = #updated ifTrue: [ ^ Color fromHexString: '9CA3AF' ].
	kind = #now ifTrue: [ ^ Color fromHexString: 'D1D5DB' ].
	^ GtBugbopVisuals colorForSide: side
]

{ #category : 'testing' }
GtBugbopLifecycleEvent >> isComment [
	^ kind = #comment
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> kind [
	^ kind
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> kind: aSymbol [
	kind := aSymbol
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> label [
	^ label
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> label: aString [
	label := aString
]

{ #category : 'printing' }
GtBugbopLifecycleEvent >> printOn: aStream [
	aStream
		nextPutAll: kind;
		nextPutAll: ' @ ';
		nextPutAll: (GtBugbopVisuals dateString: time);
		nextPutAll: ' - ';
		nextPutAll: (label ifNil: [ '' ])
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> side [
	^ side
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> side: aSymbol [
	side := aSymbol
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> target [
	^ target
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> target: anObject [
	target := anObject
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> time [
	^ time
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> time: aDateAndTime [
	time := aDateAndTime
]

{ #category : 'accessing' }
GtBugbopLifecycleEvent >> tooltipText [
	^ label , String cr , (GtBugbopVisuals dateString: time) , ' (' , (GtBugbopVisuals relativeTimeFor: time) , ')'
]
