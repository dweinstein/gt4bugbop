"
GET /reports/:id
"
Class {
	#name : 'GtBugbopGetReportAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'report'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopGetReportAPICommand >> report: aReportOrId [
	report := aReportOrId
]

{ #category : 'accessing' }
GtBugbopGetReportAPICommand >> request [
	^ self client get: 'reports/' , (self idFrom: report)
]

{ #category : 'accessing' }
GtBugbopGetReportAPICommand >> serializationClass [
	^ GtBugbopReport
]
