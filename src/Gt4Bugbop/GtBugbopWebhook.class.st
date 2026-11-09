"
I am a webhook configured on a Bugbop program. secret is only present in the create response.
"
Class {
	#name : 'GtBugbopWebhook',
	#superclass : 'GtBugbopEntity',
	#instVars : [
		'id',
		'programId',
		'url',
		'description',
		'events',
		'secret',
		'settingsUrl',
		'apiUrl',
		'pingUrl',
		'createdAt',
		'updatedAt'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopWebhook class >> serializationProperties [
	^ {
		#id -> #id.
		#program_id -> #programId.
		#url -> #url.
		#description -> #description.
		#events -> #events.
		#secret -> #secret.
		#created_at -> #createdAt.
		#updated_at -> #updatedAt.
		#settings_url -> #settingsUrl.
		#api_url -> #apiUrl.
		#ping_url -> #pingUrl }
]

{ #category : 'accessing' }
GtBugbopWebhook >> apiUrl [
	^ apiUrl
]

{ #category : 'accessing' }
GtBugbopWebhook >> apiUrl: aString [
	apiUrl := aString
]

{ #category : 'accessing' }
GtBugbopWebhook >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
GtBugbopWebhook >> createdAt: aStringOrDateAndTime [
	createdAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopWebhook >> description [
	^ description
]

{ #category : 'accessing' }
GtBugbopWebhook >> description: aString [
	description := aString
]

{ #category : 'gt views' }
GtBugbopWebhook >> detailRows [
	"Never show the signing secret in the Details view"
	^ super detailRows reject: [ :each | each key = 'secret' ]
]

{ #category : 'accessing' }
GtBugbopWebhook >> events [
	^ events ifNil: [ #() ]
]

{ #category : 'accessing' }
GtBugbopWebhook >> events: aCollection [
	events := aCollection
]

{ #category : 'accessing' }
GtBugbopWebhook >> eventsString [
	^ ', ' join: self events
]

{ #category : 'accessing' }
GtBugbopWebhook >> id [
	^ id
]

{ #category : 'accessing' }
GtBugbopWebhook >> id: aString [
	id := aString
]

{ #category : 'accessing' }
GtBugbopWebhook >> pingUrl [
	^ pingUrl
]

{ #category : 'accessing' }
GtBugbopWebhook >> pingUrl: aString [
	pingUrl := aString
]

{ #category : 'printing' }
GtBugbopWebhook >> printOn: aStream [
	aStream
		nextPutAll: (description ifNil: [ 'webhook' ]);
		nextPutAll: ' -> ';
		nextPutAll: (url ifNil: [ '?' ])
]

{ #category : 'accessing' }
GtBugbopWebhook >> programId [
	^ programId
]

{ #category : 'accessing' }
GtBugbopWebhook >> programId: aString [
	programId := aString
]

{ #category : 'accessing' }
GtBugbopWebhook >> rawData: aDictionary [
	"Keep the signing secret out of rawData so the Raw data view never shows it"
	rawData := aDictionary copy.
	rawData removeKey: 'secret' ifAbsent: [ ]
]

{ #category : 'accessing' }
GtBugbopWebhook >> secret [
	"Only present in the create response"
	^ secret
]

{ #category : 'accessing' }
GtBugbopWebhook >> secret: aString [
	secret := aString
]

{ #category : 'accessing' }
GtBugbopWebhook >> settingsUrl [
	^ settingsUrl
]

{ #category : 'accessing' }
GtBugbopWebhook >> settingsUrl: aString [
	settingsUrl := aString
]

{ #category : 'accessing' }
GtBugbopWebhook >> updatedAt [
	^ updatedAt
]

{ #category : 'accessing' }
GtBugbopWebhook >> updatedAt: aStringOrDateAndTime [
	updatedAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopWebhook >> url [
	"Answer the delivery URL"
	^ url
]

{ #category : 'accessing' }
GtBugbopWebhook >> url: aString [
	url := aString
]

{ #category : 'accessing' }
GtBugbopWebhook >> webUrl [
	^ settingsUrl
]
