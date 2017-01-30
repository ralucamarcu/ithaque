SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlRC_individus_prenoms] (
		[id_prenom_reecriture]     [int] IDENTITY(1, 1) NOT NULL,
		[prenom_initial]           [varchar](255) COLLATE French_CI_AS NULL,
		[prenom_reecriture]        [varchar](255) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_individus_prenoms]
	ADD
	CONSTRAINT [PK_DataXmlRC_individus_prenoms]
	PRIMARY KEY
	CLUSTERED
	([id_prenom_reecriture])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_individus_prenoms] SET (LOCK_ESCALATION = TABLE)
GO
