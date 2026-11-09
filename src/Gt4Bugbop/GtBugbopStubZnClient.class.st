"
I am a ZnClient that never touches the network. My responder block receives the ZnRequest and answers a ZnResponse. Used by GtBugbopClientStubBuilder for offline examples.
"
Class {
	#name : 'GtBugbopStubZnClient',
	#superclass : 'ZnClient',
	#instVars : [
		'responder'
	],
	#category : 'Gt4Bugbop-Client',
	#package : 'Gt4Bugbop',
	#tag : 'Client'
}

{ #category : 'operations' }
GtBugbopStubZnClient >> close [
	"Nothing to close"
]

{ #category : 'operations' }
GtBugbopStubZnClient >> execute [
	"Answer a canned response instead of talking to the network"
	response := responder value: self request.
	^ response contents
]

{ #category : 'accessing' }
GtBugbopStubZnClient >> responder: aBlock [
	responder := aBlock
]
