# M365-groups
Repository for M365 tools and scripts

ImportExportGroups.ps1 is used to export group members to a CSV and create new groups by uploading a CSV file.


If the script dies after you put in your MFA code then you need to enable basic authentication (Computer in InTune seem to all have this disabled).
Open the registry and go to:  Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client
Then change "AllowBasic" to 1.