SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statistiques_Controle_Qualite_Operateurs] (
		[id_statistiques_controle_qualite_operateurs]     [int] IDENTITY(1, 1) NOT NULL,
		[id_utilisateur]                                  [int] NULL,
		[operateur_nom]                                   [varchar](255) COLLATE French_CI_AS NULL,
		[operateur_prenom]                                [varchar](255) COLLATE French_CI_AS NULL,
		[DATE]                                            [datetime] NULL,
		[lots_controles]                                  [int] NULL,
		[lots_valides]                                    [int] NULL,
		[lots_rejetes]                                    [int] NULL,
		[taux_lots_rejetes]                               [float] NULL,
		[actes_controles]                                 [int] NULL,
		[actes_valides]                                   [int] NULL,
		[actes_rejetes]                                   [int] NULL,
		[taux_actes_rejetes]                              [float] NULL,
		[actes_lus]                                       [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Controle_Qualite_Operateurs]
	ADD
	CONSTRAINT [PK__Statisti__15D3670E011ADC2D]
	PRIMARY KEY
	CLUSTERED
	([id_statistiques_controle_qualite_operateurs])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Controle_Qualite_Operateurs] SET (LOCK_ESCALATION = TABLE)
GO
