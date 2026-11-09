"
GET /reports/:report_id/comments (oldest first)
"
Class {
	#name : 'GtBugbopListCommentsAPICommand',
	#superclass : 'GtBugbopListAPICommand',
	#instVars : [
		'report'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopListCommentsAPICommand >> path [
	^ 'reports/' , (self idFrom: report) , '/comments'
]

{ #category : 'accessing' }
GtBugbopListCommentsAPICommand >> report: aReportOrId [
	report := aReportOrId
]

{ #category : 'accessing' }
GtBugbopListCommentsAPICommand >> serializationClass [
	^ GtBugbopCommentsGroup
]
