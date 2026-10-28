# Project completion checklist

**Status: completed introductory detection-validation study.**

Scope: three existing Sigma rules, two Windows behavior families, six captured
Sysmon events, nine distinct rule/event checks, and an analyst report. A merged
upstream contribution is not a completion requirement.

- [x] Build a Windows VM and verify Sysmon logging.
- [x] Capture whoami, whoami /priv, and whoami /all.
- [x] Evaluate the two whoami rules on three events (six expectations).
- [x] Record rule provenance, sanitized evidence, generated queries, and versions.
- [x] Select a third rule and declare a scheduled-task test plan.
- [x] Generate scheduled-task creation, query, and deletion process events.
- [x] Preserve task query evidence of registration and Windows deletion-success output.
- [x] Evaluate the third rule on three events (three expectations).
- [x] Complete the final findings report and reproducibility review.
- [x] Document rule logic, benign matching activity, and test limitations in plain language.

Verification: the full evaluator passed all nine checks. The original whoami
entry points were also checked following consolidation into the shared evaluator.
Rule files were byte-compared with the pinned local Sigma checkout and their
hashes recorded. JSON parsing, identity sanitization, and local document links
were checked. No production deployment or upstream contribution is claimed.

Cleanup evidence is the Windows success message for deleting the unique lab
task; a separate post-deletion query was not supplied. The task was not deliberately
executed. These limits are recorded, not silently treated as additional tests.
