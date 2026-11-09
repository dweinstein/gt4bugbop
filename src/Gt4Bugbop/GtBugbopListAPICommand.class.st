"
I am a paginated list endpoint. I follow Link rel=next until exhausted, or until #limit items have been fetched. Subclasses implement #path and optionally #queryParameters.
"
Class {
	#name : 'GtBugbopListAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'limit'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'private' }
GtBugbopListAPICommand >> commaList: aCollectionOrNil [
	"Bugbop filters take comma separated values"
	^ aCollectionOrNil isString
		ifTrue: [ aCollectionOrNil ]
		ifFalse: [ ',' join: aCollectionOrNil ]
]

{ #category : 'accessing' }
GtBugbopListAPICommand >> limit [
	"Answer the maximum number of items to fetch, or nil for all of them"
	^ limit
]

{ #category : 'accessing' }
GtBugbopListAPICommand >> limit: anIntegerOrNil [
	limit := anIntegerOrNil
]

{ #category : 'accessing' }
GtBugbopListAPICommand >> path [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
GtBugbopListAPICommand >> perform [
	^ (self serializationClass
		from: (self client getAll: self path withParams: self queryParameters limit: self limit))
		client: self client;
		yourself
]

{ #category : 'accessing' }
GtBugbopListAPICommand >> queryParameters [
	^ #()
]
