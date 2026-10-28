# Scheduled-task creation: completed case study

Rule: **Scheduled Task Creation Via Schtasks.EXE**,
`92626ddd-662c-49e3-ac59-f6535f12d189`, authored by Florian Roth (Nextron Systems).
[Pinned upstream rule](https://github.com/SigmaHQ/sigma/blob/05d1031f537e830b76da53bae2400c5814c89165/rules/windows/process_creation/proc_creation_win_schtasks_creation.yml).
The copied YAML remains under the
[Detection Rule License 1.1](https://github.com/SigmaHQ/Detection-Rule-License).

Status: complete. Three real Sysmon captures were evaluated with the unchanged
Sigma rule using the pySigma SQLite backend. All three expectations were met.

## Why this case

Scheduled tasks can support legitimate administration or attacker persistence.
This rule detects a schtasks process whose command line contains ` /create `,
with exclusions for certain system-account names and specific Office activity.
It is low severity and explicitly lists administration/software installation as
possible false positives. A Sysmon process event records an attempt; it does not
prove the task was successfully registered or executed.

## Declared expectations

| Action | Expected match | Observed match | Captured process ID |
| --- | --- | --- | --- |
| Create an inert task as the logged-in lab user | Yes | Yes | 5884 |
| Query the created task | No | No | 4732 |
| Delete the lab task | No | No | 10784 |

Expectations were recorded before the user generated the activity. Generated
SQL and full results are saved alongside this README. This case does not test
the rule's system-user and Office exclusion branches.

The task's action is `cmd.exe /c exit 0`, which simply exits. The ONLOGON
trigger is not exercised; delete the task in the same session. This case tests
creation visibility, not persistence execution. Do not log off before cleanup.

## Live procedure (inside the VM, administrator PowerShell)

Choose a unique task name instead of overwriting anything:

```powershell
$taskName = 'SigmaLab-DetectionTest-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
schtasks.exe /Create /TN $taskName /TR 'C:\Windows\System32\cmd.exe /c exit 0' /SC ONLOGON /IT
schtasks.exe /Query /TN $taskName /FO LIST /V
schtasks.exe /Delete /TN $taskName /F
```

Review each command's success or failure. If creation asks for credentials or
fails, stop and record the output instead of repeatedly retrying or changing
accounts. `/F` is used only to confirm deletion of the unique task we created.

For fresh runs, an additional absence check is useful:
`Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue`.
The completed capture includes the query output showing the registered task and
Windows' deletion-success message. A separate post-deletion query was not
supplied, so this report does not claim one was performed. Preserve command
output alongside Sysmon Event ID 1 records for the three schtasks invocations.

Export using `export-scheduled-task.ps1` from the lab root, passing `-TaskName
$taskName`. It selects process events for the unique task name among the most
recent 100 schtasks process events. If the run is older, increase the search
window deliberately. Inspect all command lines before treating the export as
test evidence. Keep original evidence privately and sanitize a shared copy.

## Evidence and provenance

- `events.sanitized.json`: the three user-exported process records, with only
  `User` and `ParentUser` replaced by `DESKTOP-LAB\LabUser`.
- `task-output.sanitized.txt`: supplied query and deletion output; HostName,
  Author, and Run As User replaced by the same lab placeholders.
- Task: `SigmaLab-DetectionTest-20261028-164228`.
- Sysmon-reported UTC sequence: create `20:42:28.838`, query `20:42:28.962`,
  delete `20:42:29.030`, all on October 28, 2026.
- Original EVTX, raw Event XML, and task execution evidence were not supplied.
- The initial creation-success line was not supplied, but the task query
  independently establishes registration. Deletion success is explicitly recorded.

## Repeat the offline evaluation

From the repository root:

```powershell
.\.lab-env\Scripts\python.exe evaluate_lab.py --case scheduled-task
```

Expected: one match for creation, none for query/deletion, three expectations met.

## Analyst conclusion

The match is expected even though this is harmless administration. The rule's
low severity and documented administrative false positives fit that outcome.
Investigate the action, task name, creator, parent process, and surrounding
events before escalating. A schtasks process with `/Create` is not proof of
successful persistence; registration and execution need separate evidence.

No defect or required rule change was demonstrated. Suppressing all schtasks
activity to avoid this benign match would discard the very behavior this rule
is designed to expose.
