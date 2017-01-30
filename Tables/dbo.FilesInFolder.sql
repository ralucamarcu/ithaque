SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FilesInFolder] (
		[ID]               [int] IDENTITY(1, 1) NOT NULL,
		[TheFileName]      [nvarchar](260) COLLATE French_CI_AS NOT NULL,
		[FileLength]       [bigint] NOT NULL,
		[LastModified]     [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FilesInFolder]
	ADD
	CONSTRAINT [PK__FilesInF__3214EC2728607F6F]
	PRIMARY KEY
	CLUSTERED
	([ID])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FilesInFolder] SET (LOCK_ESCALATION = TABLE)
GO
