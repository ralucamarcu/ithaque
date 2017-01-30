SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Types_traitements] (
		[id_type_traitement]         [smallint] IDENTITY(1, 1) NOT NULL,
		[nom]                        [varchar](100) COLLATE French_CI_AS NULL,
		[date_creation]              [datetime] NULL,
		[groupe_type_traitement]     [varchar](10) COLLATE French_CI_AS NULL,
		[chemin_schema_XML]          [varchar](512) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Types_traitements]
	ADD
	CONSTRAINT [PK_Types_traitements]
	PRIMARY KEY
	CLUSTERED
	([id_type_traitement])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Types_traitements] SET (LOCK_ESCALATION = TABLE)
GO
