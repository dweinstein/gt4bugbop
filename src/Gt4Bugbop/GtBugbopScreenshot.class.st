"
I am one README screenshot: the view viewSelector of the object returned by an offline <gtExample> (exampleMethod), laid out at extent and exported as a PNG named fileName.

Screenshots only ever use offline fixtures, so no real report, hunter or program data ends up in the repository.

	GtBugbopScreenshots default first asForm
"
Class {
	#name : 'GtBugbopScreenshot',
	#superclass : 'Object',
	#instVars : [
		'fileName',
		'caption',
		'exampleMethod',
		'viewSelector',
		'extent'
	],
	#category : 'Gt4Bugbop-Docs',
	#package : 'Gt4Bugbop',
	#tag : 'Docs'
}

{ #category : 'instance creation' }
GtBugbopScreenshot class >> fileName: aFileName example: aCompiledMethod view: aSelector extent: aPoint caption: aString [
	^ self new
		setFileName: aFileName
		example: aCompiledMethod
		view: aSelector
		extent: aPoint
		caption: aString
]

{ #category : 'rendering' }
GtBugbopScreenshot >> asForm [
	"Lay the view out at my extent on a white frame and export it, as the GT MCP view renderer does"
	| form |
	self phlowView asElementDo: [ :anElement |
		form := BlExporter png
			element: (self scriptedRootFor: anElement);
			doExport: [ :aCanvas | aCanvas asForm ] ].
	^ form
]

{ #category : 'accessing' }
GtBugbopScreenshot >> caption [
	^ caption
]

{ #category : 'accessing' }
GtBugbopScreenshot >> exampleMethod [
	^ exampleMethod
]

{ #category : 'rendering' }
GtBugbopScreenshot >> exportTo: aDirectory [
	"Write me as a PNG into aDirectory and answer the file"
	| aFile form |
	form := self asForm.
	aDirectory ensureCreateDirectory.
	aFile := aDirectory / fileName.
	aFile ensureDelete.
	aFile binaryWriteStreamDo: [ :aStream | PNGReadWriter putForm: form onStream: aStream ].
	^ aFile
]

{ #category : 'accessing' }
GtBugbopScreenshot >> extent [
	^ extent
]

{ #category : 'accessing' }
GtBugbopScreenshot >> fileName [
	^ fileName
]

{ #category : 'views' }
GtBugbopScreenshot >> gtImageFor: aView [
	<gtView>
	^ aView explicit
		title: 'PNG';
		priority: 2;
		stencil: [ self asForm asElement asPannableElement ]
]

{ #category : 'views' }
GtBugbopScreenshot >> gtPreviewFor: aView [
	<gtView>
	^ aView forward
		title: 'Preview';
		priority: 1;
		object: [ self object ];
		view: viewSelector
]

{ #category : 'accessing' }
GtBugbopScreenshot >> object [
	"Answer the object produced by my offline example"
	^ exampleMethod methodClass new perform: exampleMethod selector
]

{ #category : 'accessing' }
GtBugbopScreenshot >> phlowView [
	^ (self object gtViewsInContext: GtPhlowContext new)
		detect: [ :each | each definingSelector = viewSelector ]
		ifNone: [ self error: 'No view ' , viewSelector printString , ' on ' , exampleMethod printString ]
]

{ #category : 'printing' }
GtBugbopScreenshot >> printOn: aStream [
	aStream nextPutAll: fileName; nextPutAll: ' ('; print: viewSelector; nextPutAll: ')'
]

{ #category : 'rendering' }
GtBugbopScreenshot >> scriptedRootFor: anElement [
	^ BlScripter new
		element: (BrFrame new
				background: Color white;
				size: extent;
				addChild: anElement);
		extent: extent;
		elementWithoutParent
]

{ #category : 'initialization' }
GtBugbopScreenshot >> setFileName: aFileName example: aCompiledMethod view: aSelector extent: aPoint caption: aString [
	fileName := aFileName.
	exampleMethod := aCompiledMethod.
	viewSelector := aSelector.
	extent := aPoint.
	caption := aString
]

{ #category : 'accessing' }
GtBugbopScreenshot >> viewSelector [
	^ viewSelector
]
