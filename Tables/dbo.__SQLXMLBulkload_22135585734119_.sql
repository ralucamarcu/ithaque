SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[__SQLXMLBulkload_22135585734119_] (
		[ordre]               [varchar](5) COLLATE French_CI_AS NULL,
		[cache]               [bit] NULL,
		[image]               [varchar](500) COLLATE French_CI_AS NULL,
		[rect_x1]             [varchar](50) COLLATE French_CI_AS NULL,
		[rect_y1]             [varchar](50) COLLATE French_CI_AS NULL,
		[rect_x2]             [varchar](50) COLLATE French_CI_AS NULL,
		[rect_y2]             [varchar](50) COLLATE French_CI_AS NULL,
		[date_creation]       [datetime] NULL,
		[id_acte]             [bigint] NULL,
		[tag_image]           [varchar](50) COLLATE French_CI_AS NULL,
		[tag_rectangle]       [varchar](50) COLLATE French_CI_AS NULL,
		[id_individu_xml]     [varchar](50) COLLATE French_CI_AS NULL,
		[primaire]            [bit] NULL,
		[id_image]            [uniqueidentifier] NULL,
		[statut]              [nvarchar](50) COLLATE French_CI_AS NULL,
		[id_zone_test]        [bigint] NULL,
		[id_zone]             [bigint] NULL,
		[TempId]              [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[__SQLXMLBulkload_22135585734119_]
	ADD
	CONSTRAINT [DF____SQLXMLB__date___27D7EA38]
	DEFAULT (getdate()) FOR [date_creation]
GO
CREATE CLUSTERED INDEX [__SQLXMLBulkload_22135585734119__index]
	ON [dbo].[__SQLXMLBulkload_22135585734119_] ([TempId])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[__SQLXMLBulkload_22135585734119_] SET (LOCK_ESCALATION = TABLE)
GO
