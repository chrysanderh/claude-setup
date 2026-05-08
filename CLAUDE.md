# Global Agent Guidelines

These guidelines apply to **all workspaces** and interactions.

## I. Environment & Terminal Operations (Universal Priority)

**CRITICAL**: Before running any Python scripts, tests, or installing packages via the terminal, you **MUST** ensure the correct environment is active.

### 1. Execution Strategy
1. **Check for Local Venv (Priority)**:
   - Look for a directory named `.venv`, `venv`, or `env` in the project root. The user normally uses uv.
   - *Action*: If found, activate using `source .venv/bin/activate` or use `uv run` (adjust path as needed).
2. **Check for Conda (Fallback)**:
   - If no local venv exists, infer the Conda environment name (often matches project folder name, course number like `144`, or project title).
   - *Action*: Run `conda activate <inferred_name>`. If unsure, run `conda env list`.

### 2. Environment Verification
- **Prompt Check**: Always check the current terminal prompt (e.g., `(base)` vs `(densityNO)`) before executing. If the prompt implies the wrong environment, activate the correct one immediately.
- **Path Check**: If uncertain, run `which python` to verify the active interpreter path.

### 3. Code Verification
- **Hooks & Tests**: Always run `./.git/hooks/pre-commit`. If the hook is empty or does not exist, you must run the project's tests manually to ensure code integrity.

---

## II. Coding & Output Standards (Context-Dependent)

**Check the Context**: Is the user asking for help with a **Homework/Problem Set** or a **Professional/Research Project**?

### Context A: Professional, Research & Default
*Trigger: Default case (Research, Dev, Engineering).*

- **Goal**: High-quality Industry Standard Engineering.
- **Code Style**:
  - **Structure**: Modular, robust, and scalable. Use classes, functions, and proper abstractions.
  - **Commenting**: Use comments according to industry standards. You may use comments during the drafting phase for internal reasoning or step tracking, but you must clean them up before final delivery. Final comments should be minimal, focusing on the "why" rather than the "how," and should follow standard docstring practices.
  - **Best Practices**:
    - Use Type Hinting (`typing`) where helpful.
    - **Error handling**: Only catch exceptions you can concretely handle. Never silently swallow exceptions. If catching to add context, always re-raise (`raise ... from e`). If catching at a boundary for logging, log then re-raise (`raise`). A bare `except: pass` or catching broadly and continuing as if nothing happened is always wrong — it creates silent bugs that are harder to debug than the original exception.
    - Follow PEP 8 standards.
  - **Performance**: Optimize for speed and memory efficiency (especially for ML/Data tasks).
  - **Git / Commits**:
    - **Convention**: Use Conventional Commits (`feat:`, `fix:`, `chore:`, etc.).
    - **Casing**: **Strictly use lowercase** for the subject description (e.g., `feat: add new layer`, NOT `feat: Add new layer`).
    - **Co-authors**: **Never add Claude as co-author in commits.** Do not include `Co-Authored-By: Claude ...` lines in any commit messages. Always commit with only human authors.
  - **Test Organization (REQUIRED)**:
    - **MUST**: Place all test files in a `tests/` directory that **exactly mirrors** the `src/` structure.
      - `src/utils/helper.py` → `tests/utils/test_helper.py`
      - `src/models/user.py` → `tests/models/test_user.py`
      - `src/api/endpoints/auth.py` → `tests/api/endpoints/test_auth.py`
    - **File Naming**: All test files **must** be prefixed with `test_` (e.g., `test_helper.py`, `test_auth.py`).
    - **Directory Structure**: Create directories in `tests/` to match `src/` hierarchy. Do not flatten test files into a single directory.
    - **Violations**: If you create test files outside this structure, fix the organization before committing. Do not merge PRs or commit code with disorganized tests.
- **Writing Tone**:
  - **Tone**: Academic (ML, Physics or Chemistry papers at high quality journals), technical, and concise. Avoid the "AI accent" (e.g., avoid "It is worth noting," "In conclusion," "Let's delve into," or "I have successfully..."). The quality should match a seasoned author published in Nature or Science.
  - **Vocabulary**: Use simple but precise technical language. Avoid overly complex synonyms when simpler ones work (e.g., use "use" instead of "utilize," "fix" instead of "rectify," "show" instead of "demonstrate").
  - **Style**: Focus on direct technical communication. Use active voice where appropriate for clarity but maintain the rigorous objectivity expected in top-tier journals.
  - **Punctuation**: Never use the EM dash.
  - **Brevity**: Be concise and keep things short. Avoid bloat at all costs. Keep things as short as possible and only as long as strictly necessary.

---

## III. Session Reports

At the end of every working session, generate a timestamped summary report
and save it to Google Drive.

### Filename format
`YYYYMMDD_HHMMSS_session_topic.md`

- Use the current local date and time at the moment the report is written
- `session_topic` is a short description of what the session was about
- Use lowercase, words separated by underscores, no leading underscore
- Aim for 3–6 words

Example: `20260508_143022_set_up_claude_settings_repo.md`

### Where to save
`$AGENT_OUTPUT_DIR/reports/`

### What to include
1. **Session topic** — one-line summary
2. **Date and time** — when the session ran
3. **Goal** — what the user was trying to accomplish
4. **Actions taken** — bulleted list of what was actually done
5. **Files changed** — paths of any files created or modified
6. **Commands run** — non-trivial shell commands executed
7. **Outcomes** — what worked, what didn't, what's left
8. **Next steps** — open items or follow-ups, if any

Keep the report concise but specific enough to be useful months later.
Skip sections that don't apply to the session.

### When to generate
Generate the report when the user signals the session is wrapping up
(e.g. "we're done", "thanks, that's all", "wrap this up"), or when
explicitly asked for a report. Don't generate one for every short exchange.

### Transcript sync
After writing the report, also sync the session transcripts by running
the platform-appropriate script:

- Windows: `& $HOME\.claude\scripts\sync-transcripts.ps1`
- macOS/Linux: `~/.claude/scripts/sync-transcripts.sh`

This copies all session JSONL transcripts to `$AGENT_OUTPUT_DIR/transcripts/`
with timestamps prefixed to the filename.