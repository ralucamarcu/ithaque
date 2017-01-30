SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AEL_Parametres_MAJ_MEP] (
		[id_ael_parametres]                [int] IDENTITY(1, 1) NOT NULL,
		[titre_document]                   [varchar](255) COLLATE French_CI_AS NULL,
		[description]                      [varchar](255) COLLATE French_CI_AS NULL,
		[miniature_document]               [varchar](255) COLLATE French_CI_AS NULL,
		[sous_titre]                       [varchar](255) COLLATE French_CI_AS NULL,
		[image_principale]                 [varchar](255) COLLATE French_CI_AS NULL,
		[image_secondaire]                 [varchar](255) COLLATE French_CI_AS NULL,
		[publie]                           [bit] NULL,
		[date_publication]                 [datetime] NULL,
		[id_projet]                        [uniqueidentifier] NULL,
		[id_document]                      [uniqueidentifier] NULL,
		[chemin_dossier_v4]                [varchar](255) COLLATE French_CI_AS NULL,
		[chemin_dossier_v5]                [varchar](255) COLLATE French_CI_AS NULL,
		[chemin_xml]                       [varchar](255) COLLATE French_CI_AS NULL,
		[id_association]                   [int] NULL,
		[date_creation_projet]             [datetime] NULL,
		[chemin_dossier_v6]                [varchar](255) COLLATE French_CI_AS NULL,
		[date_creation_ael_parametres]     [datetime] NOT NULL,
		[principal]                        [bit] NOT NULL,
		[chemin_dossier_general]           [varchar](255) COLLATE French_CI_AS NULL,
		[id_livraisons]                    [varchar](255) COLLATE French_CI_AS NULL,
		[id_tache_log]                     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AEL_Parametres_MAJ_MEP]
	ADD
	CONSTRAINT [PK_AEL_Parametres_MAJ_MEP]
	PRIMARY KEY
	CLUSTERED
	([id_ael_parametres])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[AEL_Parametres_MAJ_MEP]
	ADD
	CONSTRAINT [DF_AEL_Parametres_date_creation_ael_parametres_MAJ_MEP]
	DEFAULT (getdate()) FOR [date_creation_ael_parametres]
GO
ALTER TABLE [dbo].[AEL_Parametres_MAJ_MEP]
	ADD
	CONSTRAINT [DF_AEL_Parametres_principal_MAJ_MEP]
	DEFAULT ((0)) FOR [principal]
GO
ALTER TABLE [dbo].[AEL_Parametres_MAJ_MEP] SET (LOCK_ESCALATION = TABLE)
GO
