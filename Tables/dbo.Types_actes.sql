SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Types_actes] (
		[id_type_acte]     [int] IDENTITY(1, 1) NOT NULL,
		[nom]              [varchar](150) COLLATE French_CI_AS NULL,
		[valeur_xml]       [varchar](50) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Types_actes]
	ADD
	CONSTRAINT [PK_Types_actes]
	PRIMARY KEY
	CLUSTERED
	([id_type_acte])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Types_actes] SET (LOCK_ESCALATION = TABLE)
GO
