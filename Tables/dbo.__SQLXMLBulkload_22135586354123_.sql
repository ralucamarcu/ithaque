SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[__SQLXMLBulkload_22135586354123_] (
		[id_zone]             [bigint] NOT NULL,
		[id_individu_xml]     [varchar](50) COLLATE French_CI_AS NOT NULL,
		[date_creation]       [datetime] NULL,
		[id_zone_test]        [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[__SQLXMLBulkload_22135586354123_]
	ADD
	CONSTRAINT [DF____SQLXMLB__date___2E84E7C7]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[__SQLXMLBulkload_22135586354123_] SET (LOCK_ESCALATION = TABLE)
GO
