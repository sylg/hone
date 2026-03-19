<!-- 🪙 Hone Review: 2026-03-18
     Questions: 7 asked, 6 answered, 1 skipped
     Findings: 4 (🟠 0 high, 🟡 2 medium, 🔵 1 low, ⚠ 1 skipped)
     Verdict: NEEDS HONING
     Dimensions: Gaps, Assumptions, Context Completeness
-->

# Changelog Notification Popover

## Goal
Show a centered dismissible popover the first time a user opens the app after a version update, if a matching changelog entry exists in Sanity CMS for that exact version.

## How it works
1. On app launch, compare current app version against `lastSeenVersion` in localStorage
2. If version changed, query Sanity for a changelog where `version == currentVersion` and `"intent" in supportedClients`
3. If a matching entry exists → show the popover
4. If no match or fetch fails → silently do nothing
5. Save current version to localStorage regardless

## Acceptance Criteria
- On first launch after version bump, popover appears centered on screen **only if** a Sanity changelog exists for that exact version
- Body content rendered as rich text (headings, bold, italic, lists, links, code)
- "View full changelog →" link to `https://augmentcode.com/changelog/{slug}`
- Dismissible via X button, backdrop click, or Escape
- If already seen for this version, does not show again
- If Sanity fetch fails or no matching entry, silently suppressed
- First-ever launch (no stored version) does NOT show the popover

## Non-goals
- Showing multiple changelog entries
- Rendering images or YouTube embeds from Portable Text
- Changes to the existing auto-update flow or CloudFront release notes
<!-- 🪙 HONED: Removed "External Portable Text rendering library" from non-goals — custom PT renderer is disproportionate complexity for the subset needed. A lightweight library like @portabletext/svelte is now permitted. -->

## Assumptions
- Sanity public API can be queried directly from renderer (dataset is public, no auth needed)
- Existing `lastSeenVersion` localStorage key is the right tracking mechanism
- Existing `ReleaseNotesModal.svelte` + `releaseNotesStore` will be updated in-place
<!-- 🪙 HONED: Made version format assumption explicit — GROQ does exact string match, so mismatch = popover never shows -->
- Version strings use semver format without `v` prefix (e.g., `1.2.3`, not `v1.2.3`). The Sanity `version` field should include validation to enforce this format.

## Sanity details
- Project: `oraw2u2c`, dataset: `production`
- API: `https://oraw2u2c.api.sanity.io/v2021-10-21/data/query/production`
- Schema change needed: add `version` string field to `changelog` document type
- GROQ query: `*[_type == "changelog" && version == $version && "intent" in supportedClients][0]{ title, slug, publishedAt, body }`

## Verification Plan
- `pnpm run check` passes
- `pnpm tsc -p tsconfig.json --noEmit` passes
- Manual: clear `lastSeenVersion`, reload → popover appears (if matching changelog exists)
- Manual: dismiss and reload → popover does NOT appear

## Tasks

- [ ] [Add version field to Sanity changelog schema](intent://local/task/dcdbe3f2-6893-45a2-a62d-ca7bf3438f8e)

- [ ] [Update release notes store to fetch from Sanity](intent://local/task/af7f0626-15f4-4cf7-bdf0-4b71859db214)

- [ ] [Update changelog modal to render Portable Text](intent://local/task/8add6be6-7259-4446-ab39-c92e980df6bf)

<!-- ⚠ UNREVIEWED: Task implementation detail not assessed — tasks are titles only with no file paths, function names, or implementation notes. Context Completeness question was skipped. -->
