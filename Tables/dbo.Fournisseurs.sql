SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Fournisseurs] (
		[id_fournisseur]      [int] IDENTITY(1, 1) NOT NULL,
		[nom_fournisseur]     [varchar](255) COLLATE French_CI_AS NULL,
		[date_creation]       [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Fournisseurs]
	ADD
	CONSTRAINT [PK_Fournisseurs]
	PRIMARY KEY
	CLUSTERED
	([id_fournisseur])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Fournisseurs] SET (LOCK_ESCALATION = TABLE)
GO
