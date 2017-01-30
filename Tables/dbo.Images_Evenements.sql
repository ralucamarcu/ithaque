SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[Images_Evenements] (
		[id_evenement_image]     [uniqueidentifier] NOT NULL,
		[id_image]               [uniqueidentifier] NULL,
		[id_type_evenement]      [int] NULL,
		[date_evenement]         [datetime] NULL,
		[id_utilisateur]         [int] NULL,
		[id_status]              [int] NULL,
		[date_status]            [datetime] NULL,
		[date_creation]          [datetime] NULL,
		[id_tache]               [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images_Evenements]
	ADD
	CONSTRAINT [PK_Images_Evenements]
	PRIMARY KEY
	CLUSTERED
	([id_evenement_image])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images_Evenements]
	ADD
	CONSTRAINT [DF_Images_Evenements_date_evenement]
	DEFAULT (getdate()) FOR [date_evenement]
GO
ALTER TABLE [dbo].[Images_Evenements]
	ADD
	CONSTRAINT [DF_Images_Evenements_id_evenement_image]
	DEFAULT (newid()) FOR [id_evenement_image]
GO
ALTER TABLE [dbo].[Images_Evenements]
	WITH CHECK
	ADD CONSTRAINT [FK_Images_Evenements_FichiersData_Types_Evenements]
	FOREIGN KEY ([id_type_evenement]) REFERENCES [dbo].[FichiersData_Types_Evenements] ([id_type_evenement])
ALTER TABLE [dbo].[Images_Evenements]
	CHECK CONSTRAINT [FK_Images_Evenements_FichiersData_Types_Evenements]

GO
ALTER TABLE [dbo].[Images_Evenements]
	WITH CHECK
	ADD CONSTRAINT [FK_Images_Evenements_Images]
	FOREIGN KEY ([id_image]) REFERENCES [dbo].[Images_old] ([id_image])
ALTER TABLE [dbo].[Images_Evenements]
	CHECK CONSTRAINT [FK_Images_Evenements_Images]

GO
ALTER TABLE [dbo].[Images_Evenements]
	WITH CHECK
	ADD CONSTRAINT [FK_Images_Evenements_Images_Statuts]
	FOREIGN KEY ([id_status]) REFERENCES [dbo].[Images_Statuts] ([id_status])
ALTER TABLE [dbo].[Images_Evenements]
	CHECK CONSTRAINT [FK_Images_Evenements_Images_Statuts]

GO
CREATE NONCLUSTERED INDEX [idx_images_evenement_id_image]
	ON [dbo].[Images_Evenements] ([id_image], [id_type_evenement], [date_evenement])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_images_evenement_tache]
	ON [dbo].[Images_Evenements] ([id_tache], [id_type_evenement])
	ON [INDEX]
GO
ALTER TABLE [dbo].[Images_Evenements] SET (LOCK_ESCALATION = TABLE)
GO
