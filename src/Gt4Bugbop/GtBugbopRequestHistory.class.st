"
I am the list of GtBugbopRequestResponse exchanges performed by a GtBugbopClient.
"
Class {
	#name : 'GtBugbopRequestHistory',
	#superclass : 'Object',
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : 'Gt4Bugbop-Client',
	#package : 'Gt4Bugbop',
	#tag : 'Client'
}

{ #category : 'gt views' }
GtBugbopRequestHistory >> gtCallsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Calls';
		priority: 1;
		items: [ self items reversed ];
		column: 'Time' text: [ :each | each timestamp asTime print24 ] width: 80;
		column: 'Method' text: [ :each | each method ] width: 60;
		column: 'Path' text: [ :each | each url pathQueryFragmentPrintString ];
		column: 'Status' text: [ :each | self statusTextFor: each ] width: 60;
		actionUpdateButton
]

{ #category : 'gt actions' }
GtBugbopRequestHistory >> gtClearActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons remove;
		tooltip: 'Clear history';
		action: [ :aButton | 
			self removeAll.
			aButton phlow fireViewUpdateWish ]
]

{ #category : 'gt views' }
GtBugbopRequestHistory >> statusTextFor: aRequestResponse [
	^ aRequestResponse statusCode asString asRopedText
		foreground: (aRequestResponse isSuccess
				ifTrue: [ Color fromHexString: '2E7D32' ]
				ifFalse: [ Color red ])
]
