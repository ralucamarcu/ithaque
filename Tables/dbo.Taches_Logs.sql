SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Taches_Logs] (
		[id_tache_log]           [int] IDENTITY(1, 1) NOT NULL,
		[id_utilisateur]         [int] NOT NULL,
		[id_source]              [uniqueidentifier] NULL,
		[id_projet]              [uniqueidentifier] NULL,
		[id_status]              [int] NULL,
		[path_erreur_log]        [varchar](500) COLLATE French_CI_AS NULL,
		[machine_traitement]     [varchar](255) COLLATE French_CI_AS NULL,
		[date_debut]             [datetime] NULL,
		[date_fin]               [datetime] NULL,
		[date_creation]          [datetime] NOT NULL,
		[date_modification]      [datetime] NULL,
		[id_tache]               [int] NULL,
		[erreur_message]         [varchar](800) COLLATE French_CI_AS NULL,
		[ordre]                  [int] NULL,
		[doit_etre_execute]      [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Logs]
	ADD
	CONSTRAINT [PK_TachesSources]
	PRIMARY KEY
	CLUSTERED
	([id_tache_log])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Logs]
	ADD
	CONSTRAINT [DF_Taches_Logs_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Taches_Logs]
	WITH CHECK
	ADD CONSTRAINT [FK_Taches_Logs_Taches]
	FOREIGN KEY ([id_tache]) REFERENCES [dbo].[Taches] ([id_tache])
ALTER TABLE [dbo].[Taches_Logs]
	CHECK CONSTRAINT [FK_Taches_Logs_Taches]

GO
ALTER TABLE [dbo].[Taches_Logs]
	WITH CHECK
	ADD CONSTRAINT [FK_Taches_Sources_Sources]
	FOREIGN KEY ([id_source]) REFERENCES [dbo].[Sources] ([id_source])
ALTER TABLE [dbo].[Taches_Logs]
	CHECK CONSTRAINT [FK_Taches_Sources_Sources]

GO
ALTER TABLE [dbo].[Taches_Logs]
	WITH CHECK
	ADD CONSTRAINT [FK_Taches_Sources_Taches_Statuts]
	FOREIGN KEY ([id_status]) REFERENCES [dbo].[Taches_Statuts] ([id_status])
ALTER TABLE [dbo].[Taches_Logs]
	CHECK CONSTRAINT [FK_Taches_Sources_Taches_Statuts]

GO
ALTER TABLE [dbo].[Taches_Logs]
	WITH CHECK
	ADD CONSTRAINT [FK_Taches_Utilisateurs]
	FOREIGN KEY ([id_utilisateur]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[Taches_Logs]
	CHECK CONSTRAINT [FK_Taches_Utilisateurs]

GO
CREATE NONCLUSTERED INDEX [IX_source_statut_tache]
	ON [dbo].[Taches_Logs] ([id_source], [id_status], [id_tache])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Logs] SET (LOCK_ESCALATION = TABLE)
GO
