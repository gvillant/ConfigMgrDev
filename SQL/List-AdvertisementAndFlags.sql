SELECT 
  ad.AdvertisementID, 
  ad.AdvertisementName, 
  AdvertFlags, 
  (AdvertFlags & 0x00000020)/0x00000020 AS AD_IMMEDIATE, 
  (AdvertFlags & 0x00000100)/0x00000100 AS AD_ONSYSTEMSTARTUP, 
  (AdvertFlags & 0x00000200)/0x00000200 AS AD_ONUSERLOGON, 
  (AdvertFlags & 0x00000400)/0x00000400 AS AD_ONUSERLOGOFF, 
  (AdvertFlags & 0x00008000)/0x00008000 AS AD_WINDOWS_CE, 
  (AdvertFlags & 0x00020000)/0x00020000 AS AD_DONOT_FALLBACK, 
  (AdvertFlags & 0x00040000)/0x00040000 AS AD_ENABLE_TS_FROM_CD_AND_PXE, 
  (AdvertFlags & 0x00100000)/0x00100000 AS AD_OVERRIDE_SERVICE_WINDOWS, 
  (AdvertFlags & 0x00200000)/0x00200000 AS AD_REBOOT_OUTSIDE_OF_SERVICE_WINDOWS, 
  (AdvertFlags & 0x00400000)/0x00400000 AS AD_WAKE_ON_LAN_ENABLED, 
  (AdvertFlags & 0x00800000)/0x00800000 AS AD_SHOW_PROGRESS, 
  (AdvertFlags & 0x02000000)/0x02000000 AS AD_NO_DISPLAY, 
  (AdvertFlags & 0x04000000)/0x04000000 AS AD_ONSLOWNET 
FROM dbo.v_Advertisement ad