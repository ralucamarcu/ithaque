SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Logs_actions] (
		[id_log]             [bigint] IDENTITY(1, 1) NOT NULL,
		[date_log]           [datetime] NULL,
		[id_utilisateur]     [int] NULL,
		[action]             [varchar](50) COLLATE French_CI_AS NULL,
		[id_objet]           [int] NULL,
		[id_type_objet]      [int] NULL
) ON [INDEX]
GO
ALTER TABLE [dbo].[Logs_actions]
	ADD
	CONSTRAINT [PK_cms_log]
	PRIMARY KEY
	CLUSTERED
	([id_log])
	ON [INDEX]
GO
ALTER TABLE [dbo].[Logs_actions]
	WITH CHECK
	ADD CONSTRAINT [FK_Logs_actions_Utilisateurs]
	FOREIGN KEY ([id_utilisateur]) REFERENCES [dbo].[Utilisateurs] ([id_utilisateur])
ALTER TABLE [dbo].[Logs_actions]
	CHECK CONSTRAINT [FK_Logs_actions_Utilisateurs]

GO
CREATE NONCLUSTERED INDEX [idx_composed]
	ON [dbo].[Logs_actions] ([action], [id_type_objet], [date_log])
	ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [idx_id_objet]
	ON [dbo].[Logs_actions] ([id_objet])
	ON [INDEX]
GO
ALTER TABLE [dbo].[Logs_actions] SET (LOCK_ESCALATION = TABLE)
GO
