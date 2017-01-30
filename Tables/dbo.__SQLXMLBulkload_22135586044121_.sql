SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[__SQLXMLBulkload_22135586044121_] (
		[id_individu_xml]               [varchar](50) COLLATE French_CI_AS NULL,
		[principal]                     [bit] NULL,
		[nom]                           [varchar](255) COLLATE French_CI_AS NULL,
		[prenom]                        [varchar](300) COLLATE French_CI_AS NULL,
		[age]                           [varchar](50) COLLATE French_CI_AS NULL,
		[date_naissance]                [varchar](50) COLLATE French_CI_AS NULL,
		[annee_naissance]               [varchar](10) COLLATE French_CI_AS NULL,
		[calendrier_date_naissance]     [varchar](20) COLLATE French_CI_AS NULL,
		[lieu_naissance]                [varchar](255) COLLATE French_CI_AS NULL,
		[insee_naissance]               [varchar](50) COLLATE French_CI_AS NULL,
		[id_acte]                       [bigint] NULL,
		[geonameid_naissance]           [varchar](50) COLLATE French_CI_AS NULL,
		[id]                            [bigint] NULL,
		[TempId]                        [bigint] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [__SQLXMLBulkload_22135586044121__index]
	ON [dbo].[__SQLXMLBulkload_22135586044121_] ([TempId])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[__SQLXMLBulkload_22135586044121_] SET (LOCK_ESCALATION = TABLE)
GO
