"
I am the set of README screenshots for Gt4Bugbop. Each is rendered from an offline example.

Regenerate the images from the repository root with:

	GtBugbopScreenshots default exportTo: '/path/to/gt4bugbop/docs/screenshots' asFileReference
"
Class {
	#name : 'GtBugbopScreenshots',
	#superclass : 'Object',
	#instVars : [
		'shots'
	],
	#category : 'Gt4Bugbop-Docs',
	#package : 'Gt4Bugbop',
	#tag : 'Docs'
}

{ #category : 'instance creation' }
GtBugbopScreenshots class >> default [
	"The README screenshots, in the order the README shows them. All come from GtBugbopShowcaseExamples or other offline examples"
	| showcase visuals |
	showcase := GtBugbopShowcaseExamples.
	visuals := GtBugbopReportVisualsExamples.
	^ self new setShots: {
		GtBugbopScreenshot fileName: 'dashboard.png' example: showcase >> #dashboard view: #gtDashboardFor: extent: 1600 @ 540 caption: 'Dashboard: metric tiles and severity / status mix'.
		GtBugbopScreenshot fileName: 'insights.png' example: showcase >> #explorer view: #gtInsightsFor: extent: 900 @ 200 caption: 'Explorer: entry points to each insight'.
		GtBugbopScreenshot fileName: 'triage-board.png' example: showcase >> #triageBoard view: #gtBoardFor: extent: 1720 @ 560 caption: 'Triage board: kanban by status'.
		GtBugbopScreenshot fileName: 'aging.png' example: showcase >> #triageBoard view: #gtAgingFor: extent: 900 @ 330 caption: 'Aging of active reports against SLA bands'.
		GtBugbopScreenshot fileName: 'timeline.png' example: showcase >> #timeline view: #gtTimelineFor: extent: 1400 @ 390 caption: 'Timeline: severity lanes colored by status'.
		GtBugbopScreenshot fileName: 'calendar.png' example: showcase >> #timeline view: #gtCalendarFor: extent: 900 @ 385 caption: 'Calendar heatmap of submissions'.
		GtBugbopScreenshot fileName: 'duplicate-map.png' example: showcase >> #duplicateMap view: #gtDuplicateGraphFor: extent: 1400 @ 560 caption: 'Duplicate map: confirmed and suspected clusters'.
		GtBugbopScreenshot fileName: 'ai-agreement.png' example: showcase >> #aiTriageReview view: #gtAgreementMatrixFor: extent: 940 @ 520 caption: 'AI triage review: assigned vs AI-suggested severity'.
		GtBugbopScreenshot fileName: 'hunter-treemap.png' example: showcase >> #hunterLandscape view: #gtTreemapFor: extent: 1200 @ 460 caption: 'Hunter landscape: treemap by volume and signal'.
		GtBugbopScreenshot fileName: 'hunter-quadrant.png' example: showcase >> #hunterLandscape view: #gtQuadrantFor: extent: 860 @ 640 caption: 'Hunter landscape: volume vs signal'.
		GtBugbopScreenshot fileName: 'report-card.png' example: showcase >> #reportCard view: #gtCardFor: extent: 1100 @ 340 caption: 'Report card'.
		GtBugbopScreenshot fileName: 'conversation.png' example: visuals >> #conversation view: #gtBubblesFor: extent: 1000 @ 590 caption: 'Report conversation' }
]

{ #category : 'private' }
GtBugbopScreenshots >> directoryOf: aFileReference [
	aFileReference isDirectory ifTrue: [ ^ aFileReference ].
	^ aFileReference parent
]

{ #category : 'exporting' }
GtBugbopScreenshots >> exportTo: aDirectory [
	"Write every screenshot as a PNG into aDirectory; answer the files"
	^ shots collect: [ :each | each exportTo: aDirectory ]
]

{ #category : 'accessing' }
GtBugbopScreenshots >> first [
	^ shots first
]

{ #category : 'actions' }
GtBugbopScreenshots >> gtExportActionFor: anAction [
	<gtAction>
	^ anAction dropdown
		icon: BrGlamorousVectorIcons down;
		tooltip: 'Export PNGs to a directory';
		content: [ :aButton | 
			BrFileSelector new
				size: 500 @ 400;
				folder: FileLocator imageDirectory asFileReference;
				fileFilterBlock: [ :each | each isDirectory ];
				buttonLabel: 'Export here';
				okAction: [ :aFileOrDirectory | 
					aButton fireEvent: BrDropdownHideWish new.
					aButton phlow spawnObject: (self exportTo: (self directoryOf: aFileOrDirectory)) ] ]
]

{ #category : 'views' }
GtBugbopScreenshots >> gtShotsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Screenshots';
		priority: 1;
		items: [ shots ];
		column: 'File' text: [ :each | each fileName ] width: 160;
		column: 'Example' text: [ :each | each exampleMethod printString ] width: 330;
		column: 'View' text: [ :each | each viewSelector ] width: 170;
		column: 'Size' text: [ :each | each extent printString ] width: 90;
		column: 'Caption' text: [ :each | each caption ]
]

{ #category : 'accessing' }
GtBugbopScreenshots >> named: aFileName [
	^ shots detect: [ :each | each fileName = aFileName ]
]

{ #category : 'initialization' }
GtBugbopScreenshots >> setShots: aCollection [
	shots := aCollection
]

{ #category : 'accessing' }
GtBugbopScreenshots >> shots [
	^ shots
]
