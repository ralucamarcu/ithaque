SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statuts_Echantillons] (
		[id_statut]         [int] IDENTITY(1, 1) NOT NULL,
		[libelle]           [varchar](150) COLLATE French_CI_AS NULL,
		[date_creation]     [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statuts_Echantillons]
	ADD
	CONSTRAINT [PK_Statuts_Echantillons]
	PRIMARY KEY
	CLUSTERED
	([id_statut])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statuts_Echantillons] SET (LOCK_ESCALATION = TABLE)
GO
