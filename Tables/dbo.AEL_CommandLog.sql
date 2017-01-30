SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AEL_CommandLog] (
		[id_ael_command_log]       [int] IDENTITY(1, 1) NOT NULL,
		[job_id]                   [uniqueidentifier] NULL,
		[step_name]                [varchar](50) COLLATE French_CI_AS NULL,
		[message]                  [nvarchar](4000) COLLATE French_CI_AS NULL,
		[run_status]               [int] NULL,
		[run_duration]             [int] NULL,
		[start_execution_date]     [datetime] NULL,
		[end_execution_date]       [datetime] NULL,
		[sp_executed]              [varchar](255) COLLATE French_CI_AS NULL,
		[date_creation]            [datetime] NOT NULL,
		[id_document]              [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AEL_CommandLog]
	ADD
	CONSTRAINT [PK_AEL_CommandLog]
	PRIMARY KEY
	CLUSTERED
	([id_ael_command_log])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[AEL_CommandLog]
	ADD
	CONSTRAINT [DF_AEL_CommandLog_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[AEL_CommandLog] SET (LOCK_ESCALATION = TABLE)
GO
