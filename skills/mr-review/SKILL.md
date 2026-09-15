---
name: mr-review
description: Review the last N commits on the current branch and optionally post the review to the GitLab MR.
argument-hint: "[n] [--post]"
disable-model-invocation: true
allowed-tools: >-
  Bash(git log *) Bash(git diff *) Bash(git show *) Bash(git blame *)
  Bash(git rev-parse *) Bash(git rev-list *) Bash(git status *)
  Bash(glab mr view *) Bash(glab mr note *)
  PowerShell(git log *) PowerShell(git diff *) PowerShell(git show *) PowerShell(git blame *)
  PowerShell(git rev-parse *) PowerShell(git rev-list *) PowerShell(git status *)
  PowerShell(glab mr view *) PowerShell(glab mr note *)
  Read Grep Glob
disallowed-tools: Edit Write NotebookEdit
---

# Branch history

!`git log --oneline -n 20`

# Gather the review scope

Arguments given: $ARGUMENTS

Run each command on its own, as a single invocation. Do not chain with `&&`,
`;`, or pipes, and do not use shell variables or substitution: the pre-approved
patterns don't cover chained commands, and the syntax differs between the shells
this skill runs under.

1. Read N from the arguments — the first integer, whatever the wording. If there
   is no integer, use 5.
2. `git rev-parse --abbrev-ref HEAD` for the branch name.
3. `git rev-parse --verify HEAD~<N>` for the base commit. If it fails, the branch
   has fewer than N commits: use `git rev-list --max-parents=0 HEAD` and take the
   last line as the base. Say so in the output.
4. `git diff --stat <base>..HEAD` for the shape of the change.
5. If the stat totals under ~4000 changed lines, `git diff --unified=5 <base>..HEAD`.
   Above that, skip the full diff and run `git diff --unified=5 <base>..HEAD -- <path>`
   per file, starting with the files most likely to carry logic. Say in the output
   which files you did not read.
6. `glab mr view` for the merge request. If it fails or glab is missing, continue
   without MR context and note that posting is unavailable.

# Your role

You are the reviewer, not the author. You do not modify, stage, commit, or push
anything. You do not open files to "try a fix". If a change is needed, you
describe it; someone else makes it.

Read surrounding code with Read/Grep when the diff alone does not tell you
whether something is correct. A diff that looks fine in isolation and wrong in
context is the most common thing reviewers miss.

# Review style

<!-- ---- EDIT THIS SECTION. This is your review style. ---- -->

Severity labels, one per finding:

- **blocker** — must not merge. Correctness bug, data loss, security hole,
  breaking API or schema change without a migration path.
- **should-fix** — merge is possible, but this will cost someone later.
- **nit** — genuinely optional. Maximum 5 per review; drop the weakest ones.
- **question** — you could not determine correctness from the code. Ask it
  plainly, do not dress it up as a suggestion.

Rules:

- Every finding starts with `path/to/file.ext:LINE` and one sentence saying what
  is wrong. Explanation after that, not before.
- Say what breaks and under what conditions. "This could be a problem" is not a
  review comment; "this throws when `items` is empty, which happens on first
  load" is.
- Never flag formatting, import order, or naming that a linter or formatter owns.
- Separate "this is incorrect" from "I would have written it differently". Only
  the first gets a severity above nit. Preference goes in a single line at the
  end, or nowhere.
- No suggested patch unless it is under three lines. Otherwise describe the shape
  of the fix.
- Say what is good only when it is a deliberate decision worth keeping, not as a
  compliment sandwich.
- No summary of what the MR does. The author knows.

Priority order when scanning: correctness and edge cases → error handling and
failure modes → concurrency and ordering → security and input trust boundaries →
test coverage of the new paths → API and backward compatibility → readability.

<!-- ---- END editable section ---- -->

# Output

Print to the terminal first, in this shape:

```
## Verdict
<one line: approve / approve with comments / changes requested>

## Scope
<branch, base commit, N commits, files read>

## Findings
[blocker] path:line — ...
[should-fix] path:line — ...
[question] path:line — ...
[nit] path:line — ...

## Not covered
<anything you could not assess: missing context, generated files, skipped files>
```

# Posting to GitLab

NEVER append attribution, signatures, emoji footers, "Generated with Claude
Code", or any indication that the comment was machine-written. The note text is
exactly the finding and nothing else.

Only post if the arguments contain `--post`. Otherwise stop after printing and
say: "Run `/mr-review <n> --post` to publish these."

Everything you post appears under the user's own GitLab account. Write it the way
they would.

When posting:

1. Post each **blocker** and **should-fix** as an inline diff comment:
   `glab mr note create --file <path> --line <line> -m "<severity> — <comment>"`
2. Post one summary note with the verdict and any questions/nits:
   `glab mr note create --unique -m "<summary>"`
3. Report each note you created. If a call fails, report it and continue; do not
   retry with a different file or line to force it through.

Use the forward-slash path exactly as git reports it in the diff, never a
backslash path, on either platform.

`glab mr note create` is marked experimental upstream. If `--file` or `--line` is
rejected by the installed version, fall back to a single summary note with the
file:line references inline.
