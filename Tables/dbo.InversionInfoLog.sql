SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InversionInfoLog] (
		[id_inversion_info_log]     [int] IDENTITY(1, 1) NOT NULL,
		[script_applied]            [varchar](500) COLLATE French_CI_AS NULL,
		[path_projet]               [varchar](500) COLLATE French_CI_AS NULL,
		[id_source]                 [uniqueidentifier] NULL,
		[date_creation]             [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InversionInfoLog]
	ADD
	CONSTRAINT [PK_InversionInfoLog]
	PRIMARY KEY
	CLUSTERED
	([id_inversion_info_log])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[InversionInfoLog] SET (LOCK_ESCALATION = TABLE)
GO
