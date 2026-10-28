# Run INSIDE the Windows lab VM after generating the two intended test events.
# This reads Sysmon and saves an export; it does not execute test activity.
$ErrorActionPreference = 'Stop'
$filter = "*[System[EventID=1] and EventData[Data[@Name='Image']='C:\Windows\System32\whoami.exe']]"
$events = @(Get-WinEvent -LogName 'Microsoft-Windows-Sysmon/Operational' -FilterXPath $filter -MaxEvents 2 | ForEach-Object {
    $xml = [xml]$_.ToXml()
    $record = [ordered]@{ EventID = $_.Id }
    foreach ($field in $xml.Event.EventData.Data) {
        $record[$field.Name] = $field.InnerText
    }
    [pscustomobject]$record
})
if ($events.Count -ne 2) { throw 'Expected two captured whoami events. Check Sysmon and test execution.' }
$json = ConvertTo-Json -InputObject $events -Depth 5
New-Item -ItemType Directory -Path 'C:\Lab' -Force | Out-Null
$json | Set-Content -LiteralPath 'C:\Lab\whoami-events.json' -Encoding UTF8
Write-Output 'Saved C:\Lab\whoami-events.json. Check its command lines before treating it as test evidence.'
Write-Output 'Retain the original privately; sanitize a copy before publication.'
