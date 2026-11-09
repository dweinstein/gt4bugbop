"
POST /programs/:program_id/blocked_reporters with either a username or a report (whose reporter gets blocked), not both.
"
Class {
	#name : 'GtBugbopBlockReporterAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'program',
		'username',
		'report'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'private' }
GtBugbopBlockReporterAPICommand >> entity [
	(username isNil = report isNil)
		ifTrue: [ self error: 'Block by either a username or a report, not both' ].
	username ifNotNil: [ ^ Dictionary with: 'username' -> username ].
	^ Dictionary with: 'report_id' -> (self idFrom: report)
]

{ #category : 'accessing' }
GtBugbopBlockReporterAPICommand >> program: aProgramOrId [
	program := aProgramOrId
]

{ #category : 'accessing' }
GtBugbopBlockReporterAPICommand >> report: aReportOrId [
	report := aReportOrId
]

{ #category : 'accessing' }
GtBugbopBlockReporterAPICommand >> request [
	^ self client
		post: 'programs/' , (self idFrom: program) , '/blocked_reporters'
		withEntity: self entity
]

{ #category : 'accessing' }
GtBugbopBlockReporterAPICommand >> serializationClass [
	^ GtBugbopBlockedReporter
]

{ #category : 'accessing' }
GtBugbopBlockReporterAPICommand >> username: aString [
	username := aString
]
