"
I am a Bugbop user (hunter, triager, program staff). Some fields (email, identityVerified) are only present on GET /user; strikesCount and bountiesPaidCount only on access request requesters.
"
Class {
	#name : 'GtBugbopUser',
	#superclass : 'GtBugbopEntity',
	#instVars : [
		'id',
		'username',
		'url',
		'apiUrl',
		'email',
		'identityVerified',
		'strikesCount',
		'bountiesPaidCount',
		'createdAt'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopUser class >> serializationProperties [
	^ {
		#id -> #id.
		#username -> #username.
		#email -> #email.
		#identity_verified -> #identityVerified.
		#strikes_count -> #strikesCount.
		#bounties_paid_count -> #bountiesPaidCount.
		#created_at -> #createdAt.
		#url -> #url.
		#api_url -> #apiUrl }
]

{ #category : 'comparing' }
GtBugbopUser >> = anObject [
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ id = anObject id
]

{ #category : 'accessing' }
GtBugbopUser >> apiUrl [
	^ apiUrl
]

{ #category : 'accessing' }
GtBugbopUser >> apiUrl: aString [
	apiUrl := aString
]

{ #category : 'accessing' }
GtBugbopUser >> bountiesPaidCount [
	^ bountiesPaidCount
]

{ #category : 'accessing' }
GtBugbopUser >> bountiesPaidCount: anInteger [
	bountiesPaidCount := anInteger
]

{ #category : 'accessing' }
GtBugbopUser >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
GtBugbopUser >> createdAt: aStringOrDateAndTime [
	createdAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopUser >> email [
	^ email
]

{ #category : 'accessing' }
GtBugbopUser >> email: aString [
	email := aString
]

{ #category : 'comparing' }
GtBugbopUser >> hash [
	^ id hash
]

{ #category : 'accessing' }
GtBugbopUser >> id [
	^ id
]

{ #category : 'accessing' }
GtBugbopUser >> id: aString [
	id := aString
]

{ #category : 'accessing' }
GtBugbopUser >> identityVerified [
	^ identityVerified
]

{ #category : 'accessing' }
GtBugbopUser >> identityVerified: aBoolean [
	identityVerified := aBoolean
]

{ #category : 'printing' }
GtBugbopUser >> printOn: aStream [
	aStream nextPutAll: (username ifNil: [ 'a Bugbop user' ])
]

{ #category : 'accessing' }
GtBugbopUser >> strikesCount [
	^ strikesCount
]

{ #category : 'accessing' }
GtBugbopUser >> strikesCount: anInteger [
	strikesCount := anInteger
]

{ #category : 'accessing' }
GtBugbopUser >> url [
	^ url
]

{ #category : 'accessing' }
GtBugbopUser >> url: aString [
	url := aString
]

{ #category : 'accessing' }
GtBugbopUser >> username [
	^ username
]

{ #category : 'accessing' }
GtBugbopUser >> username: aString [
	username := aString
]

{ #category : 'accessing' }
GtBugbopUser >> webUrl [
	^ url
]
