# Skill Maintenance

The vocabulary for keeping a project's agent skills truthful as the project around them changes. It exists because a skill is prose about a codebase, and prose does not fail tests when the codebase moves.

## Language

### Skills

**Project skill**:
Any skill installed in a project's skill directories, whoever wrote it.
_Avoid_: local skill, repo skill

**Owned skill**:
A project skill authored in the project itself and therefore safe to edit in place.
_Avoid_: custom skill, own skill, user skill

**Vendored skill**:
A project skill installed from an upstream source and tracked by a lock file; edits to it are overwritten on the next update, so it is never edited by maintenance.
_Avoid_: installed skill, third-party skill, external skill, upstream skill

### Drift

**Drift**:
A statement in an owned skill that no longer matches what it describes.
_Avoid_: staleness, rot, outdated content

**Structural drift**:
Drift where a cited path, glob, command, symbol, or sibling file no longer exists.
_Avoid_: broken reference, dead link

**Behavioral drift**:
Drift where a described behavior or procedure disagrees with the source code.
_Avoid_: logic drift, feature drift

**External-fact drift**:
Drift in a claim about something outside the repository, such as a model identifier, a library version, or an API name.
_Avoid_: version drift, dependency drift

**Product gap**:
Behavior the skill describes correctly that the application itself no longer performs; reported, never papered over in the skill.
_Avoid_: bug, regression, app drift

### Runs

**Audit**:
A run with no change statement that scans every owned skill for every class of drift.
_Avoid_: scan, review, check

**Propagate**:
A run given a change statement that finds and fixes only that change's impact across owned skills.
_Avoid_: apply, sync, migrate

**Change statement**:
The description a user supplies to a propagate run naming what changed, from what to what.
_Avoid_: change request, diff description, event

**Preflight**:
The read-only opening check of a run that confirms git, enumerates project skills, reads the lock, and refuses to start over uncommitted edits in an owned skill.
_Avoid_: doctor, health check, setup

**Coordinator**:
The agent running a maintenance pass; the only party that edits files or ships.
_Avoid_: main agent, parent, orchestrator

**Source wave**:
The phase of a run in which one read-only subagent per owned skill explains that skill against the source and reports drift candidates.
_Avoid_: scan phase, analysis phase

**Baseline**:
The commit at which an owned skill was last modified; churn is measured from here.
_Avoid_: last audit, checkpoint, marker

**Churn**:
Changes to the repository since a baseline, excluding the skill directories themselves.
_Avoid_: diff, delta, recent changes

### Proof

**Citation**:
A reference in a skill body to something checkable in the repository: a path, glob, command, symbol, or sibling file. Ends in exactly one state: resolved, drift, or unverifiable.
_Avoid_: reference, mention, link

**Unverifiable**:
The state of a citation or external fact that cannot be judged because a prerequisite is missing, always named with the prerequisite and the route attempted.
_Avoid_: unknown, skipped, unchecked

**Orphan**:
A file inside a skill directory that no Markdown in that skill refers to.
_Avoid_: dead file, unused file, stray file

**Citation check**:
Proof that every citation in a skill resolves.
_Avoid_: link check, path check

**Dry-run**:
Proof that a corrected skill's executable steps still run, performed in isolation from the real working tree.
_Avoid_: smoke test, live pass, test run

**Proof**:
Evidence that a correction is right, required before it ships.
_Avoid_: verification, validation, confirmation

**Unproven correction**:
A correction whose only available proof was a dry-run that could not run in the current environment; reported and held back, never shipped.
_Avoid_: unverified fix, pending fix, skipped fix

**Hand-edited vendored skill**:
A vendored skill whose current contents no longer match the hash recorded in the lock file; reported because the next update will discard the edits.
_Avoid_: modified skill, dirty skill, patched skill

### Outcomes

**Clean**:
The outcome where every owned skill was covered and nothing needs shipping.

**Changed**:
The outcome where proven corrections ship as a single pull request.

**Blocked**:
The outcome where coverage could not finish or a proven fix could not ship safely, with the blocker named.
_Avoid_: failed, aborted, incomplete
