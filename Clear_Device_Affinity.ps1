############################################################
###                                                      ###
###                                                      ###
###          Script to remove Device Affinity            ###
###                   in ConfigMgr                       ###
###                                                      ###
###         Tested on ConfigMgr 2012 and 2012 R2         ###
###                                                      ###
###                                                      ###
###                    Version 1.0                       ###
###                                                      ###
###                     2013-10-23                       ###
###                                                      ###
###                   by Tim Nilimaa                     ###
###                                                      ###
###               @timnilimaa on Twitter                 ###
###                                                      ###
###                                                      ###
###                http://infoworks.tv                   ###
###                                                      ###
###                                                      ###
###                                                      ###
############################################################

#Find the PowerShell Module for ConfigMgr
$ConfigMgrModulePath = Join-Path ($Env:SMS_ADMIN_UI_PATH.ToString().SubString(0,$Env:SMS_ADMIN_UI_PATH.Length - 5)) "ConfigurationManager.psd1"

#Load the PowerShell module for ConfigMgr
Import-Module $ConfigMgrModulePath -Verbose

#Ask the user if we are running 'debug' or 'for real'
            $title = "Execution Mode"            $message = "Would you like to run in Execute Mode or Demo Mode?"            $exec = New-Object System.Management.Automation.Host.ChoiceDescription "&Execute", `                "Executes action to remove User/Device Affinity."            $query = New-Object System.Management.Automation.Host.ChoiceDescription "&Demo", `                "Performs Query to see what would have been done."            $options = [System.Management.Automation.Host.ChoiceDescription[]]($exec, $query)            #Mode value 0 = execute, 1 = query            $ExecutionMode = $host.ui.PromptForChoice($title, $message, $options, 0) 


#Enter PSDrive
cd "$((Get-PSDrive -PSProvider CMSite).Name):"

