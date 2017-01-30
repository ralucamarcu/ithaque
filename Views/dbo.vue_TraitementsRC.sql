SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vue_TraitementsRC
AS
SELECT     TOP (100) PERCENT dbo.Traitements.id_traitement, dbo.Traitements.nom, dbo.Traitements.nom_projet, dbo.Traitements.date_creation, 
                      dbo.Types_traitements.nom AS [Type traitement], dbo.Traitements.import_xml, dbo.Traitements.import_xml_debut, dbo.Traitements.import_xml_fin, 
                      dbo.Traitements.folder_XML, dbo.Traitements.folder_images, dbo.Traitements.id_type_traitement, dbo.Types_traitements.chemin_schema_XML, 
                      dbo.Traitements.id_projet, dbo.Traitements.objectif_effectif_min, ISNULL(dbo.Projets.objectif_effectif_min, dbo.Table_effectifs_lots.effectif_min) AS effectif_min_projet, 
                      dbo.Projets.NQA, dbo.Table_NQA.seuil_rejet, dbo.Traitements.dossier_source_export, dbo.Traitements.dossier_destination_export, dbo.Traitements.remarques, 
                      dbo.Traitements.commentaire_bordereau
FROM         dbo.Traitements INNER JOIN
                      dbo.Types_traitements ON dbo.Traitements.id_type_traitement = dbo.Types_traitements.id_type_traitement INNER JOIN
                      dbo.Projets ON dbo.Traitements.id_projet = dbo.Projets.id_projet INNER JOIN
                      dbo.Table_effectifs_lots ON dbo.Projets.id_effectif_lot = dbo.Table_effectifs_lots.id_effectif_lot LEFT OUTER JOIN
                      dbo.Table_NQA ON dbo.Projets.NQA = dbo.Table_NQA.NQA AND dbo.Projets.id_effectif_lot = dbo.Table_NQA.id_effectif
WHERE     (dbo.Traitements.id_type_traitement NOT IN (1)) AND (dbo.Traitements.livraison_conforme = 1) AND (NOT (dbo.Traitements.livraison_annulee = 1))
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
               Bottom = 258
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 27
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
         Begin Table = "Projets"
            Begin Extent = 
               Top = 114
               Left = 276
               Bottom = 233
               Right = 476
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Table_effectifs_lots"
            Begin Extent = 
               Top = 234
               Left = 276
               Bottom = 353
               Right = 476
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Table_NQA"
            Begin Extent = 
               Top = 258
               Left = 38
               Bottom = 377
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
      Begin ColumnWidths = 20
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
       ', 'SCHEMA', N'dbo', 'VIEW', N'vue_TraitementsRC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'  Width = 1500
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
         Column = 4680
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
', 'SCHEMA', N'dbo', 'VIEW', N'vue_TraitementsRC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', 2, 'SCHEMA', N'dbo', 'VIEW', N'vue_TraitementsRC', NULL, NULL
GO
