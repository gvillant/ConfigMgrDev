-- Find computers with BUG HINV BADMIF ErrorCode_4 (ServicePack > 8 char !) 

SELECT  MachineID, Name0,HWSCAN.LastHWScan, HBDISC.AgentTime as HeartbeatDisc,CLIREGDISC.AgentTime MpRegistration
      ,SoftwareCode00
      ,ProductName00
      ,ARPDisplayName00
      ,ProductVersion00
      ,Publisher00
      ,VersionMajor00
      ,VersionMinor00
      ,ServicePack00, len(ServicePack00) as Lenght
      ,Language00
      ,ProductID00
      ,InstallDate00
      ,RegisteredUser00
      ,SoftwarePropertiesHash00
      ,SoftwarePropertiesHashEx00
      ,ChannelCode00
      ,EvidenceSource00
  FROM INSTALLED_SOFTWARE_data
LEFT JOIN v_r_system SYS on SYS.ResourceID = INSTALLED_SOFTWARE_data.MachineID
LEFT JOIN v_GS_WORKSTATION_STATUS  HWSCAN	on SYS.ResourceID = HWSCAN.ResourceID 
LEFT JOIN v_AgentDiscoveries HBDISC			on SYS.ResourceID = HBDISC.ResourceId AND HBDISC.AgentName = 'Heartbeat Discovery'
LEFT JOIN v_AgentDiscoveries CLIREGDISC		on SYS.ResourceID = CLIREGDISC.ResourceId AND CLIREGDISC.AgentName = 'MP_ClientRegistration'  
  where  Len(ServicePack00) > 8
  --or Name0 like '7400sc%'