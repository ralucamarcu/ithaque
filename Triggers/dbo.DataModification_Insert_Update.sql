SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[DataModification_Insert_Update] 
   ON  [dbo].[Sources]
   FOR INSERT,UPDATE
AS 
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @id_source uniqueidentifier,@id_status_version_processus int
	
	IF UPDATE (id_status_version_processus) AND (SELECT i.id_status_version_processus FROM INSERTED i) IN (0,1,2,3)
	BEGIN 
		SELECT @id_source=id_source,@id_status_version_processus=id_status_version_processus FROM Inserted 

		IF OBJECT_ID('v_import_source_Parameters') IS NOT NULL 
		BEGIN
			DROP TABLE v_import_source_Parameters
			CREATE TABLE v_import_source_Parameters (id INT IDENTITY(1,1),id_source UNIQUEIDENTIFIER,id_utilisateur INT,machine_traitement VARCHAR(255),id_tache INT,path_version VARCHAR(255)
						,images_log_files_path VARCHAR(255), date_creation DATETIME,id_tache_log INT, id_projet uniqueidentifier)	
		END
		
		INSERT INTO v_import_source_Parameters(id_source) VALUES (@id_source)

		EXEC Ithaque.dbo.spTachesLogsInsertionTachesLogAFaireEnAttent
	END

	--IF UPDATE (id_status_version_processus) AND (SELECT i.id_status_version_processus FROM INSERTED i) = 4
	--BEGIN
	--		--TRUNCATE TABLE Traitements_Images.dbo.Parametres_Traitements_Images
	--		--INSERT INTO Traitements_Images.dbo.Parametres_Traitements_Images(id_source)
	--		--SELECT id_source
	--		--FROM INSERTED i

	--		EXEC msdb.dbo.sp_start_job 'Traitements Images Peuple Traitement JP2000/Miniatures'
	--END	

	


END


GO
