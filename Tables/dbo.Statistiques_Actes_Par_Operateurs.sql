SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statistiques_Actes_Par_Operateurs] (
		[id_statistiques_actes_par_operateurs]     [int] IDENTITY(1, 1) NOT NULL,
		[id_utilisateur]                           [int] NULL,
		[operateur_nom]                            [varchar](255) COLLATE French_CI_AS NULL,
		[operateur_prenom]                         [varchar](255) COLLATE French_CI_AS NULL,
		[DATE]                                     [datetime] NULL,
		[sous_projet]                              [varchar](255) COLLATE French_CI_AS NULL,
		[lots_traites]                             [int] NULL,
		[actes_traites]                            [int] NULL,
		[lots_rejetes]                             [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Actes_Par_Operateurs]
	ADD
	CONSTRAINT [PK__Statisti__272BF4B618F16754]
	PRIMARY KEY
	CLUSTERED
	([id_statistiques_actes_par_operateurs])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Actes_Par_Operateurs] SET (LOCK_ESCALATION = TABLE)
GO
