# Engineering

Skills for keeping a codebase and the agent tooling around it honest.

## User-invoked

Reachable only when you type them (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false` in `agents/openai.yaml`).

- **[maintain-project-skills](./maintain-project-skills/SKILL.md)**: Upkeep pass for the skills a project owns. Re-reads each owned skill against the code, checks every path and command it mentions, runs shipped scripts in a throwaway worktree, and delivers confirmed fixes as a single PR. With an argument, applies one named change across every owned skill.
