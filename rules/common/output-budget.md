---
paths:
  - "**/*"
---
# Output Budget

Keep assistant responses, file reads, file-writing operations, and code/document edits small enough to avoid output-limit failures and unsafe large rewrites.

This rule exists to avoid triggering `CLAUDE_CODE_MAX_OUTPUT_TOKENS` and to keep changes reviewable, deterministic, and safe.

## Core Rule

Read, create, and update files one by one into small chunks.

Use this guidance:

> please read/create/update files one by one into small chunks to avoid triggering CLAUDE_CODE_MAX_OUTPUT_TOKENS guard.

## Why

The output budget can be triggered by:

- visible chat output
- tool call arguments
- large file reads
- bulk-reading many files
- large file writes
- large file edits
- large generated markdown documents
- large diffs
- oversized patches

Do not assume that avoiding chat output is enough.

Large `Read`, `Write`, or `Edit` operations can still exceed the model output limit.

Small, incremental operations also:

- avoid truncated outputs
- reduce partial or broken file rewrites
- improve reviewability
- make execution safer and more deterministic

## General Rules

- Read, create, or update files one by one.
- Prefer small chunks over large reads/writes.
- Prefer targeted reads/edits over full-file reads/rewrites.
- Do not bulk-read many files in one tool call.
- Do not generate multiple large files in the same response.
- Do not rewrite a large file in one shot if the same result can be achieved through smaller edits.
- Do not echo generated file contents in chat.
- Return only paths and a short summary after file changes.
- If a document is large, split it into smaller files or smaller sections.
- If many files need edits, batch them into smaller groups.
- If a task requires a large patch, split the task before editing.
- Do not mix unrelated edits in the same step.

## Read Budget

Reading files also consumes output budget.

Do not bulk-read multiple large files.

Avoid:

- reading many files at once
- reading all task files in one tool call
- reading entire large documents when only a section is needed
- expanding a directory and immediately opening every file
- reading unrelated files just in case

Prefer:

- read one file at a time
- read the index/checklist first
- identify which specific file or section is needed
- read only the next relevant file
- summarize before continuing
- stop before reading a large batch
- use subagents when several files must be analyzed independently

When reviewing a document set:

1. Read the index or entry-point document first.
2. Identify the specific files that need inspection.
3. Read related files one by one.
4. After each file, record a short summary.
5. Do not read all related files in one tool call.

## Subagent Usage

When many files must be reviewed or analyzed, use multiple subagents instead of bulk-reading everything in one context.

Use subagents when:

- several files must be reviewed independently
- several task files must be analyzed
- files are large
- the analysis can be split by area, task, or concern
- reading everything at once risks exceeding the output budget

Each subagent must:

- read only its assigned file or small file group
- return a short summary
- report blocking issues only
- avoid echoing file contents
- avoid reading unrelated files
- avoid producing large analysis output

The main agent must aggregate subagent summaries instead of loading all files itself.

Do not use subagents when one or two small files are enough.

## Tool Call Budget

Tool call arguments count as model output.

Do not treat file reads or file writes as free.

Avoid:

- one large read of multiple documents
- one large `Write` call with a complete generated document
- one large `Edit` call replacing most of a document
- generating multiple detailed files in one response
- generating all detailed sections in one response
- emitting large generated patches or diffs

Prefer:

- one file per response
- one focused section per edit
- compact index files when the relevant workflow requires them
- child files for detailed content when the relevant workflow requires them
- small append/edit operations

## Documents

When editing Markdown, specs, plans, ADRs, research docs, facts, delivery artifacts, README files, or other text documents:

- update only the sections that need to change
- avoid rewriting unchanged sections
- prefer appending or replacing targeted subsections
- create child files when the relevant workflow requires them
- write one file at a time
- stop after a small batch and summarize
- if needed, continue in another step

## Code

When editing code:

- prefer narrow, scoped changes
- avoid unrelated rewrites
- avoid large multi-file patches in one response
- split large implementation work into smaller tasks
- edit one logical unit at a time
- avoid large multi-file rewrites unless explicitly requested

## Planning Work

When planning work:

- split large work into smaller executable tasks
- prefer task granularity that keeps each change small and reviewable
- if a file is likely to require a big rewrite, isolate it into its own task
- avoid plans that would require the agent to emit a massive patch in one response
- follow any workflow-specific rules for index files, child files, or task files

## When to Split

Split the work when:

- a single file needs many section edits
- the output would be long or repetitive
- several unrelated files are being changed together
- the change touches large generated docs, specs, plans, or code files
- the agent risks exceeding output limits
- a patch would be difficult to review safely

## If Splitting Is Required

State that the work will be done incrementally and continue in small chunks.

Do not attempt a large read, write, edit, or rewrite first if a token-limit risk is obvious.

## Response Format

After reading, creating, or updating files, respond with a short summary only.

Example:

```md
Updated:

- `path/to/file.md`

Summary:

- Updated one section.
- Kept the change small.

Next:

- Continue with the next file or section.
```

Do not include full file contents unless the user explicitly asks.

## Recovery Rule

If output limit errors occur:

- reduce chat output
- split the artifact
- read fewer files
- write smaller files
- avoid displaying generated content
- retry with one file or one small section only

