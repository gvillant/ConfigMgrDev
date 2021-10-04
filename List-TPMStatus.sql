select sys.name0, BITL.ProtectionStatus0, BIOS.SMBIOSBIOSVersion0, TPM.PhysicalPresenceVersionInfo0, tpm.*

from v_R_System SYS
LEFT join v_GS_ENCRYPTABLE_VOLUME BITL on SYS.ResourceID = BITL.ResourceID
LEFT JOIN v_FullCollectionMembership FCM on SYS.ResourceID = FCM.ResourceID
LEFT JOIN v_GS_PC_BIOS BIOS on SYS.ResourceID = BIOS.ResourceID
LEFT JOIN v_GS_TPM TPM on SYS.ResourceID = TPM.ResourceID
WHERE FCM.CollectionID ='STG0077C'

order by 2 
