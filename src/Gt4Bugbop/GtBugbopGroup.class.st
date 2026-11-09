"
I am the superclass of typed groups of Bugbop entities. Class-side #itemClass names the entity class used by #from:.
"
Class {
	#name : 'GtBugbopGroup',
	#superclass : 'Object',
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#instVars : [
		'client'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'instance creation' }
GtBugbopGroup class >> from: aCollection [
	^ self withAll: (aCollection collect: [ :each | self itemClass from: each ]) asOrderedCollection
]

{ #category : 'accessing' }
GtBugbopGroup class >> itemClass [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
GtBugbopGroup >> client [
	"Filtered copies (select:, reject:) don't carry the client over, so fall back to an item's"
	^ client ifNil: [ self items ifEmpty: [ nil ] ifNotEmpty: [ :theItems | theItems anyOne client ] ]
]

{ #category : 'accessing' }
GtBugbopGroup >> client: aClient [
	client := aClient.
	self do: [ :each | each client: aClient ]
]
