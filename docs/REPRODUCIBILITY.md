# Reproduce the detection checks

## Replay the bundled captures

The offline replay needs Python and the pinned dependencies. Windows, VMware,
Sysmon, a cloud account, and a SIEM are not required to replay saved evidence.
The recorded local run used Python 3.14 on Windows; GitHub Actions uses Python
3.14 on a Windows runner.

From the repository root in PowerShell:

```powershell
python -m venv .lab-env
.\.lab-env\Scripts\python.exe -m pip install -r requirements.txt
.\.lab-env\Scripts\python.exe evaluate_lab.py
```

Expected final line: `Total: 9 expectations; all met: True`.

On a Unix-like host, use `.lab-env/bin/python` in place of the Windows
interpreter path. Platform differences are not evaluated as part of the live lab.

Run a single case:

```powershell
.\.lab-env\Scripts\python.exe evaluate_lab.py --case whoami-scope
.\.lab-env\Scripts\python.exe evaluate_lab.py --case scheduled-task
```

The preserved initial baseline can be replayed with `--case whoami-priv`.
It overlaps with the scope case, so its two checks are not added to the final nine.

## What the program does

1. Load the sanitized captured event JSON and separately declared expectations.
2. Check field consistency, process IDs, and Event ID 1 source scope.
3. Verify that rule YAML hashes agree with the pinned rule manifest.
4. Parse and convert the actual Sigma rule with pySigma's SQLite backend.
5. Load the event fields into a temporary, in-memory SQLite table.
6. Execute the converted SQL and compare matched process IDs with expectations.
7. Save queries and results, including input hashes and tool versions.

No custom whoami or schtasks detection matcher is used. The event selection was
performed at export time; the evaluator does not establish arbitrary logsource
mapping or production alert delivery.

## Generated artifacts

The evaluation updates each case's `results.json` and SQL files. An all-case run
also updates `results-summary.json`. Input evidence, expected outcomes, and rule
YAML are not modified. Runtime metadata such as SQLite version can differ on
another interpreter even when the same nine expected results pass.

`requirements.txt` pins direct dependencies. `environment-lock.txt` records the
full package set used locally. A clean dependency installation is part of the
GitHub Actions check, not a requirement to modify a system-wide Python install.

## Repeat live collection separately

Follow [lab setup](LAB-SETUP.md) and the individual case studies. New captures
have different IDs and timestamps. Preserve the original exports, inspect their
contents, record expectations for the new IDs, and document any sanitization.
Do not relabel new captures as the historical evidence committed here.

The saved events were supplied as JSON exports; raw EVTX and Event XML are not
included. Their provenance and collection limits are described in the report.
