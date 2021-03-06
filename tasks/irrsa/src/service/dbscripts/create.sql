-- sqlcmd -E -S (local) -i create.sql -o output.txt

CREATE DATABASE [irrsa] ON PRIMARY
(
	NAME = N'irrsa',
	FILENAME = N'C:\ructf2014quals\irrsa\web\database\irrsa.mdf',
	SIZE = 4096KB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 1024KB
)
LOG ON
(
	NAME = N'irrsa_log',
	FILENAME = N'C:\ructf2014quals\irrsa\web\database\irrsa_log.ldf',
	SIZE = 1024KB,
	MAXSIZE = 2048GB,
	FILEGROWTH = 10%
)

GO

ALTER DATABASE [irrsa] SET RECOVERY SIMPLE

GO

USE [irrsa]

GO

CREATE USER [IIS APPPOOL\irrsa] FOR LOGIN [IIS APPPOOL\irrsa]

GO

EXEC sp_addrolemember N'db_datareader', N'IIS APPPOOL\irrsa'

GO

EXEC sp_addrolemember N'db_datawriter', N'IIS APPPOOL\irrsa'

GO

CREATE USER [WIN-88AFA5JKUTJ\Limited] FOR LOGIN [WIN-88AFA5JKUTJ\Limited]

GO

EXEC sp_addrolemember N'db_datareader', N'WIN-88AFA5JKUTJ\Limited'

GO

EXEC sp_addrolemember N'db_datawriter', N'WIN-88AFA5JKUTJ\Limited'

GO

CREATE TABLE [agents]
(
	[login] [nvarchar](64) NOT NULL,
	[pass] [nvarchar](64) NOT NULL
)

GO

INSERT INTO [agents] ([login], [pass]) VALUES ('agent007', '62c2d8bde8c24626957fb5f0e6e4da4b')

GO

CREATE TABLE [sessions]
(
	[n] [int] IDENTITY(1,1) NOT NULL,
	[login] [nvarchar](64) NOT NULL,
	[ssid] [uniqueidentifier] NOT NULL
)

GO

CREATE NONCLUSTERED INDEX [IX_sessions_ssid] ON [sessions]
(
	[login] ASC
)

GO

CREATE TABLE [msg]
(
	[n] [int] IDENTITY(1,1) NOT NULL,
	[id] [uniqueidentifier] NOT NULL,
	[ssid] [uniqueidentifier] NOT NULL,
	[to] [nvarchar](64) NOT NULL,
	[email] [nvarchar](64) NULL,
	[phone] [nvarchar](64) NULL,
	[text] [nvarchar](256) NULL,
	[ip] [nvarchar](15) NULL,
	[ua] [nvarchar](256) NULL,
	[dt] [datetime2](7) NOT NULL,
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

CREATE TABLE [msg_temp]
(
	[n] [int] IDENTITY(1,1) NOT NULL,
	[id] [uniqueidentifier] NOT NULL,
	[ssid] [uniqueidentifier] NOT NULL,
	[to] [nvarchar](64) NOT NULL,
	[email] [nvarchar](64) NULL,
	[phone] [nvarchar](64) NULL,
	[text] [nvarchar](256) NULL,
	[ip] [nvarchar](15) NULL,
	[ua] [nvarchar](256) NULL,
	[dt] [datetime2](7) NOT NULL,
	CONSTRAINT [PK_msg_preview] PRIMARY KEY CLUSTERED
	(
		[n] ASC
	)
)

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_msg_preview_id] ON [msg_temp]
(
	[id] ASC
) WITH (IGNORE_DUP_KEY = ON)

GO

CREATE NONCLUSTERED INDEX [IX_msg_preview_to] ON [msg_temp]
(
	[to] ASC
)

GO