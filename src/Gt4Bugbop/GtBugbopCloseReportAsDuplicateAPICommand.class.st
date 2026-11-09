"
POST /reports/:id/close_as_duplicate. Without an original, Bugbop uses the AI's suspected duplicate.
"
Class {
	#name : 'GtBugbopCloseReportAsDuplicateAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'report',
		'original'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopCloseReportAsDuplicateAPICommand >> original: aReportOrIdOrNil [
	"nil uses the report the AI suspected"
	original := aReportOrIdOrNil
]

{ #category : 'accessing' }
GtBugbopCloseReportAsDuplicateAPICommand >> report: aReportOrId [
	report := aReportOrId
]

{ #category : 'accessing' }
GtBugbopCloseReportAsDuplicateAPICommand >> request [
	| entity |
	entity := Dictionary new.
	original ifNotNil: [ entity at: 'duplicate_of_id' put: (self idFrom: original) ].
	^ self client
		post: 'reports/' , (self idFrom: report) , '/close_as_duplicate'
		withEntity: entity
]

{ #category : 'accessing' }
GtBugbopCloseReportAsDuplicateAPICommand >> serializationClass [
	^ GtBugbopReport
]