#Get all those devices
foreach ($Device in (Get-CMDevice))
{
    #Get ALL users registred on this device
    $PrimaryUsers = Get-CMUserDeviceAffinity -DeviceNam $Device.Name
    #For each user on that device...
    foreach ($PrimaryUser in $PrimaryUsers)
    {
        # ... try to...
        try
        {
            # if we are in execution mode of course...
            if ($ExecutionMode -eq 0)
            {
                # remove the device from the user
                Remove-CMDeviceAffinityFromUser -DeviceId $Device.ResourceID -UserName $PrimaryUser.UniqueUserName
                Write-Host "Successfully removed device $($Device.Name) from user $($PrimaryUser.UniqueUserName)."
            }
            else
            {
                Write-Host "Would remove device $($Device.Name) from user $($PrimaryUser.UniqueUserName)."
            }
        }
        catch
        {
            Write-Error "Unable to remove device $($Device.Name) from user $($PrimaryUser.UniqueUserName)."
            break
        }
    }
}
# SIG # Begin signature block
# MIIi8QYJKoZIhvcNAQcCoIIi4jCCIt4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfwJzkuW2gT3zZ24AKN4Hr7z0
# ON2ggh4jMIIDtzCCAp+gAwIBAgIQDOfg5RfYRv6P5WD8G/AwOTANBgkqhkiG9w0B
# AQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMDYxMTEwMDAwMDAwWhcNMzExMTEwMDAwMDAwWjBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCtDhXO5EOAXLGH87dg
# +XESpa7cJpSIqvTO9SA5KFhgDPiA2qkVlTJhPLWxKISKityfCgyDF3qPkKyK53lT
# XDGEKvYPmDI2dsze3Tyoou9q+yHyUmHfnyDXH+Kx2f4YZNISW1/5WBg1vEfNoTb5
# a3/UsDg+wRvDjDPZ2C8Y/igPs6eD1sNuRMBhNZYW/lmci3Zt1/GiSw0r/wty2p5g
# 0I6QNcZ4VYcgoc/lbQrISXwxmDNsIumH0DJaoroTghHtORedmTpyoeb6pNnVFzF1
# roV9Iq4/AUaG9ih5yLHa5FcXxH4cDrC0kqZWs72yl+2qp/C3xag/lRbQ/6GW6whf
# GHdPAgMBAAGjYzBhMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
# A1UdDgQWBBRF66Kv9JLLgjEtUYunpyGd823IDzAfBgNVHSMEGDAWgBRF66Kv9JLL
# gjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEAog683+Lt8ONyc3pklL/3
# cmbYMuRCdWKuh+vy1dneVrOfzM4UKLkNl2BcEkxY5NM9g0lFWJc1aRqoR+pWxnmr
# EthngYTffwk8lOa4JiwgvT2zKIn3X/8i4peEH+ll74fg38FnSbNd67IJKusm7Xi+
# fT8r87cmNW1fiQG2SVufAQWbqz0lwcy2f8Lxb4bG+mRo64EtlOtCt/qMHt1i8b5Q
# Z7dsvfPxH2sMNgcWfzd8qVttevESRmCD1ycEvkvOl77DZypoEd+A5wwzZr8TDRRu
# 838fYxAe+o0bJW1sj6W3YQGx0qMmoRBxna3iw/nDmVG3KwcIzi7mULKn+gpFL6Lw
# 8jCCBmowggVSoAMCAQICEAOf7e3LeVuN7TIMiRnwNokwDQYJKoZIhvcNAQEFBQAw
# YjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBD
# QS0xMB4XDTEzMDUyMTAwMDAwMFoXDTE0MDYwNDAwMDAwMFowRzELMAkGA1UEBhMC
# VVMxETAPBgNVBAoTCERpZ2lDZXJ0MSUwIwYDVQQDExxEaWdpQ2VydCBUaW1lc3Rh
# bXAgUmVzcG9uZGVyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAumlK
# gU1vpRQWqorNZ75Lv8Zpj1gc4HnoHp1YJpjaXNR8o/nbK4wSNsP8+WQGsbvCqJgK
# Fw3hletAtOuWbZi/po95z7yKknttnBgGUdilGFMyAScZYeiEQd/G8OjK/netX9ie
# e4xgb4VcRr1r5w+AzucDw3wxz7dlVcb74JkI5HNa+5fa0Ey+tLbGD38mkqm4/Dju
# tOQ6pEjQTOqpRidbz5IRk5wWp/7SrR8ixR6swXHvvErbAQlE35gcLWe6qIoDM8lR
# tfcCTQmkTf6AXsXXRcN9CKoBM8wz2E8wFuT/IjIu63478PkeMuuVJdLy/m1UhLrV
# 5dTR3RuvvVl7lIUwAQIDAQABo4IDNTCCAzEwDgYDVR0PAQH/BAQDAgeAMAwGA1Ud
# EwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwggG/BgNVHSAEggG2MIIB
# sjCCAaEGCWCGSAGG/WwHATCCAZIwKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRp
# Z2ljZXJ0LmNvbS9DUFMwggFkBggrBgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBz
# AGUAIABvAGYAIAB0AGgAaQBzACAAQwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBv
# AG4AcwB0AGkAdAB1AHQAZQBzACAAYQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAg
# AHQAaABlACAARABpAGcAaQBDAGUAcgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAg
# AHQAaABlACAAUgBlAGwAeQBpAG4AZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBt
# AGUAbgB0ACAAdwBoAGkAYwBoACAAbABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0
# AHkAIABhAG4AZAAgAGEAcgBlACAAaQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABo
# AGUAcgBlAGkAbgAgAGIAeQAgAHIAZQBmAGUAcgBlAG4AYwBlAC4wCwYJYIZIAYb9
# bAMVMB8GA1UdIwQYMBaAFBUAEisTmLKZB+0e36K+Vw0rZwLNMB0GA1UdDgQWBBRj
# L8nfeZJ7tSPKu+Gk7jN+4+Kd+jB9BgNVHR8EdjB0MDigNqA0hjJodHRwOi8vY3Js
# My5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURDQS0xLmNybDA4oDagNIYy
# aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5j
# cmwwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRENBLTEuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCr
# dL1AAEx2FSVXPdMcA/99RchFEmbnKGVg2N87s/oNwawzj/SBuWHxnfuYVdfeR0O6
# gD3xSMw/ZzBWH8700EyEvYeknsXhD6gGXdAvbl7cGejwh+rgTq89bCCOc29+1ocY
# 4IbTmvye6oxy6UEPuHG1OCz4KbLVHKKdG+xfKrjcNyDhy7vw0GxspbPLn0r2VOMm
# ND0uuMErHLf2wz3+0S0eUPSUyPj97nPbSbUb9PX/pZDBORQb2O1xG2qY+/pAmkSp
# KQ5VXni4t6SDw3AB8GZA5a55NOErTQOhLebbVGIY7dUJi6Kq1gzITxq+mSV4aZmJ
# 1FmJ3t+I8NNnXnSlnaZEMIIGgTCCBWmgAwIBAgIQDyPMGbrGj9Q9g2qpsllDrjAN
# BgkqhkiG9w0BAQUFADBvMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQg
# SW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMS4wLAYDVQQDEyVEaWdpQ2Vy
# dCBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBDQS0xMB4XDTEyMDcxOTAwMDAwMFoX
# DTE1MDcyNDEyMDAwMFowTTELMAkGA1UEBhMCU0UxEjAQBgNVBAcTCVN0b2NraG9s
# bTEUMBIGA1UEChMLVGltIE5pbGltYWExFDASBgNVBAMTC1RpbSBOaWxpbWFhMIIB
# IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA17dWdEkA0DAt02V3zk9erm+g
# PylIL3Mm8uVpmgAM+LStoALu7Da7+TVZ+rYG5KUi77St/2BnJw0Zk9KCAdkvBMSp
# rRBjeKm5hm2gudvUe6GslvQW80XF0JQSnhrdlw6FlBSu2lJAmDHiwwAvztUh0Rwl
# ukCVdb1XhXqLO/dTHWAxJyoP2+oxJRx4QlF9ah1wrIiWMjbAmlaO/Csc9DPQgbWG
# 5LHOWwrC6m/fpvxJUlijMvzeov3T9QgdgPQUlKu7hfrBBuYWQ4Nm6W9S254kIjRW
# wKDMgOcM1iM8YwfEU+X0rMhsgae4WqGqYjliIj56oh4DYyvmA4MmUHGND4kh8wID
# AQABo4IDOTCCAzUwHwYDVR0jBBgwFoAUe2jOKarAF75JeuHlP9an90WPNTIwHQYD
# VR0OBBYEFPFQSSFZPdPvx2GOr5sQBZxrOChEMA4GA1UdDwEB/wQEAwIHgDATBgNV
# HSUEDDAKBggrBgEFBQcDAzBzBgNVHR8EbDBqMDOgMaAvhi1odHRwOi8vY3JsMy5k
# aWdpY2VydC5jb20vYXNzdXJlZC1jcy0yMDExYS5jcmwwM6AxoC+GLWh0dHA6Ly9j
# cmw0LmRpZ2ljZXJ0LmNvbS9hc3N1cmVkLWNzLTIwMTFhLmNybDCCAcQGA1UdIASC
# AbswggG3MIIBswYJYIZIAYb9bAMBMIIBpDA6BggrBgEFBQcCARYuaHR0cDovL3d3
# dy5kaWdpY2VydC5jb20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUF
# BwICMIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUA
# cgB0AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMA
# YwBlAHAAdABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQA
# IABDAFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAA
# UABhAHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkA
# bQBpAHQAIABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4A
# YwBvAHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYA
# ZQByAGUAbgBjAGUALjCBggYIKwYBBQUHAQEEdjB0MCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wTAYIKwYBBQUHMAKGQGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENvZGVTaWduaW5nQ0EtMS5j
# cnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQUFAAOCAQEAahxIuVtRlqko781x
# cL1hd/a5ayEN7Ie447pd/KL8c2B2G/Dfz33pbjVEu4MXYoR2RygI6NpoFKiPi96Y
# nk4rD+17ByzuszMHsWgM3Mw7yDJMSmYiyauqm0nKopgeqdFW2+AJglK389eSlRAV
# ehehnasKfrJ39T7Vrf4ChwrTkRdOuCq1pKIpUjBdijOwyWKqgJ/7RgDx3QjBYGQ7
# llcFW0dsUXdCpfBRfqvob4+Mt1ADWRrwX66ZzemjL+nkPwatks4FMP8+JxGpeJIl
# 1IzcH47G12W//hV91btcnXGS9HimP7iqXFimF0nTmEetQUf6NxJpfbGfcZigWVya
# lQ0nHTCCBqAwggWIoAMCAQICEAf0c2+v70CKH2ZA8mXRCsEwDQYJKoZIhvcNAQEF
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTExMDIxMDEyMDAwMFoXDTI2MDIxMDEyMDAwMFowbzELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEuMCwGA1UEAxMlRGlnaUNlcnQgQXNzdXJlZCBJRCBDb2RlIFNp
# Z25pbmcgQ0EtMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJx8+aCP
# CsqJS1OaPOwZIn8My/dIRNA/Im6aT/rO38bTJJH/qFKT53L48UaGlMWrF/R4f8t6
# vpAmHHxTL+WD57tqBSjMoBcRSxgg87e98tzLuIZARR9P+TmY0zvrb2mkXAEusWbp
# prjcBt6ujWL+RCeCqQPD/uYmC5NJceU4bU7+gFxnd7XVb2ZklGu7iElo2NH0fiHB
# 5sUeyeCWuAmV+UuerswxvWpaQqfEBUd9YCvZoV29+1aT7xv8cvnfPjL93SosMkba
# XmO80LjLTBA1/FBfrENEfP6ERFC0jCo9dAz0eotyS+BWtRO2Y+k/Tkkj5wYW8CWr
# AfgoQebH1GQ7XasCAwEAAaOCA0AwggM8MA4GA1UdDwEB/wQEAwIBBjATBgNVHSUE
# DDAKBggrBgEFBQcDAzCCAcMGA1UdIASCAbowggG2MIIBsgYIYIZIAYb9bAMwggGk
# MDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9zc2wtY3BzLXJl
# cG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAgAHUAcwBl
# ACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAgAGMAbwBu
# AHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUAIABvAGYAIAB0
# AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQBuAGQAIAB0
# AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBlAGUAbQBl
# AG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBsAGkAdAB5
# ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQAZQBkACAAaABl
# AHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMA8GA1UdEwEB/wQF
# MAMBAf8weQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4
# oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwHQYDVR0OBBYEFHtozimqwBe+SXrh5T/Wp/dF
# jzUyMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA0GCSqGSIb3DQEB
# BQUAA4IBAQCPJ3L2XadkkG25JWDGsBetHvmd7qFQgoTHKlU1rBhCuzbY3lPwkie/
# M1WvSlq4OA3r9OQ4DY38RegRPAw1V69KXHlBV94JpA8RkxA6fG40gz3xb/l0H4sR
# KsqbsO/TgJJEQ9ElyTkyITHnKYLKxEGIyAeBp/1bIRd+HbqpY2jIctHil1lyQubY
# p7a6sy7JZK2TwuHleKm36bs9MZKa3pGJJgoLXj5Oz2HrWmxkBT57q3+mWN0elcde
# W8phnTR1pOUHSPhM0k88EjW7XxFljf1yueiXIKUxh77LAx/LAzlu97I7OJV9cEW4
# VvWAcoEETIBzoK0tOfUCyOSF1TskL7NsMIIGzTCCBbWgAwIBAgIQBv35A5YDreoA
# Cus/J7u6GzANBgkqhkiG9w0BAQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQD
# ExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMDYxMTEwMDAwMDAwWhcN
# MjExMTEwMDAwMDAwWjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQg
# SW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2Vy
# dCBBc3N1cmVkIElEIENBLTEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDogi2Z+crCQpWlgHNAcNKeVlRcqcTSQQaPyTP8TUWRXIGf7Syc+BZZ3561JBXC
# mLm0d0ncicQK2q/LXmvtrbBxMevPOkAMRk2T7It6NggDqww0/hhJgv7HxzFIgHwe
# og+SDlDJxofrNj/YMMP/pvf7os1vcyP+rFYFkPAyIRaJxnCI+QWXfaPHQ90C6Ds9
# 7bFBo+0/vtuVSMTuHrPyvAwrmdDGXRJCgeGDboJzPyZLFJCuWWYKxI2+0s4Grq2E
# b0iEm09AufFM8q+Y+/bOQF1c9qjxL6/siSLyaxhlscFzrdfx2M8eCnRcQrhofrfV
# dwonVnwPYqQ/MhRglf0HBKIJAgMBAAGjggN6MIIDdjAOBgNVHQ8BAf8EBAMCAYYw
# OwYDVR0lBDQwMgYIKwYBBQUHAwEGCCsGAQUFBwMCBggrBgEFBQcDAwYIKwYBBQUH
# AwQGCCsGAQUFBwMIMIIB0gYDVR0gBIIByTCCAcUwggG0BgpghkgBhv1sAAEEMIIB
# pDA6BggrBgEFBQcCARYuaHR0cDovL3d3dy5kaWdpY2VydC5jb20vc3NsLWNwcy1y
# ZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUFBwICMIIBVh6CAVIAQQBuAHkAIAB1AHMA
# ZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkAZgBpAGMAYQB0AGUAIABjAG8A
# bgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAAdABhAG4AYwBlACAAbwBmACAA
# dABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAALwBDAFAAUwAgAGEAbgBkACAA
# dABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIAdAB5ACAAQQBnAHIAZQBlAG0A
# ZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQAIABsAGkAYQBiAGkAbABpAHQA
# eQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIAcABvAHIAYQB0AGUAZAAgAGgA
# ZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUAbgBjAGUALjALBglghkgBhv1s
# AxUwEgYDVR0TAQH/BAgwBgEB/wIBADB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# dDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDQuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDAdBgNVHQ4EFgQU
# FQASKxOYspkH7R7for5XDStnAs0wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6ch
# nfNtyA8wDQYJKoZIhvcNAQEFBQADggEBAEZQPsm3KCSnOB22WymvUs9S6TFHq1Zc
# e9UNC0Gz7+x1H3Q48rJcYaKclcNQ5IK5I9G6OoZyrTh4rHVdFxc0ckeFlFbR67s2
# hHfMJKXzBBlVqefj56tizfuLLZDCwNK1lL1eT7EF0g49GqkUW6aGMWKoqDPkmzmn
# xPXOHXh2lCVz5Cqrz5x2S+1fwksW5EtwTACJHvzFebxMElf+X+EevAJdqP77BzhP
# DcZdkbkPZ0XN1oPt55INjbFpjE/7WeAjD9KqrgB87pxCDs+R1ye3Fu4Pw718CqDu
# LAhVhSK46xgaTfwqIa1JMYNHlXdx3LEbS0scEJx3FMGdTy9alQgpECYxggQ4MIIE
# NAIBATCBgzBvMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMS4wLAYDVQQDEyVEaWdpQ2VydCBBc3N1
# cmVkIElEIENvZGUgU2lnbmluZyBDQS0xAhAPI8wZusaP1D2DaqmyWUOuMAkGBSsO
# AwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqG
# SIb3DQEJBDEWBBSVg6UgsQFW72K5rM6JeyubIAv/mTANBgkqhkiG9w0BAQEFAASC
# AQB32V+uUDuhJaThDO2QWd8p+dHXytjgbIv+VseW15RdfsIp0cZvDm6RYU9h/o3n
# Qj7k/nyq+naf8jiFVqnsf3nLhjM9IRH/byF8zaSRdqtut75sW+EvaxPq08BK15bV
# 8zi8Cl8ae5YPpaxPnCSFOKFkSkGtKvBSVuEzznkhEeOFSeWmQZwKPS3cY4NTwZIV
# 70H8jLvcAAoFeZyJgEgUpHDsKvJhuamCRoNBh1X+M855zF1uJ/eE2qSU2S3hFKrm
# m0sUUILrHGZx/bjuvbBrQBa6HPRifZ2znG3Xp9u7gBXWfcC8FVLF5CdvN1dP4M3G
# cj6QD/25o/7aEvuU28xlUoSLoYICDzCCAgsGCSqGSIb3DQEJBjGCAfwwggH4AgEB
# MHYwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBDQS0xAhADn+3ty3lbje0yDIkZ8DaJMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0B
# CQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xMzEwMjMxMzM5MjJaMCMG
# CSqGSIb3DQEJBDEWBBQLT+LtKCf65gqTIr9KGbwryYE5HDANBgkqhkiG9w0BAQEF
# AASCAQB6YcGyOVsjZj+c4W390Hdpd6OvHBwxqciLa7DtRY30ATuQ/cZNT5FhOXDM
# eulc+qSC90lgkluknPm2rVIE8EaAxG57PQM7sXSo/XOkUhci54mU69nH1OnyjPfy
# QI4AzuOfLC1qYdXO+9BzID4NEaof9g/Dkps2FEBwEV5LRBC7JcKfzwsHVEzH1yR8
# Bg0Be2rGyubdAtaPrKK9rdYA63gwhRNaipkwSSLyyiRffMCeoZc/7AhQAvv5v6d6
# 1ucnT7d9FVf3VYS24Hp8SKrMbbph+wT5U3pc/8zJAAZ0jDgX9tCpbZ/pnlJ1odMF
# 9LiTGVHHMVaaZOFYWL1ciDk+P7fN
# SIG # End signature block
