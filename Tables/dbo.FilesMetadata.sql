SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FilesMetadata] (
		[id_file_metadata]            [int] IDENTITY(1, 1) NOT NULL,
		[id_source]                   [uniqueidentifier] NOT NULL,
		[path_source]                 [varchar](800) COLLATE French_CI_AS NULL,
		[taille_file_metadata_KB]     [bigint] NULL,
		[type_file_metadata]          [varchar](255) COLLATE French_CI_AS NULL,
		[id_status]                   [int] NULL,
		[date_creation]               [datetime] NOT NULL,
		[date_modification]           [datetime] NULL,
		[csv_columns]                 [varchar](800) COLLATE French_CI_AS NULL,
		[nom_fichier_metadata]        [varchar](255) COLLATE French_CI_AS NULL,
		[champ_terminator]            [varchar](5) COLLATE French_CI_AS NULL,
		[ligne_terminator]            [varchar](50) COLLATE French_CI_AS NULL,
		[date_dernier_acces]          [datetime] NULL,
		[date_derniere_maj]           [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FilesMetadata]
	ADD
	CONSTRAINT [PK_FilesMetadata]
	PRIMARY KEY
	CLUSTERED
	([id_file_metadata])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FilesMetadata]
	ADD
	CONSTRAINT [DF_FilesMetadata_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[FilesMetadata]
	WITH CHECK
	ADD CONSTRAINT [FK_FilesMetadata_FilesMetadata_Statuts]
	FOREIGN KEY ([id_status]) REFERENCES [dbo].[FilesMetadata_Statuts] ([id_status])
ALTER TABLE [dbo].[FilesMetadata]
	CHECK CONSTRAINT [FK_FilesMetadata_FilesMetadata_Statuts]

GO
ALTER TABLE [dbo].[FilesMetadata]
	WITH CHECK
	ADD CONSTRAINT [FK_FilesMetadata_Sources]
	FOREIGN KEY ([id_source]) REFERENCES [dbo].[Sources] ([id_source])
ALTER TABLE [dbo].[FilesMetadata]
	CHECK CONSTRAINT [FK_FilesMetadata_Sources]

GO
ALTER TABLE [dbo].[FilesMetadata] SET (LOCK_ESCALATION = TABLE)
GO
