"
I am one of your in-app Bugbop notifications.
"
Class {
	#name : 'GtBugbopNotification',
	#superclass : 'GtBugbopEntity',
	#instVars : [
		'id',
		'kind',
		'read',
		'data',
		'url',
		'program',
		'report',
		'createdAt'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopNotification class >> serializationProperties [
	^ {
		#id -> #id.
		#kind -> #kind.
		#read -> #read.
		#data -> #data.
		#program -> #program.
		#report -> #report.
		#created_at -> #createdAt.
		#url -> #url }
]

{ #category : 'accessing' }
GtBugbopNotification >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
GtBugbopNotification >> createdAt: aStringOrDateAndTime [
	createdAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopNotification >> data [
	^ data ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
GtBugbopNotification >> data: aDictionary [
	data := aDictionary
]

{ #category : 'api' }
GtBugbopNotification >> fullReport [
	"Answer the full report this notification is about, fetched from the API"
	^ report ifNotNil: [ :aReport | aReport refreshed ]
]

{ #category : 'accessing' }
GtBugbopNotification >> id [
	^ id
]

{ #category : 'accessing' }
GtBugbopNotification >> id: aString [
	id := aString
]

{ #category : 'testing' }
GtBugbopNotification >> isUnread [
	^ read ~= true
]

{ #category : 'accessing' }
GtBugbopNotification >> kind [
	"Answer e.g. report_created, comment_created, program_access_request_created"
	^ kind
]

{ #category : 'accessing' }
GtBugbopNotification >> kind: aString [
	kind := aString
]

{ #category : 'accessing' }
GtBugbopNotification >> kindLabel [
	"Answer kind as words: comment_created -> 'comment created'"
	^ (kind ifNil: [ '' ]) copyReplaceAll: '_' with: ' '
]

{ #category : 'accessing' }
GtBugbopNotification >> nestedEntities [
	^ { program. report } select: [ :each | each isKindOf: GtBugbopEntity ]
]

{ #category : 'printing' }
GtBugbopNotification >> printOn: aStream [
	aStream
		nextPutAll: self kindLabel;
		nextPutAll: ': ';
		nextPutAll: self subject
]

{ #category : 'accessing' }
GtBugbopNotification >> program [
	^ program
]

{ #category : 'accessing' }
GtBugbopNotification >> program: aDictionaryOrProgram [
	program := self deserialize: aDictionaryOrProgram as: GtBugbopProgram
]

{ #category : 'accessing' }
GtBugbopNotification >> read [
	^ read
]

{ #category : 'accessing' }
GtBugbopNotification >> read: aBoolean [
	read := aBoolean
]

{ #category : 'accessing' }
GtBugbopNotification >> report [
	"Answer a GtBugbopReport reference (id, title, apiUrl) or nil"
	^ report
]

{ #category : 'accessing' }
GtBugbopNotification >> report: aDictionaryOrReport [
	report := self deserialize: aDictionaryOrReport as: GtBugbopReport
]

{ #category : 'accessing' }
GtBugbopNotification >> subject [
	"Answer what the notification is about, for list views"
	report ifNotNil: [ :aReport | ^ aReport title ifNil: [ '' ] ].
	(self data at: 'title' ifAbsent: [ nil ]) ifNotNil: [ :aTitle | ^ aTitle asString ].
	^ program ifNil: [ '' ] ifNotNil: [ :aProgram | aProgram name ifNil: [ '' ] ]
]

{ #category : 'accessing' }
GtBugbopNotification >> url [
	^ url
]

{ #category : 'accessing' }
GtBugbopNotification >> url: aString [
	url := aString
]

{ #category : 'accessing' }
GtBugbopNotification >> webUrl [
	^ url
]
