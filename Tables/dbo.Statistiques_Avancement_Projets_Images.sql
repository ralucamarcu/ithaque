SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statistiques_Avancement_Projets_Images] (
		[id_statistiques_avancement_projets_image]      [int] IDENTITY(1, 1) NOT NULL,
		[nom_sous_projet]                               [varchar](50) COLLATE French_CI_AS NULL,
		[nb_total_img_v4]                               [int] NULL,
		[nb_img_livrees_par_prestataire]                [int] NULL,
		[pourcentage_img_livrees_v4_rapport]            [float] NULL,
		[nb_img_conforme]                               [int] NULL,
		[pourcentage_img_conformite_v4_rapport]         [float] NULL,
		[nb_img_controlees]                             [int] NULL,
		[pourcentage_img_controlees_v4_rapport]         [float] NULL,
		[nb_img_pas_controlees]                         [int] NULL,
		[pourcentage_img_pas_controlees_v4_rapport]     [float] NULL,
		[nb_img_validees]                               [int] NULL,
		[pourcentage_img_validees_v4_rapport]           [float] NULL,
		[nb_actes_valides]                              [int] NULL,
		[ratio_actes_valides_img_valides]               [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Avancement_Projets_Images]
	ADD
	CONSTRAINT [PK__Statisti__B8BE6CEB08BBFDF5]
	PRIMARY KEY
	CLUSTERED
	([id_statistiques_avancement_projets_image])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Avancement_Projets_Images] SET (LOCK_ESCALATION = TABLE)
GO
