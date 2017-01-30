SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlEchantillonCommunes] (
		[id]                 [bigint] IDENTITY(1, 1) NOT NULL,
		[id_echantillon]     [int] NOT NULL,
		[geonameid]          [bigint] NULL,
		[lieu]               [nvarchar](100) COLLATE French_CI_AS NULL,
		[date_creation]      [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlEchantillonCommunes]
	ADD
	CONSTRAINT [PK_DataXmlEchantillonCommunes]
	PRIMARY KEY
	CLUSTERED
	([id])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlEchantillonCommunes]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXmlEchantillonCommunes_DataXmlEchantillonEntete]
	FOREIGN KEY ([id_echantillon]) REFERENCES [dbo].[DataXmlEchantillonEntete] ([id_echantillon])
ALTER TABLE [dbo].[DataXmlEchantillonCommunes]
	CHECK CONSTRAINT [FK_DataXmlEchantillonCommunes_DataXmlEchantillonEntete]

GO
CREATE NONCLUSTERED INDEX [IX_geonameid]
	ON [dbo].[DataXmlEchantillonCommunes] ([geonameid])
	ON [INDEX]
GO
ALTER TABLE [dbo].[DataXmlEchantillonCommunes] SET (LOCK_ESCALATION = TABLE)
GO
