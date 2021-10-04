Function Write-log{
<#
.SYNOPSIS
    Log file writer - cmtrace.exe compatible.

.DESCRIPTION
    Writes log files from scripts.

.NOTES
    V:1.2

.LINK
    <empty>

.EXAMPLE
     Parameter usage:  
     C:\Windows> Write-log -Message "This is a Testmessage" -Program MyProgram -DisplayOutput $True -LogFile C:\logfile.log -LogFileComponent MyComponent -EnableExit -Severity 1

.PARAMETER LogFile
    Full name of the logfile.
    Logging is written in configuration manager syntax.
    For best view use CMTrace.exe or Trace32.exe.
    If Logfile parameter equals '-' no logfile is created.

.PARAMETER Message
    Defines if text written to the logfile is shown in powershell window.
    Default is to show any output.

.PARAMETER Program
    Program where log information comes from.
    Default is 'Unknown'
    (This information is shown as 'Source' in cmtrace.exe)

.PARAMETER LogFileComponent
    Component where log information comes from.
    (This information is shown as 'Component' in cmtrace.exe)

.PARAMETER Severity
    Defines message type.
    1 = information
    2 = warning
    3 = error
    If $error variable is not empty servity is automatically put to 3.

.PARAMETER Thread
    Thread where log information comes from.
    Valid only from 0 (0x0000) to 65535 (0xFFFF).

.PARAMETER EnableExit
    If this parameter is set and an error occours the 'EXIT' command is executed.
    This is helpful for fatal errors that cause the script not to run.

.PARAMETER EnableBreak
    If this parameter is set and an error occours the 'BREAK' command is executed.
    This is helpful to exit a foreach loop on error.

.PARAMETER EnableNext
    If this parameter is set and an error occours the 'NEXT' command is executed.
    This is helpful to skip an element in foreach loop on error.

.PARAMETER MaxSize
    Defines the maximum logfile size in KB.
    If logfile is bigger than defined, '_' to extension of logfile.
    Existing 'old logs' with naming of '_' are overridden.
    If MaxSize is 0, logfile is never renamed.

#>

PARAM(
    [parameter(Mandatory=$true)] [String]$Message,
    [parameter(Mandatory=$true)] [String]$LogFile,
    [parameter(Mandatory=$false)] [String]$Program="Unknown",
    [parameter(Mandatory=$false)] [String]$LogFileComponent="Unknown",
    [parameter(Mandatory=$false)] [int][ValidateRange(1,3)]$Severity = 1,
    [parameter(Mandatory=$false)] [Switch]$EnableExit,
    [parameter(Mandatory=$false)] [Switch]$EnableBreak,
    [parameter(Mandatory=$false)] [Switch]$EnableNext,
    [parameter(Mandatory=$false)] [ValidateSet($true, $false)]$DisplayOutput = $false,
    [parameter(Mandatory=$false)] [ValidateRange(0,65535)]$Thread,
    [parameter(Mandatory=$false)] [int]$MaxSize=0
    )
begin 
    { 
    $TimeZoneBias = Get-WmiObject -Query "Select Bias from Win32_TimeZone" -ComputerName $env:COMPUTERNAME
    $Date1= Get-Date -Format "HH:mm:ss.fff"
    $Date2= Get-Date -Format "MM-dd-yyyy"
    $Type=1
    }
process 
    {
    if ($LogFile -ne '-')
        {    
        if(($Error.Count -ne 0) -or ($Severity -eq 3))
            {
            $Message = $Message + "-->Failed with error: $Error"
            $Severity = 3
            }
        Elseif($Severity -eq 2)
            {
            $Message = $Message + "-->Successful with warning"
            }
        else
            {
            $Message = $Message + "-->Successfully finished"
            }      
        "<![LOG[$Message]LOG]!><time=`"$Date1+$($TimeZoneBias.bias)`" date=`"$Date2`" component=`"$LogFileComponent`" context=`"`" type=`"$Severity`" thread=`"$Thread`" file=`"$Program`">" | Out-File -FilePath $LogFile -Append -NoClobber -Encoding default
        }

    if($DisplayOutput -ne $false)
        {
        switch ($Severity)
            {
            3{Write-Host $Message -ForegroundColor Red}
            2{Write-Host $Message -ForegroundColor Yellow}
		    1{Write-Host $Message -ForegroundColor Green}
            }
        }
    }
end  
    {
    if(($EnableExit.IsPresent -eq $true) -and ($Severity -eq 3))
        {
        $Error.Clear()
        EXIT
        }
    Elseif(($EnableBreak.IsPresent -eq $true) -and ($Severity -eq 3))
        {
        $Error.Clear()
        Break
        }
    Elseif(($EnableNext.IsPresent -eq $true) -and ($Severity -eq 3))
        {
        $Error.Clear()
        Continue
        }
    Else
        {
        $Error.Clear()

        if($MaxSize -gt 0)
            {
            $File = Get-ChildItem $LogFile -Force
            $FileSize = $File.Length/1KB
            if($fileSize -ge $MaxSize)
                {
                Write-Host Greater -ForegroundColor Red
                $OldLog = $($file.FullName -replace $($File.Extension),$($File.Extension.Substring(0,($File.Extension.Length -1)) + "_"))
                move-Item -LiteralPath $file.FullName -Destination $OldLog -Force
                Write-log -Message $("Logfile size $MaxSize KB reached. Renamed logfile " + $File.FullName + " to " + $OldLog) -Program $($Program + "_Write-Log") -LogFile $LogFile -LogFileComponent $($LogFileComponent + "_Write-Log") -Thread $Thread -Severity 1                
                }
            }

        }
    }
}