SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[images_tmp_v3_64] (
		[id_image]             [uniqueidentifier] NULL,
		[path_nom_origine]     [varchar](400) COLLATE French_CI_AS NULL,
		[id_file_metadata]     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[images_tmp_v3_64] SET (LOCK_ESCALATION = TABLE)
GO
