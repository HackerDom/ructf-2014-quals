-- sqlcmd -E -S (local) -i create.sql -o output.txt

CREATE DATABASE [mssngrrr] ON PRIMARY
(
	NAME = N'mssngrrr',
	FILENAME = N'C:\ructf2014quals\mssngrrr\database\mssngrrr.mdf',
	SIZE = 3072KB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 1024KB
)
LOG ON
(
	NAME = N'mssngrrr_log',
	FILENAME = N'C:\ructf2014quals\mssngrrr\database\mssngrrr_log.ldf',
	SIZE = 1024KB,
	MAXSIZE = 2048GB,
	FILEGROWTH = 10%
)

GO

ALTER DATABASE [mssngrrr] SET RECOVERY SIMPLE

GO

USE [mssngrrr]

GO

CREATE USER [IIS APPPOOL\mssngrrr] FOR LOGIN [IIS APPPOOL\mssngrrr]

GO

EXEC sp_addrolemember N'db_datareader', N'IIS APPPOOL\mssngrrr'

GO

EXEC sp_addrolemember N'db_datawriter', N'IIS APPPOOL\mssngrrr'

GO

CREATE TABLE [msg]
(
	[n] [int] IDENTITY(1,1) NOT NULL,
	[id] [uniqueidentifier] NOT NULL,
	[from] [uniqueidentifier] NOT NULL,
	[to] [uniqueidentifier] NOT NULL,
	[subject] [nvarchar](64) NULL,
	[theme] [nvarchar](128) NULL,
	[text] [nvarchar](256) NULL,
	[img] [nvarchar](64) NULL,
	[read] bit NOT NULL DEFAULT 0,
	CONSTRAINT [PK_msg] PRIMARY KEY CLUSTERED
	(
		[n] ASC
	)
)

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_msg_id] ON [msg]
(
	[id] ASC
) WITH (IGNORE_DUP_KEY = ON)

GO

CREATE NONCLUSTERED INDEX [IX_msg_to] ON [msg]
(
	[to] ASC
)

GO