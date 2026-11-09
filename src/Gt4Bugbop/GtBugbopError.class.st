"
I am signalled when the Bugbop API answers a non-2xx status. I carry Bugbop's JSON error message and, for 422s, the list of field errors.
"
Class {
	#name : 'GtBugbopError',
	#superclass : 'Error',
	#instVars : [
		'requestResponse',
		'statusCode',
		'apiMessage',
		'fieldErrors'
	],
	#category : 'Gt4Bugbop-Client',
	#package : 'Gt4Bugbop',
	#tag : 'Client'
}

{ #category : 'instance creation' }
GtBugbopError class >> fromRequestResponse: aRequestResponse [
	^ self new initializeFromRequestResponse: aRequestResponse
]

{ #category : 'accessing' }
GtBugbopError >> apiMessage [
	^ apiMessage
]

{ #category : 'private' }
GtBugbopError >> buildMessageText [
	^ String streamContents: [ :aStream | 
		aStream
			nextPutAll: 'Bugbop API ';
			print: statusCode;
			nextPutAll: ': ';
			nextPutAll: (apiMessage ifNil: [ requestResponse response statusLine reason ]).
		fieldErrors do: [ :each | 
			aStream nextPutAll: ' ['; nextPutAll: (each at: 'message' ifAbsent: [ each printString ]); nextPutAll: ']' ].
		self hint ifNotNil: [ :aHint | aStream nextPutAll: ' -- '; nextPutAll: aHint ] ]
]

{ #category : 'accessing' }
GtBugbopError >> fieldErrors [
	"Answer the 422 validation errors: dictionaries with field, code and message"
	^ fieldErrors
]

{ #category : 'gt views' }
GtBugbopError >> gtFieldErrorsFor: aView [
	<gtView>
	fieldErrors isEmptyOrNil ifTrue: [ ^ aView empty ].
	^ aView columnedList
		title: 'Field errors';
		priority: 2;
		items: [ fieldErrors ];
		column: 'Field' text: [ :each | each at: 'field' ifAbsent: [ '' ] ] width: 140;
		column: 'Code' text: [ :each | each at: 'code' ifAbsent: [ '' ] ] width: 100;
		column: 'Message' text: [ :each | each at: 'message' ifAbsent: [ '' ] ]
]

{ #category : 'gt views' }
GtBugbopError >> gtRequestResponseFor: aView [
	<gtView>
	requestResponse ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'HTTP';
		priority: 3;
		object: [ requestResponse ];
		view: #gtResultFor:
]

{ #category : 'accessing' }
GtBugbopError >> hint [
	statusCode = 401 ifTrue: [ ^ 'check the token in ' , GtBugbopClient apiKeyFile fullName ].
	statusCode = 403 ifTrue: [ ^ 'the token lacks the scope, or your program role does not allow this' ].
	statusCode = 404 ifTrue: [ ^ 'it does not exist, or the token cannot see it' ].
	self isRateLimited ifTrue: [ ^ 'retry after ' , self retryAfter printString ].
	^ nil
]

{ #category : 'initialization' }
GtBugbopError >> initializeFromRequestResponse: aRequestResponse [
	| body |
	requestResponse := aRequestResponse.
	statusCode := aRequestResponse statusCode.
	body := aRequestResponse result.
	body isDictionary ifTrue: [
		apiMessage := body at: 'message' ifAbsent: [ nil ].
		fieldErrors := body at: 'errors' ifAbsent: [ #() ] ].
	fieldErrors ifNil: [ fieldErrors := #() ].
	self messageText: self buildMessageText
]

{ #category : 'testing' }
GtBugbopError >> isForbidden [
	^ statusCode = 403
]

{ #category : 'testing' }
GtBugbopError >> isNotFound [
	^ statusCode = 404
]

{ #category : 'testing' }
GtBugbopError >> isRateLimited [
	^ statusCode = 429
]

{ #category : 'testing' }
GtBugbopError >> isUnauthorized [
	^ statusCode = 401
]

{ #category : 'accessing' }
GtBugbopError >> requestResponse [
	^ requestResponse
]

{ #category : 'accessing' }
GtBugbopError >> retryAfter [
	^ requestResponse retryAfter
]

{ #category : 'accessing' }
GtBugbopError >> statusCode [
	^ statusCode
]
