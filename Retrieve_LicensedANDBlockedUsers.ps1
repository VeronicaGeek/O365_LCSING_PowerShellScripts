<#
.Synopsis
   This script will retrieve users that are blocked AND ALSO licensed in the tenant.
.DESCRIPTION
   This script will retrieve users that are blocked AND ALSO licensed in the tenant, and export the UPN to a .CSV file.
.EXAMPLE
   .\Retrieve_LicensedANDBlockedUsers.ps1 -OutputFile <FullPath_to_save_the_output.csv>
.EXAMPLE
   .\Retrieve_LicensedANDBlockedUsers.ps1 (if no parameters are entered, you will be prompted for them)

==========================================
Author: Veronique Lengelle (@VeronicaGeek)
Date: 02 Jan 2017 
Version: 1.0
==========================================
#>
[CmdletBinding()]
param(    
    [Parameter(Mandatory=$true,HelpMessage="Full path to create the OutputFile (i.e.: C:\MyOutputFile.csv)",Position=1)] 
    [string]$OutputFile
)
Start-Transcript
#Script started at:
$startTime = "{0:G}" -f (Get-date)
Write-Host "*** Script started on $startTime ***" -f White -b DarkYellow

#Connect to O365
$cred = Get-Credential
Connect-MsolService -Credential $cred
Write-Host "Connected to O365" -f Green

#Script
Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true -and $_.BlockCredential -eq $true} | select UserPrincipalName, IsLicensed, BlockCredential | Export-Csv $OutputFile -Append

#Script ended at:
$endTime = "{0:G}" -f (Get-date)
Write-Host "*** Script finished on $endTime ***" -f White -b DarkYellow
Write-Host "Time elapsed: $(New-Timespan $startTime $endTime)" -f White -b DarkRed

Stop-Transcript