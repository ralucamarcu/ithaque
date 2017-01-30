SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[p6_ImportXML] (
		[id]                  [uniqueidentifier] NOT NULL,
		[XMLData]             [xml] NULL,
		[date_chargement]     [datetime] NULL,
		[fichier_XML]         [varchar](200) COLLATE French_CI_AS NULL,
		[dossier_XML]         [varchar](200) COLLATE French_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[p6_ImportXML]
	ADD
	CONSTRAINT [PK_p6_ImportXML]
	PRIMARY KEY
	CLUSTERED
	([id])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[p6_ImportXML]
	ADD
	CONSTRAINT [DF_p6_ImportXML_id]
	DEFAULT (newid()) FOR [id]
GO
ALTER TABLE [dbo].[p6_ImportXML] SET (LOCK_ESCALATION = TABLE)
GO
