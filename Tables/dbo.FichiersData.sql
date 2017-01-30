SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FichiersData] (
		[id_fichier]                [uniqueidentifier] NOT NULL,
		[nom]                       [varchar](512) COLLATE French_CI_AS NULL,
		[id_projet]                 [uniqueidentifier] NULL,
		[id_statut]                 [int] NULL,
		[date_statut]               [datetime] NULL,
		[statut_id_utilisateur]     [int] NULL,
		[date_creation]             [datetime] NULL,
		[nb_images]                 [int] NULL,
		[nb_actes]                  [int] NULL,
		[nb_individus]              [int] NULL,
		[id_facture]                [uniqueidentifier] NULL,
		[version_valide]            [int] NULL,
		[id_fichier_test]           [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData]
	ADD
	CONSTRAINT [PK_FichiersData]
	PRIMARY KEY
	CLUSTERED
	([id_fichier])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData]
	ADD
	CONSTRAINT [DF_FichiersData_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[FichiersData]
	ADD
	CONSTRAINT [DF_FichiersData_id_fichier]
	DEFAULT (newid()) FOR [id_fichier]
GO
ALTER TABLE [dbo].[FichiersData]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_FichiersData_Factures]
	FOREIGN KEY ([id_facture]) REFERENCES [dbo].[FichiersData_Factures] ([id_facture])
ALTER TABLE [dbo].[FichiersData]
	CHECK CONSTRAINT [FK_FichiersData_FichiersData_Factures]

GO
ALTER TABLE [dbo].[FichiersData]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_FichiersData_Statuts]
	FOREIGN KEY ([id_statut]) REFERENCES [dbo].[FichiersData_Statuts] ([id_statut])
ALTER TABLE [dbo].[FichiersData]
	CHECK CONSTRAINT [FK_FichiersData_FichiersData_Statuts]

GO
ALTER TABLE [dbo].[FichiersData]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Projets]
	FOREIGN KEY ([id_projet]) REFERENCES [dbo].[Projets] ([id_projet])
ALTER TABLE [dbo].[FichiersData]
	CHECK CONSTRAINT [FK_FichiersData_Projets]

GO
ALTER TABLE [dbo].[FichiersData]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Utilisateurs]
	FOREIGN KEY ([statut_id_utilisateur]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[FichiersData]
	CHECK CONSTRAINT [FK_FichiersData_Utilisateurs]

GO
CREATE NONCLUSTERED INDEX [IX_FichiersData_id_projet]
	ON [dbo].[FichiersData] ([id_projet])
	INCLUDE ([id_fichier])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_FichiersData_nom]
	ON [dbo].[FichiersData] ([nom])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_FichiersData_nom_id_projet]
	ON [dbo].[FichiersData] ([nom], [id_projet])
	ON [INDEX]
GO
ALTER TABLE [dbo].[FichiersData] SET (LOCK_ESCALATION = TABLE)
GO
