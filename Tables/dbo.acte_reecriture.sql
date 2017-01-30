SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[acte_reecriture] (
		[id]                                   [bigint] NOT NULL,
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
		[id_fichier]                           [uniqueidentifier] NULL,
		[type_acte_Correction]                 [varchar](50) COLLATE French_CI_AS NULL,
		[id_image]                             [uniqueidentifier] NULL,
		[date_acte_Correction_Reecriture]      [nvarchar](50) COLLATE French_CI_AS NULL,
		[annee_acte_Correction_Reecriture]     [nvarchar](50) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[acte_reecriture] SET (LOCK_ESCALATION = TABLE)
GO
