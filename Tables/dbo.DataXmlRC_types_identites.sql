SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlRC_types_identites] (
		[id_type_identite]     [int] IDENTITY(1, 1) NOT NULL,
		[nom]                  [varchar](100) COLLATE French_CI_AS NULL,
		[nom_DTD]              [varchar](100) COLLATE French_CI_AS NULL,
		[date_creation]        [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_types_identites]
	ADD
	CONSTRAINT [PK_DataXmlRC_types_identites]
	PRIMARY KEY
	CLUSTERED
	([id_type_identite])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_types_identites] SET (LOCK_ESCALATION = TABLE)
GO
