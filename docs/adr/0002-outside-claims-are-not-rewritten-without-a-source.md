# Outside claims are not rewritten without a documentary source

Skills carry claims about things beyond the repository: model identifiers, library versions, API names. During a review, such a claim is reported as unverifiable and left as written unless a documentation lookup tool available in the host confirms the current value; during an apply run the user's change statement is the source. Rewriting these claims from the model's own memory would inject confident misinformation into instructions that other agents then follow, and a stale claim that is flagged is safer than a wrong one that is not.

## Considered Options

- **Rewrite from model knowledge.** Rejected: model knowledge of current identifiers is exactly the thing most likely to be stale, and the error propagates to every future run of the edited skill.
- **Always require the user to supply the new value.** Rejected for reviews: it makes the review blind to the kind of staleness the user most wanted caught. Kept as the rule for apply runs, where the user already names the change.
