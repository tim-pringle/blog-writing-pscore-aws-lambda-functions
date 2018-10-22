# PowerShell script file to be executed as a AWS Lambda function. 
# 
# When executing in Lambda the following variables will be predefined.
#   $LambdaInput - A PSObject that contains the Lambda function input data.
#   $LambdaContext - An Amazon.Lambda.Core.ILambdaContext object that contains information about the currently running Lambda environment.
#
# The last item in the PowerShell pipeline will be returned as the result of the Lambda function.
#
# To include PowerShell modules with your Lambda function, like the AWSPowerShell.NetCore module, add a "#Requires" statement 
# indicating the module and version.

#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.270.0'}

#Log the event data to CloudWatch
Write-Host ($LambdaInput | ConvertTo-Json)

$commandparam = $LambdaInput.currentIntent.slots.Command

$ErrorActionPreference = 'Stop'

try {
    #Get the correct casing for the command
    $command = (get-command -Name $commandparam | Select-Object -ExpandProperty Name)
    $url = "https://docs.aws.amazon.com/powershell/latest/reference/items/$($command).html"
    $pattern = "<div class=`"synopsis`">(?'synopsis'.*)</div>"
    $response = Invoke-WebRequest -Uri $url
    $response.Content -match $pattern
    If (!($description = $Matches["synopsis"])) {
        $description = "No help is available for $command" 
    }
}
Catch [System.Management.Automation.CommandNotFoundException] {$description = "Sorry, no AWS PowerShell cmdlet called $commandparam exists"}
Catch [System.Net.WebException] {$description = "Sorry, no help exists for $command"}


# Response template for Lex
$template = @"
{
	"sessionAttributes": {},
	"dialogAction": {
		"type": "Close",
		"fulfillmentState": "Fulfilled",
		"message": {
			"contentType": "PlainText",
			"content": "$description"
		}
	}
}
"@

Return $template