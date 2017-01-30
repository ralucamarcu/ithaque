SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[temp_Fichier_chemin] (
		[id]                  [int] IDENTITY(1, 1) NOT NULL,
		[nom_fichier]         [varchar](255) COLLATE French_CI_AS NULL,
		[id_fichier_data]     [uniqueidentifier] NULL,
		[chemin]              [varchar](500) COLLATE French_CI_AS NULL,
		[id_image]            [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[temp_Fichier_chemin]
	ADD
	CONSTRAINT [PK__temp_Fic__3213E83F47CA4D1C]
	PRIMARY KEY
	CLUSTERED
	([id])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[temp_Fichier_chemin] SET (LOCK_ESCALATION = TABLE)
GO
