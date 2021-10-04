/*
In SSRS Report Manager everyone can lookup and manage his own subscription.
But as a System Admin I would like to see all existing subscriptions and the schedule to check, if may at a certain time particularly many subscriptions are planned and a bottleneck could occur.
This Transact-SQL script list all existing subscriptions with the schedule data.

Please remark: Querying the ReportServer database directly is not a supported way to get informations of/from SSRS.
Works with SQL Server 2005 and higher versions in all editions.
Requires SELECT permissions on the ReportServer database.
*/

-- List all SSRS subscriptions
USE [ReportServer];  -- You may change the database name.
GO

SELECT USR.UserName AS SubscriptionOwner
      ,SUB.ModifiedDate
      ,SUB.[Description]
      ,SUB.EventType
      ,SUB.DeliveryExtension
      ,SUB.LastStatus
      ,SUB.LastRunTime
      ,SCH.NextRunTime
      ,SCH.Name AS ScheduleName      
      ,CAT.[Path] AS ReportPath
      ,CAT.[Description] AS ReportDescription
FROM dbo.Subscriptions AS SUB
     INNER JOIN dbo.Users AS USR
         ON SUB.OwnerID = USR.UserID
     INNER JOIN dbo.[Catalog] AS CAT
         ON SUB.Report_OID = CAT.ItemID
     INNER JOIN dbo.ReportSchedule AS RS
         ON SUB.Report_OID = RS.ReportID
            AND SUB.SubscriptionID = RS.SubscriptionID
     INNER JOIN dbo.Schedule AS SCH
         ON RS.ScheduleID = SCH.ScheduleID
ORDER BY USR.UserName
        ,CAT.[Path];