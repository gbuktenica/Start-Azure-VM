<#
.SYNOPSIS
  This file contains the Pester tests that will be run against the URL that has been deployed by the pipeline.
#>
param(
    [string]$WebsiteUrl,
    [PsCredential] $Credential
)
BeforeAll {
    Function Invoke-TrapWebErrors([scriptblock]$sb) {
        # Unfortunately Invoke-WebRequest throws errors for 4xx/5xx errors, but we may want
        # the raw HTML response e.g. for testing specific error codes.  In this case, run
        # an arbitrary ScriptBlock and trap WebExceptions and return the response object
        $result = try {
            & $sb
        }
        catch [System.Net.WebException] {
            # Windows PowerShell raises a System.Net.WebException error
            $_.Exception.Response
        }
        catch {
            # PowerShell Core raises a standard PowerShell error class with the exception within.
            if ($_.Exception.GetType().ToString() -eq 'Microsoft.PowerShell.Commands.HttpResponseException') {
                $_.Exception.Response
            }
            else {
                Throw $_
            }
        }
        $result
    }
}
Context "Basic Connectivity" {
    Describe "Response from ${WebsiteUrl}" {
        it "should return statuscode 200" {
            if ($Credential.length -gt 0) {
                $Result = Invoke-WebRequest -Uri $WebsiteUrl -UseBasicParsing -Credential $Credential -AllowUnencryptedAuthentication
            } else {
                $Result = Invoke-WebRequest -Uri $WebsiteUrl -UseBasicParsing -AllowUnencryptedAuthentication
            }
            $Result.StatusCode | Should -Be 200 -Because 'This indicates Website is available.'
        }
    }
    Describe "Response from ${WebsiteUrl}/missingFile.txt" {
      it "should return statuscode 404" {
        if ($Credential.length -gt 0) {
            $Result = Invoke-TrapWebErrors { Invoke-WebRequest -Uri "$WebsiteUrl/missingFile.txt" -Credential $Credential -UseBasicParsing  -AllowUnencryptedAuthentication}
        } else {
            $Result = Invoke-TrapWebErrors { Invoke-WebRequest -Uri "$WebsiteUrl/missingFile.txt" -UseBasicParsing }
        }
        $Result.StatusCode | Should -Be 404 -Because 'This indicates Website is not rewriting files.'
      }
    }
}
