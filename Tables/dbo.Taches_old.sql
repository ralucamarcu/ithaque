SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Taches_old] (
		[id_tache]               [int] IDENTITY(1, 1) NOT NULL,
		[date_creation]          [datetime] NULL,
		[nom]                    [varchar](50) COLLATE French_CI_AS NULL,
		[id_projet]              [uniqueidentifier] NULL,
		[date_debut]             [datetime] NULL,
		[date_fin]               [datetime] NULL,
		[chemin_source]          [varchar](1000) COLLATE French_CI_AS NULL,
		[chemin_destination]     [varchar](1000) COLLATE French_CI_AS NULL,
		[statut]                 [int] NULL,
		[log_statut]             [varchar](max) COLLATE French_CI_AS NULL,
		[machine_traitement]     [varchar](50) COLLATE French_CI_AS NULL,
		[id_utilisateur]         [int] NULL,
		[id_type_evenement]      [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_old]
	ADD
	CONSTRAINT [PK_Taches_old]
	PRIMARY KEY
	CLUSTERED
	([id_tache])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_old]
	ADD
	CONSTRAINT [DF_Taches_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Taches_old]
	WITH CHECK
	ADD CONSTRAINT [FK_Taches_old_Projets]
	FOREIGN KEY ([id_projet]) REFERENCES [dbo].[Projets] ([id_projet])
ALTER TABLE [dbo].[Taches_old]
	CHECK CONSTRAINT [FK_Taches_old_Projets]

GO
CREATE NONCLUSTERED INDEX [idx_tache_buildreport]
	ON [dbo].[Taches_old] ([nom], [id_projet], [statut])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_taches_id_projet]
	ON [dbo].[Taches_old] ([id_projet], [id_type_evenement])
	ON [INDEX]
GO
ALTER TABLE [dbo].[Taches_old] SET (LOCK_ESCALATION = TABLE)
GO
