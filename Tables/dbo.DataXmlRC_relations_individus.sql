SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlRC_relations_individus] (
		[id]                           [bigint] IDENTITY(1, 1) NOT NULL,
		[id_individu_xml]              [varchar](50) COLLATE French_CI_AS NULL,
		[id_individu_relation_xml]     [varchar](50) COLLATE French_CI_AS NULL,
		[nom_relation]                 [varchar](50) COLLATE French_CI_AS NULL,
		[id_acte]                      [bigint] NULL,
		[date_creation]                [datetime] NULL,
		[id_relation_test]             [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_relations_individus]
	ADD
	CONSTRAINT [PK_DataXmlRC_relation_individus]
	PRIMARY KEY
	CLUSTERED
	([id])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlRC_relations_individus]
	ADD
	CONSTRAINT [DF_DataXmlRC_relations_individus_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[DataXmlRC_relations_individus]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXmlRC_relations_individus_DataXmlRC_actes]
	FOREIGN KEY ([id_acte]) REFERENCES [dbo].[DataXmlRC_actes] ([id])
ALTER TABLE [dbo].[DataXmlRC_relations_individus]
	CHECK CONSTRAINT [FK_DataXmlRC_relations_individus_DataXmlRC_actes]

GO
CREATE NONCLUSTERED INDEX [IX_DataXmlRC_relations_individus_id_acte]
	ON [dbo].[DataXmlRC_relations_individus] ([id_acte])
	ON [INDEX]
GO
ALTER TABLE [dbo].[DataXmlRC_relations_individus] SET (LOCK_ESCALATION = TABLE)
GO
