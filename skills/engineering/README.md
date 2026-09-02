# Engineering

Skills for keeping a codebase and the agent tooling around it honest.

## User-invoked

Reachable only when you type them (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false` in `agents/openai.yaml`).

- **[maintain-project-skills](./maintain-project-skills/SKILL.md)**: Upkeep pass for the skills a project owns. Reads every owned skill against source, checks every cited path and command, dry-runs shipped scripts in an isolated worktree, and ships at most one PR of proven corrections. With an argument, propagates one named change across every owned skill.
