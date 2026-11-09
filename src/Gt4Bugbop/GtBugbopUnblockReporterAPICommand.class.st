"
DELETE /blocked_reporters/:id
"
Class {
	#name : 'GtBugbopUnblockReporterAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'blockedReporter'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopUnblockReporterAPICommand >> blockedReporter: aBlockedReporterOrId [
	blockedReporter := aBlockedReporterOrId
]

{ #category : 'accessing' }
GtBugbopUnblockReporterAPICommand >> perform [
	"DELETE answers 204 No Content"
	^ self request isSuccess
]

{ #category : 'accessing' }
GtBugbopUnblockReporterAPICommand >> request [
	^ self client delete: 'blocked_reporters/' , (self idFrom: blockedReporter)
]
