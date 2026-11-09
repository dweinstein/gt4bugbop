Class {
	#name : 'GtBugbopCommentsGroup',
	#superclass : 'GtBugbopGroup',
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopCommentsGroup class >> itemClass [
	^ GtBugbopComment
]

{ #category : 'gt - views' }
GtBugbopCommentsGroup >> gtBubblesFor: aView [
	<gtView>
	^ aView forward
		title: 'Conversation';
		priority: 0;
		object: [ (GtBugbopConversation forComments: self) fetched ];
		view: #gtBubblesFor:
]

{ #category : 'gt - views' }
GtBugbopCommentsGroup >> gtConversationFor: aView [
	<gtView>
	^ aView columnedList
		title: 'List';
		priority: 1;
		items: [ self items ];
		column: 'When' text: [ :each | each createdAt ifNil: [ '' ] ifNotNil: [ :aTime | aTime asLocal printString first: 16 ] ] width: 130;
		column: 'Author' text: [ :each | each authorName ] width: 120;
		column: 'Comment' text: [ :each | each summary ]
]

{ #category : 'gt views' }
GtBugbopCommentsGroup >> gtTranscriptFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Transcript';
		priority: 2;
		text: [ self transcriptText ]
]

{ #category : 'printing' }
GtBugbopCommentsGroup >> transcriptText [
	"The whole thread as one text, oldest first"
	| aText |
	aText := '' asRopedText.
	self do: [ :each | 
		aText append: ((each authorName , '  ' , (each createdAt ifNil: [ '' ] ifNotNil: [ :aTime | aTime asLocal printString first: 16 ])) asRopedText bold).
		aText append: (String cr , (each content ifNil: [ '' ]) , String cr , String cr) asRopedText ].
	^ aText
]
