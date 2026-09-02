# sc30gsw/skills

[日本語版 README はこちら](./README.ja.md)

Agent skills I maintain. The headline skill is **maintain-project-skills**: an upkeep pass that keeps a project's own skills truthful when the code, the directory layout, or the outside world (a renamed model, a bumped library) moves on without them.

## Install

```bash
npx skills@latest add sc30gsw/skills --skill maintain-project-skills
```

Works with Claude Code, Codex, Cursor, and any host that reads `SKILL.md`. The CLI writes the skill into `.agents/skills/` and links it into your agent's skill directory. To pick an agent explicitly, add `-a claude-code` (or `codex`, `cursor`, and so on).

## maintain-project-skills

A skill is prose about a codebase, and prose does not fail tests when the codebase moves. This skill re-reads every skill your project owns against the code it describes, fixes what has gone stale, confirms each fix, and delivers the confirmed ones as a single pull request.

### Two jobs

```
/maintain-project-skills
```

**Review.** Every owned skill, every kind of mismatch: paths and commands that no longer exist, described behavior that the code contradicts, and claims about the outside world (model ids, library versions) that can no longer be checked.

```
/maintain-project-skills Fable 5 → Fable 5.1
```

**Apply one change.** You name the change in plain words. The skill traces only that change through the owned skills and fixes what it touches. Other examples: `src/lib moved to packages/core`, `--legacy flag removed`.

### What a run does

1. Lists every project skill and splits them into owned and third-party, using `skills-lock.json` when present (`scripts/list-skills.sh`).
2. Checks every link, path, command, identifier, and slash command each owned skill mentions (`scripts/check-references.sh`).
3. Sends one read-only inspector per owned skill to read it against the code and report mismatches with evidence.
4. Makes the fixes and confirms them: the reference check must pass, and any script a skill ships is run as documented inside a throwaway git worktree.
5. Delivers one PR, one commit per skill, with all evidence pasted into the PR body.

### What it never does

- Edit product code. A skill that describes behavior the app no longer has is either stale (fix the skill) or evidence of an app regression (report it, do not reword the skill to hide it).
- Edit a third-party skill. Skills installed by `npx skills add` are overwritten on the next `npx skills update`, so the run reports hand-edits and leaves them alone.
- Rewrite a model id or library version from memory. Outside claims are changed only when a documentation lookup confirms the value or your change statement names it.
- Deliver an unconfirmed fix. If a trial run cannot happen in the current environment, the fix is reverted and listed under "Unconfirmed, reverted".

### Results

Every run ends in exactly one of three results and says which.

| Result | Meaning |
|---|---|
| `current` | Every owned skill reviewed, nothing to fix. No branch, no PR. |
| `updated` | One PR of confirmed fixes. Unconfirmed fixes and app regressions are described in the PR body, not applied. |
| `halted` | The review could not finish or a fix could not be delivered safely. The cause is named. |

### In cloud agents

Cursor Cloud Agents, Claude Code on the web, and similar sandboxes are handled by probing rather than by detecting the host. Worktree isolation is tried outside the repository first, then inside it under `.maintain-trial` (excluded from git), then skipped with the affected fixes reverted. When `gh` is not authenticated the run stops at a committed branch and lets the platform open the PR. Evidence lives in the PR body, not in scratch space that disappears with the session.

### Design notes

The vocabulary the skill uses (owned skill, mismatch, reference, confirmation, app regression, and so on) is pinned in [CONTEXT.md](./CONTEXT.md). Two decisions are recorded as ADRs in [docs/adr](./docs/adr): third-party skills are never edited, and outside claims are never rewritten without a documentary source.

## Also in this repository

`.agents/skills/` holds skills installed from [mattpocock/skills](https://github.com/mattpocock/skills) for my own use, tracked in `skills-lock.json`. Use `--skill` to install only what you want.

## Credits

The idea of a recurring upkeep pass for agent-facing docs comes from the verification skills in the [pstack](https://github.com/cursor/plugins/tree/main/pstack) plugin by Lauren Tan. The design here, its vocabulary, and its scripts are written independently for the general case of any project skill.

## License

[MIT](./LICENSE)
