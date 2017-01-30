SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXml_fichiers] (
		[id_fichier]                    [uniqueidentifier] NOT NULL,
		[id_traitement]                 [int] NULL,
		[chemin_fichier]                [nvarchar](500) COLLATE French_CI_AS NULL,
		[id_lot]                        [uniqueidentifier] NULL,
		[date_creation]                 [datetime] NULL,
		[id_FichierData]                [uniqueidentifier] NULL,
		[nom_fichier]                   [varchar](250) COLLATE French_CI_AS NULL,
		[conforme]                      [bit] NULL,
		[nb_actes]                      [int] NULL,
		[nb_individus]                  [int] NULL,
		[nb_images]                     [int] NULL,
		[nb_caracteres]                 [int] NULL,
		[nb_actes_naissance]            [int] NULL,
		[nb_actes_mariage]              [int] NULL,
		[nb_actes_deces]                [int] NULL,
		[nb_actes_autre]                [int] NULL,
		[rejete]                        [bit] NULL,
		[ignore]                        [bit] NULL,
		[ignore_export_publication]     [bit] NOT NULL,
		[version]                       [int] NULL,
		[id_fichier_test]               [uniqueidentifier] NULL,
		[MEP]                           [bit] NULL,
		[MEP_date]                      [datetime] NULL,
		[nb_actes_recensement]          [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXml_fichiers]
	ADD
	CONSTRAINT [PK_DataXml_Fichiers]
	PRIMARY KEY
	CLUSTERED
	([id_fichier])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXml_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_Fichiers_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[DataXml_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_fichiers_ignore_export_publication]
	DEFAULT ((0)) FOR [ignore_export_publication]
GO
ALTER TABLE [dbo].[DataXml_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_fichiers_nb_actes_autre]
	DEFAULT ((0)) FOR [nb_actes_autre]
GO
ALTER TABLE [dbo].[DataXml_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_fichiers_nb_actes_deces]
	DEFAULT ((0)) FOR [nb_actes_deces]
GO
ALTER TABLE [dbo].[DataXml_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_fichiers_nb_actes_mariage]
	DEFAULT ((0)) FOR [nb_actes_mariage]
GO
ALTER TABLE [dbo].[DataXml_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_fichiers_nb_actes_naissance]
	DEFAULT ((0)) FOR [nb_actes_naissance]
GO
ALTER TABLE [dbo].[DataXml_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_fichiers_nb_actes_recensement]
	DEFAULT ((0)) FOR [nb_actes_recensement]
GO
ALTER TABLE [dbo].[DataXml_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_fichiers_rejete]
	DEFAULT ((0)) FOR [rejete]
GO
ALTER TABLE [dbo].[DataXml_fichiers]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXml_fichiers_FichiersData]
	FOREIGN KEY ([id_FichierData]) REFERENCES [dbo].[FichiersData] ([id_fichier])
ALTER TABLE [dbo].[DataXml_fichiers]
	CHECK CONSTRAINT [FK_DataXml_fichiers_FichiersData]

GO
ALTER TABLE [dbo].[DataXml_fichiers]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXml_Fichiers_Traitements]
	FOREIGN KEY ([id_traitement]) REFERENCES [dbo].[Traitements] ([id_traitement])
ALTER TABLE [dbo].[DataXml_fichiers]
	CHECK CONSTRAINT [FK_DataXml_Fichiers_Traitements]

GO
ALTER TABLE [dbo].[DataXml_fichiers]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXml_Fichiers_Traitements_id_lot]
	FOREIGN KEY ([id_lot]) REFERENCES [dbo].[DataXml_lots_fichiers] ([id_lot])
ALTER TABLE [dbo].[DataXml_fichiers]
	CHECK CONSTRAINT [FK_DataXml_Fichiers_Traitements_id_lot]

GO
CREATE NONCLUSTERED INDEX [IX_DataXml_fichiers_id_FichierData]
	ON [dbo].[DataXml_fichiers] ([id_FichierData])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_DataXml_fichiers_id_traitement]
	ON [dbo].[DataXml_fichiers] ([id_traitement])
	INCLUDE ([id_fichier])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20150911-124256]
	ON [dbo].[DataXml_fichiers] ([chemin_fichier])
	ON [INDEX]
GO
ALTER TABLE [dbo].[DataXml_fichiers] SET (LOCK_ESCALATION = TABLE)
GO
