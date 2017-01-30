SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[META-ec885] (
		[registreID]                [varchar](50) COLLATE French_CI_AS NULL,
		[blocID]                    [varchar](50) COLLATE French_CI_AS NULL,
		[soublocID]                 [varchar](50) COLLATE French_CI_AS NULL,
		[Dossier]                   [nvarchar](500) COLLATE French_CI_AS NULL,
		[nomPremierFichier_old]     [nvarchar](500) COLLATE French_CI_AS NULL,
		[nomDernierFichier_old]     [nvarchar](500) COLLATE French_CI_AS NULL,
		[NombreFichiersOK]          [varchar](50) COLLATE French_CI_AS NULL,
		[Periode]                   [varchar](50) COLLATE French_CI_AS NULL,
		[Commune]                   [nvarchar](500) COLLATE French_CI_AS NULL,
		[correctedCommune]          [nvarchar](500) COLLATE French_CI_AS NULL,
		[insee]                     [varchar](50) COLLATE French_CI_AS NULL,
		[geonameid]                 [nvarchar](50) COLLATE French_CI_AS NULL,
		[type]                      [varchar](50) COLLATE French_CI_AS NULL,
		[nomRepertoire]             [nvarchar](500) COLLATE French_CI_AS NULL,
		[nomSousRepertoire]         [nvarchar](500) COLLATE French_CI_AS NULL,
		[nomPremierFichier_new]     [nvarchar](500) COLLATE French_CI_AS NULL,
		[nomDernierFichier_new]     [nvarchar](500) COLLATE French_CI_AS NULL,
		[anneeDebut]                [varchar](50) COLLATE French_CI_AS NULL,
		[anneeFin]                  [varchar](50) COLLATE French_CI_AS NULL,
		[triPeriod]                 [varchar](50) COLLATE French_CI_AS NULL,
		[triType]                   [varchar](50) COLLATE French_CI_AS NULL,
		[cpt]                       [varchar](50) COLLATE French_CI_AS NULL,
		[Comments]                  [nvarchar](500) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[META-ec885] SET (LOCK_ESCALATION = TABLE)
GO
