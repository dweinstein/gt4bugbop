"
I am a hunter's request to join a restricted Bugbop program.
"
Class {
	#name : 'GtBugbopAccessRequest',
	#superclass : 'GtBugbopEntity',
	#instVars : [
		'id',
		'program',
		'user',
		'status',
		'message',
		'rejectionReason',
		'acceptanceMessage',
		'url',
		'apiUrl',
		'createdAt',
		'updatedAt'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopAccessRequest class >> serializationProperties [
	^ {
		#id -> #id.
		#status -> #status.
		#program -> #program.
		#user -> #user.
		#message -> #message.
		#acceptance_message -> #acceptanceMessage.
		#rejection_reason -> #rejectionReason.
		#created_at -> #createdAt.
		#updated_at -> #updatedAt.
		#url -> #url.
		#api_url -> #apiUrl }
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> acceptanceMessage [
	^ acceptanceMessage
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> acceptanceMessage: aString [
	acceptanceMessage := aString
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> apiUrl [
	^ apiUrl
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> apiUrl: aString [
	apiUrl := aString
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> createdAt: aStringOrDateAndTime [
	createdAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> id [
	^ id
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> id: aString [
	id := aString
]

{ #category : 'testing' }
GtBugbopAccessRequest >> isPending [
	^ status = 'pending'
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> message [
	^ message
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> message: aString [
	message := aString
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> nestedEntities [
	^ { program. user } select: [ :each | each isKindOf: GtBugbopEntity ]
]

{ #category : 'printing' }
GtBugbopAccessRequest >> printOn: aStream [
	aStream
		nextPutAll: (user ifNil: [ '?' ] ifNotNil: [ :aUser | aUser username ]);
		nextPutAll: ' -> ';
		nextPutAll: (program ifNil: [ '?' ] ifNotNil: [ :aProgram | aProgram name ]);
		nextPutAll: ' (';
		nextPutAll: (status ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> program [
	^ program
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> program: aDictionaryOrProgram [
	program := self deserialize: aDictionaryOrProgram as: GtBugbopProgram
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> rejectionReason [
	^ rejectionReason
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> rejectionReason: aString [
	rejectionReason := aString
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> status [
	"Answer pending, approved or rejected"
	^ status
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> status: aString [
	status := aString
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> updatedAt [
	^ updatedAt
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> updatedAt: aStringOrDateAndTime [
	updatedAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> url [
	^ url
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> url: aString [
	url := aString
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> user [
	"Answer the requester, including strikesCount and bountiesPaidCount"
	^ user
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> user: aDictionaryOrUser [
	user := self deserialize: aDictionaryOrUser as: GtBugbopUser
]

{ #category : 'accessing' }
GtBugbopAccessRequest >> webUrl [
	^ url
]
