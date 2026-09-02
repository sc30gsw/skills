# Vendored skills are never edited by maintenance

Project skill directories mix skills authored in the project with skills installed from upstream by the `skills` CLI (`npx skills add`). Skill maintenance edits only owned skills: a skill whose name appears under `skills` in the project's root `skills-lock.json` is vendored and is left untouched; when no lock file exists every skill is treated as owned. The CLI re-hashes nothing on `skills update` and overwrites installed directories without detecting local edits, so any fix applied to a vendored skill would silently vanish on the next update. The right channel for a vendored fix is upstream, and maintenance reports a hand-edited vendored skill instead of fixing it.

## Considered Options

- **Fix vendored skills too.** Rejected: the fix is lost on the next `skills update`, and the user is left believing it shipped.
- **Detect origin from a frontmatter field.** Rejected: no standard field exists across skill authors, so detection would be guesswork.
- **Ask the user per skill.** Rejected: the skill must work in non-interactive and cloud-agent runs.
