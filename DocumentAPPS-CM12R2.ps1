 $ListAllInformation = 1


        $Applications = Get-WmiObject -Class sms_application -Namespace root\sms\site_STG -ComputerName frpscm01.stago.grp
        if ($ListAllInformation)
            {
                if (-not [string]::IsNullOrEmpty($Applications))
                    {
                        write-host 0 1 "The following Applications are configured in this site:"
                        foreach ($Application in $Applications)
                            {                                
                                Write-Host "Getting specific WMI instance for this App"
                                [wmi]$Application = $Application.__PATH
                                Write-Host "$(Get-Date):   Found App: $($Application.LocalizedDisplayName)"
                                Write-Host 0 2 "$($Application.LocalizedDisplayName)" -bold
                                Write-Host 0 3 "Created by: $($Application.CreatedBy)"
                                Write-Host 0 3 "Date created: $($Application.DateCreated)"
                                Write-Host 0 3 "PackageID: $($Application.PackageID)"
                                $DTs = Get-CMDeploymentType -ApplicationName $Application.LocalizedDisplayName
                                if (-not [string]::IsNullOrEmpty($DTs))
                                    {                                       
                                        Write-Host 0 0 ""
                                        $Table = $Null
                                        $TableRange = $Null
                                        $TableRange = $doc.Application.Selection.Range
				                        $Columns = 3
                                        [int]$Rows = $DTs.count + 1
				                        Write-Host "$(Get-Date):   add Deployment Types to table"
				                        $Table = $doc.Tables.Add($TableRange, $Rows, $Columns)
				                        $table.Style = $TableStyle 
				                        $table.Borders.InsideLineStyle = 1
				                        $table.Borders.OutsideLineStyle = 1
				                        [int]$xRow = 1
				                        Write-Host "$(Get-Date):   format first row with column headings"
				                        
				                        $Table.Cell($xRow,1).Range.Font.Bold = $True
				                        $Table.Cell($xRow,1).Range.Font.Size = "10"
				                        $Table.Cell($xRow,1).Range.Text = "Deployment Type name"
				                
				                        $Table.Cell($xRow,2).Range.Font.Bold = $True
				                        $Table.Cell($xRow,2).Range.Font.Size = "10"
				                        $Table.Cell($xRow,2).Range.Text = "Technology"

				                        $Table.Cell($xRow,3).Range.Font.Bold = $True
				                        $Table.Cell($xRow,3).Range.Font.Size = "10"
				                        $Table.Cell($xRow,3).Range.Text = "Commandline"
                                        foreach ($DT in $DTs)
                                            {
                                                #[wmi]$DT = $DT.__PATH
                                                $xml = [xml]$DT.SDMPackageXML
                                                $xRow++							
					                            $Table.Cell($xRow,1).Range.Font.Size = "10"
					                            $Table.Cell($xRow,1).Range.Text = $DT.LocalizedDisplayName
					                            $Table.Cell($xRow,2).Range.Font.Size = "10"
					                            $Table.Cell($xRow,2).Range.Text = $DT.Technology
                                                if (-not ($DT.Technology -like "AppV*"))
                                                    { 
					                                    $Table.Cell($xRow,3).Range.Font.Size = "10"
					                                    $Table.Cell($xRow,3).Range.Text = $xml.AppMgmtDigest.DeploymentType.Installer.CustomData.InstallCommandLine
                                                    }
                                            }				
				                        $Table.Rows.SetLeftIndent(50,1) | Out-Null
				                        $table.AutoFitBehavior(1) | Out-Null
				                        #return focus back to document
				                        Write-Host "$(Get-Date):   return focus back to document"
				                        $doc.ActiveWindow.ActivePane.view.SeekView=$wdSeekMainDocument
                                        #move to the end of the current document
			                            Write-Host "$(Get-Date):   move to the end of the current document"
			                            $selection.EndKey($wdStory,$wdMove) | Out-Null
			                            Write-Host 0 0 ""
                           
                                    }
                                else
                                    {
                                        Write-Host 0 3 "There are no Deployment Types configured for this Application."
                                    }
                            }
                    }
                else
                    {
                        Write-Host 0 1 "There are no Applications configured in this site."
                    }
            }
        elseif ($Applications)
            {
                Write-Host 0 1 "There are $($Applications.count) applications configured."
            }
            else
                {
                    Write-Host 0 1 "There are no Applications configured."
                }
