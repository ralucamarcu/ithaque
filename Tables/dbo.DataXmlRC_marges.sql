SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlRC_marges] (
		[id_marge]            [bigint] IDENTITY(1, 1) NOT NULL,
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
ALTER TABLE [dbo].[DataXmlRC_marges]
	ADD
	CONSTRAINT [PK_DataXmlRC_marges]
	PRIMARY KEY
	CLUSTERED
	([id_marge])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_marges]
	ADD
	CONSTRAINT [DF_DataXmlRC_marges_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[DataXmlRC_marges]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXmlRC_marges_DataXmlRC_actes]
	FOREIGN KEY ([id_acte]) REFERENCES [dbo].[DataXmlRC_actes] ([id])
ALTER TABLE [dbo].[DataXmlRC_marges]
	CHECK CONSTRAINT [FK_DataXmlRC_marges_DataXmlRC_actes]

GO
CREATE NONCLUSTERED INDEX [idx_id_acte]
	ON [dbo].[DataXmlRC_marges] ([id_acte])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_image]
	ON [dbo].[DataXmlRC_marges] ([image])
	ON [INDEX]
GO
ALTER TABLE [dbo].[DataXmlRC_marges] SET (LOCK_ESCALATION = TABLE)
GO
