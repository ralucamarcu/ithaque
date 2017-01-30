SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FichiersData_Commentaires_Factures] (
		[id_commentaire]     [int] IDENTITY(1, 1) NOT NULL,
		[commentaire]        [varchar](max) COLLATE French_CI_AS NULL,
		[id_utilisateur]     [int] NULL,
		[id_facture]         [uniqueidentifier] NOT NULL,
		[date_creation]      [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Commentaires_Factures]
	ADD
	CONSTRAINT [PK_FichiersData_Commentaires_Factures]
	PRIMARY KEY
	CLUSTERED
	([id_commentaire])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Commentaires_Factures]
	ADD
	CONSTRAINT [DF_FichiersData_Commentaires_Factures_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[FichiersData_Commentaires_Factures]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Commentaires_Factures_FichiersData_Factures]
	FOREIGN KEY ([id_facture]) REFERENCES [dbo].[FichiersData_Factures] ([id_facture])
ALTER TABLE [dbo].[FichiersData_Commentaires_Factures]
	CHECK CONSTRAINT [FK_FichiersData_Commentaires_Factures_FichiersData_Factures]

GO
ALTER TABLE [dbo].[FichiersData_Commentaires_Factures]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Commentaires_Factures_Utilisateurs]
	FOREIGN KEY ([id_utilisateur]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[FichiersData_Commentaires_Factures]
	CHECK CONSTRAINT [FK_FichiersData_Commentaires_Factures_Utilisateurs]

GO
ALTER TABLE [dbo].[FichiersData_Commentaires_Factures] SET (LOCK_ESCALATION = TABLE)
GO
