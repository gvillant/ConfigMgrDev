
' Script will change the value of ScriptExecutionTimeOut for ConfigMgr DCM in site settings
' clients should download new policies
' http://blogs.msdn.com/b/fei_xias_blog/archive/2013/10/21/system-center-2012-configmgr-using-vbs-to-extend-the-dcm-script-execution-timeout-value.aspx
' client side check: connect to the namespace "root\ccm\policy\machine\actualconfig" 
' then run query "Select ScriptExecutionTimeout from CCM_ConfigurationManagementClientConfig"

' command line: cscript ConfigMgr-ScriptExecutionTimeOut-Increase.vbs SITESERVER SITECODE

On Error Resume Next

' Define string variables

Class_Name =        "SMS_SCI_ClientComp"
Class_ItemName =    "Configuration Management Agent"
Class_ItemType =    "Client Component"
Property_Name =     "ScriptExecutionTimeout"
NewValue =          "300"

' Check command line parameters ?on failure, report the error and terminate.
' The SMS Provider server name and the site code are required.

set args=wscript.arguments

If args.Count = 2 then
    SMSProviderServer = UCASE(Wscript.Arguments(0))
    SiteCode = UCASE(Wscript.Arguments(1))
Else
    wscript.Echo "Incorrect command line arguments." & vbCrLf & "Usage: cscript /nologo ModifySCFProperty.vbs <smsproviderserver> <sitecode>" & vbCrLf & "Example: cscript /nologo ModifySCFProperty.vbs SERVER1 S01" & vbCrLf
    WScript.Quit(1)
End If


' Connect to the SMS Provider ?on failure, report the error and exit.

SMSProviderServer = "\\" + SMSProviderServer + "\"
Set ObjSvc = GetObject("winmgmts:" & "{impersonationLevel=Impersonate,authenticationLevel=Pkt}!" & SMSProviderServer & "root\sms\site_" & SiteCode)

If Err.Number <> 0 Then
    wscript.Echo "Failed to connect to provider server with code: " & Err.Number & ".  Exiting!"
    WScript.Quit(2)
End If

' Get the requested instance of the class ?on failure, report the error and exit.

Set objInst = ObjSvc.Get(Class_Name & ".ItemName='" & Class_ItemName & "',ItemType='" & Class_ItemType & "',SiteCode='" & SiteCode &"'")

If Err.Number <> 0 Then
    WScript.Echo "Failed to open desired object with error code " & Err.Number & " (" & Err.Description & ").  Exiting!"
    WScript.Quit(3)
End If

' Loop through the properties until we find a match (or run out of properties) ?on failure, report the error and exit.

bFoundProperty = False

For Each objProp in objInst.Props
    If objProp.PropertyName = Property_Name Then
        bFoundProperty = True
        Exit For
    End If
Next

If bFoundProperty = False Then
    WScript.Echo "Requested class instance was found but the property was not found.  Exiting without making any changes."
    WScript.Quit(4)
End If 

' Property found. Check to see if existing value matches, change it as appropriate - on failure to save, report the error and exit.

If objProp.Value = NewValue Then
    WScript.Echo "Property '" & Property_Name & "' found and matches the new value '" & NewValue & "'.  Not making any changes."
    WScript.Quit(0)
Else
    OriginalValue = objProp.Value
    objProp.Value = NewValue
    objProp.Put_
    objInst.Put_

    If Err.Number <> 0 Then
        wscript.Echo "Failed to save the change with error code: " & Err.Number & ".  Exiting!"
        WScript.Quit(5)
    Else
        WScript.Echo "Property '" & Property_Name & "' successfully change from '" & OriginalValue & "' to '" & NewValue & "'."
    End If
End If

 