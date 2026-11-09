"
POST /reports/:report_id/comments. This notifies the hunter.
"
Class {
	#name : 'GtBugbopCreateCommentAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'report',
		'content'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopCreateCommentAPICommand >> content: aMarkdownString [
	content := aMarkdownString
]

{ #category : 'accessing' }
GtBugbopCreateCommentAPICommand >> report: aReportOrId [
	report := aReportOrId
]

{ #category : 'accessing' }
GtBugbopCreateCommentAPICommand >> request [
	content isEmptyOrNil ifTrue: [ self error: 'A comment needs content' ].
	^ self client
		post: 'reports/' , (self idFrom: report) , '/comments'
		withEntity: (Dictionary with: 'content' -> content)
]

{ #category : 'accessing' }
GtBugbopCreateCommentAPICommand >> serializationClass [
	^ GtBugbopComment
]
