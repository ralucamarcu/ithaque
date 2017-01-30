SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 10/07/2013
-- Description:	Mise à jour d'un enregistrement d'échantillon et de l'enregistrement acte correspondant
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateEchantillonDetailRC] 
	-- Add the parameters for the stored procedure here
        @message nvarchar(max),
        @traite bit,
        @soustype_acte_Correction nvarchar(100) = NULL,
        @calendrier_date_acte_Correction varchar(20) = NULL,
        @date_acte_Correction nvarchar(50) = NULL,
        @annee_acte_Correction nvarchar(50) = NULL,
        @lieu_acte_Correction nvarchar(100) = NULL,
        @geonameid_acte_Correction bigint = NULL,
        @insee_acte_Correction nvarchar(10) = NULL,
        @erreur_saisie bit,
        @erreur_selection bit,
        @absence_saisie bit,
        @erreur_zonage bit,
        @erreur_image bit,
        @id int,
		@ReturnCode int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET @ReturnCode = 0
	
	DECLARE @id_acte int
	SELECT @id_acte=id_acte_RC FROM DataXmlEchantillonDetailsRC WHERE id=@id
	IF @id_acte IS NOT NULL
	BEGIN
	
		BEGIN TRANSACTION
		
		BEGIN TRY
		
			--MISE A JOUR DE LA TABLE DataXmlEchantillonDetailsRC
			UPDATE DataXmlEchantillonDetailsRC 
			SET message = @message, traite=@traite, erreur_saisie=@erreur_saisie, erreur_selection=@erreur_selection, 
			absence_saisie=@absence_saisie, erreur_zonage=@erreur_zonage, erreur_image=@erreur_image, 
			date_modification=getdate() 
			WHERE id = @id

			--MISE A JOUR DE LA TABLE DataXmlRC_actes
			UPDATE DataXmlRC_actes 
			SET soustype_acte_Correction=dbo.valeurCorrection(soustype_acte,@soustype_acte_Correction), 
			date_acte_Correction=dbo.valeurCorrection(date_acte, @date_acte_Correction), 
			annee_acte_Correction=dbo.valeurCorrection(annee_acte, @annee_acte_Correction),
			calendrier_date_acte_Correction=dbo.valeurCorrection(calendrier_date_acte, @calendrier_date_acte_Correction),
			lieu_acte_Correction=dbo.valeurCorrection(lieu_acte, @lieu_acte_Correction), 
			geonameid_acte_Correction=dbo.valeurCorrection(geonameid_acte, @geonameid_acte_Correction), 
			insee_acte_Correction=dbo.valeurCorrection(insee_acte, @insee_acte_Correction)
			FROM DataXmlRC_actes (nolock)
			WHERE id = @id_acte
	    
		END TRY
		BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
			SET @ReturnCode = -1
		END
		END CATCH
	  
		IF @@TRANCOUNT > 0
		BEGIN
			COMMIT TRANSACTION
			SET @ReturnCode = 0  
		END
	END 
END

GO
