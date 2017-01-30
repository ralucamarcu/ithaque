SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mois_republicain] (
		[id_mois]     [int] IDENTITY(1, 1) NOT NULL,
		[mois]        [varchar](255) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mois_republicain] SET (LOCK_ESCALATION = TABLE)
GO
