"
I am the superclass of Bugbop domain objects. I am built from a JSON dictionary using the class-side #serializationProperties mapping (JSON key -> selector) and keep the original JSON as rawData. Mirrors GtLEntity from gt4llm.
"
Class {
	#name : 'GtBugbopEntity',
	#superclass : 'Object',
	#instVars : [
		'rawData',
		'client'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'instance creation' }
GtBugbopEntity class >> from: aDictionary [
	(aDictionary isKindOf: self) ifTrue: [ ^ aDictionary ].
	^ self new from: aDictionary
]

{ #category : 'accessing' }
GtBugbopEntity class >> serializationProperties [
	"Answer associations of JSON key -> accessor selector"
	^ #()
]

{ #category : 'accessing' }
GtBugbopEntity >> client [
	^ client
]

{ #category : 'accessing' }
GtBugbopEntity >> client: aClient [
	client := aClient.
	self nestedEntities do: [ :each | each client: aClient ]
]

{ #category : 'private - deserialization' }
GtBugbopEntity >> deserialize: anObject as: anEntityClass [
	anObject isDictionary ifFalse: [ ^ anObject ].
	^ (anEntityClass from: anObject) client: client; yourself
]

{ #category : 'private - deserialization' }
GtBugbopEntity >> deserializeTime: anObject [
	anObject isString ifFalse: [ ^ anObject ].
	^ DateAndTime fromString: anObject
]

{ #category : 'gt views' }
GtBugbopEntity >> detailRows [
	"Answer label -> value associations shown in the Details view"
	^ self class serializationProperties
		collect: [ :aPair | aPair value asString -> (self perform: aPair value) ]
]

{ #category : 'initialization' }
GtBugbopEntity >> from: aDictionary [
	self rawData: aDictionary.
	self class serializationProperties
		do: [ :aPair | 
			aDictionary
				at: aPair key asString
				ifPresent: [ :aValue | self perform: aPair value asMutator with: aValue ] ]
]

{ #category : 'gt views' }
GtBugbopEntity >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 40;
		items: [ self detailRows ];
		column: 'Property' text: [ :each | each key ] width: 160;
		column: 'Value' text: [ :each | each value ifNil: [ '' ] ifNotNil: [ :aValue | aValue gtDisplayString ] ];
		send: [ :each | each value ]
]

{ #category : 'gt actions' }
GtBugbopEntity >> gtOpenInBrowserActionFor: anAction [
	<gtAction>
	self webUrl ifNil: [ ^ anAction noAction ].
	^ anAction button
		icon: BrGlamorousVectorIcons link;
		tooltip: 'Open on bugbop.com';
		priority: 10;
		action: [ self openInBrowser ]
]

{ #category : 'gt views' }
GtBugbopEntity >> gtRawDataFor: aView [
	<gtView>
	rawData ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Raw data';
		priority: 50;
		object: [ rawData ];
		view: #gtTreeFor:
]

{ #category : 'accessing' }
GtBugbopEntity >> nestedEntities [
	"Answer embedded entities that should share my client"
	^ #()
]

{ #category : 'actions' }
GtBugbopEntity >> openInBrowser [
	self webUrl ifNotNil: [ :aUrl | WebBrowser openOn: aUrl asString ]
]

{ #category : 'accessing' }
GtBugbopEntity >> rawData [
	^ rawData
]

{ #category : 'accessing' }
GtBugbopEntity >> rawData: aDictionary [
	rawData := aDictionary
]

{ #category : 'accessing' }
GtBugbopEntity >> webUrl [
	"Answer the page of this object on bugbop.com, if known"
	^ nil
]
