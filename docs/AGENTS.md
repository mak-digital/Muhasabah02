# Muhasabah — Agent Operating Instructions

These instructions apply to any coding agent working in this repository.

## 1. Authority order

When instructions conflict, use this order:

1. explicit current user/task instruction
2. `docs/accepted_product_state.md` when present
3. `PRODUCT_SPEC.md`
4. `docs/product_guardrails.md` when present
5. this `AGENTS.md`
6. established architecture and passing tests

A current task changes accepted product semantics only when it says so explicitly.

Do not treat implementation accidents as product decisions.

## 2. Environment adaptation

Use the tools available in your environment: shell, filesystem, Git, editor APIs, emulator/device controls, test runners, or equivalents.

If this repository names a command/tool that is unavailable, perform the equivalent operation with available tooling. Do not omit a required validation merely because the interface differs.

If a capability is genuinely unavailable, use the closest reliable substitute and document the limitation.

## 3. Repository recovery before editing

Inspect first:

- repository root
- `git status`
- branch and HEAD
- recent commits
- dirty/staged/untracked files
- project documentation
- dependency manifest
- source/test layout

Never reset, clean, revert, discard, or overwrite unknown or accepted user work.

If the tree is dirty, determine whether it contains intentional in-progress/accepted work before changing it.

## 4. Baseline validation

When practical, establish a baseline with the project-equivalent of:

```bash
dart format .
flutter analyze
flutter test --reporter compact
flutter build apk --debug
git diff --check
```

If the baseline fails because the repository is mid-implementation, inspect and repair rather than reverting blindly.

Track exact test totals and skipped tests.

## 5. Engineering rules

- Preserve sound existing architecture.
- Prefer the smallest coherent change.
- Do not introduce speculative frameworks.
- Do not opportunistically refactor unrelated code.
- Do not add dependencies without a concrete need.
- Keep domain logic out of presentation code where practical.
- Keep persistence schema changes explicit and backward-compatible.
- Treat tests as executable specification, but do not weaken a valid guardrail merely to obtain green tests.
- When fixing a defect, add a regression test where practical.

## 6. Product guardrails

Always preserve:

- RECORD → REFLECT → REVIEW → RECOGNISE → PONDER → RESPOND
- SEE → PONDER → EXPLORE
- ENGAGEMENT VISIBILITY ≠ ENGAGEMENT JUDGMENT
- MISSING / UNANSWERED ≠ NEGATIVE
- USER-OWNED ≠ APP-PRESCRIBED
- PROVENANCE ≠ CAUSALITY

Never add spiritual scores, faith rankings, automated religious remedies, pressure-based streaks, or success/failure interpretations of worship.

## 7. Privacy

Do not add telemetry, remote analytics, cloud AI, or private-content logging.

Never print or log Response text, journal text, gratitude text, personal-reflection text, contextual free text, or serialized private records.

Use synthetic data in tests and emulator verification.

## 8. UI and accessibility

The target is a modern production-quality Flutter application.

Use visual hierarchy, responsive layout, light/dark themes, meaningful colour, accessible contrast, scalable text, and non-colour state redundancy.

Do not use traffic-light colours as spiritual judgment.

Verify narrow phones and 1.0 / 1.3 / 1.5 text scaling.

No overflow is acceptable in release-critical flows.

## 9. Autonomous execution

For autonomous/full-build tasks, do not ask for approval after each internal milestone.

Internally:

1. inspect
2. plan
3. implement
4. add focused tests
5. run focused tests
6. run full validation at appropriate boundaries
7. inspect diff
8. fix defects
9. continue

Stop for the user only when blocked by a genuinely external prerequisite that cannot be solved locally.

Examples:

- missing production signing credentials
- inaccessible required external account/service
- unrecoverable source corruption
- unavailable mandatory toolchain with no workable substitute

Do not stop merely because a design choice is mildly ambiguous. Choose the smallest option that best preserves product guardrails.

## 10. Git safety

Never:

- force-push
- rewrite history without explicit authorization
- discard unknown user work
- commit secrets/generated junk

For autonomous work, local milestone commits are allowed when a coherent milestone is fully green, unless the user explicitly forbids commits.

Use descriptive commit subjects.

A configured remote may be pushed only when normal push is explicitly allowed by the task/environment. Never force-push.

## 11. Runtime validation

Widget tests do not replace actual emulator/device checks for release-critical work.

Exercise real flows when an emulator/device is available, including persistence across restart, navigation, text scaling, light/dark mode, long text, multilingual text, and privacy/log inspection.

If direct device input for a script/language is unreliable, use automated widget coverage plus real rendering checks and report the limitation accurately.

## 12. Completion standard

Do not declare completion merely because code compiles.

A release candidate requires, as applicable:

- formatting clean
- analyzer clean
- full tests passing
- no unexpected skips
- debug build passing
- release build/artifact produced when possible
- diff check clean
- runtime smoke/integration verification
- accessibility checks
- privacy checks
- documentation updated
- known limitations disclosed

## 13. Reporting

For autonomous work, produce one concise final report rather than repeated approval requests.

Include:

- scope completed
- architecture changes
- files created/modified/deleted
- schema/persistence changes
- UX changes
- test arithmetic and final totals
- runtime verification
- accessibility/privacy audit
- build artifacts
- Git branch/HEAD/status
- deviations/blockers
- known limitations
- final completion decision
