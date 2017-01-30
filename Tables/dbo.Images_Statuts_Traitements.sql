SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Images_Statuts_Traitements] (
		[id_statut_traitement]     [int] IDENTITY(1, 1) NOT NULL,
		[libelle]                  [varchar](250) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images_Statuts_Traitements]
	ADD
	CONSTRAINT [PK_Images_Statuts_Traitements]
	PRIMARY KEY
	CLUSTERED
	([id_statut_traitement])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images_Statuts_Traitements] SET (LOCK_ESCALATION = TABLE)
GO
