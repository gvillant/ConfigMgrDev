' Specify name of tag file to search for
strTagFile = "PrestagedMedia.wim"

' Create filesystem object
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Create TaskSequence Env object
Set TsENV = CreateObject("Microsoft.SMS.TSEnvironment")

' Recover from errors in the code (prevent from ending script)
On Error Resume Next

' Access the WMI service on this computer
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
If Err.Number = 0 Then
   ' Query WMI for all disks on the system
   Set colDisks = objWMIService.ExecQuery("Select * from Win32_LogicalDisk") 'Where DriveType = 3
     
   ' Search this drive for the file
   For Each objDisk in colDisks
      If objFSO.FileExists(objDisk.DeviceID & "\" & strTagFile) Then
         strFullPath = objDisk.DeviceID & "\" & strTagFile
		 Wscript.Echo "Match found: " & strFullPath
		 TsENV("PrestagedMedia")=strFullPath
      End If
   Next
     
   ' Release objects
   Set colDisks = Nothing
   Set objWMIService = Nothing
End If

Wscript.Echo "TS Variable PrestagedMedia is now : " & strFullPath

