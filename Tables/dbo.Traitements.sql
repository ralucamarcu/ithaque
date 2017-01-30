SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Traitements] (
		[id_traitement]                     [int] IDENTITY(1, 1) NOT NULL,
		[id_type_traitement]                [smallint] NULL,
		[nom]                               [varchar](150) COLLATE French_CI_AS NOT NULL,
		[nom_projet]                        [varchar](100) COLLATE French_CI_AS NULL,
		[date_creation]                     [datetime] NULL,
		[import_xml_TD]                     [bit] NULL,
		[import_xml_TD_debut]               [datetime] NULL,
		[import_xml_TD_fin]                 [datetime] NULL,
		[import_xml_EC]                     [bit] NULL,
		[import_xml_EC_debut]               [datetime] NULL,
		[import_xml_EC_fin]                 [datetime] NULL,
		[folder_XML_TD]                     [varchar](250) COLLATE French_CI_AS NULL,
		[folder_XML_EC]                     [varchar](250) COLLATE French_CI_AS NULL,
		[folder_images_TD]                  [varchar](250) COLLATE French_CI_AS NULL,
		[folder_images_EC]                  [varchar](250) COLLATE French_CI_AS NULL,
		[import_xml]                        [bit] NULL,
		[import_xml_debut]                  [datetime] NULL,
		[import_xml_fin]                    [datetime] NULL,
		[folder_XML]                        [varchar](500) COLLATE French_CI_AS NULL,
		[folder_images]                     [varchar](500) COLLATE French_CI_AS NULL,
		[id_projet]                         [uniqueidentifier] NULL,
		[objectif_effectif_min]             [bigint] NULL,
		[dossier_source_export]             [varchar](250) COLLATE French_CI_AS NULL,
		[dossier_destination_export]        [varchar](250) COLLATE French_CI_AS NULL,
		[infos]                             [varchar](max) COLLATE French_CI_AS NULL,
		[dossier_livraison]                 [varchar](500) COLLATE French_CI_AS NULL,
		[date_livraison]                    [datetime] NULL,
		[livraison_conforme]                [bit] NULL,
		[id_facture]                        [uniqueidentifier] NULL,
		[controle_livraison_conformite]     [bit] NOT NULL,
		[date_verification_conformite]      [datetime] NULL,
		[nb_images]                         [int] NULL,
		[date_retour_cq]                    [datetime] NULL,
		[date_retour_conformite_xml]        [datetime] NULL,
		[date_reecriture]                   [datetime] NULL,
		[date_publication]                  [datetime] NULL,
		[remarques]                         [varchar](max) COLLATE French_CI_AS NULL,
		[livraison_annulee]                 [bit] NOT NULL,
		[type_livraison]                    [varchar](50) COLLATE French_CI_AS NULL,
		[commentaire_bordereau]             [varchar](max) COLLATE French_CI_AS NULL,
		[id_traitement_old]                 [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Traitements]
	ADD
	CONSTRAINT [PK_Traitements]
	PRIMARY KEY
	CLUSTERED
	([id_traitement])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Traitements]
	ADD
	CONSTRAINT [DF_Traitements_controle_livraison_conformite]
	DEFAULT ((0)) FOR [controle_livraison_conformite]
GO
ALTER TABLE [dbo].[Traitements]
	ADD
	CONSTRAINT [DF_Traitements_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Traitements]
	ADD
	CONSTRAINT [DF_Traitements_import_xml_EC]
	DEFAULT ((0)) FOR [import_xml_EC]
GO
ALTER TABLE [dbo].[Traitements]
	ADD
	CONSTRAINT [DF_Traitements_import_xml_TD]
	DEFAULT ((0)) FOR [import_xml_TD]
GO
ALTER TABLE [dbo].[Traitements]
	ADD
	CONSTRAINT [DF_Traitements_livraison_annulee]
	DEFAULT ((0)) FOR [livraison_annulee]
GO
ALTER TABLE [dbo].[Traitements]
	WITH CHECK
	ADD CONSTRAINT [FK_Traitements_FichiersData_Factures]
	FOREIGN KEY ([id_facture]) REFERENCES [dbo].[FichiersData_Factures] ([id_facture])
ALTER TABLE [dbo].[Traitements]
	CHECK CONSTRAINT [FK_Traitements_FichiersData_Factures]

GO
ALTER TABLE [dbo].[Traitements]
	WITH CHECK
	ADD CONSTRAINT [FK_Traitements_Projets]
	FOREIGN KEY ([id_projet]) REFERENCES [dbo].[Projets] ([id_projet])
ALTER TABLE [dbo].[Traitements]
	CHECK CONSTRAINT [FK_Traitements_Projets]

GO
CREATE NONCLUSTERED INDEX [idx_id_projet]
	ON [dbo].[Traitements] ([id_projet])
	ON [INDEX]
GO
ALTER TABLE [dbo].[Traitements] SET (LOCK_ESCALATION = TABLE)
GO
