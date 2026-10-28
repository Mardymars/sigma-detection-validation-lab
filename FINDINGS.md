# Windows detection validation: final findings

## Outcome

Three existing Sigma rules behaved as expected on six captured Windows Sysmon
process events. Nine predeclared rule/event expectations passed. No Sigma defect
was demonstrated and no upstream fix or contribution has been submitted.

This is a completed introductory detection-validation lab. It demonstrates
controlled evidence generation, log inspection, offline rule evaluation, and
analyst interpretation. It does not establish production detection accuracy.

## Question and method

Can the selected rules distinguish their target command lines from related
comparison activity, and what conclusions can an analyst support from a match?

1. Build a Windows 11 Enterprise Evaluation VM with Sysmon.
2. Select existing rules and declare expected matches before generating activity.
3. Run harmless commands inside the VM from elevated PowerShell.
4. Export Sysmon Event ID 1 data through the event XML API into JSON.
5. Preserve the supplied fields, documenting identity substitutions.
6. Convert the pinned, unchanged rule YAML with pySigma's SQLite backend.
7. Execute each generated query on the corresponding captures in SQLite.
8. Compare results with the declared expectations and assess what they mean.

The evaluator uses no hand-coded substitute for the Sigma detection conditions.
No processing pipeline is applied because the curated Sysmon process events
already use the fields these rules reference. Source selection is made during
export; generic log routing is not tested.

## Results

Sigma rules by Florian Roth and Nasreddine Bencherchali (Nextron Systems).
See [NOTICE.md](NOTICE.md) for attribution for each rule.

| Rule | Captured command | Expected | Observed |
| --- | --- | --- | --- |
| Privilege enumeration | `whoami` | No match | No match |
| Privilege enumeration | `whoami /priv` | Match | Match |
| Privilege enumeration | `whoami /all` | No match | No match |
| All-information enumeration | `whoami` | No match | No match |
| All-information enumeration | `whoami /priv` | No match | No match |
| All-information enumeration | `whoami /all` | Match | Match |
| Task creation | `schtasks /Create ...` | Match | Match |
| Task creation | `schtasks /Query ...` | No match | No match |
| Task creation | `schtasks /Delete ...` | No match | No match |

The initial two-event whoami experiment is included within the six-check scope
comparison, not counted twice. See the case result JSON files for process IDs,
timestamps, exact command lines, generated queries, and runtime versions.

## Reading the rules in plain language

### Whoami privilege enumeration

The first rule requires two things: the program must be whoami (recognized by
image path or original filename), and its command line must contain `/priv` or
`-priv` preceded by a space. `all of selection_*` means that both the image
selection and argument selection must match. It does not mean every alternative
inside an individual selection must match.

That explains why plain whoami and `/all` did not match this narrow rule.

### Whoami all-information enumeration

The second rule checks the whoami image and an `/all` or dash-form argument.
Sigma's `windash` modifier expands the accepted argument forms during conversion.
Its match on `/all` complements the first rule; the first rule's non-match is
not evidence of a bug.

### Scheduled-task creation

The third rule selects schtasks with ` /create ` in its command line, then
excludes certain system-account name patterns and specific Office activity.
The captured lab user and PowerShell parent did not satisfy those exclusions.
Query and deletion commands did not contain the creation selector.

The rule has low severity and documents administrative activity and software
installation as possible false positives. A rule's severity is a prioritization
hint, not proof of an incident.

## Investigation and false-positive analysis

All six captured processes were deliberate, legitimate lab actions. Three
rule/event checks matched that benign activity. Do not turn those counts into a
false-positive rate: this is a deliberately selected, tiny sample with no
representative background traffic or independent labeling study.

For a real whoami alert, investigate the initiating user and parent process,
recent logons, related discovery commands, and surrounding endpoint activity.
This capture shows elevated PowerShell and High integrity, not proof of a
privilege-escalation attempt. Listing enabled privileges does not show that the
process exploited them.

For task creation, inspect task contents, executable path, trigger, run account,
creator, parent process, and relevant file/network events. The task action here
was `cmd.exe /c exit 0` with an ONLOGON trigger. A query confirmed registration,
and Windows reported successful deletion. No claim is made that the task ran.

The Sysmon event alone only proves a process was launched with those arguments.
It would also record a failed create attempt; separate task evidence matters.

## Recommendations supported by this lab

- Collect process image, command line, user, and parent image consistently;
  the scheduled-task rule also depends on user and parent context for exclusions.
- Select complementary rules according to intended behavior. Do not label an
  out-of-scope non-match a detection defect.
- Treat expected matches on administrative commands as investigation leads.
  Avoid blanket suppression of whoami or schtasks merely to eliminate benign alerts.
- Before proposing tuning, collect representative authorized activity and verify
  that a narrow exclusion does not hide relevant suspicious activity. No such
  production tuning is validated by this lab.
- Preserve evidence provenance, input hashes, rule versions, and expectations
  so another person can rerun the same checks.

## Environment and setup finding

The VM uses VMware Workstation 26H1, 4 GB RAM, 2 vCPUs, an 80 GB growing SATA
disk, Windows 11 Enterprise Evaluation, and Sysmon 15.22. Windows Update and
VMware Tools setup were performed before testing. The exact running OS release
was not independently captured; executable file-version fields are not a
substitute for the guest OS build.

During setup, installation repeatedly stopped while copying the image. The ISO
matched Microsoft's published SHA-256. VMware logs showed slow virtual NVMe
writes and later no compatible bootloader. After changing the virtual disk
controller to SATA, installation succeeded. This is a useful troubleshooting
observation, not a proven root-cause diagnosis or a general incompatibility claim.

## Reproducibility and limits

The supplied JSON was exported from live Sysmon events and pasted through chat.
Original EVTX and raw XML are not in this project; their acquisition integrity
cannot be verified here. Only documented identity fields were substituted.
The original VM exports remain the user's responsibility. Guest timestamps are
reported as UTC without independent clock validation.

The evaluation covers three particular command variants plus task operations
in one elevated session. It does not test all flags, Unicode/case combinations,
failed attempts, alternate APIs, system-user/Office exclusion branches, or
standard-user behavior. SQLite field equality and case behavior may differ from
other backends. These results must not be generalized to every SIEM.

There was no SIEM deployment, automated incident response, exploitation, real
malware, task-execution validation, production telemetry study, or demonstrated
upstream defect. Contributions are a possible later activity, not a result of
this project.

## Interview explanation

"I built a Windows lab, collected Sysmon process events, and tested three Sigma
rules against known activity. I declared expected results, converted the actual
rules into executable queries, and checked nine outcomes. I learned to separate
rule scope from missed detections and to distinguish a process starting from
the action succeeding. My benign scheduled-task test matched the creation rule,
so I documented why a match needs context rather than treating it as proof of
an attack."

The workflow, evaluator, and documentation were developed with AI assistance.
I executed and exported the live VM tests. Upstream rule authorship is preserved
in the YAML, evaluation output, and attribution notice.
