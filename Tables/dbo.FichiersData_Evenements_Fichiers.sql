SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[FichiersData_Evenements_Fichiers] (
		[id_evenement_fichier]     [uniqueidentifier] NOT NULL,
		[id_fichier]               [uniqueidentifier] NOT NULL,
		[id_type_evenement]        [int] NULL,
		[date_evenement]           [datetime] NOT NULL,
		[id_utilisateur]           [int] NULL,
		[id_statut]                [int] NULL,
		[date_statut]              [datetime] NULL,
		[date_creation]            [datetime] NULL,
		CONSTRAINT [IX_FichiersData_Evenements_Fichiers]
		UNIQUE
		NONCLUSTERED
		([id_fichier], [id_type_evenement], [date_evenement])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers]
	ADD
	CONSTRAINT [PK_FichiersData_Evenements_Fichiers]
	PRIMARY KEY
	CLUSTERED
	([id_evenement_fichier])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Fichiers_date_creation]
	DEFAULT (getdate()) FOR [date_evenement]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Fichiers_date_creation_1]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Fichiers_id_evenement_fichier]
	DEFAULT (newid()) FOR [id_evenement_fichier]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Fichiers_FichiersData]
	FOREIGN KEY ([id_fichier]) REFERENCES [dbo].[FichiersData] ([id_fichier])
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Fichiers_FichiersData]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Fichiers_FichiersData_Types_Evenements]
	FOREIGN KEY ([id_type_evenement]) REFERENCES [dbo].[FichiersData_Types_Evenements] ([id_type_evenement])
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Fichiers_FichiersData_Types_Evenements]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Fichiers_Utilisateurs]
	FOREIGN KEY ([id_utilisateur]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Fichiers_Utilisateurs]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Fichiers] SET (LOCK_ESCALATION = TABLE)
GO
