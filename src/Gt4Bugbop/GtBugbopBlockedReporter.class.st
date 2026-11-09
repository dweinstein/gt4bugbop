"
I am a user blocked from submitting reports to one Bugbop program.
"
Class {
	#name : 'GtBugbopBlockedReporter',
	#superclass : 'GtBugbopEntity',
	#instVars : [
		'id',
		'programId',
		'user',
		'blockedBy',
		'reportId',
		'apiUrl',
		'createdAt'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopBlockedReporter class >> serializationProperties [
	^ {
		#id -> #id.
		#program_id -> #programId.
		#user -> #user.
		#blocked_by -> #blockedBy.
		#report_id -> #reportId.
		#created_at -> #createdAt.
		#api_url -> #apiUrl }
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> apiUrl [
	^ apiUrl
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> apiUrl: aString [
	apiUrl := aString
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> blockedBy [
	^ blockedBy
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> blockedBy: aDictionaryOrUser [
	blockedBy := self deserialize: aDictionaryOrUser as: GtBugbopUser
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> createdAt: aStringOrDateAndTime [
	createdAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> id [
	^ id
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> id: aString [
	id := aString
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> nestedEntities [
	^ { user. blockedBy } select: [ :each | each isKindOf: GtBugbopEntity ]
]

{ #category : 'printing' }
GtBugbopBlockedReporter >> printOn: aStream [
	aStream
		nextPutAll: 'blocked ';
		nextPutAll: (user ifNil: [ '?' ] ifNotNil: [ :aUser | aUser username ])
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> programId [
	^ programId
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> programId: aString [
	programId := aString
]

{ #category : 'api' }
GtBugbopBlockedReporter >> report [
	^ reportId ifNotNil: [ :anId | self client reportAt: anId ]
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> reportId [
	^ reportId
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> reportId: aStringOrNil [
	reportId := aStringOrNil
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> user [
	^ user
]

{ #category : 'accessing' }
GtBugbopBlockedReporter >> user: aDictionaryOrUser [
	user := self deserialize: aDictionaryOrUser as: GtBugbopUser
]
