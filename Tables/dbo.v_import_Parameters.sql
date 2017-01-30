SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[v_import_Parameters] (
		[id]                        [int] IDENTITY(1, 1) NOT NULL,
		[id_source]                 [uniqueidentifier] NULL,
		[id_utilisateur]            [int] NULL,
		[machine_traitement]        [varchar](255) COLLATE French_CI_AS NULL,
		[id_tache]                  [int] NULL,
		[path_version]              [varchar](255) COLLATE French_CI_AS NULL,
		[images_log_files_path]     [varchar](255) COLLATE French_CI_AS NULL,
		[date_creation]             [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[v_import_Parameters] SET (LOCK_ESCALATION = TABLE)
GO
