SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Compteurs_types_traitements] (
		[id_compteur]            [int] IDENTITY(1, 1) NOT NULL,
		[id_type_traitement]     [smallint] NULL,
		[nom_compteur]           [varchar](100) COLLATE French_CI_AS NULL,
		[requete_sql]            [nvarchar](max) COLLATE French_CI_AS NULL,
		[requete_sql_export]     [nvarchar](max) COLLATE French_CI_AS NULL,
		[ordre]                  [int] NULL,
		[date_creation]          [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Compteurs_types_traitements]
	ADD
	CONSTRAINT [PK_Compteurs_types_traitements]
	PRIMARY KEY
	CLUSTERED
	([id_compteur])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Compteurs_types_traitements]
	WITH CHECK
	ADD CONSTRAINT [FK_Compteurs_types_traitements_Types_traitements]
	FOREIGN KEY ([id_type_traitement]) REFERENCES [dbo].[Types_traitements] ([id_type_traitement])
ALTER TABLE [dbo].[Compteurs_types_traitements]
	CHECK CONSTRAINT [FK_Compteurs_types_traitements_Types_traitements]

GO
ALTER TABLE [dbo].[Compteurs_types_traitements] SET (LOCK_ESCALATION = TABLE)
GO
