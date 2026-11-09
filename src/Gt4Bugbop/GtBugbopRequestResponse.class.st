"
I capture one HTTP exchange with the Bugbop API: the ZnRequest, the ZnResponse and the parsed JSON result. I know how to read Bugbop's pagination (Link, X-Total-Count) and rate limit headers.
"
Class {
	#name : 'GtBugbopRequestResponse',
	#superclass : 'Object',
	#instVars : [
		'request',
		'response',
		'result',
		'timestamp'
	],
	#category : 'Gt4Bugbop-Client',
	#package : 'Gt4Bugbop',
	#tag : 'Client'
}

{ #category : 'parsing' }
GtBugbopRequestResponse class >> parseLinkHeader: aString [
	"Answer a Dictionary rel -> ZnUrl. Parsed with a regex rather than by splitting on commas,
	because Bugbop's filter values (status=new,open) can put commas inside the URLs."
	| pattern links matcher |
	pattern := '<([^>]+)>\s*;\s*rel="([^"]+)"'.
	matcher := pattern asRegex.
	links := Dictionary new.
	(aString allRegexMatches: pattern)
		do: [ :aLink | 
			(matcher matches: aLink)
				ifTrue: [ links at: (matcher subexpression: 3) put: (matcher subexpression: 2) asZnUrl ] ].
	^ links
]

{ #category : 'instance creation' }
GtBugbopRequestResponse class >> request: aZnRequest response: aZnResponse [
	^ self new
		request: aZnRequest;
		response: aZnResponse;
		yourself
]

{ #category : 'gt views' }
GtBugbopRequestResponse >> gtRequestFor: aView [
	<gtView>
	request ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Request';
		priority: 5;
		object: [ request ];
		view: #gtHeadersFor:
]

{ #category : 'gt views' }
GtBugbopRequestResponse >> gtResponseFor: aView [
	<gtView>
	response ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Response';
		priority: 6;
		object: [ response ];
		view: #gtHeadersFor:
]

{ #category : 'gt views' }
GtBugbopRequestResponse >> gtResultFor: aView [
	<gtView>
	result isCollection ifFalse: [ ^ aView empty ].
	^ aView forward
		title: 'Result';
		priority: 1;
		object: [ result ];
		view: #gtTreeFor:
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> headerAt: aName [
	"Answer the response header value, or nil. ZnHeaders lookups are case-insensitive."
	^ response headers at: aName ifAbsent: [ nil ]
]

{ #category : 'initialization' }
GtBugbopRequestResponse >> initialize [
	super initialize.
	timestamp := DateAndTime now
]

{ #category : 'testing' }
GtBugbopRequestResponse >> isRateLimited [
	^ response code = 429
]

{ #category : 'testing' }
GtBugbopRequestResponse >> isSuccess [
	^ response isSuccess
]

{ #category : 'pagination' }
GtBugbopRequestResponse >> links [
	^ (self headerAt: 'Link')
		ifNil: [ Dictionary new ]
		ifNotNil: [ :aString | self class parseLinkHeader: aString ]
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> method [
	^ request method
]

{ #category : 'pagination' }
GtBugbopRequestResponse >> nextPageUrl [
	^ self links at: 'next' ifAbsent: [ nil ]
]

{ #category : 'private' }
GtBugbopRequestResponse >> parseResult [
	| contents |
	contents := response contents.
	contents isEmptyOrNil ifTrue: [ ^ nil ].
	contents isString ifFalse: [ ^ contents ].
	^ [ STONJSON fromString: contents ]
		on: Error
		do: [ :anError | anError return: contents ]
]

{ #category : 'printing' }
GtBugbopRequestResponse >> printOn: aStream [
	request ifNil: [ ^ super printOn: aStream ].
	aStream
		nextPutAll: self method;
		space;
		nextPutAll: self url pathPrintString;
		nextPutAll: ' -> ';
		print: self statusCode
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> request [
	^ request
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> request: aZnRequest [
	request := aZnRequest
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> response [
	^ response
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> response: aZnResponse [
	response := aZnResponse.
	result := self parseResult
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> result [
	"Answer the parsed JSON body (Dictionary, Array) or nil for an empty body"
	^ result
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> retryAfter [
	"Answer how long Bugbop asked us to wait, as a Duration (1 second if unspecified)"
	^ (((self headerAt: 'Retry-After') ifNotNil: [ :aValue | aValue asInteger ]) ifNil: [ 1 ]) seconds
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> statusCode [
	^ response code
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> timestamp [
	^ timestamp
]

{ #category : 'pagination' }
GtBugbopRequestResponse >> totalCount [
	"Answer X-Total-Count for list endpoints, or nil"
	^ (self headerAt: 'X-Total-Count') ifNotNil: [ :aValue | aValue asInteger ]
]

{ #category : 'accessing' }
GtBugbopRequestResponse >> url [
	^ request url
]
