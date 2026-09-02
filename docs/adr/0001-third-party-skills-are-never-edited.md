# Third-party skills are never edited by maintenance

Project skill directories mix skills authored in the project with skills installed from upstream by the `skills` CLI (`npx skills add`). Skill maintenance edits only owned skills: a skill whose directory name appears under `skills` in the project's root `skills-lock.json` is third-party and is left untouched; when no lock file exists every skill is treated as owned. The CLI overwrites installed directories on `skills update` without detecting local edits, so any fix applied to a third-party skill would silently vanish on the next update. The right channel for such a fix is upstream, and maintenance reports a hand-edited third-party skill instead of fixing it.

## Considered Options

- **Fix third-party skills too.** Rejected: the fix is lost on the next `skills update`, and the user is left believing it shipped.
- **Detect origin from a frontmatter field.** Rejected: no standard field exists across skill authors, so detection would be guesswork.
- **Ask the user per skill.** Rejected: the skill must work in non-interactive and cloud-agent runs.
