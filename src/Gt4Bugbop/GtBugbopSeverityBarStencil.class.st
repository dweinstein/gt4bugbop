"
I build a horizontal stacked bar of reports by severity (critical, high, medium, low), using the domain severity colors.

The bar length is proportional to reports size / maxCount * maxWidth, so several bars share one scale. Each segment shows its count when it is wide enough, has a tooltip, and spawns the reports of that severity when clicked.

Example: (GtBugbopSeverityBarStencil new reports: aReportsGroup; maxCount: 10; maxWidth: 300) asElement
"
Class {
	#name : 'GtBugbopSeverityBarStencil',
	#superclass : 'BrStencil',
	#instVars : [
		'reports',
		'maxCount',
		'maxWidth',
		'barHeight'
	],
	#category : 'Gt4Bugbop-Insights',
	#package : 'Gt4Bugbop',
	#tag : 'Insights'
}

{ #category : 'accessing' }
GtBugbopSeverityBarStencil >> barHeight: aNumber [
	barHeight := aNumber
]

{ #category : 'api - instantiation' }
GtBugbopSeverityBarStencil >> create [
	| bar |
	bar := BrHorizontalPane new
			fitContent;
			clipChildren: true;
			geometry: (BlRoundedRectangleGeometry cornerRadius: 4).
	self severityGroups do: [ :each | bar addChild: (self newSegmentFor: each) ].
	bar hasChildren ifFalse: [ bar addChild: self newEmptySegment ].
	^ bar
]

{ #category : 'initialization' }
GtBugbopSeverityBarStencil >> initialize [
	super initialize.
	maxWidth := 240.
	barHeight := 18.
	maxCount := 0
]

{ #category : 'accessing' }
GtBugbopSeverityBarStencil >> maxCount [
	"Default to the reports size, so a lone bar fills maxWidth"
	^ maxCount max: reports size
]

{ #category : 'accessing' }
GtBugbopSeverityBarStencil >> maxCount: aNumber [
	maxCount := aNumber
]

{ #category : 'accessing' }
GtBugbopSeverityBarStencil >> maxWidth: aNumber [
	maxWidth := aNumber
]

{ #category : 'private - instance creation' }
GtBugbopSeverityBarStencil >> newCountLabelFor: anAssociation [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
				fontSize: (barHeight >= 22 ifTrue: [ 12 ] ifFalse: [ 10 ]);
				bold;
				foreground: (GtBugbopHunterLandscape
						textColorOn: (GtBugbopReport severityColorFor: anAssociation key)));
		text: anAssociation value size printString;
		constraintsDo: [ :c | 
			c frame horizontal alignCenter.
			c frame vertical alignCenter ]
]

{ #category : 'private - instance creation' }
GtBugbopSeverityBarStencil >> newEmptySegment [
	^ BlElement new
		size: (maxWidth min: 40) @ barHeight;
		background: (Color gray alpha: 0.15)
]

{ #category : 'private - instance creation' }
GtBugbopSeverityBarStencil >> newSegmentFor: anAssociation [
	| segment width |
	width := self widthFor: anAssociation value size.
	segment := BrFrame new
			size: width @ barHeight;
			background: (GtBugbopReport severityColorFor: anAssociation key);
			aptitude: (BrGlamorousWithLabelTooltipAptitude new
					text: (self tooltipFor: anAssociation)).
	width >= 16 ifTrue: [ segment addChild: (self newCountLabelFor: anAssociation) ].
	segment
		when: BlClickEvent
		do: [ :anEvent | 
			anEvent consumed: true.
			segment phlow spawnObject: anAssociation value ].
	^ segment
]

{ #category : 'accessing' }
GtBugbopSeverityBarStencil >> reports [
	^ reports
]

{ #category : 'accessing' }
GtBugbopSeverityBarStencil >> reports: aReportsGroup [
	reports := aReportsGroup
]

{ #category : 'accessing' }
GtBugbopSeverityBarStencil >> severityGroups [
	"Answer severity -> reports associations, most severe first, empty ones skipped"
	^ (GtBugbopReport severities
		collect: [ :each | each -> (reports withSeverity: each) ])
		reject: [ :each | each value isEmpty ]
]

{ #category : 'private - instance creation' }
GtBugbopSeverityBarStencil >> tooltipFor: anAssociation [
	^ anAssociation value size printString , ' ' , anAssociation key , ' severity report'
		, (anAssociation value size = 1 ifTrue: [ '' ] ifFalse: [ 's' ]) , ' - click to open'
]

{ #category : 'accessing' }
GtBugbopSeverityBarStencil >> widthFor: aCount [
	self maxCount isZero ifTrue: [ ^ 0 ].
	^ (aCount / self maxCount * maxWidth) asFloat max: 3
]
