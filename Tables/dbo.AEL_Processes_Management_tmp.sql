SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AEL_Processes_Management_tmp] (
		[Running_Jobs]         [varchar](255) COLLATE French_CI_AS NULL,
		[Starting_time]        [datetime] NULL,
		[Has_been_running]     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AEL_Processes_Management_tmp] SET (LOCK_ESCALATION = TABLE)
GO
