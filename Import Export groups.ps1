#This script will either export a group members then re-import them with a new group name in a cloud only distribution group
#Or it will create a cloud only distribution group from an already existing CSV file with user's primary SMTP address


Function Show-Menu 
{
    cls
    Write-Host "===========Export Import AD group as cloud only distribution group========="
	
    Write-host "1: Press 1 to copy a distribution group with a new name"
    Write-Host "2: Press 2 to create a new group from CSV (must be PrimarySmtpAddress)"
	Write-Host "3: Press 3 to export a distribution list from M365"
    write-host "q: Press q to quit"
}


Function Get-FileName ($initialDirectory)
{
	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

	$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	$OpenFileDialog.initialDirectory = $initialDirectory
	$OpenFileDialog.filter = "CSV (*.csv) | *.csv"
	$OpenFileDialog.ShowDialog() | Out-Null
	$OpenFileDialog.filename
}


Import-Module ExchangeOnlineManagement

cls

$User = Read-Host "Please enter your M365 admin username: "

Connect-ExchangeOnline -UserPrincipalName $User


do
{
    Show-Menu
    $input = Read-Host "Please make a selection"
    
    switch ($input)
    {
        '1'{
			Write-Host "`nThis Funtion is still under construction, tread lightly"
			
			Write-Host "`nOnly use this to create a new group that has a different name from the original"
			
            $oldgroup = Read-Host "`nPlease enter the name of the group to copy"
            $newgroupname1 = Read-Host "`nPlease enter the name of the new group"
			
			if ($oldgroup -eq $newgroupname)
			{
				write-host "`nThe names cannot be the same"
			
			} else {
				Write-Host "`nNow enter the alias and the Primary SMTP address of the group.m" 
				
				$newgroupalias1 = Read-Host "`nPlease enter the new group alias for the Group"
				$newgroupSMTP = Read-Host "`nPlease enter the full Primary SMTP address for the new group"
				
				Get-DistributionGroupMember -Identity $oldgroup | Select PrimarySmtpAddress |
					Export-CSV "C:\DistExports\$oldgroup.csv" -NoTypeInformation -Encoding UTF8
				
				New-DistributionGroup -Name $newgroupname1 -Alias $newgroupalias1 -Displayname $newgroupname1
				
				import-csv "C:\DistExports\$oldgroup.csv" | foreach {add-distributiongroupmember -identity $newgroupname1 -member $_.PrimarySmtpAddress}
			}

        }
        '2'{
			Write-Host "`nThis funtion will allow you to import from a CSV file with user PrimarySmtpAddress"
			Pause
			
            Write-Host "`nPlease select the file you wish to import"
            Pause
			
            $inputfile = Get-FileName "C:\DistExports"
			
			do {
				$newgroupname = Read-Host "`nPlease enter the name of the new group"
			
				Write-Host "`nNow enter the alias and the Primary SMTP address of the group. (Alias can contain no spaces)"
			
				$newgroupalias = Read-Host "`nPlease enter the new group alias for the Group"
				$newgroupSMTP = Read-Host "`nPlease enter the full Primary SMTP address for the new group"
			
				cls
			
				Write-Host "`n`n`n`nGroup Name: $newgroupname"
				Write-Host "Group Alias: $newgroupalias"
				Write-Host "Group Primary SMTP address: $newgroupSMTP"
				
				$confirm = Read-Host "`nPlease press y to confirm the above names are correct"
			} until ($confirm -eq 'y')
			
				
            New-DistributionGroup -Name $newgroupname -Alias $newgroupalias -Displayname $newgroupname -PrimarySmtpAddress $newgroupSMTP

            import-csv $inputfile | foreach {add-distributiongroupmember -identity $newgroupname -member $_.PrimarySmtpAddress}
            
        }
		'3'{
			Write-Host "`nThis funtion will output a CSV file to C:\DistExports`n"
			$groupname = Read-Host "Please enter the name of the group you wish to export"
			
			Get-DistributionGroupMember -Identity $groupname | Select PrimarySmtpAddress |
				Export-CSV "C:\DistExports\$groupname.csv" -NoTypeInformation -Encoding UTF8
		}
        'q'{
            Disconnect-ExchangeOnline
            return
        }
		default {
			write-host "Incorrect input"
		}
    }
    pause
}
until ($input -eq 'q')

