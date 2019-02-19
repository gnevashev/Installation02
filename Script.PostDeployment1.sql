/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

:r .\Core\Script.PostDeploymentPopulateData.sql

:setvar XMLDATA "'"

DECLARE @jsonCoreTable nvarchar(max) = 
$(XMLDATA)
:r .\Data\t_CoreTable.json
$(XMLDATA)


set identity_insert t_CoreTable on
merge into [dbo].t_CoreTable as tc
  using (
	select Id, CoreCaption, CoreSettings
	from openjson (@jsonCoreTable)  
	with (   
				Id int '$.Id'
			, CoreCaption nvarchar (255) '$.CoreCaption'
			, CoreSettings nvarchar (50) '$.CoreSettings'
)) s (Id, CoreCaption, CoreSettings) ON s.Id = tc.Id
when matched and (
        s.CoreCaption <> tc.CoreCaption
        or not ((s.CoreSettings = tc.CoreSettings and not (s.CoreSettings IS NULL OR tc.CoreSettings IS NULL)) OR (s.CoreSettings IS NULL AND tc.CoreSettings IS NULL))
    )
then update set CoreCaption = s.CoreCaption, CoreSettings = s.CoreSettings

when not matched by target
then insert (Id, CoreCaption, CoreSettings)
values (Id, CoreCaption, CoreSettings)

when not matched by source then delete;
set identity_insert t_CoreTable off