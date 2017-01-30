SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EXCEL_IMPORT] (
		[Dossier]             [nvarchar](max) COLLATE French_CI_AS NULL,
		[Nouveau_Dossier]     [varchar](max) COLLATE French_CI_AS NULL,
		[Identique]           [varchar](max) COLLATE French_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[EXCEL_IMPORT] SET (LOCK_ESCALATION = TABLE)
GO
