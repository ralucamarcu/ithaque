SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DirTree3] (
		[FOLDER_ID]       [int] IDENTITY(1, 1) NOT NULL,
		[FILE_PATH]       [varchar](800) COLLATE French_CI_AS NULL,
		[FOLDER_NAME]     [varchar](138) COLLATE French_CI_AS NULL,
		[DEPTH]           [int] NULL,
		[IS_FILE]         [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_file_path3]
	ON [dbo].[DirTree3] ([FILE_PATH])
	ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_folder_id3]
	ON [dbo].[DirTree3] ([FOLDER_ID])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_is_file3]
	ON [dbo].[DirTree3] ([IS_FILE])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[DirTree3] SET (LOCK_ESCALATION = TABLE)
GO
