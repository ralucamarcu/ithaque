SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Images] (
		[id_image]                        [uniqueidentifier] NOT NULL,
		[id_image_type]                   [int] NULL,
		[commune]                         [varchar](500) COLLATE French_CI_AS NULL,
		[taille_image]                    [bigint] NULL,
		[id_source]                       [uniqueidentifier] NOT NULL,
		[id_projet]                       [uniqueidentifier] NULL,
		[id_fichier_data]                 [uniqueidentifier] NULL,
		[id_status_version_processus]     [int] NULL,
		[date_statut]                     [datetime] NULL,
		[locked]                          [bit] NULL,
		[cote]                            [varchar](50) COLLATE French_CI_AS NULL,
		[date_creation]                   [datetime] NOT NULL,
		[date_modification]               [datetime] NULL,
		[path_origine]                    [varchar](500) COLLATE French_CI_AS NULL,
		[nom_fichier_origine]             [varchar](255) COLLATE French_CI_AS NULL,
		[type_acte]                       [varchar](10) COLLATE French_CI_AS NULL,
		[annee_debut]                     [char](4) COLLATE French_CI_AS NULL,
		[annee_fin]                       [char](4) COLLATE French_CI_AS NULL,
		[id_statut_traitement]            [int] NULL,
		[erreur_message]                  [varchar](2000) COLLATE French_CI_AS NULL,
		[id_file_metadata]                [int] NULL,
		[id_fichier_data_batch]           [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images]
	ADD
	CONSTRAINT [PK_Images_dev]
	PRIMARY KEY
	CLUSTERED
	([id_image])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images]
	ADD
	CONSTRAINT [DF_Images_dev_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Images]
	ADD
	CONSTRAINT [DF_Images_dev_id_image]
	DEFAULT (newid()) FOR [id_image]
GO
ALTER TABLE [dbo].[Images]
	ADD
	CONSTRAINT [DF_Images_dev_locked]
	DEFAULT ((0)) FOR [locked]
GO
CREATE NONCLUSTERED INDEX [id_source_id_status_version_processus]
	ON [dbo].[Images] ([id_source], [id_status_version_processus])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_id_projet]
	ON [dbo].[Images] ([id_projet])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_id_source]
	ON [dbo].[Images] ([id_source])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Images_id_fichier_data_batch]
	ON [dbo].[Images] ([id_fichier_data_batch])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_nom_fichier_origine]
	ON [dbo].[Images] ([nom_fichier_origine])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_taille_image]
	ON [dbo].[Images] ([taille_image])
	ON [INDEX]
GO
ALTER TABLE [dbo].[Images] SET (LOCK_ESCALATION = TABLE)
GO
