SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[Statistiques_Taux_Rejet] (
		[jour]                  [int] NULL,
		[mois]                  [int] NULL,
		[annee]                 [int] NULL,
		[nb_actes_controle]     [bigint] NULL,
		[nb_actes_rejetes]      [int] NULL,
		[taux_rejet]            [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Taux_Rejet] SET (LOCK_ESCALATION = TABLE)
GO
