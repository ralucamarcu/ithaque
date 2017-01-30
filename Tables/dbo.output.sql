SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[output] (
		[Directory]     [varchar](400) COLLATE French_CI_AS NULL,
		[FileSize]      [varchar](400) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[output] SET (LOCK_ESCALATION = TABLE)
GO
