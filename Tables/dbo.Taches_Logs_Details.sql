SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Taches_Logs_Details] (
		[id_tache_log_details]        [int] IDENTITY(1, 1) NOT NULL,
		[id_tache_log]                [int] NOT NULL,
		[id_status]                   [int] NULL,
		[date_debut]                  [datetime] NULL,
		[date_fin]                    [datetime] NULL,
		[erreur_message]              [varchar](max) COLLATE French_CI_AS NULL,
		[progression_pourcentage]     [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Logs_Details]
	ADD
	CONSTRAINT [PK_Taches_Logs_Details]
	PRIMARY KEY
	CLUSTERED
	([id_tache_log_details])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Logs_Details] SET (LOCK_ESCALATION = TABLE)
GO
