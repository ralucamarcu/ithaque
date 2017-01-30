SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Requetes_Rapports] (
		[id_requete_rapport]       [int] IDENTITY(1, 1) NOT NULL,
		[type_rapport]             [int] NULL,
		[libelle]                  [varchar](150) COLLATE French_CI_AS NULL,
		[requete]                  [varchar](max) COLLATE French_CI_AS NULL,
		[orientation]              [smallint] NULL,
		[adapter_largeur_page]     [bit] NULL,
		[ordre]                    [int] NULL,
		[date_creation]            [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Requetes_Rapports]
	ADD
	CONSTRAINT [PK_Requetes_Rapports]
	PRIMARY KEY
	CLUSTERED
	([id_requete_rapport])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Requetes_Rapports] SET (LOCK_ESCALATION = TABLE)
GO
