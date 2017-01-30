SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vueExtractionActesTraitesEtCorrects
AS
SELECT     TOP (1000) id_acte_xml, chemin_fichier
FROM         (SELECT DISTINCT 
                                              a.id_acte_xml, REPLACE(REPLACE(REPLACE(REPLACE(f.chemin_fichier, '\\ARDTRAIT\Traitement\genework\p36-TD69\output', 
                                              'V:\Projets\p36-TD69\V4\delivery'), 'Z:\genework\p36-TD69\output', 'V:\Projets\p36-TD69\V4\delivery'), '\\ARDTRAIT\Traitement\genework\p36-TD69\delivery', 
                                              'V:\Projets\p36-TD69\V4\delivery'), 'V:\Projets\p36-TD69\V4\delivery\EC_REPRISE_ZONAGE-avantSept\', 
                                              'V:\Projets\p36-TD69\V4\delivery\20130930\Reprise\EC_REPRISE_ZONAGE-v2\') AS chemin_fichier
                       FROM          dbo.DataXmlEchantillonEntete AS ee WITH (NOLOCK) INNER JOIN
                                              dbo.DataXmlEchantillonDetailsRC AS ed WITH (NOLOCK) ON ee.id_echantillon = ed.id_echantillon INNER JOIN
                                              dbo.DataXmlRC_actes AS a WITH (NOLOCK) ON ed.id_acte_RC = a.id INNER JOIN
                                              dbo.DataXmlRC_individus AS i WITH (NOLOCK) ON a.id = i.id_acte INNER JOIN
                                              dbo.Traitements AS t WITH (NOLOCK) ON ee.id_traitement = t.id_traitement INNER JOIN
                                              dbo.DataXml_Fichiers AS f WITH (NOLOCK) ON a.id_fichier = f.id_fichier
                       WHERE      (t.id_projet = '65042153-90E9-47E8-9BDA-C0DBE370EDD2') AND (t.id_traitement IN (206, 214, 220, 222)) AND (ed.traite = 1) AND (ed.erreur_saisie = 0) AND 
                                              (ed.absence_saisie = 0) AND (ed.erreur_selection = 0) AND (ed.erreur_zonage = 0) AND (ed.erreur_image = 0) AND (a.date_acte_Correction IS NULL) AND 
                                              (a.annee_acte_Correction IS NULL) AND (a.calendrier_date_acte_Correction IS NULL) AND (a.geonameid_acte_Correction IS NULL) AND 
                                              (a.insee_acte_Correction IS NULL) AND (a.lieu_acte_Correction IS NULL) AND (a.soustype_acte_Correction IS NULL) AND (i.age_Correction IS NULL) AND 
                                              (i.annee_naissance_Correction IS NULL) AND (i.calendrier_date_naissance_Correction IS NULL) AND (i.date_naissance_Correction IS NULL) AND 
                                              (i.geonameid_naissance_Correction IS NULL) AND (i.insee_naissance_Correction IS NULL) AND (i.lieu_naissance_Correction IS NULL) AND 
                                              (i.nom_Correction IS NULL) AND (i.prenom_Correction IS NULL)) AS a_1
ORDER BY NEWID()

GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a_1"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 95
               Right = 238
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vueExtractionActesTraitesEtCorrects', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vueExtractionActesTraitesEtCorrects', NULL, NULL
GO
