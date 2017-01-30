SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[v_import_fichier_projet_Parameters] (
		[id]            [int] IDENTITY(1, 1) NOT NULL,
		[id_projet]     [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[v_import_fichier_projet_Parameters] SET (LOCK_ESCALATION = TABLE)
GO
