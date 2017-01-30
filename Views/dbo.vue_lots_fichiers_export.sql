SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vue_lots_fichiers_export
AS
SELECT     TOP (100) PERCENT lf.id_lot, lf.id_traitement, lf.nom_lot, lf.ordre, lf.date_creation, lf.export_pour_mep, ISNULL(lf.dossier_source_export, t.dossier_source_export) 
                      AS dossier_source_export, ISNULL(lf.dossier_destination_export, t.dossier_destination_export) AS dossier_destination_export, lf.date_export_pour_mep, 
                      COUNT(DISTINCT f.id_fichier) AS nb_fichiers_total_lot, SUM(CASE WHEN (ISNULL(f.rejete, 0) = 0 AND ISNULL(f.ignore_export_publication, 0) = 0) THEN 1 ELSE 0 END) 
                      AS nb_fichiers, SUM(CASE WHEN ISNULL(f.rejete, 0) = 1 THEN 1 ELSE 0 END) AS nb_fichiers_rejetes
FROM         dbo.DataXml_lots_fichiers AS lf WITH (NOLOCK) INNER JOIN
                      dbo.Traitements AS t WITH (NOLOCK) ON lf.id_traitement = t.id_traitement INNER JOIN
                      dbo.DataXml_fichiers AS f WITH (NOLOCK) ON lf.id_lot = f.id_lot INNER JOIN
                      dbo.DataXmlEchantillonEntete ON lf.id_lot = dbo.DataXmlEchantillonEntete.id_lot
GROUP BY lf.id_lot, lf.id_traitement, lf.nom_lot, lf.ordre, lf.date_creation, lf.export_pour_mep, ISNULL(lf.dossier_source_export, t.dossier_source_export), 
                      ISNULL(lf.dossier_destination_export, t.dossier_destination_export), lf.date_export_pour_mep, dbo.DataXmlEchantillonEntete.id_statut
HAVING      (dbo.DataXmlEchantillonEntete.id_statut IN (1, 3))
ORDER BY lf.export_pour_mep, lf.id_traitement, lf.ordre
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
         Begin Table = "lf"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 284
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "f"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DataXmlEchantillonEntete"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 485
               Right = 304
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
      Begin ColumnWidths = 12
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
', 'SCHEMA', N'dbo', 'VIEW', N'vue_lots_fichiers_export', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vue_lots_fichiers_export', NULL, NULL
GO
