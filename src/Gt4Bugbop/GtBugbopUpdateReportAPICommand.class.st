"
PATCH /reports/:id with only the changing fields. Reporters may change title and description; triagers and above status, severity, duplicate_of_id and internal_notes.
"
Class {
	#name : 'GtBugbopUpdateReportAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'report',
		'fields'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopUpdateReportAPICommand >> fields: aDictionary [
	"JSON field names -> new values, e.g. status, severity, internal_notes"
	fields := aDictionary
]

{ #category : 'accessing' }
GtBugbopUpdateReportAPICommand >> report: aReportOrId [
	report := aReportOrId
]

{ #category : 'accessing' }
GtBugbopUpdateReportAPICommand >> request [
	fields isEmptyOrNil ifTrue: [ self error: 'Nothing to update' ].
	^ self client patch: 'reports/' , (self idFrom: report) withEntity: fields
]

{ #category : 'accessing' }
GtBugbopUpdateReportAPICommand >> serializationClass [
	^ GtBugbopReport
]
