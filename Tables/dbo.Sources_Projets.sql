SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[Sources_Projets] (
		[id_projet]     [uniqueidentifier] NOT NULL,
		[id_source]     [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sources_Projets]
	ADD
	CONSTRAINT [PK_Sources_Projects]
	PRIMARY KEY
	CLUSTERED
	([id_projet], [id_source])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sources_Projets] SET (LOCK_ESCALATION = TABLE)
GO
