
--/*
declare @CollID varchar(8) 
set @CollID = 'SMS00001' 
--*/


set nocount on

-- split and conversion logic 
declare @convCode nvarchar(1023) 
set @convCode = N'declare @indx int; declare @valToConvert varchar(4); ' 
+ CHAR(13) + N'set @result=''''' 
+ CHAR(13) + N'while LEN(@input) > 0 begin ' 
+ CHAR(13) + N'select @indx = CHARINDEX('','', @input) ' 
+ CHAR(13) + N'select @valToConvert = SUBSTRING(@input, 0, @indx)' 
+ CHAR(13) + N'if (@valToConvert = ''0'') OR (@valToConvert = '''') break' 
+ CHAR(13) + N'select @result = @result + CHAR(@valToConvert) ' 
+ CHAR(13) + N'select @input = SUBSTRING(@input, @indx+2, LEN(@input) - @indx) end' 
declare @params nvarchar(500) 
set @params = N'@input varchar(255), @result varchar(255) OUTPUT'

-- table variable 
declare @convertTab table ( 
    ResourceID int, 
    Active0 int, 
    InstanceName0 nvarchar(255), 
    ManufacturerName0 nvarchar(255), 
    ProductCodeID0 nvarchar(255), 
    SerialNumberID0 nvarchar(255), 
    UserFriendlyName0 nvarchar(255), 
    UserFriendlyNameLength0 int, 
    WeekOfManufacture0 int, 
    YearOfManufacture0 int, 
    ManufacturerNameConv varchar(255), 
    ProductCodeIDConv varchar(255), 
    SerialNumberIDConv varchar(255), 
    UserFriendlyNameConv varchar(255) 
) 
-- select data to report on, into the table variable 
insert @convertTab 
    (ResourceID, InstanceName0, ManufacturerName0, ProductCodeID0, SerialNumberID0, 
    UserFriendlyName0, UserFriendlyNameLength0, WeekOfManufacture0, YearOfManufacture0) 
select 
    ResourceID, InstanceName0, ManufacturerName0, ProductCodeID0, SerialNumberID0, 
    UserFriendlyName0, UserFriendlyNameLength0, WeekOfManufacture0, YearOfManufacture0 
from v_GS_WMIMONITORID 
where ResourceID in 
    (select ResourceID from v_FullCollectionMembership where CollectionID = @CollID)

-- cursor to iterate through table variable and convert 
declare convert_cursor cursor for 
select ManufacturerName0, ProductCodeID0, SerialNumberID0,UserFriendlyName0 from @convertTab 
declare @mfg varchar(255), @pcode varchar(255), @snum varchar(255), @fname varchar(255) 
declare @out varchar(255)

open convert_cursor 
fetch next from convert_cursor into @mfg, @pcode, @snum, @fname 
while @@FETCH_STATUS = 0 
begin 
    exec sp_executesql @convCode, @params, @input=@mfg, @result=@out OUTPUT 
    update @convertTab set ManufacturerNameConv = @out where ManufacturerName0 = @mfg 
    exec sp_executesql @convCode, @params, @input=@pcode, @result=@out OUTPUT 
    update @convertTab set ProductCodeIDConv = @out where ProductCodeID0 = @pcode 
    exec sp_executesql @convCode, @params, @input=@snum, @result=@out OUTPUT 
    update @convertTab set SerialNumberIDConv = @out where SerialNumberID0 = @snum 
    exec sp_executesql @convCode, @params, @input=@fname, @result=@out OUTPUT 
    update @convertTab set UserFriendlyNameConv = @out where UserFriendlyName0 = @fname 
    fetch next from convert_cursor into @mfg, @pcode, @snum, @fname 
end 
close convert_cursor 
deallocate convert_cursor

set nocount off

-- return converted data 
select syst.Name0, cnvt.InstanceName0, cnvt.UserFriendlyNameConv, cnvt.UserFriendlyNameLength0, 
cnvt.ManufacturerNameConv, cnvt.ProductCodeIDConv, cnvt.SerialNumberIDConv, 
cnvt.YearOfManufacture0, cnvt.WeekOfManufacture0 
from @convertTab cnvt join v_R_System syst 
on cnvt.ResourceID = syst.ResourceID 