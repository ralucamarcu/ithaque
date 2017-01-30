SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[__SQLXMLBulkload_13160277442_] (
		[type_acte]                [nvarchar](50) COLLATE French_CI_AS NULL,
		[soustype_acte]            [nvarchar](50) COLLATE French_CI_AS NULL,
		[id_acte_xml]              [nvarchar](50) COLLATE French_CI_AS NULL,
		[date_acte]                [nvarchar](50) COLLATE French_CI_AS NULL,
		[annee_acte]               [nvarchar](50) COLLATE French_CI_AS NULL,
		[calendrier_date_acte]     [varchar](20) COLLATE French_CI_AS NULL,
		[lieu_acte]                [nvarchar](100) COLLATE French_CI_AS NULL,
		[geonameid_acte]           [bigint] NULL,
		[insee_acte]               [nvarchar](10) COLLATE French_CI_AS NULL,
		[soustype_xml_acte]        [nvarchar](50) COLLATE French_CI_AS NULL,
		[id_fichier]               [uniqueidentifier] NULL,
		[id_traitement]            [int] NULL,
		[fichier_xml_acte]         [nvarchar](250) COLLATE French_CI_AS NULL,
		[type_document]            [nvarchar](50) COLLATE French_CI_AS NULL,
		[id]                       [bigint] NULL,
		[TempId]                   [bigint] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [__SQLXMLBulkload_13160277442__index]
	ON [dbo].[__SQLXMLBulkload_13160277442_] ([TempId])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[__SQLXMLBulkload_13160277442_] SET (LOCK_ESCALATION = TABLE)
GO
