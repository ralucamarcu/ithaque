SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [guest].[touch] (
		[touch]     [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [guest].[touch]
	ADD
	CONSTRAINT [DF__touch__touch__6D816312]
	DEFAULT (getdate()) FOR [touch]
GO
ALTER TABLE [guest].[touch] SET (LOCK_ESCALATION = TABLE)
GO
