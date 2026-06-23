# Failure Classifier Rationale

## Purpose
An agent that treats all failures the same will retry the wrong action, compound the error, or waste iterations. The failure type determines the correct recovery action. This skill enforces the rule: **classify before retrying**.

## Special cases

### Guessing a package name
If the agent cannot verify a package from official documentation and is about to install it:
1. Classify as **wrong assumption**.
2. Search for the official package name in documentation.
3. If documentation is unavailable, escalate to Tier 2.

### API key missing
If an API call fails with 401/403 and the agent does not have a key:
1. Classify as **user clarification needed**.
2. Do not fabricate or guess a key. Ask the user.

### Conflicting error on first run
If a command fails on the very first attempt with a non-obvious error:
1. Check whether the environment is correctly set up.
2. Check whether a prerequisite step was skipped.
