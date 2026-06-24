---
layout: page_with_comment
title: "Two causes, one signature: a WebKit click that registered no POST"
date: "2026-05-26"
tags:
  - "react"
  - "useeffect"
  - "playwright"
  - "webkit"
  - "remix"
  - "turnstile"
  - "debugging"
comment_id: "2026-05-26-two-causes-one-signature-webkit-click-no-post"
---

## TL;DR

- **Signature:** a Playwright click on the login/register submit button "succeeds", but no POST is sent — a document-level capture-phase `click` listener AND React's delegated `onClick` are *both* silent, and the test times out waiting for the next step.
- **Two independent root causes produced the identical signature** (plus a third, related click-before-hydration class on the register page). **A:** a `useEffect` dependency-array race detached the click listener mid-click. **B:** a cross-origin Cloudflare Turnstile iframe rendered ~1 s late over the moving submit button and absorbed the click.
- **Two fixes.** A: drop the churning dependency so the listener persists. B: the test waits for the Turnstile token before clicking, so the layout has settled.

## Context

The login route is a Remix v2 app. Login is two-step: password, then TOTP. Because the submit path is async (signing a DPoP proof, collecting a device fingerprint), the button is `type="button"` with an `onClick` that does the async work then calls Remix's `submit()` — it is *not* a native form submit, so there is no browser fallback if the `onClick` never fires. To guard an earlier click-before-hydration race, a `useEffect` registers a **document-level capture-phase `click` listener** (a diagnostic sentinel) and sets a `data-login-form-hydrated` DOM marker that the Playwright helper waits on before clicking. The password step also renders a Cloudflare **Turnstile** widget and an async "Sign in with passkey" button. Smoke runs in Docker Playwright at high parallelism across Chromium/WebKit/WebKit-iOS; the failures only reproduced on Mac WebKit under that load. The bug lives at the intersection of async hydration, late-rendering third-party widgets, and Playwright's click actionability model.

## The signature we saw

The form-mounted log fired, the marker was set when the helper's `waitFor` resolved, the click action completed — but there was no native-click log, no React `onClick` log, and no POST. Playwright's actionability log from the failing trace:

```
locator resolved to <button type="button" data-testid="login-submit" ...>
waiting for element to be visible, enabled and stable
element is visible, enabled and stable        # after ~382 ms of motion
performing click action
click action done                              # dispatched at point (960, 420)
waiting for locator('input[name="stepToken"]') # ...then times out 60 s later
```

Both a document-capture listener and React's delegated `onClick` being silent looks impossible at first. Two distinct mechanisms produce it.

## Cause A — useEffect dependency-array detach race

**Mechanism.** The effect's dependency array was `[stepToken, navigationState]`. `useNavigation().state` cycles `idle → loading → submitting → idle` on every action and every loader revalidation. On each change React runs the effect's **cleanup** (`removeEventListener` + `removeAttribute`) and then re-runs the body (`addEventListener` + `setAttribute`). Those two steps are not atomic; between them the listener is detached and the marker is absent. On Linux the gap is microseconds; on Mac WebKit under heavy parallelism it widens to milliseconds — wide enough that a click dispatched just after the marker's `waitFor` resolved lands inside the detach window.

**Evidence.** The form-mounted log fired once; the marker was present when Playwright checked; ~4 of every 27 workers per run hit it; no native-click log, no `onClick`, no POST — all downstream of "listener not attached at click time."

**Fix.** Drop `navigation.state` from the dependencies; the listener and marker then persist for the form's life and only re-attach on the password→2FA transition. The `// eslint-disable-next-line react-hooks/exhaustive-deps` is load-bearing — exhaustive-deps will demand `navigation.state` back and reintroduce the race.

**What generalizes.** A frequently-churning router hook (`navigation.state`, `revalidator.state`) in the dependency array of an effect that registers a listener or sets a persistent marker *is* "re-run this effect on every action." Keep the listener on stable deps and read the volatile value from a ref:

```ts
const navStateRef = useRef(navigation.state);
useEffect(() => { navStateRef.current = navigation.state; });        // keep ref current; every render, no deps array, no cleanup
useEffect(() => { /* addEventListener; read navStateRef.current */ }, [stepToken]); // attach once
```

## Cause B — Turnstile cross-origin iframe layout shift

**Mechanism.** The Turnstile widget renders *late* — ~0.5–1.5 s after hydration — into a container above the submit button, pushing the button down as it paints in. Lateness is the bug, not position: a widget that rendered synchronously, or one that reserved its height, would move nothing. The "Sign in with passkey" button also inserts late. Playwright resolves the button, waits for its box to be "stable", and clicks the resolved coordinate — but Turnstile's **cross-origin `challenges.cloudflare.com` iframe** has by then painted into that coordinate, so the click is dispatched into the iframe.

