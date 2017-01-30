SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Types_actes_traitements] (
		[id]                [bigint] IDENTITY(1, 1) NOT NULL,
		[id_traitement]     [int] NULL,
		[type_dataxml]      [varchar](10) COLLATE French_CI_AS NULL,
		[type_acte]         [nvarchar](150) COLLATE French_CI_AS NULL,
		[soustype_acte]     [nvarchar](150) COLLATE French_CI_AS NULL,
		[nb_actes]          [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Types_actes_traitements]
	ADD
	CONSTRAINT [PK_Types_actes_traitements]
	PRIMARY KEY
	CLUSTERED
	([id])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_types_actes_traitements_id_traitement]
	ON [dbo].[Types_actes_traitements] ([id_traitement])
	ON [INDEX]
GO
ALTER TABLE [dbo].[Types_actes_traitements] SET (LOCK_ESCALATION = TABLE)
GO
