SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[Sources_Images_Types] (
		[id_image_type]     [int] NOT NULL,
		[id_source]         [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sources_Images_Types]
	ADD
	CONSTRAINT [PK_Sources_Images_Types_1]
	PRIMARY KEY
	CLUSTERED
	([id_image_type], [id_source])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sources_Images_Types]
	WITH CHECK
	ADD CONSTRAINT [FK_Sources_Images_Types_Images_Types]
	FOREIGN KEY ([id_image_type]) REFERENCES [dbo].[Images_Types] ([id_image_type])
ALTER TABLE [dbo].[Sources_Images_Types]
	CHECK CONSTRAINT [FK_Sources_Images_Types_Images_Types]

GO
ALTER TABLE [dbo].[Sources_Images_Types]
	WITH CHECK
	ADD CONSTRAINT [FK_Sources_Images_Types_Sources]
	FOREIGN KEY ([id_source]) REFERENCES [dbo].[Sources] ([id_source])
ALTER TABLE [dbo].[Sources_Images_Types]
	CHECK CONSTRAINT [FK_Sources_Images_Types_Sources]

GO
ALTER TABLE [dbo].[Sources_Images_Types] SET (LOCK_ESCALATION = TABLE)
GO
