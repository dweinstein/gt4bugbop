"
GET /programs/:program_id/blocked_reporters
"
Class {
	#name : 'GtBugbopListBlockedReportersAPICommand',
	#superclass : 'GtBugbopListAPICommand',
	#instVars : [
		'program'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopListBlockedReportersAPICommand >> path [
	^ 'programs/' , (self idFrom: program) , '/blocked_reporters'
]

{ #category : 'accessing' }
GtBugbopListBlockedReportersAPICommand >> program: aProgramOrId [
	program := aProgramOrId
]

{ #category : 'accessing' }
GtBugbopListBlockedReportersAPICommand >> serializationClass [
	^ GtBugbopBlockedReportersGroup
]
