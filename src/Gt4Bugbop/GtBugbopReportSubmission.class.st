"
I am a report waiting on Bugbop's AI scope check (only visible to the submitter). Once completed I embed the created report.
"
Class {
	#name : 'GtBugbopReportSubmission',
	#superclass : 'GtBugbopEntity',
	#instVars : [
		'id',
		'status',
		'programId',
		'title',
		'inScope',
		'inScopeExplanation',
		'error',
		'report',
		'apiUrl',
		'proceedAnywayUrl',
		'createdAt',
		'updatedAt'
	],
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopReportSubmission class >> serializationProperties [
	^ {
		#id -> #id.
		#status -> #status.
		#program_id -> #programId.
		#title -> #title.
		#in_scope -> #inScope.
		#in_scope_explanation -> #inScopeExplanation.
		#error -> #error.
		#report -> #report.
		#created_at -> #createdAt.
		#updated_at -> #updatedAt.
		#api_url -> #apiUrl.
		#proceed_anyway_url -> #proceedAnywayUrl }
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> apiUrl [
	^ apiUrl
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> apiUrl: aString [
	apiUrl := aString
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> createdAt: aStringOrDateAndTime [
	createdAt := self deserializeTime: aStringOrDateAndTime
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> error [
	^ error
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> error: aStringOrNil [
	error := aStringOrNil
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> id [
	^ id
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> id: aString [
	id := aString
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> inScope [
	^ inScope
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> inScope: aBooleanOrNil [
	inScope := aBooleanOrNil
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> inScopeExplanation [
	^ inScopeExplanation
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> inScopeExplanation: aString [
	inScopeExplanation := aString
]

{ #category : 'testing' }
GtBugbopReportSubmission >> isCompleted [
	^ status = 'completed'
]

{ #category : 'testing' }
GtBugbopReportSubmission >> isPending [
	^ status = 'pending'
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> nestedEntities [
	^ { report } select: [ :each | each isKindOf: GtBugbopEntity ]
]

{ #category : 'printing' }
GtBugbopReportSubmission >> printOn: aStream [
	aStream
		nextPutAll: (title ifNil: [ 'a report submission' ]);
		nextPutAll: ' (';
		nextPutAll: (status ifNil: [ '?' ]);
		nextPut: $)
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> proceedAnywayUrl [
	^ proceedAnywayUrl
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> proceedAnywayUrl: aString [
	proceedAnywayUrl := aString
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> programId [
	^ programId
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> programId: aString [
	programId := aString
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> report [
	"Answer the created GtBugbopReport once completed"
	^ report
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> report: aDictionaryOrReport [
	report := self deserialize: aDictionaryOrReport as: GtBugbopReport
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> status [
	"Answer pending, scope_failed, completed or failed"
	^ status
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> status: aString [
	status := aString
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> title [
	^ title
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> title: aString [
	title := aString
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> updatedAt [
	^ updatedAt
]

{ #category : 'accessing' }
GtBugbopReportSubmission >> updatedAt: aStringOrDateAndTime [
	updatedAt := self deserializeTime: aStringOrDateAndTime
]
