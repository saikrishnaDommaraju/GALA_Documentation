Imports System.Windows.Forms
Imports Gala.Print_Drawings

Public Class Filter

    Private m_Material As New DataTable("MaterialFilter")
    Private m_FilterByMatl As String = Space(0)

    Private Sub OK_Button_Click(ByVal sender As System.Object, _
        ByVal e As System.EventArgs) Handles OK_Button.Click

        Me.DialogResult = System.Windows.Forms.DialogResult.OK
        Me.Close()

    End Sub

    Private Sub Cancel_Button_Click(ByVal sender As System.Object, _
        ByVal e As System.EventArgs) Handles Cancel_Button.Click

        Me.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.Close()

    End Sub

    Private Sub Filter_Load(ByVal sender As System.Object, _
        ByVal e As System.EventArgs) Handles MyBase.Load

        Dim oColID As New DataColumn("ID")
        Dim oCol As New DataColumn("Material")
        Dim oNewRow As DataRow

        oColID.Unique = True
        oColID.AutoIncrement = True
        oColID.AutoIncrementSeed = 1
        oColID.AutoIncrementStep = 1

        oCol.Unique = True
        oCol.DataType = Type.GetType("System.String")

        Material.Columns.Add(oColID)
        Material.Columns.Add(oCol)

        oNewRow = Material.NewRow
        oNewRow("Material") = "<none>"

        Material.Rows.Add(oNewRow)

        For Each oRow As DataRow In Print_Drawings.PartsList.Rows
            oNewRow = Material.NewRow
            Dim strData As String = oRow("Material") & " " & oRow("MatlType")

            oNewRow("Material") = strData.Trim

            Try
                Material.Rows.Add(oNewRow)

            Catch ex As Exception

            End Try

        Next oRow

        With cboMaterial
            .DataSource = Material
            .DisplayMember = "Material"
            .ValueMember = "ID"

        End With

    End Sub


    Public ReadOnly Property Material() As DataTable
        Get
            Return m_Material

        End Get
    End Property

    Public ReadOnly Property FilterByMaterial() As String
        Get
            Return m_FilterByMatl

        End Get
    End Property

    Private Sub cboMaterial_SelectedValueChanged(ByVal sender As Object, _
        ByVal e As System.EventArgs) Handles cboMaterial.SelectedValueChanged

        If TypeOf (cboMaterial.SelectedValue) Is System.Int32 _
            AndAlso cboMaterial.SelectedIndex <> -1 Then
            For Each oRow As DataRow In Material.Rows
                If oRow("ID") = cboMaterial.SelectedValue Then
                    m_FilterByMatl = oRow("Material")

                    Exit Sub

                End If

            Next

        End If

    End Sub

End Class
