SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[cote73] (
		[id_cote]         [int] IDENTITY(1, 1) NOT NULL,
		[cote]            [varchar](50) COLLATE French_CI_AS NULL,
		[path]            [varchar](700) COLLATE French_CI_AS NULL,
		[nom_fichier]     [varchar](50) COLLATE French_CI_AS NULL,
		[id_image]        [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cote73] SET (LOCK_ESCALATION = TABLE)
GO
