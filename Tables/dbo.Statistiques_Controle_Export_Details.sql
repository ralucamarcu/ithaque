SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statistiques_Controle_Export_Details] (
		[id_statistiques_controle_qualite_export_details]     [int] IDENTITY(1, 1) NOT NULL,
		[sous_projet]                                         [varchar](255) COLLATE French_CI_AS NULL,
		[livraison]                                           [varchar](100) COLLATE French_CI_AS NULL,
		[date_livraison]                                      [datetime] NULL,
		[id_operateur]                                        [int] NULL,
		[nom_operateur]                                       [varchar](100) COLLATE French_CI_AS NULL,
		[prenom_utilisateur]                                  [varchar](100) COLLATE French_CI_AS NULL,
		[date_traitement]                                     [datetime] NULL,
		[lots_controles]                                      [int] NULL,
		[lots_valides]                                        [int] NULL,
		[lots_rejetes]                                        [int] NULL,
		[taux_lots_rejetes]                                   [float] NULL,
		[actes_controles]                                     [int] NULL,
		[actes_valides]                                       [int] NULL,
		[actes_rejetes]                                       [int] NULL,
		[taux_actes_rejetes]                                  [float] NULL,
		[actes_lus]                                           [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Controle_Export_Details]
	ADD
	CONSTRAINT [PK__Statisti__E9ED26B704EB6D11]
	PRIMARY KEY
	CLUSTERED
	([id_statistiques_controle_qualite_export_details])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Controle_Export_Details] SET (LOCK_ESCALATION = TABLE)
GO
