SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[__SQLXMLBulkload_22135586194122_] (
		[id_individu_xml]              [varchar](50) COLLATE French_CI_AS NULL,
		[id_individu_relation_xml]     [varchar](50) COLLATE French_CI_AS NULL,
		[nom_relation]                 [varchar](50) COLLATE French_CI_AS NULL,
		[id_acte]                      [bigint] NULL,
		[date_creation]                [datetime] NULL,
		[id_relation_test]             [bigint] NULL,
		[id]                           [bigint] NULL,
		[TempId]                       [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[__SQLXMLBulkload_22135586194122_]
	ADD
	CONSTRAINT [DF____SQLXMLB__date___2C9C9F55]
	DEFAULT (getdate()) FOR [date_creation]
GO
CREATE CLUSTERED INDEX [__SQLXMLBulkload_22135586194122__index]
	ON [dbo].[__SQLXMLBulkload_22135586194122_] ([TempId])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[__SQLXMLBulkload_22135586194122_] SET (LOCK_ESCALATION = TABLE)
GO
