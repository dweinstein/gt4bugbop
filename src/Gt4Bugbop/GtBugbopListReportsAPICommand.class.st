"
GET /reports or GET /programs/:program_id/reports, with optional status, severity and since filters. Newest first.
"
Class {
	#name : 'GtBugbopListReportsAPICommand',
	#superclass : 'GtBugbopListAPICommand',
	#instVars : [
		'program',
		'statuses',
		'severities',
		'since'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopListReportsAPICommand >> path [
	program ifNil: [ ^ 'reports' ].
	^ 'programs/' , (self idFrom: program) , '/reports'
]

{ #category : 'accessing' }
GtBugbopListReportsAPICommand >> program: aProgramOrIdOrNil [
	"nil lists reports across all my programs"
	program := aProgramOrIdOrNil
]

{ #category : 'accessing' }
GtBugbopListReportsAPICommand >> queryParameters [
	| params |
	params := OrderedCollection new.
	statuses isEmptyOrNil ifFalse: [ params add: 'status' -> (self commaList: statuses) ].
	severities isEmptyOrNil ifFalse: [ params add: 'severity' -> (self commaList: severities) ].
	since ifNotNil: [ params add: 'since' -> since asDateAndTime asUTC printString ].
	^ params
]

{ #category : 'accessing' }
GtBugbopListReportsAPICommand >> serializationClass [
	^ GtBugbopReportsGroup
]

{ #category : 'accessing' }
GtBugbopListReportsAPICommand >> severities: aCollectionOrNil [
	"Any of GtBugbopReport class>>#severities"
	severities := aCollectionOrNil
]

{ #category : 'accessing' }
GtBugbopListReportsAPICommand >> since: aDateAndTimeOrNil [
	"Only reports updated at or after this time, for incremental syncs"
	since := aDateAndTimeOrNil
]

{ #category : 'accessing' }
GtBugbopListReportsAPICommand >> statuses: aCollectionOrNil [
	"Any of GtBugbopReport class>>#statuses"
	statuses := aCollectionOrNil
]
