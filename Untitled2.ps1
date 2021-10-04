


	$AvailSelect = New-Object 'System.Windows.Forms.DataGridViewCheckBoxColumn'
	$GridMake = New-Object 'System.Windows.Forms.DataGridViewTextBoxColumn'
	$GridModel = New-Object 'System.Windows.Forms.DataGridViewTextBoxColumn'
	$AvailWindows = New-Object 'System.Windows.Forms.DataGridViewTextBoxColumn'
	$AvailArchitecture = New-Object 'System.Windows.Forms.DataGridViewTextBoxColumn'
	$KnownModel = New-Object 'System.Windows.Forms.DataGridViewTextBoxColumn'
	$SearchResult = New-Object 'System.Windows.Forms.DataGridViewTextBoxColumn'


#
	# MakeModelDataGrid
	#
	$MakeModelDataGrid.AllowUserToAddRows = $False
	$MakeModelDataGrid.AllowUserToDeleteRows = $False
	$MakeModelDataGrid.AllowUserToResizeColumns = $False
	$MakeModelDataGrid.AllowUserToResizeRows = $False
	$MakeModelDataGrid.Anchor = 'Top, Bottom, Left, Right'
	$MakeModelDataGrid.AutoSizeColumnsMode = 'AllCells'
	$MakeModelDataGrid.BackgroundColor = 'WhiteSmoke'
	$System_Windows_Forms_DataGridViewCellStyle_1 = New-Object 'System.Windows.Forms.DataGridViewCellStyle'
	$System_Windows_Forms_DataGridViewCellStyle_1.Alignment = 'MiddleLeft'
	$System_Windows_Forms_DataGridViewCellStyle_1.BackColor = 'WhiteSmoke'
	$System_Windows_Forms_DataGridViewCellStyle_1.Font = 'Segoe UI Semibold, 9pt, style=Bold'
	$System_Windows_Forms_DataGridViewCellStyle_1.ForeColor = 'WindowText'
	$System_Windows_Forms_DataGridViewCellStyle_1.SelectionBackColor = 'Highlight'
	$System_Windows_Forms_DataGridViewCellStyle_1.SelectionForeColor = 'HighlightText'
	$System_Windows_Forms_DataGridViewCellStyle_1.WrapMode = 'True'
	$MakeModelDataGrid.ColumnHeadersDefaultCellStyle = $System_Windows_Forms_DataGridViewCellStyle_1
	$MakeModelDataGrid.ColumnHeadersHeight = 30
	[void]$MakeModelDataGrid.Columns.Add($AvailSelect)
	[void]$MakeModelDataGrid.Columns.Add($GridMake)
	[void]$MakeModelDataGrid.Columns.Add($GridModel)
	[void]$MakeModelDataGrid.Columns.Add($AvailWindows)
	[void]$MakeModelDataGrid.Columns.Add($AvailArchitecture)
	[void]$MakeModelDataGrid.Columns.Add($KnownModel)
	[void]$MakeModelDataGrid.Columns.Add($SearchResult)
	$System_Windows_Forms_DataGridViewCellStyle_2 = New-Object 'System.Windows.Forms.DataGridViewCellStyle'
	$System_Windows_Forms_DataGridViewCellStyle_2.Alignment = 'MiddleLeft'
	$System_Windows_Forms_DataGridViewCellStyle_2.BackColor = 'WhiteSmoke'
	$System_Windows_Forms_DataGridViewCellStyle_2.Font = 'Segoe UI Semibold, 9pt, style=Bold'
	$System_Windows_Forms_DataGridViewCellStyle_2.ForeColor = 'ControlText'
	$System_Windows_Forms_DataGridViewCellStyle_2.SelectionBackColor = 'Maroon'
	$System_Windows_Forms_DataGridViewCellStyle_2.SelectionForeColor = 'HighlightText'
	$System_Windows_Forms_DataGridViewCellStyle_2.WrapMode = 'False'
	$MakeModelDataGrid.DefaultCellStyle = $System_Windows_Forms_DataGridViewCellStyle_2
	$MakeModelDataGrid.GridColor = 'WhiteSmoke'
	$MakeModelDataGrid.Location = '0, 38'
	$MakeModelDataGrid.Name = 'MakeModelDataGrid'
	$System_Windows_Forms_DataGridViewCellStyle_3 = New-Object 'System.Windows.Forms.DataGridViewCellStyle'
	$System_Windows_Forms_DataGridViewCellStyle_3.Alignment = 'MiddleLeft'
	$System_Windows_Forms_DataGridViewCellStyle_3.BackColor = 'WhiteSmoke'
	$System_Windows_Forms_DataGridViewCellStyle_3.Font = 'Segoe UI Semibold, 9pt, style=Bold'
	$System_Windows_Forms_DataGridViewCellStyle_3.ForeColor = 'Black'
	$System_Windows_Forms_DataGridViewCellStyle_3.SelectionBackColor = 'Maroon'
	$System_Windows_Forms_DataGridViewCellStyle_3.SelectionForeColor = 'HighlightText'
	$System_Windows_Forms_DataGridViewCellStyle_3.WrapMode = 'True'
	$MakeModelDataGrid.RowHeadersDefaultCellStyle = $System_Windows_Forms_DataGridViewCellStyle_3
	$MakeModelDataGrid.RowHeadersVisible = $False
	$MakeModelDataGrid.RowHeadersWidth = 20
	$MakeModelDataGrid.RowTemplate.DefaultCellStyle.BackColor = 'WhiteSmoke'
	$MakeModelDataGrid.RowTemplate.Height = 24
	$MakeModelDataGrid.SelectionMode = 'FullRowSelect'
	$MakeModelDataGrid.Size = '1110, 222'
	$MakeModelDataGrid.TabIndex = 2
	$MakeModelDataGrid.add_CurrentCellDirtyStateChanged($MakeModelDataGrid_CurrentCellDirtyStateChanged)
	$MakeModelDataGrid.add_KeyPress($MakeModelDataGrid_KeyPress)
	#