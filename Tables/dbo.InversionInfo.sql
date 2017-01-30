SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InversionInfo] (
		[tache]           [varchar](50) COLLATE French_CI_AS NULL,
		[nom_initial]     [varchar](255) COLLATE French_CI_AS NULL,
		[nom_final]       [varchar](255) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InversionInfo] SET (LOCK_ESCALATION = TABLE)
GO
