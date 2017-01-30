SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Jobs_Ithaque_Management] (
		[id_job_management]        [int] IDENTITY(1, 1) NOT NULL,
		[job_name]                 [varchar](255) COLLATE French_CI_AS NULL,
		[job_id]                   [uniqueidentifier] NULL,
		[last_outcome_id]          [int] NULL,
		[last_run_date]            [int] NULL,
		[last_outcome_message]     [nvarchar](4000) COLLATE French_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Jobs_Ithaque_Management]
	ADD
	CONSTRAINT [PK_Jobs_Ithaque_Management]
	PRIMARY KEY
	CLUSTERED
	([id_job_management])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Jobs_Ithaque_Management] SET (LOCK_ESCALATION = TABLE)
GO
