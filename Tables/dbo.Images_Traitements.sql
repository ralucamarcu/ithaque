SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Images_Traitements] (
		[id_image_traitement]     [int] IDENTITY(1, 1) NOT NULL,
		[id_image]                [uniqueidentifier] NOT NULL,
		[zone_status]             [int] NULL,
		[zone_date]               [datetime] NULL,
		[id_projet]               [uniqueidentifier] NOT NULL,
		[date_creation]           [datetime] NULL,
		[chemin]                  [varchar](500) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images_Traitements]
	ADD
	CONSTRAINT [PK_Images_Traitements]
	PRIMARY KEY
	CLUSTERED
	([id_image_traitement])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images_Traitements]
	ADD
	CONSTRAINT [DF_Images_Traitements_zone_status]
	DEFAULT ((0)) FOR [zone_status]
GO
CREATE NONCLUSTERED INDEX [idx_zone_status_date]
	ON [dbo].[Images_Traitements] ([zone_status], [zone_date])
	INCLUDE ([id_image])
	ON [INDEX]
GO
ALTER TABLE [dbo].[Images_Traitements] SET (LOCK_ESCALATION = TABLE)
GO
