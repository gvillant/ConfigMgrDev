<#
.SYNOPSIS
	Script to get ComputerCountry from 2 first digits of computerName
.DESCRIPTION
	The script will get the 2 first digits of computername and return it.
    This script is set in SCCM 2012 "Global condition"
.PARAMETER SMSProvider
    none
.EXAMPLE
.INPUTS
	None.  You cannot pipe objects to this script.
.OUTPUTS
	None.
.LINK
	
.NOTES
	NAME: get-computercountry.ps1
	VERSION: 1.0
	AUTHOR: Gaetan VILLANT @ Dell for STAGO
	LASTEDIT: February,2 2014
    Change history:
	v1.0: initial release
.REMARKS
#>

function get-computercountry
    {
$computer = gc env:computername
$ComputerCountry = $computer.substring(0,2)
write-host $ComputerCountry
}

get-computercountry
