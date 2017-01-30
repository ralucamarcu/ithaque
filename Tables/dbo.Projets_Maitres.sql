SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Projets_Maitres] (
		[id_projet_maitre]          [uniqueidentifier] NOT NULL,
		[nom]                       [varchar](100) COLLATE French_CI_AS NULL,
		[infos]                     [varchar](max) COLLATE French_CI_AS NULL,
		[date_creation]             [datetime] NULL,
		[id_effectif_lot]           [int] NULL,
		[objectif_effectif_min]     [bigint] NULL,
		[NQA]                       [float] NULL,
		[id_prestataire]            [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Projets_Maitres]
	ADD
	CONSTRAINT [PK_Projets_Maitres]
	PRIMARY KEY
	CLUSTERED
	([id_projet_maitre])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Projets_Maitres]
	ADD
	CONSTRAINT [DF_Projets_Maitres_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Projets_Maitres]
	ADD
	CONSTRAINT [DF_ProjetsMaitres_id_projet_maitre]
	DEFAULT (newid()) FOR [id_projet_maitre]
GO
ALTER TABLE [dbo].[Projets_Maitres]
	WITH CHECK
	ADD CONSTRAINT [FK_Projets_Maitres_Prestataires]
	FOREIGN KEY ([id_prestataire]) REFERENCES [dbo].[Prestataires] ([id_prestataire])
ALTER TABLE [dbo].[Projets_Maitres]
	CHECK CONSTRAINT [FK_Projets_Maitres_Prestataires]

GO
ALTER TABLE [dbo].[Projets_Maitres]
	WITH CHECK
	ADD CONSTRAINT [FK_Projets_Maitres_Table_effectifs_lots]
	FOREIGN KEY ([id_effectif_lot]) REFERENCES [dbo].[Table_effectifs_lots] ([id_effectif_lot])
ALTER TABLE [dbo].[Projets_Maitres]
	CHECK CONSTRAINT [FK_Projets_Maitres_Table_effectifs_lots]

GO
ALTER TABLE [dbo].[Projets_Maitres]
	WITH CHECK
	ADD CONSTRAINT [FK_Projets_Maitres_Table_NQA]
	FOREIGN KEY ([id_effectif_lot], [NQA]) REFERENCES [dbo].[Table_NQA] ([id_effectif], [NQA])
ALTER TABLE [dbo].[Projets_Maitres]
	CHECK CONSTRAINT [FK_Projets_Maitres_Table_NQA]

GO
ALTER TABLE [dbo].[Projets_Maitres] SET (LOCK_ESCALATION = TABLE)
GO
