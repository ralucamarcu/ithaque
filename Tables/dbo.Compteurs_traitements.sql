SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[Compteurs_traitements] (
		[id]                    [uniqueidentifier] NOT NULL,
		[id_traitement]         [int] NULL,
		[id_compteur]           [int] NOT NULL,
		[valeur]                [bigint] NULL,
		[date_creation]         [datetime] NULL,
		[id_traitement_old]     [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Compteurs_traitements]
	ADD
	CONSTRAINT [PK_Compteurs_traitements]
	PRIMARY KEY
	CLUSTERED
	([id])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Compteurs_traitements]
	ADD
	CONSTRAINT [DF_Compteurs_traitements_id]
	DEFAULT (newid()) FOR [id]
GO
ALTER TABLE [dbo].[Compteurs_traitements]
	WITH CHECK
	ADD CONSTRAINT [FK_Compteurs_traitements_Compteurs_types_traitements]
	FOREIGN KEY ([id_compteur]) REFERENCES [dbo].[Compteurs_types_traitements] ([id_compteur])
ALTER TABLE [dbo].[Compteurs_traitements]
	CHECK CONSTRAINT [FK_Compteurs_traitements_Compteurs_types_traitements]

GO
CREATE NONCLUSTERED INDEX [IX_Compteurs_traitements_id_traitement]
	ON [dbo].[Compteurs_traitements] ([id_traitement])
	ON [INDEX]
GO
ALTER TABLE [dbo].[Compteurs_traitements] SET (LOCK_ESCALATION = TABLE)
GO
