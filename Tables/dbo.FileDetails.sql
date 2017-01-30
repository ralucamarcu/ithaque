SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FileDetails] (
		[RowNum]               [int] IDENTITY(1, 1) NOT NULL,
		[Name]                 [varchar](500) COLLATE French_CI_AS NULL,
		[PATH]                 [varchar](500) COLLATE French_CI_AS NULL,
		[DateCreated]          [datetime] NULL,
		[DateLastAccessed]     [datetime] NULL,
		[DateLastModified]     [datetime] NULL,
		[SIZE]                 [int] NULL,
		[TYPE]                 [varchar](100) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileDetails]
	ADD
	CONSTRAINT [PK__FileDeta__4F4A685211A14025]
	PRIMARY KEY
	CLUSTERED
	([RowNum])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileDetails] SET (LOCK_ESCALATION = TABLE)
GO
