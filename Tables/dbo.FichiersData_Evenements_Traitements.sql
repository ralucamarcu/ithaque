SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[FichiersData_Evenements_Traitements] (
		[id_evenement_traitement]     [uniqueidentifier] NOT NULL,
		[id_traitement]               [int] NOT NULL,
		[id_type_evenement]           [int] NOT NULL,
		[date_evenement]              [datetime] NOT NULL,
		[id_utilisateur]              [int] NULL,
		[date_creation]               [datetime] NULL,
		CONSTRAINT [IX_FichiersData_Evenements_Traitements]
		UNIQUE
		NONCLUSTERED
		([id_traitement], [id_type_evenement], [date_evenement])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements]
	ADD
	CONSTRAINT [PK_FichiersData_Evenements_Traitements]
	PRIMARY KEY
	CLUSTERED
	([id_evenement_traitement])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Traitements_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Traitements_date_evenement]
	DEFAULT (getdate()) FOR [date_evenement]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Traitements_id_evenement_traitement]
	DEFAULT (newid()) FOR [id_evenement_traitement]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Traitements_FichiersData_Types_Evenements]
	FOREIGN KEY ([id_type_evenement]) REFERENCES [dbo].[FichiersData_Types_Evenements] ([id_type_evenement])
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Traitements_FichiersData_Types_Evenements]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Traitements_Traitements]
	FOREIGN KEY ([id_traitement]) REFERENCES [dbo].[Traitements] ([id_traitement])
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Traitements_Traitements]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Traitements_Utilisateurs]
	FOREIGN KEY ([id_utilisateur]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Traitements_Utilisateurs]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Traitements] SET (LOCK_ESCALATION = TABLE)
GO
