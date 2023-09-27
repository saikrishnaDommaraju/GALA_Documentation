<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class ListPartNumbers
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
        Me.TableLayoutPanel1 = New System.Windows.Forms.TableLayoutPanel()
        Me.OK_Button = New System.Windows.Forms.Button()
        Me.Cancel_Button = New System.Windows.Forms.Button()
        Me.lstPartNumbers = New System.Windows.Forms.TextBox()
        Me.lblJobNo = New System.Windows.Forms.Label()
        Me.txtProjectNo = New System.Windows.Forms.TextBox()
        Me.lblJobEquip = New System.Windows.Forms.Label()
        Me.cboProjectEquip = New System.Windows.Forms.ComboBox()
        Me.rdoFabList = New System.Windows.Forms.RadioButton()
        Me.rdoCutList = New System.Windows.Forms.RadioButton()
        Me.btnLoad = New System.Windows.Forms.Button()
        Me.lblPartListCount = New System.Windows.Forms.Label()
        Me.rdoCustomerBOMsList = New System.Windows.Forms.RadioButton()
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
        Me.TableLayoutPanel1.Location = New System.Drawing.Point(288, 419)
        Me.TableLayoutPanel1.Name = "TableLayoutPanel1"
        Me.TableLayoutPanel1.RowCount = 1
        Me.TableLayoutPanel1.RowStyles.Add(New System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50.0!))
        Me.TableLayoutPanel1.Size = New System.Drawing.Size(146, 29)
        Me.TableLayoutPanel1.TabIndex = 8
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
        'lstPartNumbers
        '
        Me.lstPartNumbers.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lstPartNumbers.Location = New System.Drawing.Point(236, 12)
        Me.lstPartNumbers.Multiline = True
        Me.lstPartNumbers.Name = "lstPartNumbers"
        Me.lstPartNumbers.ScrollBars = System.Windows.Forms.ScrollBars.Vertical
        Me.lstPartNumbers.Size = New System.Drawing.Size(198, 401)
        Me.lstPartNumbers.TabIndex = 7
        '
        'lblJobNo
        '
        Me.lblJobNo.AutoSize = True
        Me.lblJobNo.Location = New System.Drawing.Point(12, 12)
        Me.lblJobNo.Name = "lblJobNo"
        Me.lblJobNo.Size = New System.Drawing.Size(83, 13)
        Me.lblJobNo.TabIndex = 0
        Me.lblJobNo.Text = "Project Number:"
        '
        'txtProjectNo
        '
        Me.txtProjectNo.Location = New System.Drawing.Point(15, 28)
        Me.txtProjectNo.Name = "txtProjectNo"
        Me.txtProjectNo.Size = New System.Drawing.Size(155, 20)
        Me.txtProjectNo.TabIndex = 1
        '
        'lblJobEquip
        '
        Me.lblJobEquip.AutoSize = True
        Me.lblJobEquip.Location = New System.Drawing.Point(12, 56)
        Me.lblJobEquip.Name = "lblJobEquip"
        Me.lblJobEquip.Size = New System.Drawing.Size(96, 13)
        Me.lblJobEquip.TabIndex = 3
        Me.lblJobEquip.Text = "Project Equipment:"
        '
        'cboProjectEquip
        '
        Me.cboProjectEquip.FormattingEnabled = True
        Me.cboProjectEquip.Location = New System.Drawing.Point(15, 72)
        Me.cboProjectEquip.Name = "cboProjectEquip"
        Me.cboProjectEquip.Size = New System.Drawing.Size(213, 21)
        Me.cboProjectEquip.TabIndex = 4
        '
        'rdoFabList
        '
        Me.rdoFabList.AutoSize = True
        Me.rdoFabList.Checked = True
        Me.rdoFabList.Location = New System.Drawing.Point(18, 99)
        Me.rdoFabList.Name = "rdoFabList"
        Me.rdoFabList.Size = New System.Drawing.Size(62, 17)
        Me.rdoFabList.TabIndex = 5
        Me.rdoFabList.TabStop = True
        Me.rdoFabList.Text = "Fab List"
        Me.rdoFabList.UseVisualStyleBackColor = True
        '
        'rdoCutList
        '
        Me.rdoCutList.AutoSize = True
        Me.rdoCutList.Location = New System.Drawing.Point(18, 122)
        Me.rdoCutList.Name = "rdoCutList"
        Me.rdoCutList.Size = New System.Drawing.Size(60, 17)
        Me.rdoCutList.TabIndex = 6
        Me.rdoCutList.Text = "Cut List"
        Me.rdoCutList.UseVisualStyleBackColor = True
        '
        'btnLoad
        '
        Me.btnLoad.Location = New System.Drawing.Point(176, 28)
        Me.btnLoad.Name = "btnLoad"
        Me.btnLoad.Size = New System.Drawing.Size(54, 20)
        Me.btnLoad.TabIndex = 2
        Me.btnLoad.Text = "Load"
        Me.btnLoad.UseVisualStyleBackColor = True
        '
        'lblPartListCount
        '
        Me.lblPartListCount.AutoSize = True
        Me.lblPartListCount.Location = New System.Drawing.Point(15, 400)
        Me.lblPartListCount.Name = "lblPartListCount"
        Me.lblPartListCount.Size = New System.Drawing.Size(79, 13)
        Me.lblPartListCount.TabIndex = 9
        Me.lblPartListCount.Text = "Part List Count:"
        '
        'rdoCustomerBOMsList
        '
        Me.rdoCustomerBOMsList.AutoSize = True
        Me.rdoCustomerBOMsList.Location = New System.Drawing.Point(18, 145)
        Me.rdoCustomerBOMsList.Name = "rdoCustomerBOMsList"
        Me.rdoCustomerBOMsList.Size = New System.Drawing.Size(120, 17)
        Me.rdoCustomerBOMsList.TabIndex = 10
        Me.rdoCustomerBOMsList.Text = "Customer BOMs List"
        Me.rdoCustomerBOMsList.UseVisualStyleBackColor = True
        '
        'ListPartNumbers
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(446, 459)
        Me.Controls.Add(Me.rdoCustomerBOMsList)
        Me.Controls.Add(Me.lblPartListCount)
        Me.Controls.Add(Me.btnLoad)
        Me.Controls.Add(Me.rdoCutList)
        Me.Controls.Add(Me.rdoFabList)
        Me.Controls.Add(Me.cboProjectEquip)
        Me.Controls.Add(Me.lblJobEquip)
        Me.Controls.Add(Me.txtProjectNo)
        Me.Controls.Add(Me.lblJobNo)
        Me.Controls.Add(Me.lstPartNumbers)
        Me.Controls.Add(Me.TableLayoutPanel1)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "ListPartNumbers"
        Me.ShowInTaskbar = False
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent
        Me.Text = "ListPartNumbers"
        Me.TableLayoutPanel1.ResumeLayout(False)
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents TableLayoutPanel1 As System.Windows.Forms.TableLayoutPanel
    Friend WithEvents OK_Button As System.Windows.Forms.Button
    Friend WithEvents Cancel_Button As System.Windows.Forms.Button
    Friend WithEvents lstPartNumbers As System.Windows.Forms.TextBox
    Friend WithEvents lblJobNo As System.Windows.Forms.Label
    Friend WithEvents txtProjectNo As System.Windows.Forms.TextBox
    Friend WithEvents lblJobEquip As System.Windows.Forms.Label
    Friend WithEvents cboProjectEquip As System.Windows.Forms.ComboBox
    Friend WithEvents rdoFabList As System.Windows.Forms.RadioButton
    Friend WithEvents rdoCutList As System.Windows.Forms.RadioButton
    Friend WithEvents btnLoad As System.Windows.Forms.Button
    Friend WithEvents lblPartListCount As System.Windows.Forms.Label
    Friend WithEvents rdoCustomerBOMsList As System.Windows.Forms.RadioButton

End Class
