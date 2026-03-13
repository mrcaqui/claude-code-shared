---
name: release
description: "Progress log update, version bump, and git commit+push as a single workflow. Trigger on natural language requests like: release, progress and push, record progress and commit, version up and push, or Japanese equivalents such as 進捗を記録してpush, バージョン上げてpush, リリースして, 進捗記録してコミット."
---

# Release - Progress Log, Version Bump, Git Push

Automate the end-of-task workflow: generate a progress log entry from the current diff, bump the version, then git add, commit, and push.

## Workflow

### 0. Ensure Git Repository

Before any release workflow, check if the project is a git repository by running `git status`.

If the project is **not** a git repository:

1. **Ask the user to create a remote repository** on GitHub (or their preferred hosting service). Present the recommended settings:
   - Repository name: use the project's directory name or `package.json` name
   - Visibility: Private (unless the user specifies otherwise)
   - **Do NOT** initialize with README, .gitignore, or license (the project already has these locally; adding them remotely causes merge conflicts on first push)

2. **Ask the user to provide the repository URL** (e.g. `https://github.com/<user>/<repo>.git`).

3. **Initialize and push** by running the following commands in order:

       git init
       git remote add origin <repository-url>
       git add .
       git status                # Show staged files for user review
       git commit -m "feat: initial commit"
       git branch -M main
       git push -u origin main

4. **Verify** the push succeeded by running `git log --oneline -1` and confirming the commit appears. If the push is rejected due to remote commits (e.g. the user initialized with a README), run:

       git pull origin main --allow-unrelated-histories

   Then resolve any merge conflicts, commit, and push again.

Once the repository is confirmed, proceed to step 1.

### 1. Gather Context

Run in parallel:

- `git diff --stat` and `git diff` (staged + unstaged).
- `git log --oneline -5` to match the project's commit message style.
- `git status` to list untracked and modified files.

### 2. Locate the Progress File

Search for a progress or changelog file. Check these locations in order:

    docs/進捗.md
    CHANGELOG.md
    PROGRESS.md

Also search for Japanese-named equivalents with Glob `docs/*.md` and Grep for dated heading patterns (e.g. `## 2026/`). If no file exists, ask the user whether to create one (default `docs/progress.md`).

Read the first 80 lines of the found file to learn its existing format (date style, heading level, section structure).

### 3. Locate Version File

Check in order:

1. `package.json` ("version" field)
2. `pyproject.toml` (`version = ...`)
3. `Cargo.toml` (`version = ...`)
4. `VERSION` file

If none found, skip version bumping and note it to the user.

### 4. Determine Version Bump

Analyze the diff to decide the bump level:

- **patch** (0.0.x): bug fixes, small UI tweaks, documentation updates, refactoring with no behavior change.
- **minor** (0.x.0): new features, significant behavior changes, new API endpoints.
- **major** (x.0.0): breaking changes, large-scale rewrites.

Default to **patch** unless the changes clearly warrant minor or major.

### 5. Draft the Progress Entry

Follow the detected format of the existing file. If no existing format is detected, use this default:

    ## YYYY-MM-DD

    #### 1. Short title of the change group (vX.Y.Z)

    **Issue**

    - Brief description of the problem or motivation, if applicable.

    **Changes**

    - Concise bullet points describing what was done technically.

    **Changed files**

    - List of changed files with repository-relative paths.

Rules:

- **Date format**: Always use `YYYY-MM-DD` (ISO 8601) as Heading 2. Example: `## 2026-03-13`.
- **Date ordering**: Newer dates go at the top, right after the file's main heading. Dates must be sorted in reverse chronological order (newest first).
- **Today's date section**:
  - Before adding an entry, scan the file for an existing `## {today's date}` heading.
  - If today's date heading **exists**, add the new numbered item at the **end** of that date's section (i.e., just before the next `## ` heading or end of file), with the next sequential number.
  - If today's date heading **does not exist**, create a new `## {today's date}` section at the top (right after the file's main heading), starting with `#### 1.`.
  - **NEVER** append an entry under a different date's heading. Each entry must belong to the date on which it was created.
- **Numbered items within a date**: Items are numbered in ascending order from top to bottom (1, 2, 3, …). When adding a new item, read existing items under today's date to determine the next number. Do not renumber existing items.
- Group related changes under a single numbered section.
- Use separate numbered sections for logically independent changes.
- Keep descriptions concise but specific enough for someone unfamiliar with the codebase.
- Include the new version tag in the first section title when version is bumped.
- Exclude auto-generated files and the progress/version files themselves from the changed files list.

### 6. Apply Changes

Edit the progress file and version file. Show the user a summary of:

- The progress entry to be added.
- The version bump (old -> new).
- The files to be committed.

### 7. Git Commit and Push

Stage **all** changes with `git add .`. The project's `.gitignore` already excludes non-project files (`.claude/`, `plans/`, secrets, etc.), so `git add .` is safe. The goal is to leave no untracked or modified files visible in the IDE after the commit.

Craft a commit message matching the project's existing style. Include the version when applicable:

    feat: Short summary of changes (vX.Y.Z)

Push to the current branch's remote tracking branch.

### 8. Verify Clean State

After the commit and push, run `git status` to confirm the working tree is clean. If any untracked or modified files remain, investigate and resolve them (add to `.gitignore` if they should not be tracked, or stage and amend the commit if they should be included).

## Important Notes

- Always read existing files before editing.
- Never stage files containing secrets (.env, credentials, tokens). If such files appear in `git status`, add them to `.gitignore` before running `git add .`.
- The project's `.gitignore` handles exclusion of non-project directories (`.claude/`, `plans/`, etc.). If new non-project files appear as untracked, add them to `.gitignore` first.
- If the user provides specific instructions about what to include in the progress entry, follow those and supplement with diff information.
- If the push fails, report the error clearly and leave the commit in place.
