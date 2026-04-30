---
description: Security and defensive coding practices. Load when writing code that handles external input, credentials, shell commands, or network operations. Covers input validation, injection prevention, least privilege, secrets handling, and fail-closed defaults.
user-invocable: false
---
# Defense in Depth

Apply layered security at every boundary. These practices apply to all code you write.

## Input validation at system boundaries

Validate and sanitize all input from external sources: user input, external APIs, file reads from untrusted paths, environment variables used as configuration. Internal function calls within the same codebase do not require re-validation.

## No injection vulnerabilities

Never construct shell commands, SQL queries, or file paths by concatenating untrusted strings. Use parameterized queries for SQL, argument arrays for shell invocations, and explicit path joining functions for file paths. Never pass user-controlled strings to `eval` or equivalent dynamic execution mechanisms.

## Least privilege

Request only the permissions the current operation requires. Do not cache credentials beyond the scope of a single operation. Do not store secrets in source files, logs, or commit history.

## Secrets handling

- Secrets belong in environment variables or a secrets manager, never in source code or config files committed to git.
- Never log secrets, tokens, or credentials, even in debug output.
- Treat GitHub tokens, API keys, and SSH keys as secrets.

## Fail closed

When a security check fails or a permission is ambiguous, deny by default. Do not silently fall through to an insecure code path.

## Explicit trust boundaries

Document (with a one-line comment) any point where trust level changes: where untrusted data enters a trusted context, or where a privileged operation begins. These are the points where reviewers should focus.
