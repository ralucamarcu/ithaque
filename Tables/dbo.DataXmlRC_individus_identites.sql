SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlRC_individus_identites] (
		[id_individu]              [bigint] NOT NULL,
		[id_type_identite]         [int] NOT NULL,
		[ordre]                    [int] NOT NULL,
		[nom]                      [varchar](255) COLLATE French_CI_AS NULL,
		[prenom]                   [varchar](255) COLLATE French_CI_AS NULL,
		[date_creation]            [datetime] NULL,
		[id_acte]                  [int] NULL,
		[id_individu_identite]     [int] IDENTITY(1, 1) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_individus_identites]
	ADD
	CONSTRAINT [PK_DataXmlRC_individus_identites_1]
	PRIMARY KEY
	CLUSTERED
	([id_individu_identite])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_individus_identites] SET (LOCK_ESCALATION = TABLE)
GO
