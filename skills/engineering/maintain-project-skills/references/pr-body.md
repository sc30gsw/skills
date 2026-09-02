# PR body template

Title: `chore: maintain project skills (<YYYY-MM-DD>)`

Every section below appears, even when its content is "none". Evidence is pasted inline, never referenced by a scratch path, because scratch space may not outlive the session.

---

## Result

`updated`. Job: `review` | `apply "<change statement>"`. `<n>` owned skills reviewed, `<n>` third-party skills listed.

## Fixes delivered

| Skill | Kind | Text before | Evidence | Fix | Confirmed by |
|---|---|---|---|---|---|
| `<name>` | broken reference / behavior mismatch / outside claim / shape | `<quote, file:line>` | `<path:line>` | `<one sentence>` | reference check / reference check + trial run |

## Trial runs

For each trial run: the command exactly as the skill documents it, the worktree used, the exit code, and the last lines of output.

## Unconfirmed, reverted

Fixes reverted because their trial run could not happen. Each with the missing prerequisite and the route tried.

## Unverifiable

References and outside claims left as written. Each with the prerequisite and the route tried.

## App regressions

Application behavior the skills describe correctly that the code shows to be broken. Not repaired here; needs a human decision.

## Third-party skills

| Skill | Hash status |
|---|---|
| `<name>` | match / modified / unknown |

A `modified` skill has been hand-edited. The next `npx skills update` discards those edits; move them upstream or fork the skill.

## Coverage

Skills reviewed, and any phase skipped with its reason.
