SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[Table_NQA] (
		[id_effectif]             [int] NOT NULL,
		[NQA]                     [float] NOT NULL,
		[plafond_acceptation]     [int] NULL,
		[seuil_rejet]             [int] NULL,
		[date_creation]           [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Table_NQA]
	ADD
	CONSTRAINT [PK_Table_NQA]
	PRIMARY KEY
	CLUSTERED
	([id_effectif], [NQA])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Table_NQA]
	ADD
	CONSTRAINT [DF_Table_NQA_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Table_NQA] SET (LOCK_ESCALATION = TABLE)
GO
