<#
.Synopsis
    This function will export all users from the tenant with the Admin role specified.
.DESCRIPTION
    This function will loop through the tenant and export all users with the Admin role specified.
.EXAMPLE
    .\Export-AdminRoleForTenant.ps1 -RoleName 'Company Administrator' -OutputFile C:\MyOutputFile.csv

    This command will export to a .csv file all the users in the tenant having Company Administrator permissions.
.INPUTS
    None
.OUTPUTS
    Data in a .CSV file at the location specified when using the -OutputFile parameter.
#>
[CmdletBinding(SupportsShouldProcess = $true,
               ConfirmImpact = 'Low')]
param(
    [parameter(Mandatory=$true,
               HelpMessage="Choose the role name from the list offered",
               Position=0)]
    [ValidateSet("Billing Administrator","Company Administrator","CRM Service Administrator","Exchange Service Administrator","Helpdesk Administrator",
    "Intune Service Administrator","Lync Service Administrator", "Mailbox Administrator","Power BI Service Administrator","Reports Reader","Security Administrator",
    "Service Support Administrator","SharePoint Service Administrator","User Account Administrator")]
    [string]$RoleName,

    [parameter(Mandatory=$true,
               HelpMessage="Enter the path of the file to export users -- (i.e.: C:\MyOutputFile.csv)",
               Position=1)]
    [string]$OutputFile
)
try{
    $role = Get-MsolRole -RoleName $RoleName -ErrorAction Stop
    Get-MsolRoleMember -RoleObjectId $role.ObjectId | Select-Object @{n= "Role";e={$role.Name}}, @{n= "RoleDescription";e={$role.Description}}, DisplayName, EmailAddress, IsLicensed | Export-Csv -Path $OutputFile -NoTypeInformation
    }
#If not logged into Office 365 - Display error "must call Connect-MsolService"
catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException]{
    Write-Error -Message "The cmdlet returned an error: $($_.Exception.Message)"
    break
    }
Write-Host "Export completed. Output file is located at $OutputFile" -ForegroundColor Green

