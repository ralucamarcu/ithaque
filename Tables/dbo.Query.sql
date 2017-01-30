SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Query] (
		[id_queue]                [bigint] NOT NULL,
		[date_creation]           [datetime2](3) NOT NULL,
		[titre]                   [nvarchar](255) COLLATE French_CI_AS NULL,
		[id_statut]               [smallint] NULL,
		[date_statut]             [datetime2](3) NULL,
		[succes]                  [bit] NULL,
		[id_imageTraitement]      [int] NULL,
		[machine_traitement]      [varchar](50) COLLATE French_CI_AS NULL,
		[fichier_origine]         [varchar](1024) COLLATE French_CI_AS NULL,
		[fichier_destination]     [varchar](1024) COLLATE French_CI_AS NULL,
		[nb_essais]               [int] NULL,
		[message_retour]          [varchar](2000) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Query] SET (LOCK_ESCALATION = TABLE)
GO
