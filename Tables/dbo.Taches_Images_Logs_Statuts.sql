SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Taches_Images_Logs_Statuts] (
		[id_status]                  [int] IDENTITY(1, 1) NOT NULL,
		[status_tache_log_image]     [varchar](50) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Images_Logs_Statuts]
	ADD
	CONSTRAINT [PK_Taches_Images_Logs_Statuts]
	PRIMARY KEY
	CLUSTERED
	([id_status])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Taches_Images_Logs_Statuts] SET (LOCK_ESCALATION = TABLE)
GO
