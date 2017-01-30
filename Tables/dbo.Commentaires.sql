SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Commentaires] (
		[id_commentaire]     [int] IDENTITY(1, 1) NOT NULL,
		[commentaire]        [varchar](max) COLLATE French_CI_AS NULL,
		[id_utilisateur]     [int] NULL,
		[date_creation]      [datetime] NULL,
		[id_projet]          [uniqueidentifier] NULL,
		[id_objet]           [int] NULL,
		[type_objet]         [varchar](50) COLLATE French_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Commentaires]
	ADD
	CONSTRAINT [PK_Commentaires]
	PRIMARY KEY
	CLUSTERED
	([id_commentaire])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Commentaires]
	ADD
	CONSTRAINT [DF_Commentaires_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Commentaires]
	WITH CHECK
	ADD CONSTRAINT [FK_Commentaires_Projets]
	FOREIGN KEY ([id_projet]) REFERENCES [dbo].[Projets] ([id_projet])
ALTER TABLE [dbo].[Commentaires]
	CHECK CONSTRAINT [FK_Commentaires_Projets]

GO
ALTER TABLE [dbo].[Commentaires]
	WITH CHECK
	ADD CONSTRAINT [FK_Commentaires_Utilisateurs]
	FOREIGN KEY ([id_utilisateur]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[Commentaires]
	CHECK CONSTRAINT [FK_Commentaires_Utilisateurs]

GO
ALTER TABLE [dbo].[Commentaires] SET (LOCK_ESCALATION = TABLE)
GO
