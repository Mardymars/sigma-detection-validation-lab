# Lab setup and collection notes

## Recorded environment

| Component | Configuration |
| --- | --- |
| Hypervisor | VMware Workstation Pro 26H1 |
| Guest | Windows 11 Enterprise Evaluation |
| Resources | 4 GB RAM, two vCPUs, 80 GB growing virtual disk |
| Disk controller | SATA |
| Network | VMware NAT |
| Integration | VMware Tools installed |
| Telemetry | Sysmon 15.22, default installation configuration |
| Test session | Elevated Windows PowerShell |

Windows Update was performed before the captures. The exact running guest OS
build was not separately recorded. The file versions in process events describe
the executables, not necessarily the running OS release.

## Setup sequence

1. Create a Windows VM and install Windows from Microsoft's evaluation ISO.
2. Install VMware Tools, update Windows, and retain a clean VM snapshot.
3. Download [Sysmon from Microsoft](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon).
4. Extract it to `C:\Lab\Sysmon` inside the VM.
5. In administrator PowerShell, run `C:\Lab\Sysmon\Sysmon64.exe -i` and review
   the license prompt. A reboot is not required by that installation.
6. Verify events at Applications and Services Logs > Microsoft > Windows >
   Sysmon > Operational. Event ID 1 contains process creation and command line.
7. Run the case activities, export the intended events, and retain evidence of
   task registration and deletion separately from process telemetry.

The Sysmon service supplies telemetry. The Sigma rules are evaluated offline by
the repository's Python script; installing Sysmon alone does not install alerts.

## Safe activity used

- `whoami`: display the logged-in account.
- `whoami /priv`: display its privileges.
- `whoami /all`: display account, group, and privilege information.
- Create a uniquely named ONLOGON task whose action is `cmd.exe /c exit 0`,
  query it, then delete it in the same session. Task execution was not tested.

Run live collection inside a lab VM under your control. The detailed task
commands and cleanup are in the [scheduled-task case](../cases/scheduled-task/README.md).

## Export and evidence handling

The PowerShell collectors read Event XML and flatten named EventData fields into
JSON. Event ID is preserved as a number; fields such as CommandLine and User
remain strings. The supplied evidence is limited to this JSON and the user's
task console output. Raw EVTX files and screenshots are not part of the package.

User and ParentUser values are replaced with `DESKTOP-LAB\LabUser` in shared
events. Corresponding identity fields in task output use the same placeholders.
The identity substitution was checked against the actual queries to ensure it
did not change the nine match outcomes.

## Installation troubleshooting observation

Windows installation repeatedly stopped during image application while using a
virtual NVMe disk. The ISO matched Microsoft's published SHA-256, and VMware logs
showed long virtual-disk writes followed by no compatible bootloader. Installation
succeeded after the virtual disk was attached through SATA.

That records the observed resolution on this VM; it does not prove a general
NVMe compatibility defect or diagnose the physical SSD. Virtual disk controllers
are independent of the laptop's physical storage interface.
