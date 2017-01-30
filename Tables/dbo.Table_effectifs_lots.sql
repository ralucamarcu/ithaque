SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Table_effectifs_lots] (
		[id_effectif_lot]          [int] IDENTITY(1, 1) NOT NULL,
		[effectif_min]             [int] NULL,
		[effectif_max]             [int] NULL,
		[lettre_code]              [varchar](10) COLLATE French_CI_AS NULL,
		[effectif_echantillon]     [bigint] NULL,
		[date_creation]            [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Table_effectifs_lots]
	ADD
	CONSTRAINT [PK_Table_effectifs]
	PRIMARY KEY
	CLUSTERED
	([id_effectif_lot])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Table_effectifs_lots]
	ADD
	CONSTRAINT [DF_Table_effectifs_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Table_effectifs_lots] SET (LOCK_ESCALATION = TABLE)
GO
