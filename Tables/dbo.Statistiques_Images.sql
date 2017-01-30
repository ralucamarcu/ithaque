SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statistiques_Images] (
		[id_statistiques_image]                                    [int] IDENTITY(1, 1) NOT NULL,
		[nom_sous_projet]                                          [varchar](50) COLLATE French_CI_AS NULL,
		[nb_total_img_v4]                                          [int] NULL,
		[nb_total_img_envoye_a_prestataire]                        [int] NULL,
		[pourcentage_total_img_envoye_img_par_projet]              [float] NULL,
		[nb_img_validite_conformite]                               [int] NULL,
		[pourcentage_total_img_envoye_img_validite_conformite]     [float] NULL,
		[nb_img_validitate_CQ]                                     [int] NULL,
		[pourcentage_total_img_envoye_img_validitate_CQ]           [float] NULL,
		[nb_img_rejet]                                             [int] NULL,
		[pourcentage_total_img_envoye_img_rejet]                   [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Images]
	ADD
	CONSTRAINT [PK__Statisti__8181588D0C8C8ED9]
	PRIMARY KEY
	CLUSTERED
	([id_statistiques_image])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Images] SET (LOCK_ESCALATION = TABLE)
GO
