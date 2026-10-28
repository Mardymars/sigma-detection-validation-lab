# Third-party detection rules

The following SigmaHQ rules are included unchanged under the
[Detection Rule License 1.1](LICENSES/DRL-1.1.md). The original UUIDs, author
fields, references, and detection conditions are retained.

| Rule | UUID | Author(s) |
| --- | --- | --- |
| Security Privileges Enumeration Via Whoami.EXE | `97a80ec7-0e2f-4d05-9ef4-65760e634f6b` | Florian Roth (Nextron Systems) |
| Enumerate All Information With Whoami.EXE | `c248c896-e412-4279-8c15-1c558067b6fa` | Florian Roth (Nextron Systems), Nasreddine Bencherchali (Nextron Systems) |
| Scheduled Task Creation Via Schtasks.EXE | `92626ddd-662c-49e3-ac59-f6535f12d189` | Florian Roth (Nextron Systems) |

The source is [SigmaHQ/sigma](https://github.com/SigmaHQ/sigma), pinned to commit
`05d1031f537e830b76da53bae2400c5814c89165`. Exact paths and hashes are recorded
in [rules-manifest.json](rules-manifest.json).

The project evaluates these rules; it does not claim to have authored them or to
represent an official SigmaHQ project. Original tooling and documentation use
the [MIT license](LICENSE).
