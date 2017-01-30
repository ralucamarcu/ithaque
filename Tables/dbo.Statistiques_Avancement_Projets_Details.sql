SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statistiques_Avancement_Projets_Details] (
		[id_statistiques_avancement_projets_details]     [int] IDENTITY(1, 1) NOT NULL,
		[nom_sous_projet]                                [varchar](50) COLLATE French_CI_AS NULL,
		[nb_total_img_v4]                                [int] NULL,
		[nb_img_validees]                                [int] NULL,
		[nb_actes_valides]                               [int] NULL,
		[nb_actes_pas_controles]                         [int] NULL,
		[nb_individus_actes_valides]                     [bigint] NULL,
		[nb_caracteres_actes_valides]                    [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Avancement_Projets_Details]
	ADD
	CONSTRAINT [PK__Statisti__7A54AA57142DB0A1]
	PRIMARY KEY
	CLUSTERED
	([id_statistiques_avancement_projets_details])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Avancement_Projets_Details] SET (LOCK_ESCALATION = TABLE)
GO
