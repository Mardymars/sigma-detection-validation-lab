# Whoami rule scope comparison

Question: does `whoami /all`, which also prints privilege information, match
the narrow `/priv` rule, and does a separate existing Sigma rule cover it?

## Expectations declared before evaluation

| Captured command | `/priv` rule | `/all` rule |
| --- | --- | --- |
| `whoami` | No match | No match |
| `whoami /priv` | Match | No match |
| `whoami /all` | No match | Match |

Measured offline results matched all six expectations. The actual generated
queries, rule hashes, input hashes, runtime versions, and per-event results are
in [results.json](results.json).

The two rules target different arguments. The `/all` rule uses Sigma's `windash`
modifier to recognize slash and dash forms; the converter-generated SQL includes
` /all` as an alternative to the literal ` -all` in the YAML. No detection
condition was manually rewritten for this evaluation.

## Provenance

- The two original captures are reused unchanged from
  `../whoami-priv/events.sanitized.json`.
- `whoami-all.sanitized.json` is the third actual event exported by the user
  from the same Windows lab and supplied through chat. Sysmon-reported UTC:
  `2026-10-28 20:34:57.609`; ProcessId: `896`.
- Only `User` and `ParentUser` were replaced by `DESKTOP-LAB\LabUser` in the
  additional event. All other supplied fields are retained.
- The command was run from elevated PowerShell. This was legitimate test activity;
  the matching event does not demonstrate malicious intent or escalation.
- Additional rule: **Enumerate All Information With Whoami.EXE**, UUID
  `c248c896-e412-4279-8c15-1c558067b6fa`, authored by Florian Roth (Nextron Systems)
  and Nasreddine Bencherchali (Nextron Systems).
- [Pinned upstream source](https://github.com/SigmaHQ/sigma/blob/05d1031f537e830b76da53bae2400c5814c89165/rules/windows/process_creation/proc_creation_win_whoami_all_execution.yml).
  The local YAML is copied without modification and retains its attribution.
  The rule remains under the [Detection Rule License 1.1](https://github.com/SigmaHQ/Detection-Rule-License).

## Reproduce the evaluation

From the repository root after installing `windows-detection-lab/requirements.txt`:

```powershell
.\.lab-env\Scripts\python.exe evaluate_whoami.py --compare-scope
```

Expected final line: `Total: 6 expectations; all met: True`.
Evaluation uses the pySigma SQLite backend with flattened Sysmon fields and no
processing pipeline. This is an offline rule evaluation, not a deployed SIEM
alert or a validation of arbitrary source-to-backend mappings.

## Repeat the additional live capture

Inside the lab VM, run `whoami /all` and immediately export its latest event:

```powershell
$filter = "*[System[EventID=1] and EventData[Data[@Name='Image']='C:\Windows\System32\whoami.exe']]"
$event = Get-WinEvent -LogName 'Microsoft-Windows-Sysmon/Operational' -FilterXPath $filter -MaxEvents 1
$xml = [xml]$event.ToXml()
$record = [ordered]@{ EventID = $event.Id }
foreach ($field in $xml.Event.EventData.Data) {
    $record[$field.Name] = $field.InnerText
}
ConvertTo-Json -InputObject $record -Depth 5 | Set-Content C:\Lab\whoami-all-event.json -Encoding UTF8
```

Check that `CommandLine` contains `/all`; the query selects the latest whoami
event, not an argument-specific event. Keep original evidence privately and
document sanitization. The evaluator's expected process IDs refer to the supplied
captures; a fresh run needs its own evidence and explicitly recorded expectations.

## Analyst conclusion

A non-match is meaningful only relative to a rule's intended scope. Running
`/all` does not demonstrate a defect in the `/priv` rule. The existing `/all`
rule covers the tested execution. No upstream change is justified by these
results alone.

Two narrow rules passing six checks do not establish comprehensive discovery
coverage, production false-positive rates, or resistance to command variations.
