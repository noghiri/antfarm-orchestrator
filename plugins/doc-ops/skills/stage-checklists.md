# Stage Completion Checklists

Every stage gate must be fully checked before the orchestrator hands off to the next stage. Unchecked items are hard blocks. Post this checklist as a comment on the relevant GitHub Issue or PR before closing the gate.

---

## System Design Stage Gate

Run before transitioning from System Design to Feature Registry authoring.

- [ ] `project-charter.md` is `status: approved`
- [ ] `system-design.md` is `status: approved`
- [ ] `validate-doc` passes for both documents (no schema errors, no placeholders, no open questions)
- [ ] `check-staleness` shows system-design is not stale relative to project-charter
- [ ] Human has explicitly approved both documents in this session
- [ ] Both documents are committed on the `planning` branch

---

## Feature Registry Stage Gate

Run before transitioning from Feature Registry to Feature Design.

- [ ] `feature-registry.md` is `status: approved`
- [ ] `validate-doc` passes for feature-registry
- [ ] Every feature in the registry has: ID, name, status, priority, depends_on
- [ ] Dependency graph has been computed and shown to the human (no cycles)
- [ ] Human has approved the feature list and dependency order
- [ ] Feature registry is committed on the `planning` branch

---

## Feature Design Stage Gate

Run before marking a feature design approved and creating work unit GitHub Issues.

- [ ] `feature-design.md` is `status: approved`
- [ ] `validate-doc` passes (no schema errors, no placeholders, no open questions)
- [ ] `depends_on_decisions` is empty or all listed decisions are resolved
- [ ] Output Contracts section is fully specified (no placeholders)
- [ ] Contract Tests section lists at least one test per contract
- [ ] Contract test files are committed on the feature branch
- [ ] Human has reviewed and approved the feature design in this session
- [ ] GitHub Issues have been created for all work units in this feature
- [ ] Work unit issues have correct labels (`work-unit`, `feature/F00N`, `status/planned`)

---

## Work Unit Completion Gate (Builder)

Run before creating the PR and moving the work unit to `status/review`.

- [ ] All tasks in the task list are `completed`
- [ ] `run-build` passes
- [ ] `run-tests` passes (all tests, including new tests for this work unit)
- [ ] `run-lint` passes with no errors
- [ ] All acceptance criteria from the work unit spec are met
- [ ] No placeholder text or TODO comments in implementation
- [ ] Colocated tests are present for all new code
- [ ] Dry-run is implemented for any destructive/side-effecting operations
- [ ] PR is created with correct labels and links to the work unit issue
- [ ] Work unit issue updated to `status/review`

---

## Work Unit Completion Gate (Reviewer)

Run before approving the PR and marking the work unit `status/complete`.

- [ ] Implementation matches the work unit spec (all acceptance criteria checked)
- [ ] Tests cover the acceptance criteria (not just internal logic)
- [ ] Code follows house style (coding-principles, defense-in-depth, dry-run)
- [ ] No security issues: no injection vulnerabilities, no hardcoded secrets, least privilege honored
- [ ] Dry-run is correctly implemented where required
- [ ] If this is the last work unit for a feature: contract tests pass (`run-contract-tests`)
- [ ] CI passes (if `ci_required: true`)
- [ ] PR is approved
- [ ] Review result posted as comment on work unit issue
- [ ] Work unit issue updated to `status/complete`
- [ ] Label cleanup performed (remove transient labels)
- [ ] Work unit issue closed

---

## Feature Integration Gate

Run after all work units for a feature are `status/complete` and before merging the feature branch.

- [ ] All work unit issues for this feature are closed (`status/complete`)
- [ ] `run-contract-tests` passes for the feature
- [ ] Integration tests pass (if applicable)
- [ ] CI passes on the feature branch (if `ci_required: true`)
- [ ] Feature branch PR is created targeting the base branch
- [ ] Human review of the feature integration PR (if required by project config)
