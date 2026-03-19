---
name: hone-settings
description: >
  View and edit Hone configuration. Manages model selection,
  report preferences, and dimension defaults. Settings are stored
  in .hone/config.json in the project root.
user-invokable: true
---

View and edit Hone settings interactively.

## Config Location

Settings live at `.hone/config.json` in the project root. Created on first run with sensible defaults.

## Behavior

When invoked, read the current config (or create defaults if none exists). Then show the current settings and ask what to change:

```
╭─ HONE SETTINGS ───────────────────────────────────────────────────────
│
│  Config: .hone/config.json
│
│  MODEL
│  ├─ Review model:     (inherit from session)
│  ├─ Subagent model:   (inherit from session)
│  └─ One model handles everything by default.
│     Set subagent model to a cheaper option (e.g., Sonnet)
│     to reduce cost on large reviews with parallel agents.
│
│  REPORTS
│  ├─ Save reports:     yes
│  ├─ Report directory:  .hone/reports
│  └─ Reports are the review memory — future reviews
│     reference past reports to avoid repeating questions.
│
│  DIMENSIONS
│  ├─ Always run:       gaps, assumptions
│  ├─ Never run:        (none)
│  └─ Auto-recommend:   yes
│
```

Then use `AskUserQuestion` to let the user pick what to configure:

```
AskUserQuestion({
  questions: [{
    header: "Settings",
    question: "What would you like to configure?",
    options: [
      { label: "Models", description: "Set which AI model to use for reviews and subagents" },
      { label: "Reports", description: "Configure where reports are saved and whether to auto-save" },
      { label: "Dimensions", description: "Set which dimensions always/never run" },
      { label: "Done", description: "Settings look good" }
    ],
    multiSelect: false
  }]
})
```

### If "Models" selected

```
AskUserQuestion({
  questions: [{
    header: "Review model",
    question: "Which model should run the main review? This is the model that reads your spec, asks questions, and produces the verdict.",
    options: [
      { label: "Inherit from session", description: "Use whatever model you're currently running (default)" },
      { label: "opus", description: "Claude Opus — highest quality, most expensive" },
      { label: "sonnet", description: "Claude Sonnet — good balance of quality and speed" }
    ],
    multiSelect: false
  },
  {
    header: "Subagent model",
    question: "Which model should run subagents (reviewer, questioner, unknown-scout)? Using a cheaper model here saves cost on large reviews.",
    options: [
      { label: "Inherit from session", description: "Same model as the main review (default)" },
      { label: "sonnet", description: "Claude Sonnet — recommended for subagents to reduce cost" },
      { label: "haiku", description: "Claude Haiku — fastest and cheapest, lower quality" }
    ],
    multiSelect: false
  }]
})
```

### If "Reports" selected

```
AskUserQuestion({
  questions: [{
    header: "Save reports",
    question: "Should Hone automatically save a review report after each review? Reports serve as memory for future reviews.",
    options: [
      { label: "Yes (recommended)", description: "Save to .hone/reports/ after each review. Future reviews reference past reports." },
      { label: "No", description: "Don't auto-save. You can still manually run /hone-report." }
    ],
    multiSelect: false
  },
  {
    header: "Report directory",
    question: "Where should reports be saved?",
    options: [
      { label: ".hone/reports/", description: "Hidden directory, gitignored by default (recommended)" },
      { label: "docs/hone/", description: "Visible in docs/, easy to commit and share with team" }
    ],
    multiSelect: false
  }]
})
```

### If "Dimensions" selected

```
AskUserQuestion({
  questions: [{
    header: "Always run",
    question: "Which dimensions should ALWAYS run, regardless of size or signals? (Gaps and Assumptions are always core — this adds on top.)",
    options: [
      { label: "Just core (default)", description: "Only Gaps + Assumptions always run. Others are recommended per-spec." },
      { label: "Add Testability", description: "Always check if success criteria are concrete" },
      { label: "Add Context", description: "Always check if a fresh agent could execute without questions" },
      { label: "Add Unknown Unknowns", description: "Always surface domain-specific gotchas" }
    ],
    multiSelect: true
  },
  {
    header: "Auto-recommend",
    question: "Should Hone recommend optional dimensions based on spec signals?",
    options: [
      { label: "Yes (recommended)", description: "Hone suggests dimensions based on anti-patterns, size, and domain" },
      { label: "No", description: "Only run core dimensions + any you set as 'always run'" }
    ],
    multiSelect: false
  }]
})
```

After each selection, update `.hone/config.json` and loop back to the main settings menu. Continue until the user selects "Done".

## Default Config

When no config exists, create `.hone/config.json` with:

```json
{
  "model": {
    "review": null,
    "subagents": null
  },
  "reports": {
    "auto_save": true,
    "directory": ".hone/reports"
  },
  "dimensions": {
    "always_run": [],
    "never_run": [],
    "auto_recommend": true
  }
}
```

`null` means "inherit from session" — the model the user is currently running.

## Reading Config

The core `hone` skill and `/hone-review` should read `.hone/config.json` at the start of every review. If the file doesn't exist, use defaults. Never fail if config is missing — always fall back gracefully.

Settings that affect behavior:
- `model.review` → passed as `model` parameter when dispatching the review
- `model.subagents` → passed as `model` parameter when dispatching subagents via the Agent tool
- `reports.auto_save` → if true, auto-generate report after verdict (don't ask)
- `reports.directory` → where to save reports
- `dimensions.always_run` → added to core dimensions before recommendation
- `dimensions.never_run` → excluded from recommendations
- `dimensions.auto_recommend` → if false, skip the recommendation step entirely
