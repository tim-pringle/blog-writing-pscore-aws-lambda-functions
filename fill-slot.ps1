$json = @"
{
    "metadata": {
      "schemaVersion": "1.0",
      "importType": "LEX",
      "importFormat": "JSON"
    },
    "resource": {
      "name": "PScommand",
      "version": "1",
      "enumerationValues": [
        
      ],
      "valueSelectionStrategy": "ORIGINAL_VALUE"
    }
  }
"@

$slot = $json | ConvertFrom-Json
$command = Get-Command -Module 'AWSPowerShell.NetCore' 

ForEach ($obj in $command) {
    $slot.resource.enumerationValues += [PSCustomObject]@{
        value = $obj.name
        synonyms = @()
    }
}

$slot | ConvertTo-Json -Depth 4 | Out-File psCommand.json -force
Compress-Archive -Path ./psCommand.json -DestinationPath ./psCommand.zip -Force

