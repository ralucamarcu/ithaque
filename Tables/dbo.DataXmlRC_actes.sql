SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlRC_actes] (
		[id]                                   [bigint] IDENTITY(1, 1) NOT NULL,
		[type_acte]                            [nvarchar](50) COLLATE French_CI_AS NULL,
		[soustype_acte]                        [nvarchar](50) COLLATE French_CI_AS NULL,
		[id_acte_xml]                          [nvarchar](50) COLLATE French_CI_AS NULL,
		[date_acte]                            [nvarchar](50) COLLATE French_CI_AS NULL,
		[annee_acte]                           [nvarchar](50) COLLATE French_CI_AS NULL,
		[calendrier_date_acte]                 [varchar](20) COLLATE French_CI_AS NULL,
		[lieu_acte]                            [nvarchar](100) COLLATE French_CI_AS NULL,
		[geonameid_acte]                       [bigint] NULL,
		[insee_acte]                           [nvarchar](10) COLLATE French_CI_AS NULL,
		[fichier_xml_acte]                     [nvarchar](250) COLLATE French_CI_AS NULL,
		[id_traitement]                        [int] NULL,
		[date_creation]                        [datetime] NULL,
		[soustype_xml_acte]                    [nvarchar](50) COLLATE French_CI_AS NULL,
		[date_acte_gregorienne]                [datetime] NULL,
		[soustype_acte_Correction]             [nvarchar](50) COLLATE French_CI_AS NULL,
		[date_acte_Correction]                 [nvarchar](50) COLLATE French_CI_AS NULL,
		[annee_acte_Correction]                [nvarchar](50) COLLATE French_CI_AS NULL,
		[calendrier_date_acte_Correction]      [varchar](20) COLLATE French_CI_AS NULL,
		[lieu_acte_Correction]                 [nvarchar](100) COLLATE French_CI_AS NULL,
		[geonameid_acte_Correction]            [bigint] NULL,
		[insee_acte_Correction]                [nvarchar](10) COLLATE French_CI_AS NULL,
		[nb_erreurs_acte]                      AS ((case when isnull([soustype_acte],'')<>isnull([soustype_acte_Correction],isnull([soustype_acte],'')) then (1) else (0) end+case when isnull([date_acte],'')<>isnull([date_acte_Correction],isnull([date_acte],'')) then (1) else (0) end)+case when isnull([insee_acte],'')<>isnull([insee_acte_Correction],isnull([insee_acte],'')) then (1) else (0) end) PERSISTED,
		[id_fichier]                           [uniqueidentifier] NULL,
		[type_acte_Correction]                 [varchar](50) COLLATE French_CI_AS NULL,
		[id_image]                             [uniqueidentifier] NULL,
		[date_acte_Correction_Reecriture]      [nvarchar](50) COLLATE French_CI_AS NULL,
		[annee_acte_Correction_Reecriture]     [nvarchar](50) COLLATE French_CI_AS NULL,
		[type_document]                        [nvarchar](50) COLLATE French_CI_AS NULL,
		[id_acte_test]                         [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_actes]
	ADD
	CONSTRAINT [PK_DataXmlRC_actes]
	PRIMARY KEY
	CLUSTERED
	([id])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_actes]
	ADD
	CONSTRAINT [DF_DataXmlRC_actes_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[DataXmlRC_actes]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXmlRC_actes_DataXml_Fichiers]
	FOREIGN KEY ([id_fichier]) REFERENCES [dbo].[DataXml_fichiers] ([id_fichier])
ALTER TABLE [dbo].[DataXmlRC_actes]
	CHECK CONSTRAINT [FK_DataXmlRC_actes_DataXml_Fichiers]

GO
ALTER TABLE [dbo].[DataXmlRC_actes]
	WITH NOCHECK
	ADD CONSTRAINT [FK_DataXmlRC_actes_Traitements]
	FOREIGN KEY ([id_traitement]) REFERENCES [dbo].[Traitements] ([id_traitement])
ALTER TABLE [dbo].[DataXmlRC_actes]
	CHECK CONSTRAINT [FK_DataXmlRC_actes_Traitements]

GO
CREATE NONCLUSTERED INDEX [DataXmlRC_actes_id_traitement]
	ON [dbo].[DataXmlRC_actes] ([id_traitement])
	INCLUDE ([id], [date_acte], [lieu_acte], [geonameid_acte], [insee_acte], [id_fichier])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_id_image]
	ON [dbo].[DataXmlRC_actes] ([id_image])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_type_acte]
	ON [dbo].[DataXmlRC_actes] ([type_acte])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_DataXmlRC_actes_id_id_fichier]
	ON [dbo].[DataXmlRC_actes] ([id_fichier])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_DataXmlRC_actes_id_traitement]
	ON [dbo].[DataXmlRC_actes] ([id_traitement])
	INCLUDE ([lieu_acte], [geonameid_acte], [fichier_xml_acte])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_DataXmlRC_actes_id_traitement_fichier_xml_acte]
	ON [dbo].[DataXmlRC_actes] ([id_traitement], [fichier_xml_acte])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20151021-100106]
	ON [dbo].[DataXmlRC_actes] ([id_acte_xml])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20151022-144317]
	ON [dbo].[DataXmlRC_actes] ([id_acte_test])
	ON [INDEX]
GO
ALTER TABLE [dbo].[DataXmlRC_actes] SET (LOCK_ESCALATION = TABLE)
GO
