
          declare @allassignments table
          (
          AssignmentID int,
          CollectionID  nvarchar(512),
          CollecionName nvarchar(512),
          CI_ID       int,
          DisplayName nvarchar(512),
          CIType_ID   int,
          CI_UniqueID nvarchar(512),
          CIVersion   int
          )

          declare @AllCIs table
          (
          BL_CI_ID      int,
          CI_ID         int,
          CIVersion     int,
          ModelName     nvarchar(512),
          CI_UniqueID   nvarchar(512),
          CIType_ID     int,
          RelationType  int,
          DisplayName   nvarchar(512)
          )


          declare @notapplicable int
          declare @notdetected int
          declare @unknown int
          declare @compliant int
          declare @noncompliant int
          declare @conflict int
          declare @error int
          declare @IsApplicable as bit
          declare @IsDetected as bit
          declare @ResolvedState as int


          select @unknown=0
          select @compliant=1
          select @noncompliant=2
          select @conflict=3
          select @error=4
          select @notapplicable=5
          select @notdetected=6        

          set @ResolvedState=@ActualState
          if(@unknown = @ActualState)      begin set @ResolvedState=@ActualState set @IsDetected=NULL set @IsApplicable=NULL  end
          if(@compliant = @ActualState)    begin set @ResolvedState=@ActualState set @IsDetected=1    set @IsApplicable=1     end
          if(@noncompliant = @ActualState) begin set @ResolvedState=@ActualState set @IsDetected=1    set @IsApplicable=1     end
          if(@conflict = @ActualState)     begin set @ResolvedState=@ActualState set @IsDetected=1    set @IsApplicable=1     end
          if(@error = @ActualState)        begin set @ResolvedState=@ActualState set @IsDetected=NULL set @IsApplicable=NULL  end
          if(@notapplicable = @ActualState)begin set @ResolvedState=@compliant   set @IsDetected=NULL set @IsApplicable=0     end
          if(@notdetected = @ActualState)  begin set @ResolvedState=@compliant   set @IsDetected=0    set @IsApplicable=NULL  end
          

          declare @lcid as int set @lcid = dbo.fn_LShortNameToLCID(@locale)

          insert into @allassignments (AssignmentID,CollectionID,CollecionName,CI_ID, DisplayName,CIType_ID,CI_UniqueID,CIVersion)
          select assign.AssignmentID,coll.CollectionID as CollectionID,coll.name as CollecionName,bls.CI_ID, dbo.fn_GetLocalizedCIName(@lcid,bls.CI_ID),bls.CIType_ID,bls.CI_UniqueID,bls.CIVersion
          from fn_rbac_CIAssignment(@UserSIDs)  assign
          inner join fn_rbac_Collection(@UserSIDs)  coll on coll.CollectionID=assign.CollectionID
          inner join fn_rbac_CIAssignmentToCI(@UserSIDs)  targ on targ.AssignmentID=assign.AssignmentID
          inner join fn_rbac_CIRelation_All(@UserSIDs)  rel on rel.CI_ID=targ.CI_ID
          inner join fn_rbac_SMSConfigurationItems(@UserSIDs)  bls on bls.CI_ID=rel.ReferencedCI_ID
          where CIType_ID in (2,50) and bls.IsTombstoned=0
          and (assign.AssignmentID = @assignmentID or @assignmentID='' or @assignmentID is NULL)
          and assign.AssignmentType in (0,8)
          and (coll.CollectionID=@collid or @collid='')
          and (dbo.fn_GetLocalizedCIName(@lcid,bls.CI_ID) = @BLName or @BLName = '')
 
 
          Insert into @AllCIs
          select distinct rel.CI_ID, rel.ReferencedCI_ID,ciref.CIVersion,ciref.ModelName,ciref.CI_UniqueID,ciref.CIType_ID,rel.RelationType, dbo.fn_GetLocalizedCIName(@lcid,ciref.CI_ID) 
          from @allassignments bl
          inner join fn_rbac_CIRelation_All(@UserSIDs)  rel on rel.CI_ID=bl.CI_ID and rel.RelationType<>5 and rel.RelationType<>50 and rel.RelationType<>8 and rel.RelationType<>80
          inner join fn_rbac_ConfigurationItems(@UserSIDs)  ciref on ciref.CI_ID=rel.ReferencedCI_ID
          where
          ((rel.RelationType in (0, 1, 2, 3, 4)) OR (rel.RelationType = 7 and ciref.CIType_ID=50))
          and ciref.CIType_ID<>2 and ciref.CIType_ID <> 11--no baselines or global cis
          and ciref.IsTombstoned=0
          and (dbo.fn_GetLocalizedCIName(@lcid,ciref.CI_ID) = @CIname or @CIname='' or @CIName is null)
          and (ciref.CIVersion = @CIVersion or @CIVersion='' or @CIVersion is null)


          CREATE TABLE #assstatus
          (
          LastComplianceMessageTime DateTime,
          ResourceID int,
          UserID int,
          CI_ID int
          )
          insert into #assstatus
          select MAX(assstatus.LastEvaluationMessageTime) as LastComplianceMessageTime,ResourceID,UserID, AllCIs.CI_ID from fn_rbac_CIAssignmentStatus(@UserSIDs)  assstatus
          join @allassignments bls on bls.AssignmentID = assstatus.AssignmentID
          join @AllCIs AllCIs on bls.CI_ID=AllCIs.BL_CI_ID
          group by ResourceID,UserID,AllCIs.CI_ID

          CREATE INDEX IX on #assstatus (ResourceID, UserID, CI_ID)

          declare @UserIDs  table (UserID int)
          insert into @UserIDs(UserID) select UserID from fn_rbac_Users(@UserSIDs)  where FullName = @UserName

          declare @MachineID as int

          if(@computer is NULL OR @computer= '')     set @MachineID = ''
          else                                       set @MachineID = (select ResourceID from fn_rbac_R_System_Valid(@UserSIDs)  where Netbios_Name0 = @computer)

          declare @TargetIDs  table (TargetID int)
          insert into @TargetIDs(TargetID) select ResourceID from fn_rbac_R_System_Valid(@UserSIDs)  where Netbios_Name0 = @TargetName
          

          if (exists (select 1 from @TargetIDs))
          begin       
          insert into @TargetIDs(TargetID) select UserID from fn_rbac_Users(@UserSIDs)  where FullName = @TargetName
          end

          CREATE TABLE #status
          (
          ResourceID int,
          UserID int,
          CI_ID int,
          ComplianceState int,
          MaxNoncomplianceCriticality int,
          IsApplicable bit,
          IsDetected bit
          )

          CREATE TABLE #machines(ItemKey int)
          CREATE INDEX IX on #machines (ItemKey)

          insert into #machines
          select distinct cm.ResourceID
          from fn_rbac_ClientCollectionMembers(@UserSIDs)  cm
          join @allassignments allbl on allbl.CollectionID=cm.CollectionID

          insert into #status
          select cs.ResourceID,cs.UserID,AllCIs.CI_ID,cs.ComplianceState,cs.MaxNoncomplianceCriticality,cs.IsApplicable, cs.IsDetected
          from (select distinct CI_ID from @allassignments) assign
          inner join @AllCIs AllCIs on assign.CI_ID=AllCIs.BL_CI_ID
          inner join fn_rbac_CICurrentComplianceStatus(@UserSIDs)  cs on cs.CI_ID=AllCIs.CI_ID
          inner join #machines cm on cm.ItemKey = cs.ResourceID
          where (cs.ResourceID = @MachineID or @MachineID = '')
          and (cs.UserID  in (select UserID from @UserIDs) or @UserName = '' or @UserName is null)
          and (cs.UserID in (select TargetID from @TargetIDs) OR cs.ResourceID in (select TargetID from @TargetIDs) OR @TargetName='' OR @TargetName is NULL)
          and (cs.IsEnforced  = 1 or @IsEnforced = '0' or @IsEnforced is null or @IsEnforced = '')
          and (cs.ComplianceState = @ResolvedState or @ResolvedState is null or @ResolvedState = '')
          and (cs.MaxNoncomplianceCriticality = @Severity or @Severity='' or @Severity is null)
          and (cs.IsApplicable = @IsApplicable or @IsApplicable is NULL)
          and (cs.IsDetected = @IsDetected   or @IsDetected is NULL)

          CREATE TABLE #users(DiscUserID int, UserID int)
          CREATE INDEX IX on #users (UserID)

          insert into #users
          select distinct resources.DiscoveredUserID,users.UserID
          from fn_rbac_DCMDeploymentResourcesUser(@UserSIDs)  resources
          join @allassignments allbl on allbl.AssignmentID=resources.AssignmentID
          join fn_rbac_Users(@UserSIDs)  users on users.FullName = resources.UserName

          insert into #status
          select cs.ResourceID,cs.UserID,AllCIs.CI_ID,cs.ComplianceState,cs.MaxNoncomplianceCriticality,cs.IsApplicable, cs.IsDetected
          from (select distinct CI_ID from @allassignments) assign
          inner join @AllCIs AllCIs on assign.CI_ID=AllCIs.BL_CI_ID
          inner join fn_rbac_CICurrentComplianceStatus(@UserSIDs)  cs on cs.CI_ID=AllCIs.CI_ID
          inner join #users resources on resources.UserID=cs.UserID
          where (cs.ResourceID = @MachineID or @MachineID = '')
          and (cs.UserID  in (select UserID from @UserIDs) or @UserName = '' or @UserName is null)
          and (cs.UserID in (select TargetID from @TargetIDs) OR cs.ResourceID in (select TargetID from @TargetIDs) OR @TargetName='' OR @TargetName is NULL)
          and (cs.IsEnforced  = 1 or @IsEnforced = '0' or @IsEnforced is null or @IsEnforced = '')
          and (cs.ComplianceState = @ResolvedState or @ResolvedState is null or @ResolvedState = '')
          and (cs.MaxNoncomplianceCriticality = @Severity or @Severity='' or @Severity is null)
          and (cs.IsApplicable = @IsApplicable or @IsApplicable is NULL)
          and (cs.IsDetected = @IsDetected   or @IsDetected is NULL)

          CREATE INDEX IX2 on #status (CI_ID, ResourceID, UserID)

          select
          @assignmentID as AssignmentID,
          @collid as CollectionID,
          sys.Netbios_Name0 as MachineName,
          users.FullName,
          @BLName as BLName,
          cis.DisplayName as CIName,
          cis.CIVersion,
          case when TargetCompliance.ComplianceState=4 then  TargetCompliance.ComplianceState
          when TargetCompliance.IsApplicable=0 then @notapplicable
          when TargetCompliance.IsDetected=0   then @notdetected
          else TargetCompliance.ComplianceState end as ComplianceState,

          TargetCompliance.MaxNoncomplianceCriticality,
          @IsEnforced as IsEnforced,
          assstatus.LastComplianceMessageTime,
          cis.CI_UniqueID as Baseline_UniqueID
          from (select distinct CI_UniqueID,CI_ID,DisplayName,CIVersion from @AllCIs) cis
          inner join (select distinct * from #status) TargetCompliance on TargetCompliance.CI_ID = cis.CI_ID
          inner join fn_rbac_R_System_Valid(@UserSIDs)  sys on sys.ResourceID=TargetCompliance.ResourceID
          inner join fn_rbac_Users(@UserSIDs)  users on users.UserID = TargetCompliance.UserID
          inner join #assstatus assstatus on assstatus.ResourceID=TargetCompliance.ResourceID and assstatus.UserID=TargetCompliance.userID and assstatus.CI_ID=cis.CI_ID
          order by
          sys.Netbios_Name0,
          cis.DisplayName,
          cis.CIVersion

          drop table #assstatus
          drop table #status
          drop table #machines
          drop table #users
        