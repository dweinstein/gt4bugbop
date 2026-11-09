"
GET /report_submissions/:id
"
Class {
	#name : 'GtBugbopGetReportSubmissionAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'submission'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopGetReportSubmissionAPICommand >> request [
	^ self client get: 'report_submissions/' , (self idFrom: submission)
]

{ #category : 'accessing' }
GtBugbopGetReportSubmissionAPICommand >> serializationClass [
	^ GtBugbopReportSubmission
]

{ #category : 'accessing' }
GtBugbopGetReportSubmissionAPICommand >> submission: aSubmissionOrId [
	submission := aSubmissionOrId
]
