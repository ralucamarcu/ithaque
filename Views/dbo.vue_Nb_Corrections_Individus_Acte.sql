SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vue_Nb_Corrections_Individus_Acte
AS
SELECT     id_acte, COUNT(DISTINCT id) AS nb_individus, SUM(CASE WHEN (LEN(ISNULL(i.nom, '')) > 0 AND isnull(i.nom, '') <> isnull(i.nom_Correction, isnull(i.nom, ''))) THEN (1) 
                      ELSE (0) END) AS nb_corrections_nom, SUM(CASE WHEN (LEN(ISNULL(i.prenom, '')) > 0 AND isnull(i.prenom, '') <> isnull(i.prenom_Correction, isnull(i.prenom, ''))) 
                      THEN (1) ELSE (0) END) AS nb_corrections_prenom, SUM(CASE WHEN (LEN(ISNULL(i.nom, '')) = 0) AND (LEN(ISNULL(i.nom_Correction, '')) > 0) THEN (1) ELSE (0) END) 
                      AS nb_absences_nom, SUM(CASE WHEN (LEN(ISNULL(i.prenom, '')) = 0) AND (LEN(ISNULL(i.prenom_Correction, '')) > 0) THEN (1) ELSE (0) END) 
                      AS nb_absences_prenom, SUM(nb_erreurs_individu) AS nb_corrections_individus
FROM         dbo.DataXmlRC_individus AS i WITH (nolock)
GROUP BY id_acte

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
         Configuration = "(H (4[30] 2[40] 3) )"
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
      ActivePaneConfig = 3
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "i"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 327
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
', 'SCHEMA', N'dbo', 'VIEW', N'vue_Nb_Corrections_Individus_Acte', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vue_Nb_Corrections_Individus_Acte', NULL, NULL
GO
