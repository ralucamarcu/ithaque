SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CorrectionProcess_ModifiedActs] (
		[id_acte_xml]         [nvarchar](50) COLLATE French_CI_AS NULL,
		[id_acte_ithaque]     [bigint] NULL,
		[flag]                [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CorrectionProcess_ModifiedActs] SET (LOCK_ESCALATION = TABLE)
GO
