"
GET /user
"
Class {
	#name : 'GtBugbopGetUserAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopGetUserAPICommand >> request [
	^ self client get: 'user'
]

{ #category : 'accessing' }
GtBugbopGetUserAPICommand >> serializationClass [
	^ GtBugbopUser
]
