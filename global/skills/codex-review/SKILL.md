---
name: codex-review
description: Review implementation plans (ExecPlans) using OpenAI Codex CLI as an external reviewer. Automates the review-fix-re-review cycle. Use when user says "計画書をレビューして", "ExecPlanをレビュー", "planをチェック", "Codexでレビュー", "review the plan", "review ExecPlan", "レビューサイクルを回して", or asks to have a plan reviewed by an external AI. Sends plans to Codex CLI in read-only sandbox mode for software engineering review (requirements correctness, DRY principle, readability), then iteratively fixes issues until the plan passes or max iterations are reached.
---

# Codex Plan Review

Automates the review-fix-re-review cycle for implementation plans using OpenAI Codex CLI as an external reviewer. Codex reviews the plan from a software engineering perspective (not document format), and Claude Code fixes the issues.

## Prerequisites

Verify Codex CLI is installed and authenticated:

    codex --version

If the command fails, inform the user that OpenAI Codex CLI must be installed and authenticated, then stop.

## Required Permissions

This skill uses the following tools that may require user approval. To run the review cycle without manual permission prompts, add these entries to the project's `.claude/settings.local.json`:

    {
      "permissions": {
        "allow": [
          "Bash(codex --version:*)",
          "Bash(codex exec:*)",
          "Bash(rm *tmp_review_prompt*:*)",
          "Write(.claude/tmp_review_prompt.md)"
        ]
      }
    }

If these permissions are not configured, Claude Code will prompt the user for approval at each step. Plan file edits (Edit tool) are automatically allowed when running in plan mode.

## Parameters

- **plan_file**: Path to the plan markdown file. If not specified, find the most recently modified `.md` file in the project's `plans/` directory.
- **max_iters**: Maximum review-fix cycles. Default: 5. User can override (e.g., "3回で", "max 3 iterations", "max_iters=2").

## Workflow

### Step 0: Identify Target

If the user specified a file path, use it. Otherwise, use Glob to find `.md` files in `plans/` and pick the most recently modified one. Confirm the target file with the user before proceeding.

### Step 1: Load Review Resources

Read these files from this skill's directory:

1. `references/review-criteria.md` — the review criteria covering requirements correctness, DRY principle, simplicity/readability, and technical accuracy
2. `references/codex-prompt-template.md` — the prompt template with placeholders

### Step 2: Assemble the Codex Prompt

Build the complete review prompt by replacing placeholders in the template:

1. Replace `{{REVIEW_CRITERIA}}` with the full content of `references/review-criteria.md`
2. Replace `{{PLAN_FILE_PATH}}` with the absolute path to the target plan file
3. For iteration 1: Replace `{{RE_REVIEW_CONTEXT}}` with an empty string
4. For iteration 2+: Replace `{{RE_REVIEW_CONTEXT}}` with the re-review context (see template for format), listing previous issues and the fixes applied

Write the assembled prompt to `.claude/tmp_review_prompt.md` in the project root.

### Step 3: Execute Codex

Run the following Bash command (timeout: 300000ms):

    codex exec -s read-only -C "<project_root>" "Read the file at .claude/tmp_review_prompt.md and follow the instructions in it exactly. Output your review in the specified format."

Capture the full stdout output.

### Step 4: Parse the Review Output

Extract the review from the Codex CLI output. The output contains headers, conversation log, and token usage in addition to the actual response. Parse by searching for the "VERDICT:" keyword in the output.

Extract:
- **VERDICT**: APPROVED or NEEDS_REVISION
- **SUMMARY**: Overall assessment
- **ISSUES**: List of issues with severity, section, description, and suggestion
- **CODEBASE_CHECKS**: Verified file paths and references

If the output cannot be parsed (error, unexpected format), display the raw output to the user and ask how to proceed.

### Step 5: Decision

- If VERDICT is **APPROVED** or no issues found: proceed to Step 7 (Report).
- If VERDICT is **NEEDS_REVISION** and iteration < max_iters: proceed to Step 6 (Fix).
- If VERDICT is **NEEDS_REVISION** and iteration >= max_iters: proceed to Step 7 (Report) with remaining issues noted.

### Step 6: Fix the Plan

Display the issues to the user as a summary.

For each issue, ordered by severity (CRITICAL first, then MAJOR, then MINOR):

1. Read the relevant section of the plan file.
2. Apply an appropriate fix using the Edit tool.
3. Record what was changed and why.

If an issue is ambiguous or conflicts with the plan's stated intent, skip it and note it for the user.

**Circular issue detection**: If the same issue (by description similarity) appears in two consecutive iterations, flag it to the user as a potential circular issue rather than attempting to fix it again.

After all fixes are applied, build the re-review context and return to Step 2 for the next iteration.

### Step 7: Report Results

Display a final summary:

    ## Codex Review Complete

    - **Plan**: <file path>
    - **Iterations**: N / max_iters
    - **Final Verdict**: APPROVED / NEEDS_REVISION
    - **Issues Found**: X (Critical: N, Major: N, Minor: N)
    - **Issues Fixed**: X
    - **Issues Remaining**: X

    ### Review History
    [For each iteration: verdict, issues found, fixes applied]

    ### Remaining Issues (if any)
    [List with explanation of why they were not addressed]

Clean up the temporary file `.claude/tmp_review_prompt.md`.

## Error Handling

- **Codex CLI not installed**: Report to user and stop.
- **Codex timeout** (5 minutes): Ask user whether to retry or stop.
- **Unparseable output**: Show raw output, ask user how to proceed.
- **Circular issues** (same issue 2+ times): Report to user, skip the fix, note in report.
- **Codex execution error** (non-zero exit code): Show error output, ask user how to proceed.

## Additional Resources

- **`references/review-criteria.md`** — The software engineering review criteria sent to Codex. Covers: requirements correctness, DRY principle, simplicity/readability, technical accuracy. Read this to understand or customize what Codex checks.
- **`references/codex-prompt-template.md`** — The prompt template defining the structure of review requests. Read this to understand or customize the prompt format and output structure.
