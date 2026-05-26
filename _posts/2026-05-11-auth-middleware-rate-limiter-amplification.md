---
layout: page_with_comment
title: "Auth middleware rate-limiter amplification: a 3×-per-request bug hidden by admin-account UAT"
date: "2026-05-11"
tags:
  - "hono"
  - "middleware"
  - "rate-limiting"
  - "cloudflare-workers"
  - "performance"
  - "postmortem"
---

A bug that was latent for months, found by accident while chasing something else, and fixed in ten minutes once understood.

- **Bug duration:** latent for many months — since the 8th sub-app was mounted under `/ledger`.
- **Detection:** by accident, while diagnosing a dashboard stream timeout.
- **Fix:** a per-middleware idempotency guard in the worker's auth middleware.
- **Severity if it had shipped:** **critical** — a 4–6 s wait on every dashboard load for every non-admin user, tipping Remix's `streamTimeout` into an "Unexpected Server Error" page on cold-container loads. Total brokenness to a first-time visitor.

## What the bug was

`authOnboardedMiddleware` (and its siblings `authMiddleware`, `rejectApiKeyMiddleware`) ran **3+ times per HTTP request** because of two compounding factors:

1. **Hono sub-app fan-out.** The worker mounts 8 separate sub-apps at `/ledger`. Each has `app.use('*', authOnboardedMiddleware())`. Hono runs middleware for every matching prefix, so one request to `/ledger/{id}/statement/summary` runs the auth middleware 3+ times before reaching the route handler.
2. **The per-user rate limiter counted on every invocation.** Three invocations → three decrements on the per-user budget. With 6–8 parallel dashboard fetches, the budget exhausted instantly. Each rejected call slept `scheduler.wait(2000)` as a pacing penalty. Penalties stacked within one request → 4–6 s of pad on a route that does ~150 ms of real work.

Admin clients skipped the rate-limit branch entirely (`if (authResult.client === 'web' && ...)`), so admins never experienced it. Hold that thought.

## Why we did not catch it

This is the part that hurts.

### 1. Hands-on UAT during development used the admin account

We **do** have a non-admin account and we **do** use it — smoke registrations use non-admin users. The gap is more specific: when iterating on a feature, the day-to-day "open the browser, click around, see if it works" is done as the admin account almost every time. That's the account with all permissions, all admin pages, no trial gates — the path of least friction for an engineer mid-development.

The admin account issues a `web-admin` JWT. The rate-limit branch is gated on `client === 'web'`. **Admin-as-engineer hands-on UAT made the bug literally unreachable for the account we used the most during interactive work.** Every dashboard load during development looked instant.

The fix is not "test as a real user — we already do that." It is "do hands-on UAT as a non-admin user, not just smoke." Different muscle.

### 2. Smoke covers the non-admin path — but not the interactive burst pattern

Smoke registers fresh non-admin users and runs full flows against them. What it does NOT exercise is the pattern that triggered the bug at perceptible scale: **rapid in-app navigation that fans out 6–8 parallel deferred-loader fetches in <100 ms.** Smoke specs do one thing at a time and wait for it; they don't simulate a user double-clicking nav links. The bug was visible in smoke (a `handler_ms: 4779` was already in the logs) — we just weren't looking at log latencies as a signal because smoke "passed".

Smoke is a great correctness gate; it is a poor latency gate without explicit assertions on response times.

### 3. The Hono fan-out behaviour is non-obvious

Adding `app.route('/ledger', xApp)` 8 times reads like 8 independent route groups. It is not. Each sub-app's `app.use('*', authOnboardedMiddleware())` is layered on top of every other sub-app's, so Hono runs them in series for each request. There is no warning, no log, no test that breaks. The 8-mount pattern grew organically — ledger, then transaction-edit, then statement, then reconcile, then tax-tables, then clients, then attachments, then export-full. Each addition silently multiplied auth-middleware invocations per request, decrementing the rate limiter one more time.

### 4. The rate limiter looked tuned correctly

The per-user budget was set assuming ONE check per request. With 3× amplification + 8 parallel dashboard fetches it sees ~24 hits in <100 ms — but no one ever computed that math because no one realised the multiplier existed. The limiter "worked" in isolation tests.

### 5. We had no aggregate metrics

Wall-time per request was visible in logs only. There was no chart of "p99 dashboard latency by client" — so the asymmetric `web` vs `web-admin` performance was invisible to anyone not hand-tailing logs side by side. A simple percentile chart by `client` would have screamed at us the day the 8th sub-app was added.

### 6. The bug surfaced only by accident

The chain that led to detection:

1. A refactor moved dashboard pages to Remix `defer()` + `<Suspense><Await>`.
2. Smoke caught "Unexpected Server Error" on the dashboard for fresh users. We hypothesised — correctly — that Remix's ~5 s `streamTimeout` was firing.
3. We added per-step timing to confirm.
4. Someone noticed: a corp dashboard returned `200 OK (350ms)` but a solo dashboard returned `200 OK (6288ms)` for the same route. That asymmetry was the lever.
5. A global request-timing middleware showed `handler_ms: 4779` vs `summary total_ms: 137` — the handler was fast, the gap was *outside* it.
6. Per-step timing inside the auth middleware showed THREE `auth-middleware` entries for one `request_id`, each adding 2 s of pad.

