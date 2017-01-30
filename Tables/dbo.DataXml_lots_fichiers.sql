SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXml_lots_fichiers] (
		[id_lot]                         [uniqueidentifier] NOT NULL,
		[id_traitement]                  [int] NOT NULL,
		[nom_lot]                        [nvarchar](200) COLLATE French_CI_AS NULL,
		[ordre]                          [int] NULL,
		[date_creation]                  [datetime] NULL,
		[dossier_source_export]          [varchar](250) COLLATE French_CI_AS NULL,
		[dossier_destination_export]     [varchar](250) COLLATE French_CI_AS NULL,
		[export_pour_mep]                [bit] NOT NULL,
		[date_export_pour_mep]           [datetime] NULL,
		[id_lot_old]                     [uniqueidentifier] NULL,
		[MEP_date]                       [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXml_lots_fichiers]
	ADD
	CONSTRAINT [PK_DataXml_lots_fichiers_1]
	PRIMARY KEY
	CLUSTERED
	([id_lot])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXml_lots_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_lots_fichiers_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[DataXml_lots_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_lots_fichiers_export_pour_mep]
	DEFAULT ((0)) FOR [export_pour_mep]
GO
ALTER TABLE [dbo].[DataXml_lots_fichiers]
	ADD
	CONSTRAINT [DF_DataXml_lots_fichiers_guid]
	DEFAULT (newid()) FOR [id_lot]
GO
ALTER TABLE [dbo].[DataXml_lots_fichiers]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXml_lots_fichiers]
	FOREIGN KEY ([id_traitement]) REFERENCES [dbo].[Traitements] ([id_traitement])
ALTER TABLE [dbo].[DataXml_lots_fichiers]
	CHECK CONSTRAINT [FK_DataXml_lots_fichiers]

GO
ALTER TABLE [dbo].[DataXml_lots_fichiers] SET (LOCK_ESCALATION = TABLE)
GO
