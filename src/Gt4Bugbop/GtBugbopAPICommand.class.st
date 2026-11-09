"
I am one Bugbop API endpoint call. Subclasses implement #request (answering a GtBugbopRequestResponse) and #serializationClass (the entity or group class built from the JSON result). Mirrors GtLAPICommand from gt4llm.
"
Class {
	#name : 'GtBugbopAPICommand',
	#superclass : 'Object',
	#instVars : [
		'client'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopAPICommand >> client [
	^ client
]

{ #category : 'accessing' }
GtBugbopAPICommand >> client: aClient [
	client := aClient
]

{ #category : 'private' }
GtBugbopAPICommand >> idFrom: anEntityOrId [
	^ self client idFrom: anEntityOrId
]

{ #category : 'accessing' }
GtBugbopAPICommand >> perform [
	^ (self serializationClass from: self request result)
		client: self client;
		yourself
]

{ #category : 'accessing' }
GtBugbopAPICommand >> request [
	"Answer a GtBugbopRequestResponse"
	^ self subclassResponsibility
]

{ #category : 'accessing' }
GtBugbopAPICommand >> serializationClass [
	^ self subclassResponsibility
]
