SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FichiersData_Types_Evenements] (
		[id_type_evenement]     [int] IDENTITY(1, 1) NOT NULL,
		[libelle]               [varchar](256) COLLATE French_CI_AS NULL,
		[description]           [varchar](1000) COLLATE French_CI_AS NULL,
		[date_creation]         [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Types_Evenements]
	ADD
	CONSTRAINT [PK_Types_Evenements]
	PRIMARY KEY
	CLUSTERED
	([id_type_evenement])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Types_Evenements]
	ADD
	CONSTRAINT [DF_FichiersData_Types_Evenements_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[FichiersData_Types_Evenements] SET (LOCK_ESCALATION = TABLE)
GO
