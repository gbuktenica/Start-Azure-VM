<#
.SYNOPSIS
    Runs Post Deployment Pester tests against a web URL.
.EXAMPLE
    .\Invoke-PesterTests.ps1 -WebsiteUrl http://localhost

    Runs all Pester test files located in the same path as this script against the website http://localhost
.EXAMPLE
    .\Invoke-PesterTests.ps1 -WebsiteUrl http://localhost -TestPath D:\Agent\1\

    Runs all Pester test files located in "D:\Agent\1\" against the website http://localhost
#>
param (
    $WebsiteUrl,
    $TestPath = $PSScriptRoot,
    $Username,
    $Secret
)
Write-Host "Running post deployment tests for $WebsiteUrl"
Write-Host "Running test files found in $TestPath"
if ($Secret.length -gt 0) {
    Write-Host "Creating credential object for $Username"
    $SecurePassword = $Secret | ConvertTo-SecureString -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword -ErrorAction Stop
    $PesterContainer = New-PesterContainer -Path $TestPath -Data @{ 'WebsiteUrl' = $WebsiteUrl ; 'Credential' = $Credential}
} else {
    $PesterContainer = New-PesterContainer -Path $TestPath -Data @{ 'WebsiteUrl' = $WebsiteUrl}
}
$PesterResult = Invoke-Pester -Container $PesterContainer -ErrorAction Stop -Output Detailed -PassThru
if ($PesterResult.Result -ne 'Passed') { Exit 1; return }