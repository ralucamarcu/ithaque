SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Images_old] (
		[id_image]            [uniqueidentifier] NOT NULL,
		[path_origine]        [varchar](800) COLLATE French_CI_AS NOT NULL,
		[path_projet]         [varchar](800) COLLATE French_CI_AS NULL,
		[id_projet]           [uniqueidentifier] NOT NULL,
		[id_fichier_data]     [uniqueidentifier] NULL,
		[date_creation]       [datetime] NOT NULL,
		[id_statut]           [int] NULL,
		[date_statut]         [datetime] NULL,
		[locked]              [bit] NOT NULL,
		[cote]                [varchar](50) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images_old]
	ADD
	CONSTRAINT [PK_Images]
	PRIMARY KEY
	CLUSTERED
	([id_image])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images_old]
	ADD
	CONSTRAINT [DF_Images_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[Images_old]
	ADD
	CONSTRAINT [DF_Images_id_image]
	DEFAULT (newid()) FOR [id_image]
GO
ALTER TABLE [dbo].[Images_old]
	ADD
	CONSTRAINT [DF_Images_locked]
	DEFAULT ((0)) FOR [locked]
GO
CREATE NONCLUSTERED INDEX [idx_image_id_projet]
	ON [dbo].[Images_old] ([id_projet])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_image_path_origine]
	ON [dbo].[Images_old] ([path_origine], [id_projet], [id_statut])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_status_jpeg2000]
	ON [dbo].[Images_old] ([id_projet], [id_statut], [locked])
	INCLUDE ([id_image], [path_projet])
	ON [INDEX]
GO
ALTER TABLE [dbo].[Images_old] SET (LOCK_ESCALATION = TABLE)
GO
