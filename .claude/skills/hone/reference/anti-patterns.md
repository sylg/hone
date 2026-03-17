# Spec Anti-Patterns

Common spec problems to watch for during every review. When you spot one, name it. Developers remember named patterns.

## The Happy Path Only

**What it looks like**: Every scenario described works perfectly. No error cases, no failure modes, no "what if" scenarios. The spec reads like a demo script.

**The tell**: No mention of: error codes, retry logic, fallback behavior, timeout handling, validation failure, partial success, rollback.

**Question**: "This spec describes what happens when everything goes right. What happens when [specific thing] fails?"

**Risk**: The implementation will handle the happy path beautifully and crash on the first real-world edge case.

---

## The Assumption Iceberg

**What it looks like**: The spec is clear and concise — suspiciously so. It covers 10% of the decisions needed and leaves 90% to "common sense" or "obvious" choices.

**The tell**: Short spec for a complex feature. Phrases like "standard approach", "handle appropriately", "as expected", "normal flow."

**Question**: "This spec says '[vague phrase].' There are at least 3 ways to implement this. Which one do you mean, and why?"

**Risk**: The implementer makes different assumptions than the author. The feature works, but not the way anyone intended.

---

## The Scope Balloon

**What it looks like**: Started as "add a button to export CSV" and now includes a redesigned export pipeline, a new file format, a settings page, and a notification system.

**The tell**: The spec's title doesn't match its content. Tasks at the end feel increasingly tangential. "While we're at it" or "it would be nice to also" appear.

**Question**: "The original ask was [X]. Tasks [N, N+1, N+2] seem to be about [Y], which is a different feature. Are these truly required for this change, or can they be a follow-up?"

**Risk**: The feature takes 3x longer than expected, ships late, and the core ask gets buried under nice-to-haves.

---

## The Untestable Task

**What it looks like**: Success criteria that can't be objectively verified. "Improve performance." "Make it more intuitive." "Clean up the code."

**The tell**: No numbers, no baselines, no comparison points. Adjectives instead of metrics.

**Question**: "Task [N] says 'improve performance.' What's the current baseline, what's the target, and how will you measure it?"

**Risk**: The task is never "done" because done was never defined. Or it's declared done based on vibes.

---

## The God Task

**What it looks like**: A single task that's actually an entire feature. "Implement the authentication system" as one line item.

**The tell**: The task description is longer than most tasks combined. It contains sub-bullets that are themselves complex tasks. Estimation is wildly uncertain.

**Question**: "Task [N] contains at least [X] distinct pieces of work: [list them]. Should these be separate tasks with their own success criteria?"

**Risk**: Progress is invisible until everything is done. Blockers in one sub-task block all sub-tasks. Testing is all-or-nothing.

---

## The Missing Why

**What it looks like**: Detailed "what" and "how" but no "why." The spec describes the implementation without explaining the motivation.

**The tell**: No user story, no problem statement, no context section. The spec jumps straight to tasks. If you ask "why are we doing this?" the answer isn't in the document.

**Question**: "What problem does this solve? Who benefits, and how will we know it's working?"

**Risk**: Without "why," the implementer can't make good tradeoff decisions. They'll follow the spec literally even when a better option is obvious, because they don't know what "better" means in this context.

---

## The Copy-Paste Spec

**What it looks like**: An agent-generated spec that follows a template perfectly but hasn't been adapted to the actual situation. Generic success criteria, boilerplate structure, placeholder-quality details.

**The tell**: Success criteria that could apply to any feature ("tests pass", "no regressions"). Risk sections that list generic risks ("timeline", "complexity") without specifics. Sections that feel like they exist because the template has them, not because they add value.

**Question**: "This success criterion says 'tests pass.' Which tests? What are they testing? What's the minimum coverage that gives you confidence?"

**Risk**: The spec looks complete but is actually hollow. The implementer fills in the real decisions during implementation — which is exactly what the spec was supposed to prevent.

---

## The LGTM Spec

**What it looks like**: A spec that looks professional, reads well, and was approved without real scrutiny. Nobody asked hard questions because it seemed fine.

**The tell**: No review comments. No version history. No "changed because" notes. The spec went from draft to approved in one step.

**Question**: "This is the first version of this spec with no revisions. Has anyone pushed back on any of these decisions?"

**Risk**: The first time the spec is truly tested is during implementation, when changes are 10x more expensive.

---

## The Kitchen Sink

**What it looks like**: Every possible feature, edge case, and future requirement crammed into v1. The spec tries to solve every problem at once.

**The tell**: The spec is very long. Features are categorized as "must have" but the list is 30 items. There's no concept of iteration or phasing.

**Question**: "If you could only ship 3 of these [N] features, which 3 would you pick? What's the minimum viable version?"

**Risk**: The project takes forever, team burns out, and the product ships late with features nobody asked for while missing the core value proposition.

---

## The Wall of Text

**What it looks like**: The spec is correct but unreadable. Paragraphs of prose where bullet points would do. No structure, no headers, no visual hierarchy.

**The tell**: You have to read it three times to understand the task list. Information is buried in paragraphs. There's no clear separation between context, requirements, and implementation details.

**Question**: "Can you restructure this so each task is a discrete bullet with its own success criteria? Right now, tasks [N] and [M] are buried in paragraph [X]."

**Risk**: The implementer misses requirements because they're hidden in prose. Different readers extract different task lists from the same spec.
