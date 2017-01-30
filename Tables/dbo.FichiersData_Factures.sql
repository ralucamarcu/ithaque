SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FichiersData_Factures] (
		[id_facture]                    [uniqueidentifier] NOT NULL,
		[nom]                           [varchar](100) COLLATE French_CI_AS NOT NULL,
		[date_facture]                  [datetime] NULL,
		[valide]                        [bit] NULL,
		[date_validation]               [datetime] NULL,
		[id_utilisateur_validation]     [int] NULL,
		[date_creation]                 [datetime] NULL,
		[montant_HT]                    [decimal](18, 2) NULL,
		[montant_TTC]                   [decimal](18, 2) NULL,
		[montant_taxes]                 [decimal](18, 2) NULL,
		[paye]                          [bit] NOT NULL,
		[date_paiement]                 [datetime] NULL,
		[id_projet]                     [uniqueidentifier] NULL,
		[id_projet_maitre]              [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Factures]
	ADD
	CONSTRAINT [PK_FichiersData_Factures]
	PRIMARY KEY
	CLUSTERED
	([id_facture])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Factures]
	ADD
	CONSTRAINT [DF_FichiersData_Factures_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[FichiersData_Factures]
	ADD
	CONSTRAINT [DF_FichiersData_Factures_date_facture]
	DEFAULT (getdate()) FOR [date_facture]
GO
ALTER TABLE [dbo].[FichiersData_Factures]
	ADD
	CONSTRAINT [DF_FichiersData_Factures_id_facture]
	DEFAULT (newid()) FOR [id_facture]
GO
ALTER TABLE [dbo].[FichiersData_Factures]
	ADD
	CONSTRAINT [DF_FichiersData_Factures_payee]
	DEFAULT ((0)) FOR [paye]
GO
ALTER TABLE [dbo].[FichiersData_Factures]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Factures_Projets_Maitres]
	FOREIGN KEY ([id_projet_maitre]) REFERENCES [dbo].[Projets_Maitres] ([id_projet_maitre])
ALTER TABLE [dbo].[FichiersData_Factures]
	CHECK CONSTRAINT [FK_FichiersData_Factures_Projets_Maitres]

GO
ALTER TABLE [dbo].[FichiersData_Factures]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Factures_Utilisateurs]
	FOREIGN KEY ([id_utilisateur_validation]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[FichiersData_Factures]
	CHECK CONSTRAINT [FK_FichiersData_Factures_Utilisateurs]

GO
ALTER TABLE [dbo].[FichiersData_Factures] SET (LOCK_ESCALATION = TABLE)
GO
