SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DirTree] (
		[FOLDER_ID]       [int] IDENTITY(1, 1) NOT NULL,
		[FILE_PATH]       [varchar](800) COLLATE French_CI_AS NULL,
		[FOLDER_NAME]     [varchar](800) COLLATE French_CI_AS NULL,
		[DEPTH]           [int] NULL,
		[IS_FILE]         [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_file_path]
	ON [dbo].[DirTree] ([FILE_PATH])
	ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_folder_id]
	ON [dbo].[DirTree] ([FOLDER_ID])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_is_file]
	ON [dbo].[DirTree] ([IS_FILE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DirTree] SET (LOCK_ESCALATION = TABLE)
GO
