SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[v_import_backupV2_Parameters] (
		[id]                       [int] IDENTITY(1, 1) NOT NULL,
		[Path_DossierBackUpV2]     [varchar](500) COLLATE French_CI_AS NULL,
		[Path_DossierV2]           [varchar](500) COLLATE French_CI_AS NULL,
		[id_tache_log]             [int] NULL,
		[id_tache_log_details]     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[v_import_backupV2_Parameters] SET (LOCK_ESCALATION = TABLE)
GO
