SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[FichiersData_Evenements_Projets] (
		[id_evenement_projet]     [uniqueidentifier] NOT NULL,
		[id_projet]               [uniqueidentifier] NOT NULL,
		[id_type_evenement]       [int] NOT NULL,
		[date_evenement]          [datetime] NOT NULL,
		[id_utilisateur]          [int] NULL,
		[date_creation]           [datetime] NULL,
		CONSTRAINT [IX_FichiersData_Evenements_Projets]
		UNIQUE
		NONCLUSTERED
		([id_projet], [id_type_evenement], [date_evenement])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Projets]
	ADD
	CONSTRAINT [PK_FichiersData_Evenements_Projets]
	PRIMARY KEY
	CLUSTERED
	([id_evenement_projet])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Projets]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Projets_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Projets]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Projets_date_evenement]
	DEFAULT (getdate()) FOR [date_evenement]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Projets]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Projets_FichiersData_Types_Evenements]
	FOREIGN KEY ([id_type_evenement]) REFERENCES [dbo].[FichiersData_Types_Evenements] ([id_type_evenement])
ALTER TABLE [dbo].[FichiersData_Evenements_Projets]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Projets_FichiersData_Types_Evenements]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Projets]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Projets_Projets]
	FOREIGN KEY ([id_projet]) REFERENCES [dbo].[Projets] ([id_projet])
ALTER TABLE [dbo].[FichiersData_Evenements_Projets]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Projets_Projets]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Projets]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Projets_Utilisateurs]
	FOREIGN KEY ([id_utilisateur]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[FichiersData_Evenements_Projets]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Projets_Utilisateurs]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Projets] SET (LOCK_ESCALATION = TABLE)
GO
