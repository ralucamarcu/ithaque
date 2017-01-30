SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FichiersData_Statuts] (
		[id_statut]         [int] NOT NULL,
		[libelle]           [varchar](256) COLLATE French_CI_AS NULL,
		[date_creation]     [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Statuts]
	ADD
	CONSTRAINT [PK_FichiersData_Statuts]
	PRIMARY KEY
	CLUSTERED
	([id_statut])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[FichiersData_Statuts]
	ADD
	CONSTRAINT [DF_FichiersData_Statuts_date_creation]
	DEFAULT (getdate()) FOR [date_creation]
GO
ALTER TABLE [dbo].[FichiersData_Statuts] SET (LOCK_ESCALATION = TABLE)
GO
