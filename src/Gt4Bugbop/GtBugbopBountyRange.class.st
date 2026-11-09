"
I am the suggested cash bounty range of a program for one severity.
"
Class {
	#name : 'GtBugbopBountyRange',
	#superclass : 'Object',
	#instVars : [
		'severity',
		'minCents',
		'maxCents'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'formatting' }
GtBugbopBountyRange class >> amountStringFromCents: anIntegerOrNil [
	"Answer e.g. '$1,250.00'. Bugbop amounts are USD cents."
	anIntegerOrNil ifNil: [ ^ '' ].
	^ String streamContents: [ :aStream | 
		aStream
			nextPut: $$;
			nextPutAll: (self groupThousands: anIntegerOrNil // 100);
			nextPut: $..
		(anIntegerOrNil \\ 100) printOn: aStream base: 10 nDigits: 2 ]
]

{ #category : 'formatting' }
GtBugbopBountyRange class >> groupThousands: anInteger [
	"12345 -> '12,345'"
	| digits |
	digits := anInteger printString.
	^ String streamContents: [ :aStream | 
		digits withIndexDo: [ :aDigit :anIndex | 
			(anIndex > 1 and: [ (digits size - anIndex + 1) \\ 3 = 0 ]) ifTrue: [ aStream nextPut: $, ].
			aStream nextPut: aDigit ] ]
]

{ #category : 'instance creation' }
GtBugbopBountyRange class >> severity: aString from: aDictionary [
	^ self new
		severity: aString;
		minCents: (aDictionary at: 'min_cents' ifAbsent: [ nil ]);
		maxCents: (aDictionary at: 'max_cents' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'printing' }
GtBugbopBountyRange >> maxAmountString [
	^ self class amountStringFromCents: maxCents
]

{ #category : 'accessing' }
GtBugbopBountyRange >> maxCents [
	^ maxCents
]

{ #category : 'accessing' }
GtBugbopBountyRange >> maxCents: anInteger [
	maxCents := anInteger
]

{ #category : 'printing' }
GtBugbopBountyRange >> minAmountString [
	^ self class amountStringFromCents: minCents
]

{ #category : 'accessing' }
GtBugbopBountyRange >> minCents [
	^ minCents
]

{ #category : 'accessing' }
GtBugbopBountyRange >> minCents: anInteger [
	minCents := anInteger
]

{ #category : 'printing' }
GtBugbopBountyRange >> printOn: aStream [
	aStream
		nextPutAll: (severity ifNil: [ '?' ]);
		nextPutAll: ': ';
		nextPutAll: self minAmountString;
		nextPutAll: ' - ';
		nextPutAll: self maxAmountString
]

{ #category : 'accessing' }
GtBugbopBountyRange >> severity [
	^ severity
]

{ #category : 'accessing' }
GtBugbopBountyRange >> severity: aString [
	severity := aString
]
