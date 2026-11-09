"
I am a comment on a Bugbop report.
"
Class {
	#name : 'GtBugbopComment',
	#superclass : 'GtBugbopEntity',
	#instVars : [
		'id',
		'reportId',
		'user',
		'content',
		'metadata',
		'program',
		'url',
		'apiUrl',
		'reportUrl',
		'createdAt',
		'updatedAt'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopComment class >> serializationProperties [
	^ {
		#id -> #id.
		#report_id -> #reportId.
		#user -> #user.
		#content -> #content.
		#metadata -> #metadata.
		#program -> #program.
		#created_at -> #createdAt.
		#updated_at -> #updatedAt.
		#url -> #url.
		#api_url -> #apiUrl.
		#report_url -> #reportUrl }
]

{ #category : 'accessing' }
GtBugbopComment >> apiUrl [
	^ apiUrl
]

{ #category : 'accessing' }
GtBugbopComment >> apiUrl: aString [
	apiUrl := aString
]

{ #category : 'accessing' }
GtBugbopComment >> authorName [
	^ user ifNil: [ '' ] ifNotNil: [ :aUser | aUser username ]
]

{ #category : 'accessing' }
GtBugbopComment >> content [
	"Answer the comment body (Markdown)"
	^ content
]

{ #category : 'accessing' }
GtBugbopComment >> content: aString [
	content := aString
]

{ #category : 'accessing' }
GtBugbopComment >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
GtBugbopComment >> createdAt: aStringOrDateAndTime [
	createdAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'gt views' }
GtBugbopComment >> gtContentFor: aView [
	<gtView>
	content ifNil: [ ^ aView empty ].
	^ aView textEditor
		title: 'Content';
		priority: 1;
		text: [ content asRopedText ]
]

{ #category : 'accessing' }
GtBugbopComment >> id [
	^ id
]

{ #category : 'accessing' }
GtBugbopComment >> id: aString [
	id := aString
]

{ #category : 'accessing' }
GtBugbopComment >> metadata [
	^ metadata
]

{ #category : 'accessing' }
GtBugbopComment >> metadata: aDictionary [
	metadata := aDictionary
]

{ #category : 'accessing' }
GtBugbopComment >> nestedEntities [
	^ { program. user } select: [ :each | each isKindOf: GtBugbopEntity ]
]

{ #category : 'printing' }
GtBugbopComment >> printOn: aStream [
	aStream
		nextPutAll: self authorName;
		nextPutAll: ': ';
		nextPutAll: (self summary truncateWithElipsisTo: 60)
]

{ #category : 'accessing' }
GtBugbopComment >> program [
	^ program
]

{ #category : 'accessing' }
GtBugbopComment >> program: aDictionaryOrProgram [
	program := self deserialize: aDictionaryOrProgram as: GtBugbopProgram
]

{ #category : 'api' }
GtBugbopComment >> report [
	^ self client reportAt: reportId
]

{ #category : 'accessing' }
GtBugbopComment >> reportId [
	^ reportId
]

{ #category : 'accessing' }
GtBugbopComment >> reportId: aString [
	reportId := aString
]

{ #category : 'accessing' }
GtBugbopComment >> reportUrl [
	^ reportUrl
]

{ #category : 'accessing' }
GtBugbopComment >> reportUrl: aString [
	reportUrl := aString
]

{ #category : 'accessing' }
GtBugbopComment >> summary [
	"Answer the first line of the content, for list views"
	content isEmptyOrNil ifTrue: [ ^ '' ].
	^ (content lines detect: [ :each | each trimBoth notEmpty ] ifNone: [ '' ]) trimBoth
]

{ #category : 'accessing' }
GtBugbopComment >> updatedAt [
	^ updatedAt
]

{ #category : 'accessing' }
GtBugbopComment >> updatedAt: aStringOrDateAndTime [
	updatedAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopComment >> url [
	^ url
]

{ #category : 'accessing' }
GtBugbopComment >> url: aString [
	url := aString
]

{ #category : 'accessing' }
GtBugbopComment >> user [
	^ user
]

{ #category : 'accessing' }
GtBugbopComment >> user: aDictionaryOrUser [
	user := self deserialize: aDictionaryOrUser as: GtBugbopUser
]

{ #category : 'accessing' }
GtBugbopComment >> webUrl [
	^ url
]
