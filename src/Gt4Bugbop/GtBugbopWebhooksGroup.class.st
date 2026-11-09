Class {
	#name : 'GtBugbopWebhooksGroup',
	#superclass : 'GtBugbopGroup',
	#category : 'Gt4Bugbop-Model',
	#package : 'Gt4Bugbop',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtBugbopWebhooksGroup class >> itemClass [
	^ GtBugbopWebhook
]

{ #category : 'gt views' }
GtBugbopWebhooksGroup >> gtWebhooksFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Webhooks';
		priority: 1;
		items: [ self items ];
		column: 'Description' text: [ :each | each description ifNil: [ '' ] ] width: 160;
		column: 'URL' text: [ :each | each url ifNil: [ '' ] ];
		column: 'Events' text: [ :each | each eventsString ]
]
