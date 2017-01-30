SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlStatsCommunesRC] (
		[id_detail_commune]     [uniqueidentifier] NOT NULL,
		[id_traitement]         [int] NULL,
		[lieu_acte]             [nvarchar](150) COLLATE French_CI_AS NULL,
		[geonameid_acte]        [bigint] NULL,
		[insee_acte]            [nvarchar](10) COLLATE French_CI_AS NULL,
		[nb_actes]              [int] NULL,
		[nb_individus]          [int] NULL,
		[nb_caracteres]         [int] NULL,
		[nb_images]             [int] NULL,
		[nb_fichiers_XML]       [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlStatsCommunesRC]
	ADD
	CONSTRAINT [PK_DataXmlStatsCommunesRC]
	PRIMARY KEY
	CLUSTERED
	([id_detail_commune])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlStatsCommunesRC]
	ADD
	CONSTRAINT [DF_DataXmlStatsCommunesRC_id_detail_commune]
	DEFAULT (newid()) FOR [id_detail_commune]
GO
ALTER TABLE [dbo].[DataXmlStatsCommunesRC] SET (LOCK_ESCALATION = TABLE)
GO
