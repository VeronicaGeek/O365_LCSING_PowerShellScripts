<#
.Synopsis
   This script will loop through your CSV file and retrieve the licensed and/or blocked information.
.DESCRIPTION
   This script will loop through your CSV file and retrieve the licensed and/or blocked information, then export a .CSV file called "Output_File" onto the desktop.
   A transcript will also be created and the path will be displayed on the console.
.EXAMPLE
   .\Retrieve_StatusLicensedBlocked_FromCsvFile.ps1 -TenantName <TenantName> -CsvFileLocation <CsvFile_Location>
.EXAMPLE
   .\Retrieve_StatusLicensedBlocked_FromCsvFile.ps1 (if no parameters are entered, you will be prompted for them)

==========================================
Author: Veronique Lengelle (@VeronicaGeek)
Date: 02 Jan 2017 
Version: 1.0
==========================================
#>
[CmdletBinding()]
param(    
    [Parameter(Mandatory=$true,HelpMessage="This is the location of the CSV file containing all the users",Position=2)] 
    [string]$CsvFileLocation
)
Start-Transcript
#Start Time
$startTime = "{0:G}" -f (Get-date)
Write-Host "*** Script started on $startTime ***" -f White -b DarkYellow

#Connect to O365
$cred = Get-Credential
Connect-MsolService -Credential $cred

# Check if the below output .CSV file name exists - If yes, delete it.
Write-Host "Checking if an Output file already exists..." -f Gray
$OutputFile = "C:\users\$env:USERNAME\desktop\Output_File.csv"
    If (test-Path $OutputFile)
        {
		   Write-Host "Output file with same name found - Deleting it now..." -f Yellow
           Remove-Item $OutputFile
        }
    Else
        {
		   Write-Host "No output file found - OK." -f Gray
        }


#Import users
$UsersList = Import-csv $CsvFileLocation

$Results = @()
foreach ($user in $UsersList) 
    {
        Write-Host ">> Checking" $user.UserPrincipalName
        $Results += (Get-MsolUser -UserPrincipalName $user.UserPrincipalName) | select UserPrincipalName,isLicensed,BlockCredential
    }
   
$Results | Export-Csv $OutputFile

#End Time
$endTime = "{0:G}" -f (Get-date)
Write-Host "*** Script finished on $endTime ***" -f White -b DarkYellow
Write-Host "Time elapsed: $(New-Timespan $startTime $endTime)" -f White -b DarkRed

Stop-Transcript