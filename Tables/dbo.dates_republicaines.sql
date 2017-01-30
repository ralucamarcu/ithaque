SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[dates_republicaines] (
		[id_date_republicaine]     [int] IDENTITY(1, 1) NOT NULL,
		[annee_republicaine]       [varchar](50) COLLATE French_CI_AS NULL,
		[mois_republicaine]        [varchar](100) COLLATE French_CI_AS NULL,
		[jour_republicaine]        [int] NULL,
		[date_republicaine]        [varchar](255) COLLATE French_CI_AS NULL,
		[annee_gregoriene]         [int] NULL,
		[mois_gregoriene]          [varchar](50) COLLATE French_CI_AS NULL,
		[jour_gregoriene]          [int] NULL,
		[date_gregoriene]          [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dates_republicaines] SET (LOCK_ESCALATION = TABLE)
GO
