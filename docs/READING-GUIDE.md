# Reading guide

## A short review

1. [README](../README.md): purpose, results, architecture, and quick replay.
2. [Final findings](../FINDINGS.md): what was investigated, why matches occurred,
   what the evidence supports, and the practical limitations.
3. [Whoami case study](../cases/whoami-scope/README.md): how two rules cover
   different arguments, including a plain-command comparison.
4. [Scheduled-task case study](../cases/scheduled-task/README.md): creation
   detection and the distinction between a process event and a registered task.

## Follow the evidence

| Question | Where to look |
| --- | --- |
| What did Windows record? | [Initial whoami events](../cases/whoami-priv/events.sanitized.json), [whoami /all](../cases/whoami-scope/whoami-all.sanitized.json), [task events](../cases/scheduled-task/events.sanitized.json) |
| Was the task registered and cleaned up? | [Sanitized task query and deletion output](../cases/scheduled-task/task-output.sanitized.txt) |
| What results were expected? | [Whoami expectations](../cases/whoami-scope/expected.json), [task expectations](../cases/scheduled-task/expected.json) |
| What did the evaluator find? | [Whoami results](../cases/whoami-scope/results.json), [task results](../cases/scheduled-task/results.json), [summary](../results-summary.json) |
| Which upstream rules were used? | [Pinned rule manifest](../rules-manifest.json), [authors and licenses](../NOTICE.md) |
| How can the results be reproduced? | [Replay instructions](REPRODUCIBILITY.md), [evaluation code](../evaluate_lab.py) |
| How was the live lab built? | [Lab setup and collection notes](LAB-SETUP.md) |

## What to assess

- Are expectations separated from observed outcomes?
- Do the captured fields support the rule conditions?
- Does the interpretation distinguish benign matching activity from an incident?
- Are conclusions limited to the tests actually performed?
- Can the same evidence and pinned rule logic reproduce the nine results?

The strongest takeaway is the reasoning chain from activity to evidence to
detection to analyst interpretation. The count of rules or checks is simply
the scope of this introductory study.
