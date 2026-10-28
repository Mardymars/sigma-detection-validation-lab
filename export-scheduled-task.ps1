param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName
)
# Run inside the VM immediately after the create/query/delete experiment.
$ErrorActionPreference = 'Stop'
$filter = "*[System[EventID=1] and EventData[Data[@Name='Image']='C:\Windows\System32\schtasks.exe']]"
$events = @(Get-WinEvent -LogName 'Microsoft-Windows-Sysmon/Operational' -FilterXPath $filter -MaxEvents 100 | ForEach-Object {
    $xml = [xml]$_.ToXml()
    $record = [ordered]@{ EventID = $_.Id }
    foreach ($field in $xml.Event.EventData.Data) {
        $record[$field.Name] = $field.InnerText
    }
    [pscustomobject]$record
} | Where-Object { $_.CommandLine.IndexOf($TaskName, [StringComparison]::OrdinalIgnoreCase) -ge 0 })
if ($events.Count -eq 0) { throw 'No matching task process events found. Check Sysmon, task name, and time window.' }
New-Item -ItemType Directory -Path 'C:\Lab' -Force | Out-Null
ConvertTo-Json -InputObject $events -Depth 5 | Set-Content -LiteralPath 'C:\Lab\scheduled-task-events.json' -Encoding UTF8
Write-Output "Saved $($events.Count) events to C:\Lab\scheduled-task-events.json. Inspect the command lines and sanitize a copy before sharing."
