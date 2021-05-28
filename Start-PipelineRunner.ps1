<#
.SYNOPSIS
    Start the pipeline runner.
.EXAMPLE
    Start-PipelineRunner -ComputerName Serenity
#>
[CmdletBinding()]
param (
    $ComputerName,
    $ResourceGroupName
)
Write-Output "Getting State of $ComputerName"
# Trap all errors because we do not want to fail the pipeline.
try {
    $PowerState = (Get-AzVM -Name $ComputerName -ResourceGroupName $ResourceGroupName -Status -ErrorAction Stop -NoWait).Statuses[1].Code
} catch {
    $_.Exception.Response
}
if ($PowerState -ne "PowerState/running") {
    Write-Output "$ComputerName not running. Powering on now"
    # Trap all errors because we do not want to fail the pipeline.
    try {
        Start-AzVM -Name $ComputerName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
    } catch {
        $_.Exception.Response
    }

} else {
    Write-Output "$ComputerName already running"
}