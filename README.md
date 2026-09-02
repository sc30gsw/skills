# sc30gsw/skills

[日本語版 README はこちら](./README.ja.md)

Agent skills I maintain. The headline skill is **maintain-project-skills**: an upkeep pass that keeps a project's own skills truthful when the code, the directory layout, or the outside world (a renamed model, a bumped library) moves on without them.

## Install

```bash
npx skills@latest add sc30gsw/skills --skill maintain-project-skills
```

Works with Claude Code, Codex, Cursor, and any host that reads `SKILL.md`. The CLI writes the skill into `.agents/skills/` and links it into your agent's skill directory. To pick an agent explicitly, add `-a claude-code` (or `codex`, `cursor`, and so on).

## maintain-project-skills

A skill is prose about a codebase, and prose does not fail tests when the codebase moves. This skill reads every skill your project owns against the source it describes, proves each correction, and ships the proven ones as one pull request.

### Two modes

```
/maintain-project-skills
```

**Audit.** Every owned skill, every class of drift: cited paths and commands that no longer exist, described behavior that disagrees with source, and claims about the outside world (model ids, library versions) that can no longer be verified.

```
/maintain-project-skills Fable 5 → Fable 5.1
```

**Propagate.** You name one change in plain words. The skill finds and fixes only that change's impact across owned skills. Other examples: `src/lib moved to packages/core`, `--legacy flag removed`.

### What a run does

1. Lists every project skill and splits them into owned and vendored, using `skills-lock.json` when present (`scripts/list-skills.sh`).
2. Checks every cited link, path, command, and identifier in each owned skill (`scripts/check-citations.sh`).
3. Launches one read-only subagent per owned skill to read it against source and report drift with citations.
4. Applies corrections and proves them: the citation check must pass, and any script a skill ships is dry-run in an isolated git worktree.
5. Ships one PR, one commit per skill, with all evidence pasted into the PR body.

### What it never does

- Edit product code. A skill that describes behavior the app no longer performs is either stale (fix the skill) or a product regression (report it, do not paper over it).
- Edit a vendored skill. Skills installed by `npx skills add` are overwritten on the next `npx skills update`, so the pass reports hand-edits and leaves them alone.
- Rewrite a model id or library version from memory. Outside-world facts are corrected only when a documentation lookup confirms the value or your change statement names it.
- Ship an unproven correction. If a dry-run cannot run in the current environment, the correction is reverted and listed under "Unproven, held back".

### Outcomes

Every run ends in exactly one of three states and says which.

| Outcome | Meaning |
|---|---|
| `clean` | Every owned skill covered, nothing to ship. No branch, no PR. |
| `changed` | One PR of proven corrections. Unproven corrections and product gaps are listed in the PR body, not applied. |
| `blocked` | Coverage could not finish or a fix could not ship safely. The blocker is named. |

### In cloud agents

Cursor Cloud Agents, Claude Code on the web, and similar sandboxes are supported by probing rather than by detecting the host. Worktree isolation is tried outside the repository first, then inside it under `.maintain-dryrun` (excluded from git), then skipped with the affected corrections held back. When `gh` is not authenticated the pass stops at a committed branch and lets the platform open the PR. Evidence lives in the PR body, not in a scratch directory that disappears with the session.

### Design notes

The vocabulary the skill uses (owned skill, drift, citation, proof, product gap, and so on) is pinned in [CONTEXT.md](./CONTEXT.md). Two decisions are recorded as ADRs in [docs/adr](./docs/adr): vendored skills are never edited, and external facts are never rewritten without a documentary source.

## Also in this repository

`.agents/skills/` holds skills vendored from [mattpocock/skills](https://github.com/mattpocock/skills) for my own use, tracked in `skills-lock.json`. Use `--skill` to install only what you want.

## Credits

maintain-project-skills descends from `maintain-verification-skill` in the [pstack](https://github.com/cursor/plugins/tree/main/pstack) plugin by Lauren Tan. The verification pair proves a product by driving it; this skill proves a skill by reading it against source and running what it ships.

## License

[MIT](./LICENSE)
