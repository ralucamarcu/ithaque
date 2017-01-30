SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Images_Types] (
		[id_image_type]       [int] IDENTITY(1, 1) NOT NULL,
		[image_type]          [varchar](255) COLLATE French_CI_AS NULL,
		[image_type_code]     [varchar](50) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images_Types]
	ADD
	CONSTRAINT [PK_Images_Types]
	PRIMARY KEY
	CLUSTERED
	([id_image_type])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_image_type_code]
	ON [dbo].[Images_Types] ([image_type_code])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images_Types] SET (LOCK_ESCALATION = TABLE)
GO
