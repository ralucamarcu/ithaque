SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlRC_zones] (
		[id_zone]               [bigint] IDENTITY(1, 1) NOT NULL,
		[ordre]                 [varchar](5) COLLATE French_CI_AS NULL,
		[cache]                 [bit] NULL,
		[image]                 [varchar](500) COLLATE French_CI_AS NULL,
		[rect_x1]               [varchar](50) COLLATE French_CI_AS NULL,
		[rect_y1]               [varchar](50) COLLATE French_CI_AS NULL,
		[rect_x2]               [varchar](50) COLLATE French_CI_AS NULL,
		[rect_y2]               [varchar](50) COLLATE French_CI_AS NULL,
		[date_creation]         [datetime] NULL,
		[id_acte]               [bigint] NULL,
		[tag_image]             [varchar](50) COLLATE French_CI_AS NULL,
		[tag_rectangle]         [varchar](50) COLLATE French_CI_AS NULL,
		[id_individu_xml]       [varchar](50) COLLATE French_CI_AS NULL,
		[primaire]              [bit] NULL,
		[id_image]              [uniqueidentifier] NULL,
		[statut]                [nvarchar](50) COLLATE French_CI_AS NULL,
		[id_zone_test]          [bigint] NULL,
		[date_modification]     [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_zones]
	ADD
	CONSTRAINT [PK_DataXmlRC_zones]
	PRIMARY KEY
	CLUSTERED
	([id_zone])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_zones]
	ADD
	CONSTRAINT [DF_DataXmlRC_zones_cache]
	DEFAULT ((0)) FOR [cache]
GO
ALTER TABLE [dbo].[DataXmlRC_zones]
	ADD
	CONSTRAINT [DF_DataXmlRC_zones_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[DataXmlRC_zones]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXmlRC_zones_DataXmlRC_actes]
	FOREIGN KEY ([id_acte]) REFERENCES [dbo].[DataXmlRC_actes] ([id])
ALTER TABLE [dbo].[DataXmlRC_zones]
	CHECK CONSTRAINT [FK_DataXmlRC_zones_DataXmlRC_actes]

GO
CREATE NONCLUSTERED INDEX [idx_id_acte]
	ON [dbo].[DataXmlRC_zones] ([id_acte])
	INCLUDE ([id_zone])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_id_image]
	ON [dbo].[DataXmlRC_zones] ([id_image])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_id_image2]
	ON [dbo].[DataXmlRC_zones] ([id_image])
	INCLUDE ([id_zone], [id_acte])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_image]
	ON [dbo].[DataXmlRC_zones] ([image])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_DataXmlRC_zones_1]
	ON [dbo].[DataXmlRC_zones] ([id_acte], [rect_x1], [rect_y1], [rect_x2], [rect_y2])
	ON [INDEX]
GO
ALTER TABLE [dbo].[DataXmlRC_zones] SET (LOCK_ESCALATION = TABLE)
GO
