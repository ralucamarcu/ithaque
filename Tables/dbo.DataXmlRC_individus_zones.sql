SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlRC_individus_zones] (
		[id_zone]             [bigint] NOT NULL,
		[id_individu_xml]     [varchar](50) COLLATE French_CI_AS NOT NULL,
		[date_creation]       [datetime] NULL,
		[id_zone_test]        [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_individus_zones]
	ADD
	CONSTRAINT [DF_DataXmlRC_individus_zones_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
CREATE NONCLUSTERED INDEX [IX_DataXmlRC_individus_zones_id_zone]
	ON [dbo].[DataXmlRC_individus_zones] ([id_zone])
	ON [INDEX]
GO
ALTER TABLE [dbo].[DataXmlRC_individus_zones] SET (LOCK_ESCALATION = TABLE)
GO
