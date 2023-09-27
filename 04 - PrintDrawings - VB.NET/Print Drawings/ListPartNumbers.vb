Imports System.Windows.Forms
Imports Gala.Utility

Public Class ListPartNumbers
    Private m_dtProjectEquipList As DataTable
    Private m_blnBlankEntry As Boolean = False
    Private m_blnCountEntries As Boolean = False

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

    Private Sub ListPartNumbers_Load(ByVal sender As System.Object, _
        ByVal e As System.EventArgs) Handles MyBase.Load

        txtProjectNo.Select()

    End Sub

    Private Sub txtProjectNo_Validating(ByVal sender As Object, _
        ByVal e As System.ComponentModel.CancelEventArgs) Handles txtProjectNo.Validating

        If txtProjectNo.Text.Trim.Length > 0 AndAlso Not ValidCoNum(txtProjectNo.Text) Then
            e.Cancel = True
            txtProjectNo.Select(0, txtProjectNo.Text.Length)

            MessageBox.Show("Invalid project number!  Enter a project number in Ordered, Stopped, or Complete status only.", _
                "Invald Project Number", MessageBoxButtons.OK, MessageBoxIcon.Error)

        Else
            m_dtProjectEquipList = GetProjectEquipList(txtProjectNo.Text.Trim)

            With cboProjectEquip
                .DataSource = m_dtProjectEquipList
                .DisplayMember = "description"
                .ValueMember = "co_line"

            End With

        End If

    End Sub

    Private Sub cboProjectEquip_SelectedValueChanged(ByVal sender As Object, _
        ByVal e As System.EventArgs) Handles cboProjectEquip.SelectedValueChanged
        Application.DoEvents()

        GetPartsList()

    End Sub

    Private Function GetDwgNo(ByVal DrawingNo As String) As String
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

    Private Sub GetPartsList()
        Dim dtPartsList As DataTable

        If TypeOf (cboProjectEquip.SelectedValue) Is System.Int16 _
            AndAlso cboProjectEquip.SelectedIndex <> -1 Then

            Me.Cursor = Cursors.WaitCursor

            Dim strDwgNo As String = vbNullString
            Dim strItemNo As String = vbNullString
            Dim strPartList As String = Space(0)
            Dim intCnt As Integer = 0

            If rdoFabList.Checked Then
                dtPartsList = GetFabricationList(txtProjectNo.Text.Trim, _
                    cboProjectEquip.SelectedValue)

            ElseIf rdoCutList.Checked Then
                dtPartsList = GetCutList(txtProjectNo.Text.Trim, _
                    cboProjectEquip.SelectedValue)

            ElseIf rdoCustomerBOMsList.Checked Then
                dtPartsList = GetCustomerBOMs(txtProjectNo.Text.Trim, _
                    cboProjectEquip.SelectedValue)

            End If

            If dtPartsList IsNot Nothing Then
                For Each oRow As DataRow In dtPartsList.Rows
                    Select Case oRow("wc")
                        Case "EGV-01", "DOC-99", "FBF-99", "PEN-99"
                            ' Do nothing

                        Case Else
                            If Not IsDBNull(oRow("drawing_nbr")) Then
                                strItemNo = oRow("item")

                                If Not IsDiePlate(strItemNo) Then
                                    strDwgNo = GetDwgNo(oRow("drawing_nbr"))

                                    If strDwgNo.Trim.Length > 0 Then
                                        strPartList &= strDwgNo & vbCrLf
                                        intCnt += 1

                                    End If

                                End If

                            End If
                    End Select

                Next

                lstPartNumbers.Text = strPartList
                lblPartListCount.Text = "Part List Count: " & intCnt

            End If

            Me.Cursor = Cursors.Default

        End If

    End Sub

    Private Sub rdoFabList_CheckedChanged(sender As System.Object, e As System.EventArgs) Handles rdoFabList.CheckedChanged
        Application.DoEvents()

        GetPartsList()

    End Sub

    Private Sub rdoCutList_CheckedChanged(sender As System.Object, e As System.EventArgs) Handles rdoCutList.CheckedChanged
        Application.DoEvents()

        GetPartsList()

    End Sub

    Private Sub rdoCustomerBOMsList_CheckedChanged(sender As System.Object, e As System.EventArgs) Handles rdoCustomerBOMsList.CheckedChanged
        GetPartsList()

    End Sub

    Private Sub lstPartNumbers_KeyDown(sender As Object, e As System.Windows.Forms.KeyEventArgs) Handles lstPartNumbers.KeyDown
        m_blnBlankEntry = False
        m_blnCountEntries = False

        If e.KeyCode = Keys.Enter Then
            'MsgBox(Asc(lstPartNumbers.Text.Substring(lstPartNumbers.Text.Length - 2, 1)) & vbCrLf & Asc(lstPartNumbers.Text.Substring(lstPartNumbers.Text.Length - 1, 1)))

            If lstPartNumbers.Text.Trim().Length >= 2 Then
                If lstPartNumbers.Text.Substring(lstPartNumbers.Text.Length - 2, 2) = vbCrLf Then
                    m_blnBlankEntry = True

                Else
                    m_blnCountEntries = True

                End If
            Else
                m_blnBlankEntry = True

            End If

        End If

    End Sub

    Private Sub lstPartNumbers_KeyPress(sender As Object, e As System.Windows.Forms.KeyPressEventArgs) Handles lstPartNumbers.KeyPress
        If m_blnBlankEntry Then
            e.Handled = True

        Else
            If m_blnCountEntries Then
                lblPartListCount.Text = "Part List Count: " & CountPartListEntries()

            End If

        End If

    End Sub

    Private Function CountPartListEntries() As Integer

        Return lstPartNumbers.Text.Trim().Split(vbCr).GetLength(0)

    End Function

End Class
