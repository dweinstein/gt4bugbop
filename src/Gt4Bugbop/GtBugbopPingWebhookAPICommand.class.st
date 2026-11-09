"
POST /webhooks/:id/ping, queues a webhook.ping delivery
"
Class {
	#name : 'GtBugbopPingWebhookAPICommand',
	#superclass : 'GtBugbopAPICommand',
	#instVars : [
		'webhook'
	],
	#category : 'Gt4Bugbop-Commands',
	#package : 'Gt4Bugbop',
	#tag : 'Commands'
}

{ #category : 'accessing' }
GtBugbopPingWebhookAPICommand >> perform [
	"Bugbop answers 202 Accepted and queues a webhook.ping"
	^ self request isSuccess
]

{ #category : 'accessing' }
GtBugbopPingWebhookAPICommand >> request [
	^ self client post: 'webhooks/' , (self idFrom: webhook) , '/ping' withEntity: nil
]

{ #category : 'accessing' }
GtBugbopPingWebhookAPICommand >> webhook: aWebhookOrId [
	webhook := aWebhookOrId
]
