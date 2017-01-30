SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[FichiersData_Evenements_Lots] (
		[id_evenement_lot]      [uniqueidentifier] NOT NULL,
		[id_lot]                [uniqueidentifier] NOT NULL,
		[id_type_evenement]     [int] NULL,
		[date_evenement]        [datetime] NOT NULL,
		[id_utilisateur]        [int] NULL,
		[date_creation]         [datetime] NULL,
		CONSTRAINT [IX_FichiersData_Evenements_Lots]
		UNIQUE
		NONCLUSTERED
		([id_lot], [id_type_evenement], [date_evenement])
		ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Lots]
	ADD
	CONSTRAINT [PK_FichiersData_Evenements_Lots]
	PRIMARY KEY
	CLUSTERED
	([id_evenement_lot])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Lots]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Lots_date_creation]
	DEFAULT (getdate()) FOR [date_evenement]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Lots]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Lots_date_creation_1]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Lots]
	ADD
	CONSTRAINT [DF_FichiersData_Evenements_Lots_id_evenement_lot]
	DEFAULT (newid()) FOR [id_evenement_lot]
GO
ALTER TABLE [dbo].[FichiersData_Evenements_Lots]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Lots_DataXml_lots_fichiers]
	FOREIGN KEY ([id_lot]) REFERENCES [dbo].[DataXml_lots_fichiers] ([id_lot])
ALTER TABLE [dbo].[FichiersData_Evenements_Lots]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Lots_DataXml_lots_fichiers]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Lots]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Lots_FichiersData_Types_Evenements]
	FOREIGN KEY ([id_type_evenement]) REFERENCES [dbo].[FichiersData_Types_Evenements] ([id_type_evenement])
ALTER TABLE [dbo].[FichiersData_Evenements_Lots]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Lots_FichiersData_Types_Evenements]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Lots]
	WITH CHECK
	ADD CONSTRAINT [FK_FichiersData_Evenements_Lots_Utilisateurs]
	FOREIGN KEY ([id_utilisateur]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[FichiersData_Evenements_Lots]
	CHECK CONSTRAINT [FK_FichiersData_Evenements_Lots_Utilisateurs]

GO
ALTER TABLE [dbo].[FichiersData_Evenements_Lots] SET (LOCK_ESCALATION = TABLE)
GO
