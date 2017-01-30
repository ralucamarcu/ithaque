SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Frédéric ROBILLARD
-- Create date: 16/01/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spVerrouEchantillon]
@etatVerrou AS BIT,
@id_traitement AS INTEGER = NULL,
@id_echantillon AS INTEGER = NULL,
@list_id_echantillon AS VARCHAR(2048) = NULL,
@dt AS dbo.DataTableIdEchantillon READONLY,
@verrouAll AS BIT = NULL,
@id_utilisateur AS INTEGER

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnCode int 
	DECLARE @verrou AS BIT
	DECLARE @id_utilisateur_verrou AS INTEGER
	
	IF OBJECT_ID('tempdb..#tempDataXmlEchantillonEntete') is not null 
		DROP TABLE #tempDataXmlEchantillonEntete
	SELECT TOP(0) CAST(NULL AS INTEGER) as id_echantillon INTO #tempDataXmlEchantillonEntete
	/*
	IF NOT(@id_echantillon IS NULL)	--SI IL S'AGIT D'UN SEUL ECHANTILLON
		INSERT #tempDataXmlEchantillonEntete(id_echantillon) SELECT id_echantillon FROM dbo.DataXmlEchantillonEntete ee (nolock) WHERE ee.id_echantillon=@id_echantillon AND NOT(ee.verrou=@etatVerrou) AND ISNULL(ee.id_utilisateur_verrou, @id_utilisateur)=@id_utilisateur
	ELSE
	BEGIN
		IF 	NOT(@list_id_echantillon IS NULL) --SI IL S'AGIT D'UNE LISTE D'ECHANTILLONS
			INSERT #tempDataXmlEchantillonEntete(id_echantillon) SELECT id_echantillon FROM dbo.DataXmlEchantillonEntete ee (nolock) WHERE ee.id_echantillon IN (SELECT * FROM dbo.fnSplitString(@list_id_echantillon,',')) AND NOT(ee.verrou=@etatVerrou) AND ISNULL(ee.id_utilisateur_verrou, @id_utilisateur)=@id_utilisateur
		ELSE
			IF NOT(ISNULL(@verrouAll,0)=0) AND NOT(@id_traitement IS NULL) --SI IL S'AGIT DE TOUS LES ECHANTILLONS D'UN TRAITEMENT
			BEGIN
				INSERT #tempDataXmlEchantillonEntete(id_echantillon) SELECT id_echantillon FROM dbo.DataXmlEchantillonEntete ee (nolock) WHERE ee.id_traitement=@id_traitement AND NOT(ee.verrou=@etatVerrou) AND ISNULL(ee.id_utilisateur_verrou, @id_utilisateur)=@id_utilisateur
			END
	END	
	*/

	IF ISNULL(@verrouAll,0)=1 AND NOT(@id_traitement IS NULL) --SI IL S'AGIT DE TOUS LES ECHANTILLONS D'UN TRAITEMENT
	BEGIN
		INSERT #tempDataXmlEchantillonEntete(id_echantillon) SELECT id_echantillon FROM dbo.DataXmlEchantillonEntete ee (nolock) WHERE ee.id_traitement=@id_traitement AND NOT(ee.verrou=@etatVerrou) AND ISNULL(ee.id_utilisateur_verrou, @id_utilisateur)=@id_utilisateur
	END
	ELSE IF NOT(@id_echantillon IS NULL) --SI IL S'AGIT D'UN SEUL ECHANTILLON
	BEGIN
		INSERT #tempDataXmlEchantillonEntete(id_echantillon) SELECT id_echantillon FROM dbo.DataXmlEchantillonEntete ee (nolock) WHERE ee.id_echantillon IN (@id_echantillon) AND NOT(ee.verrou=@etatVerrou) AND ISNULL(ee.id_utilisateur_verrou, @id_utilisateur)=@id_utilisateur
	END
	ELSE IF (@id_echantillon IS NULL) --SI IL S'AGIT DE PLUSIEURS ECHANTILLONS
	BEGIN
		INSERT #tempDataXmlEchantillonEntete(id_echantillon) SELECT id_echantillon FROM dbo.DataXmlEchantillonEntete ee (nolock) WHERE ee.id_echantillon IN (SELECT valeur FROM @dt) AND NOT(ee.verrou=@etatVerrou) AND ISNULL(ee.id_utilisateur_verrou, @id_utilisateur)=@id_utilisateur
	END

	UPDATE dbo.DataXmlEchantillonEntete SET verrou=ISNULL(@etatVerrou, 0), id_utilisateur_verrou=CASE ISNULL(@etatVerrou, 0) WHEN 1 THEN @id_utilisateur ELSE NULL END 
	FROM dbo.DataXmlEchantillonEntete ee
	INNER JOIN #tempDataXmlEchantillonEntete t ON ee.id_echantillon=t.id_echantillon
	
	SET @ReturnCode = @@ROWCOUNT

	SELECT @ReturnCode
END



GO
