"
GET /comments/:id
"
Class {
	#name : 'GtBugbopGetCommentAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'comment'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopGetCommentAPICommand >> comment: aCommentOrId [
	comment := aCommentOrId
]

{ #category : 'accessing' }
GtBugbopGetCommentAPICommand >> request [
	^ self client get: 'comments/' , (self idFrom: comment)
]

{ #category : 'accessing' }
GtBugbopGetCommentAPICommand >> serializationClass [
	^ GtBugbopComment
]
