SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Sources] (
		[id_source]                                   [uniqueidentifier] NOT NULL,
		[id_departement]                              [varchar](50) COLLATE French_CI_AS NULL,
		[nom_departement]                             [varchar](255) COLLATE French_CI_AS NULL,
		[id_fournisseur]                              [int] NULL,
		[taille_dossier_GB]                           [int] NULL,
		[id_status_version_processus]                 [int] NULL,
		[date_creation]                               [datetime] NULL,
		[date_modifications]                          [datetime] NULL,
		[nom_format_dossier]                          [varchar](255) COLLATE French_CI_AS NULL,
		[chemin_dossier_general]                      [varchar](255) COLLATE French_CI_AS NULL,
		[id_status_version_processus_complements]     [int] NOT NULL,
		[MEP]                                         [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sources]
	ADD
	CONSTRAINT [PK_Sources]
	PRIMARY KEY
	CLUSTERED
	([id_source])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sources]
	ADD
	CONSTRAINT [DF_Sources_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Sources]
	ADD
	CONSTRAINT [DF_Sources_id_source]
	DEFAULT (newid()) FOR [id_source]
GO
ALTER TABLE [dbo].[Sources]
	ADD
	CONSTRAINT [DF_Sources_id_status_version_processus_complements]
	DEFAULT ((0)) FOR [id_status_version_processus_complements]
GO
ALTER TABLE [dbo].[Sources]
	WITH CHECK
	ADD CONSTRAINT [FK_Sources_Fournisseurs]
	FOREIGN KEY ([id_fournisseur]) REFERENCES [dbo].[Fournisseurs] ([id_fournisseur])
ALTER TABLE [dbo].[Sources]
	CHECK CONSTRAINT [FK_Sources_Fournisseurs]

GO
ALTER TABLE [dbo].[Sources] SET (LOCK_ESCALATION = TABLE)
GO
