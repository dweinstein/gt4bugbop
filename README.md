# gt4bugbop

A [Glamorous Toolkit](https://gtoolkit.com) client and explorer for the [Bugbop](https://bugbop.com) bug bounty platform ([REST API docs](https://bugbop.com/docs/api)).

## Load

```smalltalk
Metacello new
	repository: 'gitlocal:///Users/user/work/gtoolkit/gt4bugbop/src';
	baseline: 'Gt4Bugbop';
	load.
```

## Token

Create a token on the **API Tokens** tab of your Bugbop profile and save it to:

```
~/.secrets/bugbop-api-key.txt
```

`GtBugbopClient withApiKeyFromFile` reads it. The key is never displayed:

- Request history stores a copy with `Authorization: Bearer ***`.
- Redirects aren't followed, and `getUrl:` refuses hosts other than bugbop.com, so the token can't leak elsewhere.
- Webhook signing secrets are stripped from `rawData`.

## Explore

```smalltalk
GtBugbopExplorer withApiKeyFromFile
```

| View | What it shows |
|------|---------------|
| Overview | Account, programs, report counts, triage queue size, bounties awarded, unread notifications, rate limit. Click a row to drill in |
| Triage queue | new / open / needs_info reports, most severe first |
| All reports | Every report you can see, color-coded by severity and status |
| Severity x status | Count matrix; click a severity row for its reports |
| Hunters | Per-hunter reports, fixed/rejected, signal ratio, top severity, bounties |
| Weekly activity | Reports submitted per week |
| Programs / Notifications / API calls | |

Every object drills further: a report has Overview, Description, AI triage, Internal notes, Comments (with a full-thread Transcript), Raw data, and an "Open on bugbop.com" action.

## Client API

```smalltalk
client := GtBugbopClient withApiKeyFromFile.
client currentUser.
client programs.
client reports.                                  "all pages, newest first"
client activeReports.                            "new, open, needs_info"
client reportsWithStatuses: #('new') severities: #('high' 'critical') since: nil.
client reportsUpdatedSince: 1 day ago.           "incremental sync"
(client reportAt: anId) comments.
client unreadNotifications.
```

Write operations go out to hunters by email or webhook, so they only run when you call them explicitly:
`updateReport:status:`, `updateReport:severity:`, `updateReport:internalNotes:`, `closeReport:asDuplicateOf:`, `addComment:toReport:`, `approveAccessRequest:message:`, `rejectAccessRequest:reason:`, `blockReporterOf:inProgram:`, `unblockReporter:`, `markNotificationsRead:`, `pingWebhook:`.

## Design

The package follows feenk's gt4llm HTTP clients (`GtLOpenAIClient`):

- **`GtBugbopClient`**: holds `apiKey`, `baseUrl`, `history` and `clientBuilder`. The class side reads `ApiKeyFile` from `~/.secrets`.
- **`GtBugbopClientZincBuilder`**: creates a configured `ZnClient` with bearer auth and JSON accept. It does not use `forJsonREST`, so an error body is parsed only after its status has been checked.
- **One `GtBugbopAPICommand` subclass per endpoint**: each defines `request` and `serializationClass`, and `perform` returns domain objects. Paginated endpoints subclass `GtBugbopListAPICommand`. It follows `Link: rel="next"` and stops early when given a `limit:`.
- **`GtBugbopEntity` subclasses**: built from JSON through `serializationProperties`. Each keeps the original JSON in `rawData`.
- **Groups**: built on `TGtGroupWithItems`, with type-preserving filters such as `active`, `withStatus:`, `byReporter:` and `matching:`.
- **Bugbop specifics**:
  - `X-RateLimit-*` headers are tracked in `client rateLimit`.
  - A GET that gets a 429 is retried once if `Retry-After` is 60 seconds or less. Writes are never retried.
  - API errors raise `GtBugbopError`, which carries the status, Bugbop's message and any 422 field errors.

## Examples

- `GtBugbopExamples`: offline. It uses fixtures from the API docs and a stub `ZnClient` to cover parsing, pagination, `limit`, filters, 401/404/422/429, the retry policy, JSON bodies and the explorer. These examples run in automated sweeps.
- `GtBugbopLiveExamples`: read-only calls to the live API, marked `<noTest>`.
