get-childitem c:\users | where name -match "temp" | Remove-Item -recurse -force
#Remove Temp profiles

get-childitem c:\ | where name -match "temp" | Remove-Item -recurse -force
#Remote Temp folders on the root

foreach ($profile in (Get-CimInstance win32_userprofile | select sid, localpath, lastusetime)) {
#foreach profile on the computer
    $sid = $profile.sid #remember the sid
    $paths = $profile.localpath #remember the user profile path   

    foreach ($line in $paths) {
    #foreach path, do:
        if ($line -eq "C:\Users\*INSERT LOCAL ADMIN ACCOUNT*") {
        write-host "Did not delete *INSERT LOCAL ADMIN ACCOUNT*"
        #do not delete local admin
        } elseif ($line -eq "C:\Windows\ServiceProfiles\NetworkService") {        
        write-host "Did not delete NetworkService"
        #do not delete NetworkService account
        } elseif ($line -eq "C:\Windows\ServiceProfiles\LocalService") {
        write-host "Did not delete LocalService"
        #do not delete LocalService account
        } elseif ($line -eq "C:\Windows\system32\config\systemprofile") {
        write-host "Did not delete systemprofile"
        #do not delete systemprofile account
        } else {    
            write-host $sid                                      
            $currProf = Get-wmiobject win32_userprofile | where sid -eq $sid
            $currProf.Delete()
        }
       }
      }
     
$userfolders = (get-childitem c:\users)
#get all of the user folders on a machine
foreach ($folder in $userfolders) {
#for each user folder
if ($folder.name -ne $env:username){
#if the user folder is not equal to the current user of the machine
    if ($folder.name -ne "Public"){ 
    #and the user folder is not equal to Public
    Remove-Item -path c:\users\$folder -recurse -force    
    #delete the user folder
    }
  }
}
          
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 8
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 2
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 1
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 16
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 32
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 255
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 4351
#these rundlls are built into IE and are the triggers to force cleanups    
#not sure these will work without a user logged in, but worth a shot - won't hurt anything

$tempfolders = @("C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Users\*\Appdata\Local\Temp\*")
#set tempfolders to all of the temp folders on the machine
#the wildcard in the c:\users says "do this for all users ever on this machine"
Remove-Item $tempfolders -force -recurse
#clean up temp
