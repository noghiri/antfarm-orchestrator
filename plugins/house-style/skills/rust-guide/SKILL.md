---
description: Rust language coding standards. Load when writing Rust code. Covers error handling, ownership, async, naming conventions, module structure, testing, dependencies, and Clippy compliance.
user-invocable: false
---
# Rust Language Guide

These guidelines apply when writing Rust code in this project. They supplement the general coding principles.

## Error handling

Use `Result<T, E>` for all fallible operations. Prefer specific error types over `Box<dyn Error>` in library code. Use `anyhow` for application-level error propagation where context matters more than type. Use `thiserror` for defining library error types.

Never use `.unwrap()` in production paths. Use `.expect("reason")` only when the invariant is documented and guaranteed by the call site. In test code, `.unwrap()` is acceptable.

## Ownership and borrowing

Prefer borrows over clones. Clone only when ownership transfer is necessary and the cost is acceptable. Document with a comment if a clone exists for a non-obvious reason.

## Async

Use `tokio` as the async runtime unless the project config specifies otherwise. Mark the minimum required surface as `async`. Avoid `async` on functions that are trivially synchronous.

## Naming conventions

Follow Rust's standard naming conventions:
- `snake_case` for functions, variables, modules
- `CamelCase` for types, traits, enums
- `SCREAMING_SNAKE_CASE` for constants
- `snake_case` for crate names (with hyphens in `Cargo.toml`, underscores in code)

## Module structure

Keep modules small and single-purpose. Use `pub(crate)` to restrict visibility to the crate unless items are part of the public API. Avoid `pub use` re-exports unless building a flat public API surface.

## Testing

Use `#[cfg(test)]` modules colocated at the bottom of each source file. Use `#[test]` for unit tests. Use `#[tokio::test]` for async tests. Prefer deterministic tests — avoid time-dependent or order-dependent behavior.

## Dependencies

Add dependencies deliberately. Every new `Cargo.toml` entry must have a clear justification. Prefer the standard library when it suffices. Pin to specific minor versions in application `Cargo.toml`; use SemVer ranges in library `Cargo.toml`.

## Clippy

All code must pass `cargo clippy -- -D warnings` with no suppressions unless a specific lint is demonstrably wrong for the use case. Document any `#[allow(...)]` with a comment explaining why.

---

## Attribution

This skill is derived from the `howto-code-in-rust` skill in [ed3d-plugins](https://github.com/ed3dai/ed3d-plugins) by Ed Ropple and contributors, and is licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/). Changes were made: content was condensed and adapted to this project's toolchain and conventions.
