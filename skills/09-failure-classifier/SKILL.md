---
name: failure-classifier
description: Use immediately after any task failure — test failure, command failure, tool error, permission error, missing file, or API error — before retrying. Classifies the failure type so the correct recovery action is taken. Prevents the agent from repeating the same wrong fix.
---
# Failure Classifier

## Purpose

An agent that treats all failures the same will retry the wrong action, compound the error, or waste iterations. The failure type determines the correct recovery action. This skill enforces the rule: **classify before retrying**.

---

## Classification table

| Failure type | Key signal | Recovery action | Escalation |
|---|---|---|---|
| **Syntax failure** | Parse error, SyntaxError, linting error | Implementer fixes locally | None unless 3 retries fail |
| **Test failure** | Test assertion failed, expected vs actual mismatch | Implementer debugs logic | Tier 2 if test design is ambiguous |
| **Dependency failure** | `ModuleNotFoundError`, `Cannot find module`, `command not found` | Install missing package | Tier 2 if package name is unverified |
| **Permission failure** | `Permission denied`, `EACCES`, `403`, `sudo required` | Do not retry. Escalate immediately | Tier 2 or Tier 3 depending on scope |
| **Missing file** | `FileNotFoundError`, `ENOENT`, `No such file or directory` | Check if file was supposed to exist. Create or ask. | Tier 2 if file is outside project scope |
| **Wrong assumption** | Command runs but output is unexpected. Package exists but has wrong API. | Stop. Re-read Mission Anchor. Replan. | Tier 2 if user assumption was baked in |
| **External service failure** | API timeout, 503, rate limit, DNS failure | Retry once with backoff. Then escalate. | Tier 2 after 1 retry |
| **User clarification needed** | Ambiguous intent, multiple valid interpretations, conflicting instructions | Do not guess. Ask. | Tier 2 always |
| **Irreversible action attempted** | rm -rf, force push, production deploy, firmware flash | Stop immediately. Do not execute. | Tier 3 always |

---

## Procedure

### 1. Read the error message precisely

Do not paraphrase. Copy the exact error text. Identify:

- What command or call produced it
- What line or file it points to
- Whether it is deterministic (will always fail this way) or transient (network, race condition)

### 2. Match to the classification table

Select the failure type. If two types apply, use the one with the higher escalation tier.

### 3. Apply the recovery action

Follow the recovery action from the table. Do not modify the code before classifying.

### 4. Log the failure

Append to `.agents/COMMAND_LOG.md`:

```markdown
### [timestamp] Failure classified

Command: <exact command>
Error: <exact error message>
Type: <failure type>
Recovery action: <what will be done>
Escalation: <None | Tier 1 | Tier 2 | Tier 3>
```

### 5. Enforce the retry limit

- Same failure type, same root cause: **max 2 retries**.
- After 2 retries with no different approach: escalate to Tier 2.
- After 3 retries total (any approach): escalate to Tier 3.
- **Never retry a permission failure or an irreversible action.** Escalate immediately.

---

## Integration with other components

- **Loop Executor**: Calls this skill before every retry.
- **Scope Drift Detector**: Receives "repeated failure signal" from this classifier.
- **Human Escalation Protocol**: Receives escalation requests from this classifier.
- **Checkpoint & Rollback**: Called when a wrong assumption was already acted on.

---

## Special cases

### Guessing a package name

If the agent cannot verify a package from official documentation and is about to install it:

1. Classify as **wrong assumption** (the assumption is that the package exists).
2. Do not run the install command.
3. Search for the official package name in documentation.
4. If documentation is unavailable, escalate to Tier 2 and ask the user.

### API key missing

If an API call fails with 401/403 and the agent does not have a key:

1. Classify as **user clarification needed**.
2. Do not fabricate or guess a key.
3. Ask the user to provide the key via environment variable.
4. Do not log or echo the key once provided.

### Conflicting error on first run

If a command fails on the very first attempt with a non-obvious error:

1. Check whether the environment is correctly set up (dependency-env-harness).
2. Check whether a prerequisite step was skipped.
3. Do not assume the code is wrong before verifying the environment.

---

## Output format

When classifying a failure, produce:

```markdown
## Failure Classification

Command: <exact command>
Error: <exact error message>

Type: <failure type>
Deterministic: Yes / No / Unknown
Retry limit reached: Yes / No (attempt <N> of 2)

Recovery action: <what will happen next>
Escalation: <None | Tier 2 — reason | Tier 3 — reason>
```
