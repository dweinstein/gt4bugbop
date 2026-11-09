"
GET /programs/:id/hunters (program staff only)
"
Class {
	#name : 'GtBugbopListProgramHuntersAPICommand',
	#superclass : 'GtBugbopListAPICommand',
	#instVars : [
		'program'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopListProgramHuntersAPICommand >> path [
	^ 'programs/' , (self idFrom: program) , '/hunters'
]

{ #category : 'accessing' }
GtBugbopListProgramHuntersAPICommand >> program: aProgramOrId [
	program := aProgramOrId
]

{ #category : 'accessing' }
GtBugbopListProgramHuntersAPICommand >> serializationClass [
	^ GtBugbopUsersGroup
]
