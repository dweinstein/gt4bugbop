"
I create ZnClients configured for the Bugbop API: JSON accept header, bearer authentication and a user agent.

I deliberately do not use forJsonREST: error bodies are parsed by GtBugbopRequestResponse only after the status code has been inspected.
"
Class {
	#name : 'GtBugbopClientZincBuilder',
	#superclass : 'Object',
	#instVars : [
		'apiKey'
	],
	#category : 'Gt4Bugbop-Client',
	#package : 'Gt4Bugbop',
	#tag : 'Client'
}

{ #category : 'accessing' }
GtBugbopClientZincBuilder >> apiKey [
	^ apiKey
]

{ #category : 'accessing' }
GtBugbopClientZincBuilder >> apiKey: aString [
	apiKey := aString
]

{ #category : 'building' }
GtBugbopClientZincBuilder >> create [
	"Create a ZnClient for the Bugbop API. Not forJsonREST: we inspect the status before parsing.
	Redirects are not followed, so the bearer token is never forwarded to another host."
	| aClient |
	aClient := self newBasicClient.
	aClient
		accept: ZnMimeType applicationJson;
		headerAt: 'User-Agent' put: self userAgent;
		followRedirects: false;
		timeout: 60.
	apiKey isEmptyOrNil ifFalse: [ aClient setBearerAuthentication: apiKey ].
	^ aClient
]

{ #category : 'building' }
GtBugbopClientZincBuilder >> newBasicClient [
	^ ZnClient new
]

{ #category : 'accessing' }
GtBugbopClientZincBuilder >> userAgent [
	^ 'Gt4Bugbop (Glamorous Toolkit)'
]