Without the streamTimeout investigation, we would not have added the instrumentation. Without the instrumentation, we would not have seen the multiple invocations. Without the asymmetry between two users on the same code path, we would not have known something specific to `client: 'web'` was wrong. This is **luck**, not process.

## Impact (counterfactual: if we had launched last week)

- Every non-admin user opens the dashboard → 4–6 s wait for every load. Modern web standard: 1 s is "slow", 3 s is "broken".
- ~5 s exceeds Remix's default `streamTimeout`. Slow loaders would have surfaced as **"Unexpected Server Error"** for a meaningful fraction of cold-container loads — total brokenness, no error detail, no path to recover.
- First-impression damage to a free-trial signup is permanent. Users do not come back after "the app doesn't work".

## Why the fix is small

The fix is a 4-line helper plus one line at the top of each affected middleware. It is small **because the bug was structural, not algorithmic** — the auth-middleware code was correct in isolation; the architectural composition was wrong. The right fix is to make middleware idempotent against the composition, not to rewrite the auth flow.

```ts
function claimMiddlewareRun(c: Context<...>, name: string): boolean { /* ... */ }

// In each middleware:
if (!claimMiddlewareRun(c, 'authOnboardedMiddleware')) { await next(); return; }
```

Per-middleware names (not a shared `c.var.auth` check) so a parent `authMiddleware` cannot short-circuit a child `authOnboardedMiddleware` and skip the stricter check. Verified by reload: one `auth-middleware` log per `request_id`, total ~240 ms instead of ~6500 ms.

## What we are changing — and what we are not

Things to fix beyond the one-liner:

- **Aggregate metrics** (p50/p95/p99 by `client`, by path) so the next instance of this class shows up as a percentile-chart spike, not via lucky log-tailing. This is the structural fix for "why we didn't catch it".
- **A non-admin hands-on walkthrough** before any launch tag: 60 seconds clicking the whole product as a non-admin user, stopwatch in hand. Anything over 1 s for a page transition is a launch blocker. The instrumentation and the non-admin account already exist; what's missing is the habit.
- **An architectural reconsideration** of allowing multiple sub-apps under one prefix (or moving auth to a parent app that owns the routing). Not urgent now that the guard exists, but the composition smell remains.

Deliberately *not* changed: the per-user budget (it was doing its job — the amplification was the bug), the admin bypass (admins must repair things during incidents), and the 8-sub-app architecture (the idempotency guard makes the composition safe; restructuring is a larger refactor for later).

## Lessons

1. **UAT as a non-admin, not just smoke.** Smoke already covers the non-admin code path — that's not the gap. The gap is that hands-on, browser-in-front-of-me UAT defaults to the admin account because admin has fewer gates. Admin accounts skip rate limits, trial gates, billing checks, audit side-channels — every shortcut you give admins during dev is a class of bug you can ship without noticing interactively.
2. **Aggregate metrics are not optional for any real launch.** Per-request logs are diagnosis; percentile charts are detection. We caught this by luck. The next bug of this class will not be lucky.
3. **Hono sub-app composition is a footgun.** Mounting N sub-apps at the same prefix silently fans out middleware N times. "One sub-app per area" needs to come with a "what runs N times per request" audit.
4. **Asymmetric performance between two users on the same code path is the loudest signal you have.** If feature X is 350 ms for user A and 6 s for user B, the difference is almost always a per-user toggle (admin, plan tier, feature flag, trust level). Pursue that asymmetry hard — it is faster than any general profiling.
5. **Diagnostic instrumentation pays for itself.** The request-timing middleware took ~15 minutes to write and immediately revealed the gap. Keep cheap instrumentation in; convert to metrics later; don't optimise it out before the bug class is closed.
6. **A small diff after a long investigation is the right outcome.** When the fix is one line per middleware after hours of digging, the time was spent on understanding, not coding. Resist bundling a "cleanup" refactor with the bug fix — keep the fix minimal so the post-mortem can point at the actual change.

## Detection delay

| Phase | Approximate duration |
|---|---|
| Bug introduced (8th sub-app mounted) | ~3 months ago |
| Bug latent (admin-only testing masked it) | ~3 months |
| Pre-launch review noticed slow non-admin dashboard | 0 days (would have been launch-day if we hadn't looked) |
| Investigation (streamTimeout → instrumentation → root cause) | a few hours |
| Fix | ~10 minutes |
| Verification | ~1 dashboard reload |

**Three months of latency. A few hours of detection. Ten minutes of fix.** The asymmetry is the whole story: the cost was not in the fix; it was in the time the bug had to exist undetected.
