SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[Statistiques_MoyenneParHeure] (
		[date_debut]              [datetime] NULL,
		[date_fin]                [datetime] NULL,
		[nb_actes_considere]      [bigint] NULL,
		[nb_heures_considere]     [int] NULL,
		[moyenne_par_heure]       [float] NULL,
		[par_utilisateur]         [int] NULL,
		[statistique_type]        [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_MoyenneParHeure] SET (LOCK_ESCALATION = TABLE)
GO
