SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataXmlEchantillonEntete] (
		[id_echantillon]                        [int] IDENTITY(1, 1) NOT NULL,
		[id_traitement]                         [int] NULL,
		[nom_echantillon]                       [nvarchar](100) COLLATE French_CI_AS NULL,
		[date_creation]                         [datetime] NULL,
		[pourcent_selection_commune]            [float] NULL,
		[pourcent_selection_echantillon]        [float] NULL,
		[pourcent_echantillon_sur_totalite]     [float] NULL,
		[flag_echantillon_communes]             [bit] NULL,
		[flag_echantillon_actes]                [bit] NULL,
		[type_echantillon]                      [varchar](10) COLLATE French_CI_AS NULL,
		[id_lot]                                [uniqueidentifier] NULL,
		[id_lot_old]                            [int] NULL,
		[id_statut]                             [int] NULL,
		[traite]                                [bit] NOT NULL,
		[remarques]                             [varchar](max) COLLATE French_CI_AS NULL,
		[verrou]                                [bit] NOT NULL,
		[id_utilisateur_verrou]                 [int] NULL,
		[flag_arret_controle]                   [bit] NULL,
		[nb_champs_echantillon]                 [bigint] NULL,
		[id_effectif]                           [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlEchantillonEntete]
	ADD
	CONSTRAINT [PK_DataXmlEchantillonEntete]
	PRIMARY KEY
	CLUSTERED
	([id_echantillon])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataXmlEchantillonEntete]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonEntete_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[DataXmlEchantillonEntete]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonEntete_flag_echantillon_actes]
	DEFAULT ((0)) FOR [flag_echantillon_actes]
GO
ALTER TABLE [dbo].[DataXmlEchantillonEntete]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonEntete_flag_echantillon_communes]
	DEFAULT ((0)) FOR [flag_echantillon_communes]
GO
ALTER TABLE [dbo].[DataXmlEchantillonEntete]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonEntete_traite]
	DEFAULT ((0)) FOR [traite]
GO
ALTER TABLE [dbo].[DataXmlEchantillonEntete]
	ADD
	CONSTRAINT [DF_DataXmlEchantillonEntete_verrou]
	DEFAULT ((0)) FOR [verrou]
GO
ALTER TABLE [dbo].[DataXmlEchantillonEntete]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXmlEchantillonEntete_Statuts_Echantillons]
	FOREIGN KEY ([id_statut]) REFERENCES [dbo].[Statuts_Echantillons] ([id_statut])
ALTER TABLE [dbo].[DataXmlEchantillonEntete]
	CHECK CONSTRAINT [FK_DataXmlEchantillonEntete_Statuts_Echantillons]

GO
ALTER TABLE [dbo].[DataXmlEchantillonEntete]
	WITH CHECK
	ADD CONSTRAINT [FK_DataXmlEchantillonEntete_Utilisateurs]
	FOREIGN KEY ([id_utilisateur_verrou]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[DataXmlEchantillonEntete]
	CHECK CONSTRAINT [FK_DataXmlEchantillonEntete_Utilisateurs]

GO
CREATE NONCLUSTERED INDEX [idx_id_lot]
	ON [dbo].[DataXmlEchantillonEntete] ([id_lot])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_id_statut]
	ON [dbo].[DataXmlEchantillonEntete] ([id_statut])
	INCLUDE ([id_lot])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_traite]
	ON [dbo].[DataXmlEchantillonEntete] ([traite])
	INCLUDE ([id_lot])
	ON [INDEX]
GO
ALTER TABLE [dbo].[DataXmlEchantillonEntete] SET (LOCK_ESCALATION = TABLE)
GO
