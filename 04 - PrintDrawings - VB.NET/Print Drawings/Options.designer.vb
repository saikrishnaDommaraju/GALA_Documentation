<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Options
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing AndAlso components IsNot Nothing Then
            components.Dispose()
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.TableLayoutPanel1 = New System.Windows.Forms.TableLayoutPanel
        Me.OK_Button = New System.Windows.Forms.Button
        Me.Cancel_Button = New System.Windows.Forms.Button
        Me.lblPlotter = New System.Windows.Forms.Label
        Me.lblPrintServerName = New System.Windows.Forms.Label
        Me.chkPrintToDefaultPrinter = New System.Windows.Forms.CheckBox
        Me.txtPrintServerName = New System.Windows.Forms.TextBox
        Me.cboPlotter = New System.Windows.Forms.ComboBox
        Me.TableLayoutPanel1.SuspendLayout()
        Me.SuspendLayout()
        '
        'TableLayoutPanel1
        '
        Me.TableLayoutPanel1.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TableLayoutPanel1.ColumnCount = 2
        Me.TableLayoutPanel1.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50.0!))
        Me.TableLayoutPanel1.ColumnStyles.Add(New System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50.0!))
        Me.TableLayoutPanel1.Controls.Add(Me.OK_Button, 0, 0)
        Me.TableLayoutPanel1.Controls.Add(Me.Cancel_Button, 1, 0)
        Me.TableLayoutPanel1.Location = New System.Drawing.Point(186, 90)
        Me.TableLayoutPanel1.Name = "TableLayoutPanel1"
        Me.TableLayoutPanel1.RowCount = 1
        Me.TableLayoutPanel1.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50.0!))
        Me.TableLayoutPanel1.Size = New System.Drawing.Size(146, 29)
        Me.TableLayoutPanel1.TabIndex = 0
        '
        'OK_Button
        '
        Me.OK_Button.Anchor = System.Windows.Forms.AnchorStyles.None
        Me.OK_Button.Location = New System.Drawing.Point(3, 3)
        Me.OK_Button.Name = "OK_Button"
        Me.OK_Button.Size = New System.Drawing.Size(67, 23)
        Me.OK_Button.TabIndex = 0
        Me.OK_Button.Text = "OK"
        '
        'Cancel_Button
        '
        Me.Cancel_Button.Anchor = System.Windows.Forms.AnchorStyles.None
        Me.Cancel_Button.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.Cancel_Button.Location = New System.Drawing.Point(76, 3)
        Me.Cancel_Button.Name = "Cancel_Button"
        Me.Cancel_Button.Size = New System.Drawing.Size(67, 23)
        Me.Cancel_Button.TabIndex = 1
        Me.Cancel_Button.Text = "Cancel"
        '
        'lblPlotter
        '
        Me.lblPlotter.AutoSize = True
        Me.lblPlotter.Location = New System.Drawing.Point(12, 9)
        Me.lblPlotter.Name = "lblPlotter"
        Me.lblPlotter.Size = New System.Drawing.Size(161, 13)
        Me.lblPlotter.TabIndex = 3
        Me.lblPlotter.Text = "Plotter to send large drawings to:"
        '
        'lblPrintServerName
        '
        Me.lblPrintServerName.AutoSize = True
        Me.lblPrintServerName.Location = New System.Drawing.Point(77, 36)
        Me.lblPrintServerName.Name = "lblPrintServerName"
        Me.lblPrintServerName.Size = New System.Drawing.Size(96, 13)
        Me.lblPrintServerName.TabIndex = 5
        Me.lblPrintServerName.Text = "Print Server Name:"
        '
        'chkPrintToDefaultPrinter
        '
        Me.chkPrintToDefaultPrinter.AutoSize = True
        Me.chkPrintToDefaultPrinter.Checked = Global.Gala.My.MySettings.Default.PrintToDefaultPrinter1
        Me.chkPrintToDefaultPrinter.DataBindings.Add(New System.Windows.Forms.Binding("Checked", Global.Gala.My.MySettings.Default, "PrintToDefaultPrinter1", True, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged))
        Me.chkPrintToDefaultPrinter.Location = New System.Drawing.Point(179, 59)
        Me.chkPrintToDefaultPrinter.Name = "chkPrintToDefaultPrinter"
        Me.chkPrintToDefaultPrinter.Size = New System.Drawing.Size(133, 17)
        Me.chkPrintToDefaultPrinter.TabIndex = 7
        Me.chkPrintToDefaultPrinter.Text = "Print To Default Printer"
        Me.chkPrintToDefaultPrinter.UseVisualStyleBackColor = True
        '
        'txtPrintServerName
        '
        Me.txtPrintServerName.DataBindings.Add(New System.Windows.Forms.Binding("Text", Global.Gala.My.MySettings.Default, "PrintServerName", True, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged))
        Me.txtPrintServerName.Location = New System.Drawing.Point(179, 33)
        Me.txtPrintServerName.Name = "txtPrintServerName"
        Me.txtPrintServerName.Size = New System.Drawing.Size(100, 20)
        Me.txtPrintServerName.TabIndex = 6
        Me.txtPrintServerName.Text = Global.Gala.My.MySettings.Default.PrintServerName
        '
        'cboPlotter
        '
        Me.cboPlotter.DataBindings.Add(New System.Windows.Forms.Binding("Text", Global.Gala.My.MySettings.Default, "PlotterName", True, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged))
        Me.cboPlotter.FormattingEnabled = True
        Me.cboPlotter.Location = New System.Drawing.Point(179, 6)
        Me.cboPlotter.Name = "cboPlotter"
        Me.cboPlotter.Size = New System.Drawing.Size(153, 21)
        Me.cboPlotter.TabIndex = 4
        Me.cboPlotter.Text = Global.Gala.My.MySettings.Default.PlotterName
        '
        'Options
        '
        Me.AcceptButton = Me.OK_Button
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.CancelButton = Me.Cancel_Button
        Me.ClientSize = New System.Drawing.Size(344, 131)
        Me.Controls.Add(Me.chkPrintToDefaultPrinter)
        Me.Controls.Add(Me.txtPrintServerName)
        Me.Controls.Add(Me.lblPrintServerName)
        Me.Controls.Add(Me.cboPlotter)
        Me.Controls.Add(Me.lblPlotter)
        Me.Controls.Add(Me.TableLayoutPanel1)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "Options"
        Me.ShowInTaskbar = False
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent
        Me.Text = "Options"
        Me.TableLayoutPanel1.ResumeLayout(False)
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents TableLayoutPanel1 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents OK_Button As System.Windows.Forms.Button
    Friend WithEvents Cancel_Button As System.Windows.Forms.Button
    Friend WithEvents lblPlotter As System.Windows.Forms.Label
    Friend WithEvents cboPlotter As System.Windows.Forms.ComboBox
    Friend WithEvents lblPrintServerName As System.Windows.Forms.Label
    Friend WithEvents txtPrintServerName As System.Windows.Forms.TextBox
    Friend WithEvents chkPrintToDefaultPrinter As System.Windows.Forms.CheckBox

End Class
