SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlEchantillonDetailsRC] (
		[id]                    [bigint] IDENTITY(1, 1) NOT NULL,
		[id_echantillon]        [int] NOT NULL,
		[id_acte_RC]            [bigint] NOT NULL,
		[message]               [nvarchar](max) COLLATE French_CI_AS NULL,
		[traite]                [bit] NULL,
		[date_creation]         [datetime] NULL,
		[date_modification]     [datetime] NULL,
		[erreur_saisie]         [bit] NULL,
		[erreur_selection]      [bit] NULL,
		[absence_saisie]        [bit] NULL,
		[erreur_zonage]         [bit] NULL,
		[erreur_image]          [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	ADD
	CONSTRAINT [PK_DataXmlEchantillonDetailsRC]
	PRIMARY KEY
	CLUSTERED
	([id])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonDetailsRC_absence_saisie]
	DEFAULT ((0)) FOR [absence_saisie]
GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonDetailsRC_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonDetailsRC_erreur_image]
	DEFAULT ((0)) FOR [erreur_image]
GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonDetailsRC_erreur_saisie]
	DEFAULT ((0)) FOR [erreur_saisie]
GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonDetailsRC_erreur_selection]
	DEFAULT ((0)) FOR [erreur_selection]
GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonDetailsRC_erreur_zonage]
	DEFAULT ((0)) FOR [erreur_zonage]
GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonDetailsRC_traite]
	DEFAULT ((0)) FOR [traite]
GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXmlEchantillonDetailsRC_DataXmlEchantillonEntete]
	FOREIGN KEY ([id_echantillon]) REFERENCES [dbo].[DataXmlEchantillonEntete] ([id_echantillon])
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	CHECK CONSTRAINT [FK_DataXmlEchantillonDetailsRC_DataXmlEchantillonEntete]

GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXmlEchantillonDetailsRC_DataXmlRC_actes]
	FOREIGN KEY ([id_acte_RC]) REFERENCES [dbo].[DataXmlRC_actes] ([id])
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC]
	CHECK CONSTRAINT [FK_DataXmlEchantillonDetailsRC_DataXmlRC_actes]

GO
CREATE NONCLUSTERED INDEX [IX_id_acteRC]
	ON [dbo].[DataXmlEchantillonDetailsRC] ([id_acte_RC])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_id_echantillon_id_acteRC]
	ON [dbo].[DataXmlEchantillonDetailsRC] ([id_echantillon], [id_acte_RC])
	ON [INDEX]
GO
ALTER TABLE [dbo].[DataXmlEchantillonDetailsRC] SET (LOCK_ESCALATION = TABLE)
GO
