Imports System.Windows.Forms

Public Class Options

    Dim m_OriginalPlotter As String = Space(0)

    Private Sub OK_Button_Click(ByVal sender As System.Object, _
        ByVal e As System.EventArgs) Handles OK_Button.Click

        Me.DialogResult = System.Windows.Forms.DialogResult.OK
        Me.Close()

    End Sub

    Private Sub Cancel_Button_Click(ByVal sender As System.Object, _
        ByVal e As System.EventArgs) Handles Cancel_Button.Click

        cboPlotter.Text = m_OriginalPlotter

        Me.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.Close()

    End Sub

    Private Sub Options_Load(ByVal sender As System.Object, _
        ByVal e As System.EventArgs) Handles MyBase.Load

        m_OriginalPlotter = My.Settings.PlotterName

        cboPlotter.Items.Clear()

        cboPlotter.Items.Add("Plotter01")
        cboPlotter.Items.Add("Plotter02")

    End Sub

End Class
