SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vue_IndividusRC
AS
SELECT     TOP (100) PERCENT dbo.DataXmlRC_individus.id_acte, dbo.DataXmlRC_individus.rang, dbo.DataXmlRC_individus.id_individu_xml, 
                      dbo.DataXmlRC_individus.principal, dbo.DataXmlRC_individus.nom, dbo.DataXmlRC_individus.prenom, dbo.DataXmlRC_individus.age, 
                      dbo.DataXmlRC_individus.date_naissance, dbo.DataXmlRC_individus.annee_naissance, dbo.DataXmlRC_individus.calendrier_date_naissance, 
                      dbo.DataXmlRC_individus.lieu_naissance, dbo.DataXmlRC_individus.insee_naissance, dbo.DataXmlRC_individus.geonameid_naissance, 
                      dbo.DataXmlRC_relations_individus.nom_relation, dbo.DataXmlRC_relations_individus.id_individu_xml AS id_individu_xml_lien, 
                      ISNULL(dbo.DataXmlRC_individus.nom_Correction, dbo.DataXmlRC_individus.nom) AS nom_Correction, ISNULL(dbo.DataXmlRC_individus.prenom_Correction, 
                      dbo.DataXmlRC_individus.prenom) AS prenom_Correction, ISNULL(dbo.DataXmlRC_individus.age_Correction, dbo.DataXmlRC_individus.age) AS age_Correction, 
                      ISNULL(dbo.DataXmlRC_individus.date_naissance_Correction, dbo.DataXmlRC_individus.date_naissance) AS date_naissance_Correction, 
                      ISNULL(dbo.DataXmlRC_individus.annee_naissance_Correction, dbo.DataXmlRC_individus.annee_naissance) AS annee_naissance_Correction, 
                      ISNULL(dbo.DataXmlRC_individus.calendrier_date_naissance_Correction, dbo.DataXmlRC_individus.calendrier_date_naissance) 
                      AS calendrier_date_naissance_Correction, ISNULL(dbo.DataXmlRC_individus.lieu_naissance_Correction, dbo.DataXmlRC_individus.lieu_naissance) 
                      AS lieu_naissance_Correction, ISNULL(dbo.DataXmlRC_individus.insee_naissance_Correction, dbo.DataXmlRC_individus.insee_naissance) 
                      AS insee_naissance_Correction, ISNULL(dbo.DataXmlRC_individus.geonameid_naissance_Correction, dbo.DataXmlRC_individus.geonameid_naissance) 
                      AS geonameid_naissance_Correction, dbo.DataXmlRC_individus.id, ISNULL(dbo.DataXmlRC_individus.nom_jeune_fille_Correction, 
                      dbo.DataXmlRC_individus.nom_jeune_fille) AS nom_jeune_fille_Correction, dbo.DataXmlRC_individus.nom_jeune_fille
FROM         dbo.DataXmlRC_individus WITH (nolock) LEFT OUTER JOIN
                      dbo.DataXmlRC_relations_individus WITH (nolock) ON dbo.DataXmlRC_individus.id_acte = dbo.DataXmlRC_relations_individus.id_acte AND 
                      dbo.DataXmlRC_individus.id_individu_xml = dbo.DataXmlRC_relations_individus.id_individu_relation_xml
WHERE     (dbo.DataXmlRC_individus.id_individu_xml <> '')
ORDER BY dbo.DataXmlRC_individus.id_acte, dbo.DataXmlRC_individus.rang
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
         Begin Table = "DataXmlRC_individus"
            Begin Extent = 
               Top = 3
               Left = 15
               Bottom = 307
               Right = 290
            End
            DisplayFlags = 280
            TopColumn = 16
         End
         Begin Table = "DataXmlRC_relations_individus"
            Begin Extent = 
               Top = 4
               Left = 462
               Bottom = 186
               Right = 660
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
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 8730
         Alias = 2985
         Table = 3390
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
', 'SCHEMA', N'dbo', 'VIEW', N'vue_IndividusRC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vue_IndividusRC', NULL, NULL
GO
