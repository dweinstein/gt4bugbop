"
Loads gt4bugbop, a Glamorous Toolkit client and explorer for the Bugbop bug bounty platform API.

	Metacello new
		repository: 'gitlocal:///Users/user/work/gtoolkit/gt4bugbop/src';
		baseline: 'Gt4Bugbop';
		load
"
Class {
	#name : 'BaselineOfGt4Bugbop',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGt4Bugbop',
	#package : 'BaselineOfGt4Bugbop'
}

{ #category : 'baselines' }
BaselineOfGt4Bugbop >> baseline: spec [
	<baseline>
	spec for: #common do: [ spec package: 'Gt4Bugbop' ]
]
