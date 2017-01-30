SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Taches_Images_Logs] (
		[id_log]                            [int] IDENTITY(1, 1) NOT NULL,
		[id_image]                          [uniqueidentifier] NOT NULL,
		[path_origine]                      [varchar](500) COLLATE French_CI_AS NULL,
		[path_destination]                  [varchar](500) COLLATE French_CI_AS NULL,
		[id_tache]                          [int] NULL,
		[date_creation]                     [datetime] NOT NULL,
		[nom_fichier_image_origine]         [varchar](255) COLLATE French_CI_AS NULL,
		[nom_fichier_image_destination]     [varchar](255) COLLATE French_CI_AS NULL,
		[taille_image]                      [int] NULL,
		[id_status]                         [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Images_Logs]
	ADD
	CONSTRAINT [PK_Images_Taches_Logs]
	PRIMARY KEY
	CLUSTERED
	([id_log])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Images_Logs]
	ADD
	CONSTRAINT [DF_Taches_Images_Logs_date_creation_1]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Taches_Images_Logs]
	WITH CHECK
	ADD CONSTRAINT [FK_Taches_Images_Logs_Taches]
	FOREIGN KEY ([id_tache]) REFERENCES [dbo].[Taches] ([id_tache])
ALTER TABLE [dbo].[Taches_Images_Logs]
	CHECK CONSTRAINT [FK_Taches_Images_Logs_Taches]

GO
CREATE NONCLUSTERED INDEX [idx_id_image]
	ON [dbo].[Taches_Images_Logs] ([id_image])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_id_status]
	ON [dbo].[Taches_Images_Logs] ([id_status])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_id_tache]
	ON [dbo].[Taches_Images_Logs] ([id_tache])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_nom_fichier_image_destination]
	ON [dbo].[Taches_Images_Logs] ([nom_fichier_image_destination])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_nom_fichier_image_origine]
	ON [dbo].[Taches_Images_Logs] ([nom_fichier_image_origine])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_path_destination]
	ON [dbo].[Taches_Images_Logs] ([path_destination])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Images_Logs] SET (LOCK_ESCALATION = TABLE)
GO
