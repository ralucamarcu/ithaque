SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[preparation_imagesLogs] (
		[oldPath]     [varchar](500) COLLATE French_CI_AS NULL,
		[newPath]     [varchar](500) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[preparation_imagesLogs] SET (LOCK_ESCALATION = TABLE)
GO