**Cross-origin iframes are separate browsing contexts — the parent document cannot observe pointer events dispatched into them.** This is what makes the signature indistinguishable from Cause A: not "no click happened" but "the click happened somewhere the parent can't see."

**Evidence.** After broadening the diagnostic listener (below) the trace showed the form mounted but **zero** clicks or pointerdowns of any kind reaching the document → the press went cross-origin. The actionability log shows 382 ms of button motion before "stable". Screencast frames put the submit button at y≈277 (mount) → 262 (passkey appears) → 293 (Turnstile "Success!" widget appears). A screen recording — "Turnstile and passkey show late, so the button moves in the first second" — reconciled every artifact. Why only Mac WebKit (as with Cause A): on Linux the widget paints and settles before Playwright's click window opens; WebKit's slower paint under load lands the iframe in the dispatch window often enough to flake.

**Fix.** The test waits for the hidden `input[name="cf-turnstile-response"]` to receive a value (widget shown + token issued = the last layout shift settled) before clicking; it's a no-op if Turnstile isn't mounted. A reserve-space / CLS fix in the app was considered and rejected — don't reshape the UI for a test-timing issue (the layout shift *is* a real CLS smell, logged as a separate follow-up).

**What generalizes.** A cross-origin iframe absorbs pointer events invisibly to the parent. Playwright's "stable" check samples two animation frames and is fooled by a quiet window before a *late* async paint; gate the click on the semantic signal that causes the last shift (the Turnstile token), not on bounding-box stability or a generic hydration marker.

## A sibling on register — a third mechanism

The register page hit the same no-POST signature but from a *third* mechanism, and noting it keeps "two causes" honest: the signature space is larger than "A or B". Register has no document-level click listener to tear down, so Cause A cannot apply. Its race is Remix `<Form>`'s submit interception during hydration — `preventDefault` is wired before the JS submit path is ready, so an early click is swallowed. Fixed by porting login's marker guard verbatim: a `[]`-dependency effect that attaches a capture-phase listener and sets `data-register-form-hydrated`, plus a helper wait on the marker. Register is *also* subject to Cause B (Turnstile renders above its submit button too). Three distinct mechanisms across two routes converge on one symptom — "click, no POST".

## Why we thought A was sufficient (the diagnostic blind spot)

After the Cause-A fix landed, the symptom persisted, but we initially read it as a regression or flake rather than a second cause — because **our instrumentation could not tell A and B apart.** The capture listener did `const btn = target.closest('[data-testid="login-submit"]'); if (!btn) return;` — it logged only clicks *on the submit button*. A click that landed off the button, or into the Turnstile iframe, logged **nothing**, identical to "listener detached". We had even written this ambiguity into an earlier note as a *certainty* — "both handlers silent is impossible for any cause other than the listener being detached." It was not: a cross-origin absorb produces the same silence. The investigation only moved once we **broadened the listener to log every click and pointerdown with `document.elementFromPoint`**; the next trace immediately showed the press never reached the document at all.

## Lessons

1. **Frequently-churning router hooks in a listener/marker effect's deps are a race surface.** Use stable deps; read the volatile value via a ref.
2. **When a fix verifies its own mechanism but the symptom persists, broaden instrumentation before assuming regression or flake.** The same observable signature may have a second, independent cause.
3. **Never early-return in a diagnostic listener.** Log every event and flag the interesting subset with a boolean and its surroundings (`elementFromPoint`); filtering to "my element" throws away the evidence that distinguishes causes. The cheapest change in this whole arc — deleting one `if (!btn) return;` — is what ended it.
4. **"Both handlers silent" ≠ "no event dispatched."** A cross-origin iframe absorbs the click invisibly. Distinguish "dispatched elsewhere" from "never dispatched" with `pointerdown` + `elementFromPoint`, not by inference.
5. **Playwright's actionability "stable" check is not "the page is done."** Wait for the semantic readiness signal that causes the last layout shift, not generic bounding-box stability or a hydration-only marker.
6. **Screencasts catch transient layout shifts that trace timestamps flatten.** Pull the video before the third round of trace-theorizing — a screen recording settled in one sentence what the trace logs had obscured.
7. **Don't reshape the app for a test-timing problem** when a targeted wait suffices — but log the genuine UX defect (the layout shift) separately rather than conflating it with the test fix.
