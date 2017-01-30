SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Taches_Logs_test] (
		[id_tache_log]           [int] IDENTITY(1, 1) NOT NULL,
		[id_utilisateur]         [int] NOT NULL,
		[id_source]              [uniqueidentifier] NULL,
		[id_projet]              [uniqueidentifier] NULL,
		[id_status]              [int] NULL,
		[path_erreur_log]        [varchar](500) COLLATE French_CI_AS NULL,
		[machine_traitement]     [varchar](255) COLLATE French_CI_AS NULL,
		[date_debut]             [datetime] NULL,
		[date_fin]               [datetime] NULL,
		[date_creation]          [datetime] NOT NULL,
		[date_modification]      [datetime] NULL,
		[id_tache]               [int] NULL,
		[erreur_message]         [varchar](800) COLLATE French_CI_AS NULL,
		[ordre]                  [int] NULL,
		[doit_etre_execute]      [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Logs_test]
	ADD
	CONSTRAINT [PK_TachesSources_test]
	PRIMARY KEY
	CLUSTERED
	([id_tache_log])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Logs_test]
	ADD
	CONSTRAINT [DF_Taches_Logs_date_creation_test]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Taches_Logs_test] SET (LOCK_ESCALATION = TABLE)
GO
