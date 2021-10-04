SELECT SCHEMA_NAME(schema_id) AS schema_name
,name AS view_name
,OBJECTPROPERTYEX(OBJECT_ID,'IsIndexed') AS IsIndexed
,OBJECTPROPERTYEX(OBJECT_ID,'IsIndexable') AS IsIndexable
--,*
FROM sys.views
--where name like '%machine%'
order by name