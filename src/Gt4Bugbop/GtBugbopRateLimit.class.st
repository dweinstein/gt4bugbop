"
I hold the most recent X-RateLimit-* values reported by Bugbop. Limits are per user and per bucket (read, quiet, noisy).
"
Class {
	#name : 'GtBugbopRateLimit',
	#superclass : 'Object',
	#instVars : [
		'limit',
		'remaining',
		'resetsAt',
		'resource',
		'updatedAt'
	],
	#category : 'Gt4Bugbop-Client',
	#package : 'Gt4Bugbop',
	#tag : 'Client'
}

{ #category : 'testing' }
GtBugbopRateLimit >> isKnown [
	^ limit notNil
]

{ #category : 'accessing' }
GtBugbopRateLimit >> limit [
	^ limit
]

{ #category : 'printing' }
GtBugbopRateLimit >> printOn: aStream [
	self isKnown ifFalse: [ ^ aStream nextPutAll: 'Rate limit: unknown (no requests yet)' ].
	aStream
		print: remaining;
		nextPut: $/;
		print: limit;
		nextPutAll: ' ';
		nextPutAll: (resource ifNil: [ '?' ]);
		nextPutAll: ' requests left this hour'.
	resetsAt ifNotNil: [ :aTime | aStream nextPutAll: ', resets at '; print: aTime asLocal asTime ]
]

{ #category : 'accessing' }
GtBugbopRateLimit >> remaining [
	^ remaining
]

{ #category : 'accessing' }
GtBugbopRateLimit >> resetsAt [
	^ resetsAt
]

{ #category : 'accessing' }
GtBugbopRateLimit >> resource [
	"Answer the bucket: read, quiet or noisy"
	^ resource
]

{ #category : 'updating' }
GtBugbopRateLimit >> updateFromResponse: aZnResponse [
	"Bugbop sends X-RateLimit-* on every response; keep the values of the last one"
	| headers |
	headers := aZnResponse headers.
	(headers includesKey: 'X-RateLimit-Limit') ifFalse: [ ^ self ].
	limit := (headers at: 'X-RateLimit-Limit') asInteger.
	remaining := (headers at: 'X-RateLimit-Remaining' ifAbsent: [ nil ]) ifNotNil: #asInteger.
	resetsAt := (headers at: 'X-RateLimit-Reset' ifAbsent: [ nil ])
			ifNotNil: [ :aValue | DateAndTime fromUnixTime: aValue asInteger ].
	resource := headers at: 'X-RateLimit-Resource' ifAbsent: [ nil ].
	updatedAt := DateAndTime now
]

{ #category : 'accessing' }
GtBugbopRateLimit >> updatedAt [
	^ updatedAt
]
