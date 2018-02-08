[CmdletBinding()]
param 
(
    [parameter()]
    [string]
    $TaskName = 'Update-XYLiteDB',
    
    [parameter()]
    [string]
    $FilePath = 'C:\Github\Public\dev\PSLiteDB_Filesystem\ScheduledJobs\UpdateXYLiteDB.ps1',

    [parameter()]
    [timespan]
    $Repetition = (New-TimeSpan -Minutes 45)
)
#This scheduled task will reset all local changes in E:\Cortex-Github
#This script will also pull the latest changes from saasplaza github to the Cortex repo.


try
{
    ipmo "C:\Github\Public\dev\PSLiteDB_Filesystem\PSLiteDB.psd1"  
    Update-XYRecord

    sleep -Seconds 5 
    
    Remove-XYOrphan
}
catch
{
    

    $message = $_ | Format-List * -Force | Out-String
    $message | Out-File c:\temp\schedjobs_xy_error.txt -Append
        
}



if( (Get-ScheduledJob).Name -notcontains $TaskName)
{
    #Create the JOB Trigger
    $Trigger = New-JobTrigger -Once -At 6:15AM -RepetitionInterval $Repetition -RepeatIndefinitely

    Register-ScheduledJob -Name $TaskName -FilePath $FilePath -Trigger $Trigger 
    #Unregister-ScheduledJob -Name $TaskName -Force -Confirm:$false
}


