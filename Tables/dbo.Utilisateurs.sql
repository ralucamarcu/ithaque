SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Utilisateurs] (
		[id_utilisateur]      [int] IDENTITY(1, 1) NOT NULL,
		[niveau]              [int] NOT NULL,
		[login]               [varchar](50) COLLATE French_CI_AS NOT NULL,
		[password]            [varchar](50) COLLATE French_CI_AS NOT NULL,
		[prenom]              [varchar](50) COLLATE French_CI_AS NULL,
		[nom]                 [varchar](250) COLLATE French_CI_AS NULL,
		[email]               [varchar](100) COLLATE French_CI_AS NULL,
		[actif]               [bit] NOT NULL,
		[date_expiration]     [datetime] NULL,
		[date_creation]       [datetime] NOT NULL,
		[role]                [varchar](50) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Utilisateurs]
	ADD
	CONSTRAINT [PK_Utilisateurs]
	PRIMARY KEY
	CLUSTERED
	([id_utilisateur])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Utilisateurs]
	ADD
	CONSTRAINT [DF_Utilisateurs_actif]
	DEFAULT ((1)) FOR [actif]
GO
ALTER TABLE [dbo].[Utilisateurs]
	ADD
	CONSTRAINT [DF_Utilisateurs_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Utilisateurs] SET (LOCK_ESCALATION = TABLE)
GO
