SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statistiques_Controle_Qualite_General] (
		[id_statistiques_controle_qualite_general]     [int] IDENTITY(1, 1) NOT NULL,
		[nom_projet_maitre]                            [varchar](255) COLLATE French_CI_AS NULL,
		[lots_conformes]                               [int] NULL,
		[actes_conformes]                              [int] NULL,
		[lots_a_controler]                             [int] NULL,
		[taux_lots_a_controler]                        [float] NULL,
		[lots_controles]                               [int] NULL,
		[taux_lots_controles]                          [float] NULL,
		[lots_valides]                                 [int] NULL,
		[taux_lots_valides]                            [float] NULL,
		[lots_rejetes]                                 [int] NULL,
		[taux_lots_rejetes]                            [float] NULL,
		[actes_a_controler]                            [int] NULL,
		[taux_actes_a_controler]                       [float] NULL,
		[actes_controles]                              [int] NULL,
		[taux_actes_controles]                         [float] NULL,
		[actes_valides]                                [int] NULL,
		[taux_actes_valides]                           [int] NULL,
		[actes_rejetes]                                [int] NULL,
		[taux_actes_rejetes]                           [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Controle_Qualite_General]
	ADD
	CONSTRAINT [PK__Statisti__83BF08DB17FE4185]
	PRIMARY KEY
	CLUSTERED
	([id_statistiques_controle_qualite_general])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Controle_Qualite_General] SET (LOCK_ESCALATION = TABLE)
GO
