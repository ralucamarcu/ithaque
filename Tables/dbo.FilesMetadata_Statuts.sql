SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FilesMetadata_Statuts] (
		[id_status]                [int] IDENTITY(1, 1) NOT NULL,
		[status_file_metadata]     [varchar](50) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FilesMetadata_Statuts]
	ADD
	CONSTRAINT [PK_FilesMetadata_Statuts]
	PRIMARY KEY
	CLUSTERED
	([id_status])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FilesMetadata_Statuts] SET (LOCK_ESCALATION = TABLE)
GO
