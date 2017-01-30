SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Projets] (
		[id_projet]                       [uniqueidentifier] NOT NULL,
		[nom]                             [varchar](100) COLLATE French_CI_AS NULL,
		[infos]                           [varchar](max) COLLATE French_CI_AS NULL,
		[date_creation]                   [datetime] NULL,
		[id_effectif_lot]                 [int] NULL,
		[objectif_effectif_min]           [bigint] NULL,
		[NQA]                             [float] NULL,
		[id_projet_maitre]                [uniqueidentifier] NULL,
		[dossier_batches_xml]             [varchar](500) COLLATE French_CI_AS NULL,
		[import_batches_xml]              [smallint] NOT NULL,
		[id_departement]                  [varchar](5) COLLATE French_CI_AS NULL,
		[nom_departement]                 [varchar](50) COLLATE French_CI_AS NULL,
		[nom_projet_dossier]              [varchar](150) COLLATE French_CI_AS NULL,
		[taille_dossier_GB]               [int] NULL,
		[id_status_version_processus]     [int] NULL,
		[date_modification]               [datetime] NULL,
		[chemin_dossier_general]          [varchar](255) COLLATE French_CI_AS NULL,
		[indexation_xml_terminee]         [bit] NOT NULL,
		[zonage_fichier]                  [int] NULL,
		[nb_img_zonage]                   [int] NULL,
		[id_association]                  [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Projets]
	ADD
	CONSTRAINT [PK_Projets]
	PRIMARY KEY
	CLUSTERED
	([id_projet])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Projets]
	ADD
	CONSTRAINT [DF_Projets_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Projets]
	ADD
	CONSTRAINT [DF_Projets_id_projet]
	DEFAULT (newid()) FOR [id_projet]
GO
ALTER TABLE [dbo].[Projets]
	ADD
	CONSTRAINT [DF_Projets_import_batches_xml]
	DEFAULT ((0)) FOR [import_batches_xml]
GO
ALTER TABLE [dbo].[Projets]
	ADD
	CONSTRAINT [DF_Projets_indexation_xml_terminee]
	DEFAULT ((0)) FOR [indexation_xml_terminee]
GO
ALTER TABLE [dbo].[Projets]
	WITH CHECK
	ADD CONSTRAINT [FK_Projets_Projets_Maitres]
	FOREIGN KEY ([id_projet_maitre]) REFERENCES [dbo].[Projets_Maitres] ([id_projet_maitre])
ALTER TABLE [dbo].[Projets]
	CHECK CONSTRAINT [FK_Projets_Projets_Maitres]

GO
ALTER TABLE [dbo].[Projets]
	WITH CHECK
	ADD CONSTRAINT [FK_Projets_Table_effectifs_lots]
	FOREIGN KEY ([id_effectif_lot]) REFERENCES [dbo].[Table_effectifs_lots] ([id_effectif_lot])
ALTER TABLE [dbo].[Projets]
	CHECK CONSTRAINT [FK_Projets_Table_effectifs_lots]

GO
ALTER TABLE [dbo].[Projets]
	WITH CHECK
	ADD CONSTRAINT [FK_Projets_Table_NQA]
	FOREIGN KEY ([id_effectif_lot], [NQA]) REFERENCES [dbo].[Table_NQA] ([id_effectif], [NQA])
ALTER TABLE [dbo].[Projets]
	CHECK CONSTRAINT [FK_Projets_Table_NQA]

GO
ALTER TABLE [dbo].[Projets] SET (LOCK_ESCALATION = TABLE)
GO
