SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Statistiques_Actes] (
		[id_statistiques_actes]      [int] IDENTITY(1, 1) NOT NULL,
		[projet]                     [varchar](50) COLLATE French_CI_AS NULL,
		[sous-projet]                [varchar](50) COLLATE French_CI_AS NULL,
		[prestataire]                [varchar](50) COLLATE French_CI_AS NULL,
		[lots_recus]                 [int] NULL,
		[actes_recus]                [int] NULL,
		[lots_controles]             [int] NULL,
		[actes_controles]            [int] NULL,
		[avancement_pourcentage]     [float] NULL,
		[lots_rejet]                 [int] NULL,
		[tx_rejet_pourcentage]       [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Actes]
	ADD
	CONSTRAINT [PK__Statisti__0502443A105D1FBD]
	PRIMARY KEY
	CLUSTERED
	([id_statistiques_actes])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Statistiques_Actes] SET (LOCK_ESCALATION = TABLE)
GO
