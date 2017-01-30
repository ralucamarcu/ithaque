SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Traitements_Info] (
		[id_livraison]                    [int] NULL,
		[nom]                             [varchar](255) COLLATE French_CI_AS NULL,
		[date_livraison]                  [datetime] NULL,
		[TYPE]                            [varchar](10) COLLATE French_CI_AS NULL,
		[LivA_B]                          [varchar](50) COLLATE French_CI_AS NULL,
		[description]                     [varchar](255) COLLATE French_CI_AS NULL,
		[nb_fichiers]                     [int] NULL,
		[nb_actes]                        [int] NULL,
		[ImportCQ]                        [bit] NULL,
		[taille_lots_echantillonnage]     [int] NULL,
		[nb_lots_rejetes]                 [int] NULL,
		[avancement_controle]             [int] NULL,
		[nb_total_lots_livraison]         [int] NULL,
		[date_retour_conformite_xml]      [datetime] NULL,
		[date_retour_cq]                  [datetime] NULL,
		[date_reecriture]                 [datetime] NULL,
		[date_publication]                [datetime] NULL,
		[commentaire]                     [varchar](max) COLLATE French_CI_AS NULL,
		[id_projet]                       [uniqueidentifier] NULL,
		[statut]                          [int] NULL,
		[date_conforme]                   [datetime] NULL,
		[nb_individus]                    [int] NULL,
		[nb_images]                       [int] NULL,
		[nb_naissances]                   [int] NULL,
		[nb_mariages]                     [int] NULL,
		[nb_deces]                        [int] NULL,
		[nb_recensements]                 [int] NULL,
		[import_xml]                      [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Traitements_Info] SET (LOCK_ESCALATION = TABLE)
GO
