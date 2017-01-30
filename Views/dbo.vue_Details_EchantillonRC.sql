SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vue_Details_EchantillonRC
AS
SELECT     ed.id, ed.id_echantillon, ed.id_acte_RC, ed.message, ed.traite, ed.date_creation, ed.date_modification, ed.erreur_saisie, ed.erreur_selection, ed.absence_saisie, 
                      ed.erreur_zonage, ed.erreur_image, a.type_acte, a.soustype_acte, a.id_acte_xml, a.date_acte, a.annee_acte, a.calendrier_date_acte, a.lieu_acte, a.geonameid_acte, 
                      a.insee_acte, f.chemin_fichier AS fichier_xml_acte, a.soustype_xml_acte, a.date_acte_gregorienne, individu_principal, ISNULL(a.date_acte_Correction, a.date_acte) 
                      AS date_acte_Correction, ISNULL(a.annee_acte_Correction, a.annee_acte) AS annee_acte_Correction, ISNULL(a.lieu_acte_Correction, a.lieu_acte) 
                      AS lieu_acte_Correction, ISNULL(a.geonameid_acte_Correction, a.geonameid_acte) AS geonameid_acte_Correction, ISNULL(a.insee_acte_Correction, a.insee_acte) 
                      AS insee_acte_Correction, ISNULL(a.soustype_acte_Correction, a.soustype_acte) AS soustype_acte_Correction, ISNULL(a.calendrier_date_acte_Correction, 
                      a.calendrier_date_acte) AS calendrier_date_acte_Correction
FROM         dbo.DataXmlEchantillonDetailsRC ed with (nolock) INNER JOIN
                      dbo.DataXmlRC_actes a with (nolock) ON ed.id_acte_RC = a.id OUTER APPLY
                          (SELECT     TOP 1 id_acte, ISNULL(nom, '') + ' ' + ISNULL(prenom, '') AS individu_principal
                            FROM          dbo.DataXmlRC_individus with (nolock) 
                            WHERE      id_acte = a.id AND principal = 1
                            ORDER BY id_individu_xml) b INNER JOIN
                      dbo.DataXml_fichiers f with (nolock) ON a.id_fichier = f.id_fichier
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[42] 4[18] 2[24] 3) )"
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
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 33
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
', 'SCHEMA', N'dbo', 'VIEW', N'vue_Details_EchantillonRC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vue_Details_EchantillonRC', NULL, NULL
GO
