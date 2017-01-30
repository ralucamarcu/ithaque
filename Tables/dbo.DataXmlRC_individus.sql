SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlRC_individus] (
		[id]                                       [bigint] IDENTITY(1, 1) NOT NULL,
		[id_individu_xml]                          [varchar](50) COLLATE French_CI_AS NULL,
		[principal]                                [bit] NULL,
		[nom]                                      [varchar](255) COLLATE French_CI_AS NULL,
		[prenom]                                   [varchar](300) COLLATE French_CI_AS NULL,
		[age]                                      [varchar](50) COLLATE French_CI_AS NULL,
		[date_naissance]                           [varchar](50) COLLATE French_CI_AS NULL,
		[annee_naissance]                          [varchar](10) COLLATE French_CI_AS NULL,
		[calendrier_date_naissance]                [varchar](20) COLLATE French_CI_AS NULL,
		[lieu_naissance]                           [varchar](255) COLLATE French_CI_AS NULL,
		[insee_naissance]                          [varchar](50) COLLATE French_CI_AS NULL,
		[geonameid_naissance_old]                  [varchar](50) COLLATE French_CI_AS NULL,
		[id_acte]                                  [bigint] NULL,
		[rang]                                     [int] NULL,
		[date_naissance_gregorienne]               [datetime] NULL,
		[date_creation]                            [datetime] NULL,
		[nom_Correction]                           [varchar](255) COLLATE French_CI_AS NULL,
		[prenom_Correction]                        [varchar](300) COLLATE French_CI_AS NULL,
		[age_Correction]                           [varchar](50) COLLATE French_CI_AS NULL,
		[date_naissance_Correction]                [varchar](50) COLLATE French_CI_AS NULL,
		[annee_naissance_Correction]               [varchar](10) COLLATE French_CI_AS NULL,
		[calendrier_date_naissance_Correction]     [nvarchar](20) COLLATE French_CI_AS NULL,
		[date_modification]                        [datetime] NULL,
		[lieu_naissance_Correction]                [varchar](100) COLLATE French_CI_AS NULL,
		[insee_naissance_Correction]               [varchar](10) COLLATE French_CI_AS NULL,
		[geonameid_naissance_Correction]           [bigint] NULL,
		[nb_erreurs_individu]                      AS ((((case when isnull([nom],'')<>isnull([nom_Correction],isnull([nom],'')) then (1) else (0) end+case when isnull([prenom],'')<>isnull([prenom_Correction],isnull([prenom],'')) then (1) else (0) end)+case when isnull([age],'')<>isnull([age_Correction],isnull([age],'')) then (1) else (0) end)+case when isnull([date_naissance],'')<>isnull([date_naissance_Correction],isnull([date_naissance],'')) then (1) else (0) end)+case when isnull([insee_naissance],'')<>isnull([insee_naissance_Correction],isnull([insee_naissance],'')) then (1) else (0) end) PERSISTED,
		[nom_Correction_Reecriture]                [varchar](255) COLLATE French_CI_AS NULL,
		[prenom_Correction_Reecriture]             [varchar](255) COLLATE French_CI_AS NULL,
		[id_individu_test]                         [bigint] NULL,
		[nom_jeune_fille]                          [varchar](255) COLLATE French_CI_AS NULL,
		[nom_jeune_fille_Correction]               [varchar](255) COLLATE French_CI_AS NULL,
		[geonameid_naissance]                      [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_individus]
	ADD
	CONSTRAINT [PK_DataXmlRC_individus]
	PRIMARY KEY
	CLUSTERED
	([id])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_individus]
	ADD
	CONSTRAINT [DF_DataXmlRC_individus_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[DataXmlRC_individus]
	WITH NOCHECK
	ADD CONSTRAINT [FK_DataXmlRC_individus_DataXmlRC_actes]
	FOREIGN KEY ([id_acte]) REFERENCES [dbo].[DataXmlRC_actes] ([id])
ALTER TABLE [dbo].[DataXmlRC_individus]
	CHECK CONSTRAINT [FK_DataXmlRC_individus_DataXmlRC_actes]

GO
CREATE NONCLUSTERED INDEX [IX_DataXmlRC_individus_id_acte]
	ON [dbo].[DataXmlRC_individus] ([id_acte])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_DataXmlRC_individus_id_acte_id_individu_xml]
	ON [dbo].[DataXmlRC_individus] ([id_acte], [id_individu_xml])
	INCLUDE ([id], [principal], [nom], [prenom], [age], [date_naissance], [annee_naissance], [calendrier_date_naissance], [lieu_naissance], [insee_naissance], [geonameid_naissance_old], [rang], [nom_Correction], [prenom_Correction], [age_Correction], [date_naissance_Correction], [annee_naissance_Correction], [calendrier_date_naissance_Correction], [lieu_naissance_Correction], [insee_naissance_Correction], [geonameid_naissance_Correction])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_DataXmlRC_individus_id_individu_xml]
	ON [dbo].[DataXmlRC_individus] ([id_individu_xml])
	INCLUDE ([principal])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_DataXmlRC_individus_principal]
	ON [dbo].[DataXmlRC_individus] ([principal], [id_acte])
	INCLUDE ([id_individu_xml], [nom], [prenom])
	ON [INDEX]
GO
ALTER TABLE [dbo].[DataXmlRC_individus] SET (LOCK_ESCALATION = TABLE)
GO
