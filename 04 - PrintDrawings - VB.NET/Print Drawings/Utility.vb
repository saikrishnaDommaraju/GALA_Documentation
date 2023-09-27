Imports System.Data.SqlClient

Public Class Utility

    Public Shared Function ValidCoNum(ByVal JobNo As String) As Boolean
        Dim conSL As SqlConnection
        Dim cmd As New SqlCommand
        Dim adp As New SqlDataAdapter
        Dim dsCOs As New DataSet
        Dim blnValid As Boolean = False

        conSL = SL()
        cmd.Connection = conSL
        cmd.CommandType = CommandType.Text
        cmd.CommandTimeout = 90
        cmd.CommandText = "Select co_num From co_mst Where co_num like '%" & JobNo _
            & "' and stat IN ('O', 'S', 'C')"

        adp.SelectCommand = cmd

        adp.Fill(dsCOs, "COs")

        blnValid = dsCOs.Tables("COs").Rows.Count > 0

        Return blnValid

    End Function

    Public Shared Function IsDiePlate(ByVal PartNo As String) As Boolean
        Dim conSL As SqlConnection
        Dim cmd As New SqlCommand
        Dim adp As New SqlDataAdapter
        Dim dsItems As New DataSet
        Dim blnIsDP As Boolean = False

        conSL = SL()
        cmd.Connection = conSL
        cmd.CommandType = CommandType.Text
        cmd.CommandTimeout = 90
        cmd.CommandText = "Select Uf_DiePlate From item_mst Where item = '" & PartNo _
            & "' And Uf_DiePlate = 1"

        adp.SelectCommand = cmd

        adp.Fill(dsItems, "Items")

        blnIsDP = dsItems.Tables("Items").Rows.Count > 0

        Return blnIsDP

    End Function

    Public Shared Function GetProjectEquipList(ByVal ProjectNo As String) As DataTable
        Dim conSL As SqlConnection
        Dim cmd As New SqlCommand
        Dim adp As New SqlDataAdapter
        Dim dsProjects As New DataSet
        Dim blnValid As Boolean = False
        Dim strWhere As String = Space(0)
        Dim oRow As DataRow
        Dim tblProjectEquipList As DataTable

        If ProjectNo.Trim.Length = 0 Or Val(ProjectNo) = 0 Then
            strWhere = "0 = 1"

        Else
            strWhere = "co_num LIKE '%" & ProjectNo.Trim & "' "

        End If

        conSL = SL()
        cmd.Connection = conSL
        cmd.CommandType = CommandType.Text
        cmd.CommandTimeout = 90
        cmd.CommandText = "Select description, co_line " _
            & "From GI_CoLineEquipmentView Where " & strWhere _
            & "Order By co_line"

        adp.SelectCommand = cmd

        adp.Fill(dsProjects, "ProjectEquipList")

        tblProjectEquipList = dsProjects.Tables("ProjectEquipList")

        oRow = tblProjectEquipList.NewRow
        oRow("description") = "<All>"
        oRow("co_line") = 0

        tblProjectEquipList.Rows.InsertAt(oRow, 0)

        Return tblProjectEquipList

    End Function

    Public Shared Function GetEquipJobOrder(ByVal ProjectNo As String, ByVal CoLine As Integer) As String
        Dim conSL As SqlConnection
        Dim cmd As New SqlCommand
        Dim adp As New SqlDataAdapter
        Dim dsProjects As New DataSet
        Dim blnValid As Boolean = False
        Dim strWhere As String = Space(0)

        If ProjectNo.Trim.Length = 0 Or Val(ProjectNo) = 0 Then
            strWhere = "0 = 1"

        ElseIf CoLine > 0 Then
            strWhere = "co_num LIKE '%" & ProjectNo.Trim & "' And co_line = " & CoLine

        End If

        conSL = SL()
        cmd.Connection = conSL
        cmd.CommandType = CommandType.Text
        cmd.CommandTimeout = 90
        cmd.CommandText = "Select ref_num " _
            & "From GI_CoLineEquipmentView Where " & strWhere

        adp.SelectCommand = cmd

        adp.Fill(dsProjects, "ProjectEquipList")

        Return dsProjects.Tables("ProjectEquipList").Rows(0).Item("ref_num")

    End Function

    Public Shared Function isPorJ(ByVal ProjectNo As String) As String
        Dim conSL As SqlConnection
        Dim cmd As New SqlCommand
        Dim adp As New SqlDataAdapter
        Dim dsList As New DataSet

        conSL = SL()
        cmd.Connection = conSL
        cmd.CommandType = CommandType.Text
        cmd.CommandTimeout = 90

        cmd.CommandText = "SELECT TOP 1 TRIM(ord_num) As proj, TRIM(job) AS job FROM dbo.job_mst WHERE TRIM(ord_num) = '" & ProjectNo & "' OR TRIM(job) = '" & ProjectNo & "'"

        adp.SelectCommand = cmd
        adp.Fill(dsList, "pList")

        If dsList.Tables("pList").Rows.Count = 0 Then Return "N"

        If dsList.Tables("pList").Rows(0).Item(0).ToString = ProjectNo Then Return "P"

        If dsList.Tables("pList").Rows(0).Item(1).ToString = ProjectNo Then Return "J"

        Return "N"
    End Function

    Public Shared Function GetFabricationList(ByVal ProjectNo As String,
     Optional ByVal CoLine As Integer = 0, Optional ByVal pType As String = "P") As DataTable

        Dim conSL As SqlConnection
        Dim cmd As New SqlCommand
        Dim adp As New SqlDataAdapter
        Dim dsFabList As New DataSet
        Dim blnValid As Boolean = False
        Dim strJobOrder As String = ""

        If (ProjectNo.Trim.Length > 0 Or Val(ProjectNo) <> 0) And CoLine > 0 Then
            strJobOrder = GetEquipJobOrder(ProjectNo, CoLine)

        Else
            strJobOrder = ""

        End If

        conSL = SL()
        cmd.Connection = conSL
        cmd.CommandType = CommandType.Text
        cmd.CommandTimeout = 90

        If strJobOrder <> "" Then
            cmd.CommandText = "EXEC dbo.GIRpt_FabricationListSp " &
                "@StartJob = N'" & strJobOrder & "'" &
                ", @EndJob = N'" & strJobOrder & "'" &
                ", @StartSuffix = NULL" &
                ", @EndSuffix = NULL" &
                ", @StartWC = NULL" &
                ", @EndWC = NULL" &
                ", @StartOrdNum = NULL" &
                ", @EndOrdNum = NULL" &
                ", @StartOrdLine = NULL" &
                ", @EndOrdLine = NULL" &
                ", @JobStat = N'FRSCH'" &
                ", @EngineeringDept = N'A'"

            adp.SelectCommand = cmd

            adp.Fill(dsFabList, "FabricationList")
        ElseIf pType = "J" Then
            cmd.CommandText = "EXEC dbo.GIRpt_FabricationListSp " &
                    "@StartJob = N'" & ProjectNo & "'" &
                    ", @EndJob = N'" & ProjectNo & "'" &
                    ", @StartSuffix = NULL" &
                    ", @EndSuffix = NULL" &
                    ", @StartWC = NULL" &
                    ", @EndWC = NULL" &
                    ", @StartOrdNum = NULL" &
                    ", @EndOrdNum = NULL" &
                    ", @StartOrdLine = NULL" &
                    ", @EndOrdLine = NULL" &
                    ", @JobStat = N'FRSCH'" &
                    ", @EngineeringDept = N'A'"

            adp.SelectCommand = cmd

            adp.Fill(dsFabList, "FabricationList")
        ElseIf ProjectNo.Trim.Length > 0 Or Val(ProjectNo) <> 0 And CoLine = 0 Then
            cmd.CommandText = "EXEC dbo.GIRpt_FabricationListSp " &
                "@StartJob = NULL" &
                ", @EndJob = NULL" &
                ", @StartSuffix = NULL" &
                ", @EndSuffix = NULL" &
                ", @StartWC = NULL" &
                ", @EndWC = NULL" &
                ", @StartOrdNum = N'" & ProjectNo & "'" &
                ", @EndOrdNum = N'" & ProjectNo & "'" &
                ", @StartOrdLine = NULL" &
                ", @EndOrdLine = NULL" &
                ", @JobStat = N'FRSCH'" &
                ", @EngineeringDept = N'A'"

            adp.SelectCommand = cmd

            adp.Fill(dsFabList, "FabricationList")

        End If

        Return dsFabList.Tables("FabricationList")

    End Function

    Public Shared Function GetCutList(ByVal ProjectNo As String,
        Optional ByVal CoLine As Integer = 0, Optional ByVal pType As String = "P"
        ) As DataTable

        Dim conSL As SqlConnection
        Dim cmd As New SqlCommand
        Dim adp As New SqlDataAdapter
        Dim dsCutList As New DataSet
        Dim blnValid As Boolean = False
        Dim strJobOrder As String = ""

        If (ProjectNo.Trim.Length > 0 Or Val(ProjectNo) <> 0) And CoLine > 0 Then
            strJobOrder = GetEquipJobOrder(ProjectNo, CoLine)

        Else
            strJobOrder = ""
        End If

        conSL = SL()
        cmd.Connection = conSL
        cmd.CommandType = CommandType.Text
        cmd.CommandTimeout = 90

        If strJobOrder <> "" Then
            cmd.CommandText = "EXEC dbo.GIRpt_CutListSp " &
                "@StartJob = N'" & strJobOrder & "'" &
                ", @EndJob = N'" & strJobOrder & "'" &
                ", @StartSuffix = NULL" &
                ", @EndSuffix = NULL" &
                ", @StartWC = NULL" &
                ", @EndWC = NULL" &
                ", @StartOrdNum = NULL" &
                ", @EndOrdNum = NULL" &
                ", @StartOrdLine = NULL" &
                ", @EndOrdLine = NULL" &
                ", @JobStat = N'FRSCH'" &
                ", @EngineeringDept = N'A'" &
                ", @Language = N'EN'"

            adp.SelectCommand = cmd

            adp.Fill(dsCutList, "CutList")
        ElseIf pType = "J" Then
            cmd.CommandText = "EXEC dbo.GIRpt_CutListSp " &
                "@StartJob = N'" & ProjectNo & "'" &
                ", @EndJob = N'" & ProjectNo & "'" &
                ", @StartSuffix = NULL" &
                ", @EndSuffix = NULL" &
                ", @StartWC = NULL" &
                ", @EndWC = NULL" &
                ", @StartOrdNum = NULL" &
                ", @EndOrdNum = NULL" &
                ", @StartOrdLine = NULL" &
                ", @EndOrdLine = NULL" &
                ", @JobStat = N'FRSCH'" &
                ", @EngineeringDept = N'A'" &
                ", @Language = N'EN'"

            adp.SelectCommand = cmd

            adp.Fill(dsCutList, "CutList")
        ElseIf ProjectNo.Trim.Length > 0 Or Val(ProjectNo) <> 0 And CoLine = 0 Then
            cmd.CommandText = "EXEC dbo.GIRpt_CutListSp " &
                "@StartJob = NULL" &
                ", @EndJob = NULL" &
                ", @StartSuffix = NULL" &
                ", @EndSuffix = NULL" &
                ", @StartWC = NULL" &
                ", @EndWC = NULL" &
                ", @StartOrdNum = N'" & ProjectNo & "'" &
                ", @EndOrdNum = N'" & ProjectNo & "'" &
                ", @StartOrdLine = NULL" &
                ", @EndOrdLine = NULL" &
                ", @JobStat = N'FRSCH'" &
                ", @EngineeringDept = N'A'" &
                ", @Language = N'EN'"

            adp.SelectCommand = cmd

            adp.Fill(dsCutList, "CutList")

        End If

        Return dsCutList.Tables("CutList")

    End Function

    Public Shared Function GetCustomerBOMs(ByVal ProjectNo As String,
                                           Optional ByVal CoLine As Integer = 0, Optional ByVal pType As String = "P"
                                           ) As DataTable
        Dim conSL As SqlConnection
        Dim cmd As New SqlCommand
        Dim adp As New SqlDataAdapter
        Dim dsProjects As New DataSet

        conSL = SL()
        cmd.Connection = conSL
        cmd.CommandTimeout = 90
        cmd.CommandType = CommandType.Text
        'cmd.CommandText = "EXEC dbo.GIProjectCustomerBOMsListSp                
        '                        @CoNum = N'" & ProjectNo & "',
        '                         @CoLine = " & CoLine

        If pType = "J" Then
            cmd.CommandText = "EXEC [dbo].GIRpt_GalaJobOperationListingSp 
                                @StartJob = N'" & ProjectNo & "',
                                @EndJob = N'" & ProjectNo & "',
                                @StartSuffix = 0,
                                @EndSuffix = 9999,
                                @JobStat = 'FRSCH',
                                @EngineeringDept = N'A',
                                @PageOpera = 1,
                                @ShowInternal = 0,
                                @ShowExternal = 1,
                                @LowestBOMLevel = 2,
                                @IncludeTopLevel = 1"
        Else
            cmd.CommandText = "EXEC [dbo].GIRpt_GalaJobOperationListingSp 
                                @CoNum = N'" & ProjectNo & "',
                                @StartSuffix = 0,
                                @EndSuffix = 9999,
                                @JobStat = 'FRSCH',
                                @EngineeringDept = N'A',
                                @PageOpera = 1,
                                @ShowInternal = 0,
                                @ShowExternal = 1,
                                @LowestBOMLevel = 2,
                                @IncludeTopLevel = 1"
        End If

        adp.SelectCommand = cmd

        adp.Fill(dsProjects, "CustomerBOMList")
        Return dsProjects.Tables("CustomerBOMList")

    End Function

    Public Shared Function GetJobListDrw(ByVal ProjectNo As String, ByVal WC As String, ByVal BomLvl As String) As DataTable
        Dim conSL As SqlConnection
        Dim cmd As New SqlCommand
        Dim adp As New SqlDataAdapter
        Dim dsProjects As New DataSet

        conSL = SL()
        cmd.Connection = conSL
        cmd.CommandTimeout = 90
        cmd.CommandType = CommandType.Text

        If Left(ProjectNo.Trim, 1) = "M" Or ProjectNo.Trim.Length = 5 Then
            cmd.CommandText = "EXEC [dbo].GIRpt_GalaJobOperationListingSp 
                                @StartJob = N'" & ProjectNo & "',
                                @EndJob = N'" & ProjectNo & "',
                                @StartSuffix = 0,
                                @EndSuffix = 9999,
                                @StartWC = '" & WC & "', 
                                @EndWC = '" & WC & "',
                                @JobStat = 'FRSCH',
                                @EngineeringDept = N'A',
                                @PageOpera = 1,
                                @ShowInternal = 0,
                                @ShowExternal = 1,
                                @LowestBOMLevel = " & BomLvl & ",
                                @IncludeTopLevel = 1"
        Else
            cmd.CommandText = "EXEC [dbo].GIRpt_GalaJobOperationListingSp 
                                @CoNum = N'" & ProjectNo & "',
                                @StartSuffix = 0,
                                @EndSuffix = 9999,
                                @StartWC = '" & WC & "', 
                                @EndWC = '" & WC & "',
                                @JobStat = 'FRSCH',
                                @EngineeringDept = N'A',
                                @PageOpera = 1,
                                @ShowInternal = 0,
                                @ShowExternal = 1,
                                @LowestBOMLevel = " & BomLvl & ",
                                @IncludeTopLevel = 1"
        End If


        adp.SelectCommand = cmd

        adp.Fill(dsProjects, "JobDrwList")

        Return dsProjects.Tables("JobDrwList")

    End Function

    Private Shared Function SL() As SqlConnection
        Dim connSL As New SqlConnection

        'connSL.ConnectionString = "Data Source=ER308;Initial Catalog=ER_App;Integrated Security=True"

        'connSL.ConnectionString = "Password=rv4CSI10;Persist Security Info=True;" _
        '    & "User ID=rv;Initial Catalog=CSI_EGR;Data Source=MAG-EGR-DATA01"

        connSL.ConnectionString = "Persist Security Info=False;Integrated Security=true;Initial Catalog=" & My.Settings.DatabaseName & ";server=" & My.Settings.DataServerName

        Return connSL

    End Function

    Public Shared Function GetDwgNo(ByVal DrawingNo As String) As String
        Dim strRetVal As String = Space(0)
        Dim intCnt As Integer = 0

        If Not IsNumeric(DrawingNo) Then
            For intCnt = 1 To DrawingNo.Trim.Length
                If IsNumeric(DrawingNo.Substring(intCnt, 1)) Then
                    strRetVal = CLng(DrawingNo.Substring(intCnt)).ToString

                    Exit For

                End If

            Next

        Else
            strRetVal = DrawingNo

        End If

        Return strRetVal

    End Function

End Class
