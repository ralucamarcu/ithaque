SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Prestataires] (
		[id_prestataire]     [int] IDENTITY(1, 1) NOT NULL,
		[nom]                [varchar](100) COLLATE French_CI_AS NOT NULL,
		[email]              [varchar](100) COLLATE French_CI_AS NULL,
		[description]        [varchar](max) COLLATE French_CI_AS NULL,
		[date_creation]      [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Prestataires]
	ADD
	CONSTRAINT [PK_Prestataires]
	PRIMARY KEY
	CLUSTERED
	([id_prestataire])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Prestataires] SET (LOCK_ESCALATION = TABLE)
GO
