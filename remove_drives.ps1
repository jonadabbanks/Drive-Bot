

    $ErrorActionPreference = 'SilentlyContinue'
    $file = Get-Content -Path  C:\ProgramData\Drive\files\NULL.txt
    $file | Out-File -FilePath C:\ProgramData\Drive\files\FLOW.txt
  # This part of the script gets only plugged in usb devices 
  Get-WmiObject Win32_USBControllerDevice |ForEach-Object{[wmi]($_.Dependent)} | Where-Object {($_.Description -like '*mass*')} | Sort-Object Description, pnpclass,DeviceID | Format-Table DeviceID  -auto | Format-Table -AutoSize | Out-File -FilePath C:\ProgramData\Drive\files\GET_DISK.txt 
  (Get-Content C:\ProgramData\Drive\files\GET_DISK.txt ) | Where-Object {$_.trim() -ne "" } | set-content C:\ProgramData\Drive\files\GET_DISK.txt
  $exclude = 1,2	
 
  $drives = Get-Content "C:\ProgramData\Drive\files\GET_DISK.txt" | Where-Object { $_.ReadCount -NotIn $exclude }
  $drives | Out-File -FilePath C:\ProgramData\Drive\files\GET_DISK.txt
  #drive ui checker to keep it running 
  
  # This part of the script compares the newly scanned drives with the registered ones, and isolate the unregistered ones 
  $registered = Get-Content -Path  C:\ProgramData\Drive\files\REGISTERED_DRIVE.txt
   $registered = $registered.Substring(0,43)
   $registered = $registered.Trim()
  $unregistered = Get-Content -Path  C:\ProgramData\Drive\files\GET_DISK.txt | Where-Object {$_ -notin $registered} 
  $unregistered | Out-File -FilePath C:\ProgramData\Drive\files\Unauthorized.txt 
  #added a text file to merge both ui control for phones and drives
  $unregistered | Out-File -FilePath C:\ProgramData\Drive\files\UI.txt 
  Start-sleep -Seconds 1
   # conditional statement to know when an unregistered drive is connected 
  if ($Null -eq (Get-Content -Path  "C:\ProgramData\Drive\files\Unauthorized.txt")){ 
  $null = Get-Content -Path  C:\ProgramData\Drive\files\NULL.txt
  $null | Out-File -FilePath C:\ProgramData\Drive\files\mounted.txt
  }Else{
   #This part of the script filters the instance id from isolated drives.
  $id = Get-Content C:\ProgramData\Drive\files\Unauthorized.txt
  $id = $id.trim()
  #this code tells the program to leave temp authorised drives.
  $mounted = Get-Content -Path  C:\ProgramData\Drive\files\mounted.txt
  $notmounted = $id | Where-Object {$_ -notin $mounted} 
  $notmounted | Out-File -FilePath  C:\ProgramData\Drive\files\notmounted.txt
  if ($Null -eq (Get-Content -Path  "C:\ProgramData\Drive\files\notmounted.txt")){ 
  }Else{
  #this scrip removes the unregistered drives using its instance id 
  

#add a checker that will reduce the stress on the script: A checker that will know if a drive has been removed or not using  its status as the paremeter
  foreach-object {		
  Disable-PnpDevice  -InstanceId $notmounted -Confirm:$false -ErrorAction SilentlyContinue}

  #this script alerts the ui to pop out an insert password gui.
  "ALERT" | Out-File -FilePath  C:\ProgramData\Drive\files\hotkey.txt
  
  if ($Null -eq (Get-Content -Path  "C:\ProgramData\Drive\files\online.txt")){
    }Else{
  foreach-object {
  $notmounted = Get-Content -Path   C:\ProgramData\Drive\files\notmounted.txt  
  Enable-PnpDevice  -InstanceId $notmounted -Confirm:$false  -Ev Err -EA SilentlyContinue}
  #this saves the temp drive allowed not to be removed when the cycle begins again 
  
  Add-Content C:\ProgramData\Drive\files\mounted.txt $notmounted
  #this reloads the enable drive zone to be used again 
  $file = Get-Content -Path  C:\ProgramData\Drive\files\NULL.txt
  $file | Out-File -FilePath C:\ProgramData\Drive\files\online.txt
 
}
}

}
