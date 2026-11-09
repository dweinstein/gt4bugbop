"
I am one labelled number on the GtBugbopExplorer overview. target is the object to spawn when I am selected.
"
Class {
	#name : 'GtBugbopMetric',
	#superclass : 'Object',
	#instVars : [
		'label',
		'value',
		'target'
	],
	#category : 'Gt4Bugbop-Explorer',
	#package : 'Gt4Bugbop',
	#tag : 'Explorer'
}

{ #category : 'instance creation' }
GtBugbopMetric class >> label: aString value: anObject target: aTargetOrNil [
	^ self new
		label: aString;
		value: anObject;
		target: aTargetOrNil;
		yourself
]

{ #category : 'accessing' }
GtBugbopMetric >> label [
	^ label
]

{ #category : 'accessing' }
GtBugbopMetric >> label: aString [
	label := aString
]

{ #category : 'printing' }
GtBugbopMetric >> printOn: aStream [
	aStream
		nextPutAll: label;
		nextPutAll: ': ';
		nextPutAll: value gtDisplayString
]

{ #category : 'accessing' }
GtBugbopMetric >> target [
	"Answer the object to spawn when selected; defaults to the value"
	^ target ifNil: [ value ]
]

{ #category : 'accessing' }
GtBugbopMetric >> target: anObject [
	target := anObject
]

{ #category : 'accessing' }
GtBugbopMetric >> value [
	^ value
]

{ #category : 'accessing' }
GtBugbopMetric >> value: anObject [
	value := anObject
]
