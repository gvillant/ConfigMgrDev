'==========================================================================
' NAME   : Get_BADMIFS
' AUTHOR : Nick Moseley, https://t3chn1ck.wordpress.com
' DATE   : 5/14/2009
' UPDATE : 10/29/2014 - Added code to output the SMS Unique Identifier
' COMMENT: Ensure the value for sSMSInbox is the UNC path to your SCCM inboxes
'==========================================================================
Const ForReading = 1
Dim sSMSInbox, sNamePosition, bNameFound, sFileLine, sSystemName, iFileCount, oExcel, iRow
sSMSInbox = "\\FRPSCM01\SMS_STG\inboxes"
Set oShell = CreateObject("WScript.Shell")
Set oFSO = CreateObject("Scripting.FileSystemObject")
Set oBadDDRFolder = oFSO.GetFolder(sSMSInbox & "\ddm.box\BAD_DDRS")
Set cBadDDRFiles = oBadDDRFolder.Files
Set oBadMIFFolder = oFSO.GetFolder(sSMSInbox & "\auth\dataldr.box\BADMIFS")
Set colBadMIFFiles = oBadMIFFolder.Files
Set oExcel = CreateObject("Excel.Application")
 
' Create Excel Spreadsheet and Header
oExcel.Visible = True
Set oWorkbook = oExcel.Workbooks.Add
Set oWorksheet = oWorkbook.Worksheets(1)
iRow = 1
oExcel.Cells (iRow,1) = "System Name"
oExcel.Cells (iRow,2) = "File Name"
oExcel.Cells (iRow,3) = "File Date"
oExcel.Cells (iRow,4) = "File Size (MB)"
oExcel.Cells (iRow,5) = "SMS Unique ID"
' End Create
 
iFileCount = 0
For each oFile In colBadMIFFiles
    iFileCount = iFileCount + 1
    iRow = iRow + 1
    Set oMIFFile = oFSO.OpenTextFile (oFile.Path, ForReading, True)
     
    bNameFound = False
    Do Until bNameFound
        sFileLine = CStr (oMIFFile.ReadLine)
        sNamePosition = InStr (sFileLine, "<NetBIOS Name>")
        If sNamePosition > 1 Then
            sSystemName = Replace (Right (sFileLine, len(sFileLine) - (sNamePosition+14)), ">", "")
            sFoundBug = InStr (sSystemName, "//Client")
            If sFoundBug > 0 Then
                ' This is to fix a bug in the script which is undetermined
                ' Do Nothing
            Else
                oExcel.Cells (iRow,1) = sSystemName
                oExcel.Cells (iRow,2) = oFile.Name
                oExcel.Cells (iRow,3) = oFile.DateLastModified
                oExcel.Cells (iRow,4) = (oFile.Size/1024)/1024
                bNameFound = True
            End if
        End If
    Loop
    oMIFFile.Close
     
    Set oMIFFile = oFSO.OpenTextFile (oFile.Path, ForReading, True)
    bGuidFound = False
    Do Until bGuidFound
        sFileLine = CStr (oMIFFile.ReadLine)
        sNamePosition = InStr (sFileLine, "UniqueID")
        If sNamePosition > 1 Then
            sGUID = Replace (Right (sFileLine, len(sFileLine) - (sNamePosition+8)), ">", "")
                oExcel.Cells (iRow,5) = sGUID
                bGuidFound = True
        End If
    Loop   
    oMIFFile.Close
Next
 
oExcel.Range("A1:E1").Select
oExcel.Selection.Interior.ColorIndex = 19
oExcel.Selection.Font.ColorIndex = 11
oExcel.Selection.Font.Bold = True
oExcel.Cells.EntireColumn.AutoFit
oExcel.Cells.HorizontalAlignment = -4131
Set oExcelRange = oWorksheet.UsedRange
Set oExcelRangeA1 = oExcel.Range("A1")
oExcelRange.Sort oExcelRangeA1, 1, , , , , , 1
WScript.Echo "File Count: " & iFileCount