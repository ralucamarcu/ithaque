SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statistiques_Types] (
		[id_statistique_type]      [int] IDENTITY(1, 1) NOT NULL,
		[statistique_type_nom]     [varchar](50) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Types]
	ADD
	CONSTRAINT [PK_Statistiques_Type]
	PRIMARY KEY
	CLUSTERED
	([id_statistique_type])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Types] SET (LOCK_ESCALATION = TABLE)
GO
