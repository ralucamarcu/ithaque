SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Taches] (
		[id_tache]                        [int] IDENTITY(1, 1) NOT NULL,
		[nom_tache]                       [varchar](255) COLLATE French_CI_AS NULL,
		[description_tache]               [varchar](max) COLLATE French_CI_AS NULL,
		[id_status_version_processus]     [int] NULL,
		[id_parent]                       [int] NULL,
		[id_precedent]                    [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches]
	ADD
	CONSTRAINT [PK_Taches]
	PRIMARY KEY
	CLUSTERED
	([id_tache])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches]
	WITH CHECK
	ADD CONSTRAINT [FK_Taches_Version_Processus_Statuts]
	FOREIGN KEY ([id_status_version_processus]) REFERENCES [dbo].[Version_Processus_Statuts] ([id_status])
ALTER TABLE [dbo].[Taches]
	CHECK CONSTRAINT [FK_Taches_Version_Processus_Statuts]

GO
ALTER TABLE [dbo].[Taches] SET (LOCK_ESCALATION = TABLE)
GO
