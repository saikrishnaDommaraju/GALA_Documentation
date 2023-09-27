Imports System.Windows.Forms

Public Class ListPartNumberExceptions

    Private Sub OK_Button_Click(ByVal sender As System.Object, _
        ByVal e As System.EventArgs) Handles OK_Button.Click

        Me.DialogResult = System.Windows.Forms.DialogResult.OK
        Me.Close()
    End Sub

    Private Sub ListPartNumberExceptions_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        lstPartNumbers.Select()

    End Sub
End Class
