SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Saisie_donnees_images] (
		[id_image]               [int] NOT NULL,
		[path]                   [varchar](500) COLLATE French_CI_AS NULL,
		[zones_a_traiter]        [bit] NULL,
		[zones_traitees]         [datetime] NULL,
		[jp2_a_traiter]          [bit] NULL,
		[jp2_traitee]            [datetime] NULL,
		[id_page]                [uniqueidentifier] NULL,
		[id_document]            [uniqueidentifier] NULL,
		[status]                 [int] NOT NULL,
		[date_status]            [datetime] NULL,
		[production]             [bit] NULL,
		[date_production]        [datetime] NULL,
		[thumb_a_traiter]        [bit] NULL,
		[thumb_traitee]          [datetime] NULL,
		[taille_img_verifie]     [int] NULL,
		[id_fichier_xml]         [uniqueidentifier] NULL,
		[date_creation]          [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Saisie_donnees_images] SET (LOCK_ESCALATION = TABLE)
GO
