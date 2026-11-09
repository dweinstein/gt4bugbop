"
I build GtBugbopStubZnClients so a GtBugbopClient can be exercised offline with canned responses.
"
Class {
	#name : 'GtBugbopClientStubBuilder',
	#superclass : 'GtBugbopClientZincBuilder',
	#instVars : [
		'responder'
	],
	#category : 'Gt4Bugbop-Client',
	#package : 'Gt4Bugbop',
	#tag : 'Client'
}

{ #category : 'building' }
GtBugbopClientStubBuilder >> newBasicClient [
	^ GtBugbopStubZnClient new responder: responder
]

{ #category : 'accessing' }
GtBugbopClientStubBuilder >> responder: aBlock [
	"aBlock receives a ZnRequest and answers a ZnResponse"
	responder := aBlock
]
