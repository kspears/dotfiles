---
name: interview-to-spec
description: Interview the user in rounds to turn a fuzzy feature or app idea into a written spec (docs/specs/<slug>.md) that an implementing agent can build from without guessing. Use when the user asks to build, add, or create a new feature, app, service, or sizeable capability and no spec for it exists yet, or says "spec this", "let's spec out", "interview me", "write a spec". Not for bug fixes or small tweaks.
---

# Interview to Spec

The goal is to get what is in the user's head onto the page precisely enough that a different agent, with no access to this conversation, builds the right thing the first time. The spec is the deliverable. Do not plan the implementation and do not write code.

This skill deliberately interviews in rounds. It is the sanctioned exception to the global rule that clarifying questions go in a single batch.

## Step 0: Orient in the codebase

Before asking anything, read. Questions shaped by the code are better than generic ones, and the user should never be asked something the repo already answers.

- Read the repo's `AGENTS.md` / `CLAUDE.md`, README, and any existing specs in `docs/specs/`. Match their style. Note overlap with anything already specified.
- Decide: greenfield project, or feature in an existing repo?
- In an existing repo, locate what the feature would touch: related modules, data models, API or CLI surface, UI patterns, test setup, config. Note candidate "extend X or build new?" decisions.
- Keep it a survey, not an audit. Do not narrate it as you go. Open round 1 with one short paragraph: what you found that is relevant, and what you are assuming because of it.

## Step 1: Interview in rounds

Ask in topic-batched rounds: one numbered list per round, roughly 3–6 questions. Each round is shaped by the answers to the last. Never one question at a time; never a single dump of twenty questions.

Question rules:
- Offer your best-guess default wherever you have one ("I'd assume X, correct?"). People correct faster than they generate.
- Ask only what you cannot infer from the code or the conversation.
- Add a one-line "why this matters" only when the reason is not obvious.
- Use the user's vocabulary, not spec jargon.
- Never invent a number, threshold, or fixture the user did not give. If one matters, ask for it.
- When the user answers a specific question with "your call" or "you decide", pick, and record it in the Decisions table as an agent default so they can see it.
- If the user says "just write it", stop asking, write the spec, and put everything unanswered under Open questions.

Round plan. Skip rounds already answered; merge rounds when there is little to ask.

1. **Problem and outcome.** Who it is for, what pain it removes, what "done" looks like, how success is judged, what is explicitly out of scope, and whether it ships in phases (if so, what the first phase contains).
2. **Users and flows.** The main path step by step and what the user sees at each step (screen, command, response). Secondary paths. Who else is affected (admins, other systems).
3. **Data and interfaces.** Entities and their fields, where they live, what is exposed (API, CLI, UI), how it connects to existing code. Extend-vs-new decisions surfaced in step 0 go here.
4. **Edge cases and failure.** Bad, empty, huge, duplicate, or concurrent input. Offline, timeouts, partial failure. What the user sees when it fails, in their actual words.
5. **Constraints.** Stack, allowed dependencies, performance numbers, auth and security, compatibility, migrations, where it runs, deadlines, and what must be tested and at what level.
6. **Acceptance.** Turn everything above into checkable criteria. Read them back to the user and confirm before writing.

Stop when you could write every section without guessing, or after about five rounds, whichever comes first. Anything still unsettled at that point goes under Open questions rather than into another round.

## Step 2: Write the spec

Location: `docs/specs/<kebab-case-slug>.md` at the repo root, always. For a greenfield project, create the directory in the project root. Other rules key off this path, so do not put specs elsewhere.

Sections, in this order:

```markdown
# <Feature name>

Status: Draft
Date: YYYY-MM-DD
Summary: one sentence.

## Problem and goals
## Non-goals
## Users and flows
## Data and interfaces
## Edge cases and failure modes
## Constraints
## Acceptance criteria
## Decisions
## Open questions
## Existing code touched
```

Section notes:
- **Status** is `Draft` while writing, `Reviewed` after step 3. The user may later set `Approved`; nothing in this skill does.
- **Non-goals** covers both what is out of scope for good and what is deferred to a later phase. Say which.
- **Constraints** includes testing expectations: which tests must exist and at what level.
- **Acceptance criteria** are numbered. Each must be checkable without asking anyone: by a command with an expected output where possible, otherwise by a human following explicit steps. Given/When/Then works well. "Should be fast" is not a criterion; a number the user gave you is. Do not manufacture numbers or fixtures to make a criterion look checkable.
- **Decisions** is a table: decision, choice, why, decided by (user or agent default). This is where "your call" answers land.
- **Open questions** lists anything the interview could not settle and who needs to resolve it. Fewer is better, but this is the honest escape hatch, not a failure.
- **Existing code touched** is for existing repos: files or modules, and whether each is extended, replaced, or left alone. Omit the section for greenfield.

Writing rules:
- Concrete over abstract. Name real files, endpoints, fields, commands.
- Quote user-facing strings (labels, error messages, command output) verbatim. Do not paraphrase them.
- Say what, not how. Architecture and implementation order belong to the plan that follows. Include a "how" only when it is a constraint the user set.
- Short sentences. No filler.

## Step 3: Adversarial review

Before showing the user the draft, have it attacked.

- If the agent can spawn a clean-context subagent (in Claude Code, the `adversary` agent), give it the spec path and the repo, and ask for: statements an implementer would have to guess at, contradictions between sections, conflicts or duplication with existing code, missing edge cases, and acceptance criteria that are not actually checkable.
- Otherwise, run this mechanical checklist over the file, treating each miss as a finding:
  - Every acceptance criterion names a command with expected output, or explicit human steps.
  - Every section is non-empty, or is "Existing code touched" on a greenfield project.
  - Every file, module, endpoint, or field named in the spec exists in the repo, or is listed as new.
  - Every user-facing string appears in quotes.
  - No number or threshold appears that the Decisions table or the user's answers do not account for.
  - No sentence contains "should", "appropriate", "as needed", "etc.", or "and so on".

Triage the findings. Fix what is clearly right. Anything that is a product decision goes back to the user as one final numbered round. Do not silently resolve product questions.

## Step 4: Hand off

- Set status to Reviewed.
- Show the user the spec path, the Decisions table, and any Open questions.
- If not already on a feature branch for this work, create `feat/<slug>`. Commit the spec there. Implementation continues on that branch.
- Stop. Do not plan and do not implement. Say that the next step is to plan from the spec (in Claude Code: enter plan mode with the spec as input).
