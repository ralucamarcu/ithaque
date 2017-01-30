SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_images] (
		[id_projet]       [uniqueidentifier] NOT NULL,
		[nom_projet]      [varchar](50) COLLATE French_CI_AS NULL,
		[v1]              [int] NULL,
		[v2]              [int] NULL,
		[v3]              [int] NULL,
		[v4]              [int] NULL,
		[v5]              [int] NULL,
		[prod]            [int] NULL,
		[v1_statut]       [int] NULL,
		[v2_statut]       [int] NULL,
		[v3_statut]       [int] NULL,
		[v4_statut]       [int] NULL,
		[v5_statut]       [int] NULL,
		[prod_statut]     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[report_images]
	ADD
	CONSTRAINT [PK_report_images2]
	PRIMARY KEY
	CLUSTERED
	([id_projet])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[report_images] SET (LOCK_ESCALATION = TABLE)
GO
