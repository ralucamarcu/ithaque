SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Cotes2] (
		[cote]       [varchar](50) COLLATE French_CI_AS NULL,
		[chemin]     [varchar](500) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Cotes2] SET (LOCK_ESCALATION = TABLE)
GO
