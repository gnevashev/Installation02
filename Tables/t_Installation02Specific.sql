CREATE TABLE [dbo].[t_Installation02Specific]
(
	[Id] INT NOT NULL identity PRIMARY KEY
	, dt datetime2(2) not null default (getdate())
)
