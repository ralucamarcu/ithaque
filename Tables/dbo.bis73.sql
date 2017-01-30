SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[bis73] (
		[Column 0]     [varchar](500) COLLATE French_CI_AS NULL,
		[Column 1]     [varchar](500) COLLATE French_CI_AS NULL,
		[Column 2]     [varchar](500) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bis73] SET (LOCK_ESCALATION = TABLE)
GO
