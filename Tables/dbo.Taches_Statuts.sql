SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Taches_Statuts] (
		[id_status]        [int] IDENTITY(1, 1) NOT NULL,
		[status_tache]     [varchar](250) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Statuts]
	ADD
	CONSTRAINT [PK_Taches_Statuts]
	PRIMARY KEY
	CLUSTERED
	([id_status])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Statuts] SET (LOCK_ESCALATION = TABLE)
GO
