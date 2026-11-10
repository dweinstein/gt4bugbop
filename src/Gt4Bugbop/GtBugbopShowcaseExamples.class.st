"
I build a made-up but realistic 33-report program used for the README screenshots (see GtBugbopScreenshots).

Dates are relative to now, so ages, SLA bands and 'submitted 3d ago' read naturally whenever the screenshots are regenerated. Hunters have enough resolved reports to show their signal colors. No real Bugbop data is used.
"
Class {
	#name : 'GtBugbopShowcaseExamples',
	#superclass : 'Object',
	#category : 'Gt4Bugbop-Examples',
	#package : 'Gt4Bugbop',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtBugbopShowcaseExamples >> aiTriageReview [
	<gtExample>
	<return: #GtBugbopAiTriageReview>
	^ GtBugbopAiTriageReview forReports: self reports
]

{ #category : 'examples' }
GtBugbopShowcaseExamples >> dashboard [
	<gtExample>
	<return: #GtBugbopDashboard>
	^ self explorer dashboard
]

{ #category : 'examples' }
GtBugbopShowcaseExamples >> duplicateMap [
	<gtExample>
	<return: #GtBugbopDuplicateMap>
	| aMap |
	aMap := GtBugbopDuplicateMap forReports: self reports.
	self assert: aMap clusters size equals: 3.
	^ aMap
]

{ #category : 'examples' }
GtBugbopShowcaseExamples >> explorer [
	<gtExample>
	<return: #GtBugbopExplorer>
	| anExplorer |
	anExplorer := GtBugbopExamples new explorer.
	anExplorer reports: self reports.
	^ anExplorer
]

{ #category : 'examples' }
GtBugbopShowcaseExamples >> hunterLandscape [
	<gtExample>
	<return: #GtBugbopHunterLandscape>
	| aLandscape hunters |
	aLandscape := GtBugbopHunterLandscape forReports: self reports.
	hunters := self reports hunterSummaries items.
	self assert: hunters size equals: 7.
	"Every hunter but grace has enough resolved reports to be colored"
	self assert: (hunters select: [ :each | each hasSignificantSignal ]) size equals: 6.
	^ aLandscape
]

{ #category : 'fixtures' }
GtBugbopShowcaseExamples >> isoTimeDaysAgo: aNumber hourOffset: anHours [
	^ (DateAndTime now asUTC - (Duration days: aNumber hours: anHours minutes: 0 seconds: 0)) printString
]

{ #category : 'examples' }
GtBugbopShowcaseExamples >> reportCard [
	"The suspected-duplicate XSS report: shows severity, AI disagreement and duplicate pills"
	<gtExample>
	<return: #GtBugbopReport>
	^ self reports items detect: [ :each | each id = 'e1' ]
]

{ #category : 'fixtures' }
GtBugbopShowcaseExamples >> reportJsonFromRow: aRow index: anIndex [
	^ GtBugbopExamples new
		insightsReportJsonWithId: (aRow at: 1)
		title: (aRow at: 2)
		status: (aRow at: 3)
		severity: (aRow at: 4)
		aiSeverity: (aRow at: 5)
		reporter: (aRow at: 6)
		bountyCents: (aRow at: 7)
		createdAt: (self isoTimeDaysAgo: (aRow at: 8) hourOffset: anIndex \\ 9)
		duplicateOf: (aRow at: 9)
		suspectedDuplicateOf: (aRow at: 10)
		scopeWarning: (aRow at: 11)
		comments: (aRow at: 12)
]

{ #category : 'examples' }
GtBugbopShowcaseExamples >> reports [
	<gtExample>
	<return: #GtBugbopReportsGroup>
	| aGroup |
	aGroup := GtBugbopReportsGroup from: (self rows withIndexCollect: [ :aRow :anIndex | self reportJsonFromRow: aRow index: anIndex ]).
	self assert: aGroup size equals: 33.
	self assert: aGroup active size equals: 9.
	self assert: (aGroup items allSatisfy: [ :each | each ageInDays <= 70 ]).
	^ aGroup
]

{ #category : 'fixtures' }
GtBugbopShowcaseExamples >> rows [
	"id title status severity aiSeverity reporter bountyCents daysAgo duplicateOf suspectedOf scopeWarning comments"
	^ #(
		#('s1' 'SQL injection in search' 'fixed' 'critical' 'critical' 'alice' 150000 70 nil nil false 6)
		#('s2' 'IDOR on invoices' 'open' 'high' 'high' 'alice' 0 34 nil nil false 9)
		#('s3' 'RCE via image upload' 'new' 'critical' 'critical' 'alice' 0 2 nil nil false 2)
		#('s4' 'SSRF in webhook tester' 'fixed' 'high' 'high' 'alice' 80000 52 nil nil false 5)
		#('s5' 'Auth bypass on password reset' 'fixed' 'critical' 'high' 'alice' 200000 60 nil nil false 7)
		#('s6' 'Verbose error page' 'not_applicable' 'low' 'low' 'alice' 0 45 nil nil true 1)
		#('s7' 'JWT none algorithm accepted' 'fixed' 'high' 'high' 'alice' 60000 25 nil nil false 3)
		#('b1' 'Stored XSS in profile bio' 'fixed' 'high' 'high' 'bob' 50000 58 nil nil false 4)
		#('b2' 'Rate limit bypass on login' 'needs_info' 'medium' 'medium' 'bob' 0 26 nil nil false 3)
		#('b3' 'CSRF on email change' 'fixed' 'medium' 'medium' 'bob' 20000 40 nil nil false 2)
		#('b4' 'Open redirect on logout' 'fixed' 'low' 'low' 'bob' 5000 15 nil nil false 1)
		#('b5' 'XSS in markdown preview' 'fixed' 'high' 'high' 'bob' 40000 10 nil nil false 2)
		#('c1' 'SQLi via search param (again)' 'duplicate' 'high' 'critical' 'carol' 0 68 's1' 's1' false 2)
		#('c2' 'Invoice IDOR via export' 'new' 'high' 'high' 'carol' 0 5 nil 's2' false 0)
		#('c3' 'Missing security headers' 'not_applicable' 'low' 'low' 'carol' 0 50 nil nil true 1)
		#('c4' 'Clickjacking on login' 'wont_fix' 'low' 'low' 'carol' 0 44 nil nil false 1)
		#('c5' 'Cookie without Secure flag' 'not_applicable' 'low' 'medium' 'carol' 0 20 nil nil false 0)
		#('c6' 'Exposed .git directory' 'fixed' 'medium' 'high' 'carol' 25000 12 nil nil false 3)
		#('d1' 'Search box SQL error leak' 'duplicate' 'medium' 'high' 'dave' 0 66 's1' 's1' false 1)
		#('d2' 'Self-XSS in console' 'not_applicable' 'low' 'low' 'dave' 0 38 nil nil false 0)
		#('d3' 'Version disclosure in footer' 'not_applicable' 'low' nil 'dave' 0 22 nil nil true 0)
		#('d4' 'Reverse tabnabbing' 'wont_fix' 'low' 'low' 'dave' 0 8 nil nil false 1)
		#('e1' 'XSS in bio field' 'open' 'medium' 'high' 'erin' 0 54 nil 'b1' false 2)
		#('e2' 'Subdomain takeover' 'fixed' 'medium' 'medium' 'erin' 25000 36 nil nil false 5)
		#('e3' 'Public S3 bucket listing' 'fixed' 'high' 'high' 'erin' 40000 28 nil nil false 3)
		#('e4' 'GraphQL introspection leaks PII' 'new' 'medium' 'high' 'erin' 0 1 nil nil false 0)
		#('e5' 'Path traversal in export' 'fixed' 'high' 'critical' 'erin' 70000 18 nil nil false 4)
		#('f1' 'Staging tenant exposed' 'new' 'low' 'medium' 'frank' 0 7 nil nil true 0)
		#('f2' 'Missing HSTS header' 'not_applicable' 'low' 'low' 'frank' 0 48 nil nil true 0)
		#('f3' 'Out-of-scope CDN bucket' 'not_applicable' 'low' nil 'frank' 0 32 nil nil true 0)
		#('f4' 'Exposed admin login page' 'fixed' 'medium' 'medium' 'frank' 10000 14 nil nil false 2)
		#('g1' 'Race condition in coupon redeem' 'open' 'high' 'high' 'grace' 0 9 nil nil false 4)
		#('g2' 'Mass assignment on profile' 'new' 'medium' 'medium' 'grace' 0 3 nil nil false 1))
]

{ #category : 'examples' }
GtBugbopShowcaseExamples >> timeline [
	<gtExample>
	<return: #GtBugbopReportTimeline>
	^ GtBugbopReportTimeline forReports: self reports
]

{ #category : 'examples' }
GtBugbopShowcaseExamples >> triageBoard [
	<gtExample>
	<return: #GtBugbopTriageBoard>
	^ GtBugbopTriageBoard forReports: self reports
]
