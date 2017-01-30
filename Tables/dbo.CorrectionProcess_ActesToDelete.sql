SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CorrectionProcess_ActesToDelete] (
		[id_acte_xml]          [nvarchar](50) COLLATE French_CI_AS NULL,
		[id_acte_ithaque]      [bigint] NULL,
		[id_acte_archives]     [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CorrectionProcess_ActesToDelete] SET (LOCK_ESCALATION = TABLE)
GO
