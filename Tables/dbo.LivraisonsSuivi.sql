SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LivraisonsSuivi] (
		[id_livraisons_suivi]        [int] IDENTITY(1, 1) NOT NULL,
		[id_livraison]               [int] NULL,
		[nom_livraisons]             [varchar](250) COLLATE French_CI_AS NULL,
		[date_livraisons]            [datetime] NULL,
		[nom_projet]                 [varchar](250) COLLATE French_CI_AS NULL,
		[type_livraisons]            [varchar](10) COLLATE French_CI_AS NULL,
		[a_traiter]                  [bit] NULL,
		[conformity]                 [bit] NULL,
		[valide]                     [bit] NULL,
		[import_cq]                  [bit] NULL,
		[echantill]                  [bit] NULL,
		[avancement_controle]        [float] NULL,
		[nb_fichiers]                [int] NULL,
		[nb_actes]                   [int] NULL,
		[rejetess]                   [float] NULL,
		[nb_actes_naissance]         [int] NULL,
		[nb_actes_mariage]           [int] NULL,
		[nb_actes_deces]             [int] NULL,
		[nb_actes_recensement]       [int] NULL,
		[livraison_annule]           [bit] NULL,
		[date_retour_conformite]     [datetime] NULL,
		[date_retour_CQ]             [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LivraisonsSuivi]
	ADD
	CONSTRAINT [PK__Livraiso__6D10605C7D4A4B49]
	PRIMARY KEY
	CLUSTERED
	([id_livraisons_suivi])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[LivraisonsSuivi] SET (LOCK_ESCALATION = TABLE)
GO
