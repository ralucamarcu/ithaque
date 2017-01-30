SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[cotes05] (
		[Date debut]          [varchar](50) COLLATE French_CI_AS NULL,
		[Date fin]            [varchar](50) COLLATE French_CI_AS NULL,
		[Cote]                [varchar](50) COLLATE French_CI_AS NULL,
		[col libelle]         [varchar](255) COLLATE French_CI_AS NULL,
		[act lis libelle]     [varchar](255) COLLATE French_CI_AS NULL,
		[ref ref bobine]      [varchar](255) COLLATE French_CI_AS NULL,
		[ref dates]           [varchar](255) COLLATE French_CI_AS NULL,
		[lieu]                [varchar](255) COLLATE French_CI_AS NULL,
		[Image champ a]       [varchar](255) COLLATE French_CI_AS NULL,
		[Image champ b]       [varchar](255) COLLATE French_CI_AS NULL,
		[Image champ c]       [varchar](255) COLLATE French_CI_AS NULL,
		[Colonne 11]          [varchar](255) COLLATE French_CI_AS NULL,
		[Colonne 12]          [varchar](255) COLLATE French_CI_AS NULL,
		[Colonne 13]          [varchar](255) COLLATE French_CI_AS NULL,
		[Colonne 14]          [varchar](255) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cotes05] SET (LOCK_ESCALATION = TABLE)
GO
