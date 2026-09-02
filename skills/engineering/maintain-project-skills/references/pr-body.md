# PR body template

Title: `chore: maintain project skills (<YYYY-MM-DD>)`

Every section below appears, even when its content is "none". Evidence is pasted inline, never referenced by a scratch path, because the scratch directory may not outlive the session.

---

## Outcome

`changed`. Mode: `audit` | `propagate "<change statement>"`. `<n>` owned skills covered, `<n>` vendored skills reported.

## Corrections shipped

| Skill | Class | Skill text before | Evidence | Fix | Proof |
|---|---|---|---|---|---|
| `<name>` | structural / behavioral / external-fact / shape | `<quote, file:line>` | `<path:line>` | `<one sentence>` | citation check / citation check + dry-run |

## Dry-run records

For each dry-run: the command exactly as the skill documents it, the isolation used (worktree path), the exit code, and the last lines of output.

## Unproven, held back

Corrections reverted because their dry-run could not run. Each with the missing prerequisite and the route attempted.

## Unverifiable

Citations and external-fact claims left as written. Each with the prerequisite and the route attempted.

## Product gaps

Application behavior the skills describe correctly that source shows broken. Not fixed here; needs a human decision.

## Vendored skills

| Skill | Hash status |
|---|---|
| `<name>` | match / modified / unknown |

A `modified` skill has been hand-edited. The next `npx skills update` discards those edits; move them upstream or fork the skill.

## Coverage

Skills covered, and any step skipped as `skip: <reason>`.
