SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FolderBucket] (
		[FOLDER_ID]       [int] IDENTITY(1, 1) NOT NULL,
		[FILE_PATH]       [varchar](800) COLLATE French_CI_AS NULL,
		[FOLDER_NAME]     [varchar](800) COLLATE French_CI_AS NULL,
		[PROCESSED]       [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FolderBucket]
	ADD
	CONSTRAINT [DF__FolderBuc__PROCE__364501BE]
	DEFAULT ((0)) FOR [PROCESSED]
GO
CREATE CLUSTERED INDEX [idx_folder_id_fd]
	ON [dbo].[FolderBucket] ([FOLDER_ID])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_processed]
	ON [dbo].[FolderBucket] ([PROCESSED])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FolderBucket] SET (LOCK_ESCALATION = TABLE)
GO
