SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vue_Traitements
AS
SELECT     TOP (100) PERCENT dbo.Traitements.id_traitement, dbo.Traitements.nom, dbo.Traitements.nom_projet, dbo.Traitements.date_creation, 
                      dbo.Traitements.import_xml_TD, dbo.Traitements.import_xml_TD_debut, dbo.Traitements.import_xml_TD_fin, dbo.Traitements.import_xml_EC, 
                      dbo.Traitements.import_xml_EC_debut, dbo.Traitements.import_xml_EC_fin, dbo.Types_traitements.nom AS [Type traitement], dbo.Traitements.folder_XML_TD, 
                      dbo.Traitements.folder_XML_EC, dbo.Traitements.folder_images_TD, dbo.Traitements.folder_images_EC, dbo.Traitements.import_xml, 
                      dbo.Traitements.import_xml_debut, dbo.Traitements.import_xml_fin, dbo.Traitements.folder_XML, dbo.Traitements.folder_images, 
                      dbo.Traitements.id_type_traitement, dbo.Traitements.id_projet
FROM         dbo.Traitements INNER JOIN
                      dbo.Types_traitements ON dbo.Traitements.id_type_traitement = dbo.Types_traitements.id_type_traitement
WHERE     (dbo.Traitements.id_type_traitement IN (1, 3, 4))
ORDER BY dbo.Traitements.date_creation DESC

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
         Begin Table = "Traitements"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 232
               Right = 238
            End
            DisplayFlags = 280
            TopColumn = 21
         End
         Begin Table = "Types_traitements"
            Begin Extent = 
               Top = 6
               Left = 276
               Bottom = 110
               Right = 476
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
         Column = 2550
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
', 'SCHEMA', N'dbo', 'VIEW', N'vue_Traitements', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vue_Traitements', NULL, NULL
GO
