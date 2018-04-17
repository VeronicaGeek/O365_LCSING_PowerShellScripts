<#
.Synopsis
    This function will export specific users and their associated Admin role.
.DESCRIPTION
    This function will export specific users (from .csv file) and their associated Admin role.
.EXAMPLE
    .\Export-AdminRolePerUser -InputFile "C:\MyUsers.csv" -OutputFile "C:\MyOutputFile.csv"

    This command will export to a .csv file the admin permissions for users provided using the -InputFile parameter.
.INPUTS
    CSV file containing all the users to check.
.OUTPUTS
    Data in a .CSV file at the location specified when using the -OutputFile parameter.
.NOTES
    If multiple Admin roles per user, don't forget to format the output file to display the full content of the cell in Excel.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
    [parameter(Mandatory=$true, HelpMessage="Enter the path of the file containing the users (i.e.: C:\MyUsers.csv)", Position=0)]
    [string]$InputFile,
    [parameter(Mandatory=$true, HelpMessage="Enter the path of the file to export users -- i.e.: C:\MyOutputFile.csv", Position=1)]
    [string]$OutputFile
)

try{
    $CsvUsers = Import-Csv $InputFile
    $RolePerUser = @()

    foreach($row in $CsvUsers){

        $UPN = $row.UserPrincipalName
        $AllRoles = Get-MsolUserRole -UserPrincipalName $row.UserPrincipalName -ErrorAction Stop

            $properties = @{
                Role = ((Get-MsolUserRole -UserPrincipalName $UPN).Name -join "`r`n")
                RoleDescription = ((Get-MsolUserRole -UserPrincipalName $UPN).Description -join "`n")
                DisplayName = (Get-MsolUser -UserPrincipalName $UPN).DisplayName
                UserPrincipalName = $row.UserPrincipalName
                Licensed = (Get-MsolUser -UserPrincipalName $UPN).IsLicensed
            }
        $RolePerUser += New-Object PSObject -Property $properties
    }
        $RolePerUser | Select-Object Role, RoleDescription, DisplayName, UserPrincipalName, Licensed | Export-Csv -Path $OutputFile -NoTypeInformation
    }

catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException]{
    Write-Verbose -Message "The cmdlet Get-MsolUser returned an error: $($_.Exception.Message)" -Verbose
    break
}

Write-Host "Export completed. Output file is located at $OutputFile" -ForegroundColor Green