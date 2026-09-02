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

**Third-party skill**:
A project skill installed from an upstream source and tracked by a lock file; the next update overwrites it, so maintenance never edits it.
_Avoid_: vendored skill, installed skill, external skill, upstream skill

**Hand-edited third-party skill**:
A third-party skill whose current contents no longer match the hash recorded in the lock file; reported because the next update will discard the edits.
_Avoid_: modified skill, dirty skill, patched skill

### Mismatches

**Mismatch**:
A statement in an owned skill that the repository no longer supports.
_Avoid_: drift, staleness, rot, outdated content

**Broken reference**:
A mismatch where a cited path, glob, link, command, or slash command no longer exists.
_Avoid_: structural drift, dead link, missing path

**Behavior mismatch**:
A mismatch where a described procedure or effect is contradicted by the code.
_Avoid_: behavioral drift, logic drift, feature drift

**Outside claim**:
A statement about something beyond the repository, such as a model identifier, a library version, or an API name, that cannot be checked from the repository alone.
_Avoid_: external fact, external-fact drift, version drift

**App regression**:
Application behavior the skill describes correctly that the application itself no longer performs; reported, never repaired by maintenance, never hidden by rewording the skill.
_Avoid_: product gap, bug, regression

### Runs

**Review**:
A run with no change statement that compares every owned skill with the repository and its outside facts.
_Avoid_: audit, scan, check, pass

**Apply**:
A run given a change statement that traces only that change through the owned skills.
_Avoid_: propagate, sync, migrate

**Change statement**:
The plain-words description a user supplies to an apply run naming what changed, from what to what.
_Avoid_: change request, diff description, event

**Maintainer**:
The agent running a maintenance run; the only party that edits files or delivers.
_Avoid_: coordinator, orchestrator, main agent, parent

**Inspector**:
A read-only helper that reads one owned skill against the code and reports mismatches with evidence.
_Avoid_: source reader, child, worker

**Inspection**:
The phase in which one inspector per owned skill reads and reports.
_Avoid_: source wave, scan phase, analysis phase

**Preflight**:
The read-only opening of a run that confirms git, lists project skills, reads the lock, and refuses to start over uncommitted edits in an owned skill.
_Avoid_: doctor, health check, setup

**Baseline**:
The commit that last touched an owned skill's directory; the delta is measured from here.
_Avoid_: last audit, checkpoint, marker

**Delta**:
Files changed in the repository since a baseline, skill directories excluded.
_Avoid_: churn, diff, recent changes

### Confirmation

**Reference**:
A checkable mention in a skill body: a path, glob, link, command, identifier, or slash command.
_Avoid_: citation, mention

**Reference check**:
The deterministic pass that reports each reference as resolved, missing, candidate, or unverifiable.
_Avoid_: citation check, link check, path check

**Trial run**:
Running a script a skill ships, exactly as the skill documents it, inside a throwaway worktree.
_Avoid_: dry-run, live pass, smoke test, drive

**Confirmation**:
The evidence a fix needs before delivery: a passing reference check, plus a passing trial run when a script or its command line was touched.
_Avoid_: proof, verification, validation

**Unconfirmed fix**:
A fix whose only possible confirmation was a trial run that could not happen; reverted and described, never delivered.
_Avoid_: unproven correction, unverified fix, pending fix

**Unverifiable**:
The state of a reference or outside claim that cannot be judged because a prerequisite is missing, always reported with the prerequisite and the route tried.
_Avoid_: unknown, skipped, unchecked

**Orphan**:
A file inside a skill directory that no Markdown in that skill refers to.
_Avoid_: dead file, unused file, stray file

### Results

**Current**:
The result where every owned skill was reviewed and nothing needed fixing.
_Avoid_: clean, ok, pass

**Updated**:
The result where confirmed fixes are delivered as a single pull request.
_Avoid_: changed, fixed

**Halted**:
The result where the review could not finish or a fix could not be delivered safely, with the cause named.
_Avoid_: blocked, failed, aborted
