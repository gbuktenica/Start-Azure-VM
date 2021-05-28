<#
.SYNOPSIS
    Sends a notification email when a stage completes successfully.
.EXAMPLE
    Send-Notification.ps1 -Subject "Deployed to Production" -Password $(NoReplyPassword) -Recipient "admin@company.com"
#>
[CmdletBinding()]
param (
    $fromAddress,
    $toAddress,
    $Pipeline,
    $client_secret,
    $client_id,
    $tenant_id
)

$mailSubject = "$Pipeline has successfully been deployed to production"

# Get the token
$request = @{
    Method = 'POST'
    URI    = "https://login.microsoftonline.com/$tenant_id/oauth2/v2.0/token"
    body   = @{
        grant_type    = "client_credentials"
        scope         = "https://graph.microsoft.com/.default"
        client_id     = $client_id
        client_secret = $client_secret
    }
}
$mailMessage = 'The documentation for this message is <a href="https://github.com/gbuktenica/Start-Azure-VM">here.</a>'

$token = (Invoke-RestMethod @request).access_token

# Build the mail message
$params = @{
    "URI"         = "https://graph.microsoft.com/v1.0/users/$fromAddress/sendMail"
    "Headers"     = @{
        "Authorization" = ("Bearer {0}" -F $token)
    }
    "Method"      = "POST"
    "ContentType" = 'application/json'
    "Body"        = (@{
            "message" = @{
                "subject"      = $mailSubject
                "body"         = @{
                    "contentType" = 'HTML'
                    "content"     = $mailMessage
                }
                "toRecipients" = @(
                    @{
                        "emailAddress" = @{
                            "address" = $toAddress
                        }
                    }
                )
            }
        }) | ConvertTo-JSON -Depth 10
}

# Send the message
Invoke-RestMethod @params -Verbose