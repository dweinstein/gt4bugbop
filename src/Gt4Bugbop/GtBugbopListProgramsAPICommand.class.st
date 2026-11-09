"
GET /programs
"
Class {
	#name : 'GtBugbopListProgramsAPICommand',
	#superclass : 'GtBugbopListAPICommand',
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopListProgramsAPICommand >> path [
	^ 'programs'
]

{ #category : 'accessing' }
GtBugbopListProgramsAPICommand >> serializationClass [
	^ GtBugbopProgramsGroup
]
