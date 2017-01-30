SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[temp_DataXmlRC_marges_35] (
		[id_marge]            [bigint] NOT NULL,
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
		[statut]              [nvarchar](50) COLLATE French_CI_AS NULL,
		[id_marge_test]       [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[temp_DataXmlRC_marges_35] SET (LOCK_ESCALATION = TABLE)
GO
