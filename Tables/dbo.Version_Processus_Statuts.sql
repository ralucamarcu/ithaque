SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Version_Processus_Statuts] (
		[id_status]         [int] IDENTITY(1, 1) NOT NULL,
		[libelle]           [varchar](256) COLLATE French_CI_AS NULL,
		[date_creation]     [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Version_Processus_Statuts]
	ADD
	CONSTRAINT [PK_Images_Version_Statuts]
	PRIMARY KEY
	CLUSTERED
	([id_status])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Version_Processus_Statuts] SET (LOCK_ESCALATION = TABLE)
GO
