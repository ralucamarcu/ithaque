SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ec173-bis_1] (
		[Registre_orig]                                        [varchar](50) COLLATE French_CI_AS NULL,
		[Bloc_orig]                                            [varchar](50) COLLATE French_CI_AS NULL,
		[Sousbloc_orig]                                        [varchar](50) COLLATE French_CI_AS NULL,
		[Commune_orig]                                         [varchar](50) COLLATE French_CI_AS NULL,
		[Periode_orig]                                         [varchar](50) COLLATE French_CI_AS NULL,
		[Dossier_orig]                                         [varchar](500) COLLATE French_CI_AS NULL,
		[PremierFichier_orig]                                  [varchar](50) COLLATE French_CI_AS NULL,
		[NombreFichiersOK]                                     [varchar](50) COLLATE French_CI_AS NULL,
		[DernierFichier_orig]                                  [varchar](50) COLLATE French_CI_AS NULL,
		[sousbloc_Nom_Complet_orig]                            [varchar](50) COLLATE French_CI_AS NULL,
		[observations_orig]                                    [text] COLLATE French_CI_AS NULL,
		[Bloc_Nom_Complet_orig]                                [varchar](50) COLLATE French_CI_AS NULL,
		[fichier_image]                                        [varchar](500) COLLATE French_CI_AS NULL,
		[LF_CommuneMaj CommuneMaj_Periode TypeActe Source]     [varchar](500) COLLATE French_CI_AS NULL,
		[LF_DocInsee_Periode_TypeActe_Incr jpg]                [varchar](50) COLLATE French_CI_AS NULL,
		[LF_Doc]                                               [varchar](50) COLLATE French_CI_AS NULL,
		[LF_Insee]                                             [varchar](50) COLLATE French_CI_AS NULL,
		[LF_Lieu]                                              [varchar](50) COLLATE French_CI_AS NULL,
		[LF_LieuMaj]                                           [varchar](50) COLLATE French_CI_AS NULL,
		[LF_PeriodeNew]                                        [varchar](50) COLLATE French_CI_AS NULL,
		[LF_LibelTypeActe]                                     [varchar](50) COLLATE French_CI_AS NULL,
		[LF_CheminComplet]                                     [varchar](500) COLLATE French_CI_AS NULL,
		[LF_TypeActe]                                          [varchar](50) COLLATE French_CI_AS NULL,
		[LF_Source]                                            [varchar](50) COLLATE French_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ec173-bis_1] SET (LOCK_ESCALATION = TABLE)
GO
