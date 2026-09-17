---
name: testflight-notes
description: Add automatic TestFlight release notes to an iOS repo, filling each build's "What to Test" from git (branch, SHA, recent commit subjects) via the App Store Connect API so builds are identifiable in App Store Connect. Use when the user says TestFlight builds are hard to tell apart, asks to auto-fill release notes or "What to Test", or wants build provenance visible in App Store Connect. Not for changing build or version numbering on its own.
---

# TestFlight Release Notes

Fill each TestFlight build's "What to Test" automatically from git, so a build in App Store Connect identifies itself without cross-referencing anything.

Target content:

```
main @ a1ff643  (build 412)

Recent commits:
- Fix crash when resuming a paused session
- ...
```

## Why the notes and not the build number

`CFBundleVersion` is limited to period-separated integers — no SHA, no branch, no words. Any numbering scheme can encode *when* a build was made, never *what is in it*. The notes field is the only place provenance can live, so resist the pull toward solving this with a cleverer build number. If the user is also reworking build numbers, treat that as a separate question and note that App Store Connect already shows an upload-date column, which makes a date-encoding scheme largely redundant once these notes exist.

## First, orient

Find how the repo currently uploads to TestFlight — a shell script, fastlane, a CI workflow, or raw `xcodebuild` / `altool`. Extend that path rather than adding a parallel one.

App Store Connect API credentials very likely already exist: look for a key ID, an issuer ID, and a `.p8` key path in whatever config the upload already reads. Reuse them. Do not introduce new credentials when these are present, and never move the `.p8` or print its contents.

## What to build

A script, invoked after a successful upload, that:

1. Mints an ES256 JWT for the App Store Connect API.
2. Resolves the app: `GET /v1/apps?filter[bundleId]=<bundle id>`
3. Finds the build: `GET /v1/builds` with `filter[app]`, `filter[preReleaseVersion.version]=<marketing version>`, and `filter[version]=<build number>`
4. Waits until the build reports `processingState` of `VALID`.
5. Reads `GET /v1/builds/{id}/betaBuildLocalizations`, then PATCHes the existing `en-US` entry, or POSTs one if none exists.

## Gotchas that otherwise cost a full upload cycle

**The attribute is `whatsNew`, not `whatsToTest`.** TestFlight's UI labels the field "What to Test", and Apple's own documentation has used both names. Sending `whatsToTest` fails with `ENTITY_ERROR.ATTRIBUTE.UNKNOWN`. Before writing, GET an existing betaBuildLocalization and print its attributes to confirm the field name against the live API rather than trusting docs or recall. Leave a comment at the call site, because the UI label will mislead the next reader.

**A freshly uploaded build is not queryable for several minutes.** The builds query returns zero results well after the upload command exits. Poll until the build *appears*, then poll again until it leaves `PROCESSING`. Treating "not found" as fatal is the obvious bug here and it fails every time the script runs right after an upload. Give both waits one shared deadline — roughly 20 minutes at a 30-second interval.

**Notes are rejected while the build is still processing**, hence the second wait.

**Capture the git SHA and branch at archive time**, not when the notes are written. Many minutes separate the two and the working tree can move.

**`whatsNew` caps at 4000 characters.** Truncate.

**Make failure non-fatal.** By this point the build is already safely in TestFlight; a notes failure must not fail the upload. Print a warning and provide a retry entry point (such as a `--notes-only` flag) that targets the newest build in the train and skips the archive entirely. This matters more than it sounds: it turns each bug into a 30-second retry instead of a 15-minute rebuild, and these bugs only surface against the live API.

## Implementation note

If using Python, PyJWT is often not installed but `cryptography` usually is, and it is enough. Sign with `ec.ECDSA(hashes.SHA256())`, then convert the DER signature to JOSE's raw `r||s` using `decode_dss_signature` and two 32-byte big-endian integers. JWT claims: `iss` (issuer ID), `iat`, `exp` (at most 20 minutes out), and `aud` of `appstoreconnect-v1`; `kid` (key ID) goes in the header. The standard library's `urllib` is fine for the HTTP calls — no third-party HTTP dependency needed.

## Done means

The notes are verified by reading them back from the API, not by the write returning a success status.
