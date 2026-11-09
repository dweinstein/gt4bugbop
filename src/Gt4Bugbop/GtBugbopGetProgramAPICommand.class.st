"
GET /programs/:id
"
Class {
	#name : 'GtBugbopGetProgramAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'program'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopGetProgramAPICommand >> program: aProgramOrId [
	program := aProgramOrId
]

{ #category : 'accessing' }
GtBugbopGetProgramAPICommand >> request [
	^ self client get: 'programs/' , (self idFrom: program)
]

{ #category : 'accessing' }
GtBugbopGetProgramAPICommand >> serializationClass [
	^ GtBugbopProgram
]
