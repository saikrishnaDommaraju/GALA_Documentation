Imports System
Imports System.IO
Imports System.Drawing.Printing
Imports System.Linq
Imports EPDM.Interop.epdm
Imports EModelView
Imports Gala.Utility

Public Class Print_Drawings
    Private hostContainer As eDwHost = Nothing
    Private WithEvents eDrwViewer As EModelView.EModelViewControl = Nothing
    Private isFromCmd As Boolean = False
    Private appPath As String = Application.StartupPath()

    Public Enum swDocumentTypes_e
        swDocNONE = 0 ' Used to be TYPE_NONE
        swDocPART = 1 ' Used to be TYPE_PART
        swDocASSEMBLY = 2 ' Used to be TYPE_ASSEMBLY
        swDocDRAWING = 3 ' Used to be TYPE_DRAWING
        swDocSDM = 4 ' Solid data manager.
    End Enum

    Public Enum swOpenDocOptions_e
        swOpenDocOptions_Silent = &H1S ' Open document silently or not
        swOpenDocOptions_ReadOnly = &H2S ' Open document read only or not
        swOpenDocOptions_ViewOnly = &H4S ' Open document view only or not
        swOpenDocOptions_RapidDraft = &H8S ' Convert document to RapidDraft format or not (drawings only)
        swOpenDocOptions_LoadModel = &H10S ' Load detached models automatically or not (drawings only)
        swOpenDocOptions_AutoMissingConfig = &H20S '  Automatically handle missing configs of drawing views (drawings only)
    End Enum

    Public Enum swFileLoadError_e
        swGenericError = &H1S
        swFileNotFoundError = &H2S
        swIdMatchError = &H4S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swReadOnlyWarn = &H8S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swSharingViolationWarn = &H10S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swDrawingANSIUpdateWarn = &H20S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swSheetScaleUpdateWarn = &H40S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swNeedsRegenWarn = &H80S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swBasePartNotLoadedWarn = &H100S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swFileAlreadyOpenWarn = &H200S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swInvalidFileTypeError = &H400S '  the type argument passed into the API is not valid
        swDrawingsOnlyRapidDraftWarn = &H800S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swViewOnlyRestrictions = &H1000S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swFutureVersion = &H2000S '  document being opened is of a future version.
        swViewMissingReferencedConfig = &H4000S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
        swDrawingSFSymbolConvertWarn = &H8000S '  NO LONGER USED as of OpenDoc6, moved to swFileLoadWarning_e
    End Enum

    '  Warnings that occured during a Open API, but did NOT cause the save to fail.
    Public Enum swFileLoadWarning_e
        swFileLoadWarning_IdMismatch = &H1S
        swFileLoadWarning_ReadOnly = &H2S
        swFileLoadWarning_SharingViolation = &H4S
        swFileLoadWarning_DrawingANSIUpdate = &H8S
        swFileLoadWarning_SheetScaleUpdate = &H10S
        swFileLoadWarning_NeedsRegen = &H20S
        swFileLoadWarning_BasePartNotLoaded = &H40S
        swFileLoadWarning_AlreadyOpen = &H80S
        swFileLoadWarning_DrawingsOnlyRapidDraft = &H100S
        swFileLoadWarning_ViewOnlyRestrictions = &H200S
        swFileLoadWarning_ViewMissingReferencedConfig = &H400S
        swFileLoadWarning_DrawingSFSymbolConvert = &H800S
        swFileLoadWarning_RevolveDimTolerance = &H1000S
        swFileLoadWarning_ModelOutOfDate = &H2000S
    End Enum

    Public Enum swDwgPaperSizes_e
        swDwgPaperAsize = 0
        swDwgPaperAsizeVertical = 1
        swDwgPaperBsize = 2
        swDwgPaperCsize = 3
        swDwgPaperDsize = 4
        swDwgPaperEsize = 5
        swDwgPaperA4size = 6
        swDwgPaperA4sizeVertical = 7
        swDwgPaperA3size = 8
        swDwgPaperA2size = 9
        swDwgPaperA1size = 10
        swDwgPaperA0size = 11
        swDwgPapersUserDefined = 12
    End Enum

    Const NumPaperSize As Integer = 13
    Const WindowCaption As String = "Print Drawings"

    Dim m_PaperSize(NumPaperSize) As String
    Dim m_FileName As String = Space(0)
    Dim oVault As New EdmVault5
    Dim blnWaitToPrint As Boolean = False
    Dim blnWaitForDwgToLoad As Boolean = False
    Dim m_BOMs As DataTable
    Dim m_bsBOMs As BindingSource

    Private Sub Print_Drawings_Load(ByVal sender As System.Object,
        ByVal e As System.EventArgs) Handles MyBase.Load

        If Not System.IO.Directory.Exists(appPath & "\Tmp") Then
            System.IO.Directory.CreateDirectory(appPath & "\Tmp")
        End If

        Initialize()

        m_BOMs = BuildListTable()
        m_bsBOMs = New BindingSource
        m_bsBOMs.DataSource = m_BOMs
        dgvParts.DataSource = m_BOMs

        For Each col As DataGridViewColumn In dgvParts.Columns
            col.SortMode = DataGridViewColumnSortMode.NotSortable
        Next

        dgvParts.Columns("ItemID").Visible = False

        dgvParts.SelectionMode = DataGridViewSelectionMode.FullRowSelect

        ToolStripStatusLabel1.Visible = False
        ToolStripProgressBar1.Visible = False
        ToolStripStatusLabel2.Visible = False

    End Sub

    Private Sub Print_Drawings_Shown(sender As Object, e As EventArgs) Handles Me.Shown

        Dim byWhat As String
        Dim args = My.Application.CommandLineArgs
        If args.Count > 0 Then isFromCmd = True

        If isFromCmd Then
            Application.DoEvents()

            byWhat = args(0)
            If byWhat = "project" Then
                GetPartNumbersByProj(args(1))
            ElseIf byWhat = "drawing" Then
                GetPartNumbersByDraw(args(1))
            Else 'the byWhat is wrong
                MsgBox("The first argument should be project or drawing")
                Application.Exit()
            End If
            Print()
            Application.Exit()
        End If

    End Sub

    Private Sub Initialize()
        Me.Text = WindowCaption

        hostContainer = New eDwHost
        Me.Controls.Add(hostContainer)

        Try
            eDrwViewer = hostContainer.GetOcx()

        Catch ex As Exception
            MsgBox("An error occured creating the eDrawing Viewer control.  Probably a version conflict." & vbCr & vbCrLf & ex.Message, MsgBoxStyle.Exclamation, "Error")

            End

        End Try

        hostContainer.Location = New System.Drawing.Point(dgvParts.Width + 10, dgvParts.Top)
        hostContainer.Size = New System.Drawing.Size(Me.Width - (dgvParts.Width + 10), dgvParts.Height)
        hostContainer.Anchor = AnchorStyles.Top + AnchorStyles.Bottom + AnchorStyles.Left + AnchorStyles.Right

        eDrwViewer.EnableFeatures = EModelView.EMVEnableFeatures.eMVReadOnly
        eDrwViewer.AlwaysShowWarningWatermark = 0

        m_PaperSize(swDwgPaperSizes_e.swDwgPaperAsize) = "A - Landscape"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperAsizeVertical) = "A - Portrait"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperBsize) = "B - Landscape"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperCsize) = "C - Landscape"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperDsize) = "D - Landscape"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperEsize) = "E - Landscape"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperA4size) = "A4 - Landscape"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperA4sizeVertical) = "A4 - Portrait"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperA3size) = "A3 - Landscape"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperA2size) = "A2 - Landscape"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperA1size) = "A1 - Landscape"
        m_PaperSize(swDwgPaperSizes_e.swDwgPaperA0size) = "A0 - Landscape"
        m_PaperSize(swDwgPaperSizes_e.swDwgPapersUserDefined) = "Custom"

        m_FileName = ""

    End Sub

    Private Sub LoadSWDrawing(ByVal DwgFilename As String)
        Dim strFile As String = Space(0)

        Windows.Forms.Cursor.Current = Cursors.WaitCursor

        Me.Text = WindowCaption & " <loading " & DwgFilename & ">"

        Dim oVault As New EdmVault5

        If Not oVault.IsLoggedIn Then
            oVault.Login("viewer", "viewer", "_PDMWorksVault")
        End If

        Dim oSearch As IEdmSearch5
        oSearch = oVault.CreateSearch

        oSearch.FileName = DwgFilename
        oSearch.FindFolders = False

        Dim oResult As IEdmSearchResult5
        oResult = oSearch.GetFirstResult
        Dim oFile As IEdmFile5

        oFile = oVault.GetFileFromPath(oResult.Path)

        Try
            ViewSWDrawing(oFile)

        Catch ex As Exception
            MessageBox.Show("Error occurred viewing the document!" & vbCrLf _
                & vbCrLf _
                & ex.Message _
                & vbCrLf _
                & "Stack:  " & ex.StackTrace, "Viewing Error",
                MessageBoxButtons.OK, MessageBoxIcon.Exclamation)

        Finally
            Windows.Forms.Cursor.Current = Cursors.Default

        End Try

        Me.Text = WindowCaption & " (" & DwgFilename & ")"

        Windows.Forms.Cursor.Current = Cursors.Default

    End Sub

    Private Sub ViewSWDrawing(ByVal Drawing As IEdmFile5)
        Try
            Drawing.GetFileCopy(Me.Handle.ToInt32, 0, appPath & "\Tmp\", 0)
            'Drawing.GetFileCopy(Me.Handle.ToInt32)

            Try
                'eDrwViewer.OpenDoc(Drawing.GetLocalPath(GetIEdmFolderID(Drawing)), False, False, True, "")
                eDrwViewer.OpenDoc(appPath & "\Tmp\" & Drawing.Name, False, False, True, "")

            Catch ex As Exception
                MessageBox.Show("eDrwViewer.OpenDoc:  " & ex.Message)

                Return

            End Try

            blnWaitForDwgToLoad = True

            Timer1.Interval = 20000
            Timer1.Start()

            While blnWaitForDwgToLoad
                My.Application.DoEvents()

            End While

            Timer1.Stop()

        Catch ex As Exception
            MessageBox.Show("Error occurred viewing the SolidWorks document!" & vbCrLf _
                 & vbCrLf _
                 & ex.Message _
                 & vbCrLf _
                 & "Stack:  " & ex.StackTrace, "Viewing Error",
                 MessageBoxButtons.OK, MessageBoxIcon.Exclamation)

        End Try

    End Sub

    Private Function SWDocType(ByVal DocName As String) As swDocumentTypes_e
        Dim intDocType As swDocumentTypes_e = swDocumentTypes_e.swDocNONE

        ' Determine type of SolidWorks file based on file extension
        Select Case LCase(DocName.Trim.Substring(DocName.Trim.Length - 6))
            Case "sldprt"
                intDocType = swDocumentTypes_e.swDocPART

            Case "sldasm"
                intDocType = swDocumentTypes_e.swDocASSEMBLY

            Case "slddrw"
                intDocType = swDocumentTypes_e.swDocDRAWING

            Case Else
                intDocType = swDocumentTypes_e.swDocNONE

        End Select

        Return intDocType

    End Function

    Private Function GetPaperSize(ByVal SheetWidth As Long, ByVal SheetHeight As Long) As Integer

        If (SheetWidth <= 11000 And SheetHeight <= 8500) _
        Or (SheetWidth <= 8500 And SheetHeight <= 11000) Then

            Return 1    'Letter

        ElseIf (SheetWidth <= 18000 And SheetHeight <= 12000) _
            Or (SheetWidth <= 12000 And SheetHeight <= 18000) Then

            Return 24    'C Size

        ElseIf (SheetWidth <= 24000 And SheetHeight <= 18000) _
            Or (SheetWidth <= 18000 And SheetHeight <= 24000) Then

            Return 25    'D Size

        ElseIf (SheetWidth <= 36000 And SheetHeight <= 24000) _
            Or (SheetWidth <= 24000 And SheetHeight <= 36000) Then

            Return 26    'D Size

        Else
            Return 1

        End If

    End Function

    Private Function GetPrinterName(ByVal PaperSize As Integer) As String
        Dim strPrtSvr As String = "\\" & My.Settings.PrintServerName & "\"

        If My.Settings.PrintToDefaultPrinter1 Then
            Dim oPD As New PrintDocument

            Return oPD.PrinterSettings.PrinterName

        End If

        If (PaperSize >= 283 And PaperSize <= 284) _
            Or (PaperSize >= 4442 And PaperSize <= 4444) _
            Or PaperSize = 256 Then

            Return strPrtSvr & My.Settings.PlotterName

        Else
            Try
                Dim oPD As New PrintDocument

                Return oPD.PrinterSettings.PrinterName

            Catch ex As Exception
                MessageBox.Show("Error occurred retrieving default printer!" & vbCrLf _
                     & vbCrLf _
                     & ex.Message _
                     & vbCrLf _
                     & "Stack:  " & ex.StackTrace, "Print Drawings Error",
                     MessageBoxButtons.OK, MessageBoxIcon.Exclamation)

                Return strPrtSvr & "AAA"

            End Try

        End If

    End Function

    Private Function GetDwgOrientation(ByVal SheetWidth As Double,
        ByVal SheetHeight As Double) As EMVPrintOrientation

        If SheetWidth < SheetHeight Then
            Return EMVPrintOrientation.ePortrait
        Else
            Return EMVPrintOrientation.eLandscape
        End If

        'Disabling since we are printing to PDF, not to a printer
        'If GetPrinterName(GetPaperSize(SheetWidth, SheetHeight)) Like "*Plotter02" Then
        '    Or GetPrinterName(GetPaperSize(SheetWidth, SheetHeight)) Like "*Plotter01" Then
        '    Return EMVPrintOrientation.eLandscape
        'Else
        '    If SheetWidth < SheetHeight Then
        '        Return EMVPrintOrientation.ePortrait
        '    Else
        '        Return EMVPrintOrientation.eLandscape
        '    End If
        'End If

    End Function

    Private Function MToIn(ByVal Meters As Double) As Double
        Return Meters * 39.37008

    End Function

    Private Function InToTh(ByVal Inches As Double) As Long
        Return Inches * 1000

    End Function

    Private Sub PrintToolStripMenuItem_Click(ByVal sender As System.Object,
        ByVal e As System.EventArgs) Handles PrintToolStripMenuItem.Click

        Print()

    End Sub

    Private Sub tbtnPrint_Click(sender As System.Object, e As System.EventArgs) Handles tbtnPrint.Click
        Print()

    End Sub

    Private Sub Print()
        Dim strDwg As String = Space(0)
        Dim lngWidth As Long = 0
        Dim lngHeight As Long = 0
        Dim intPaperSize As Integer = 1
        Dim strPrinterName As String = Space(0)
        Dim oPD As New PrintDocument
        Dim Progress = 1

        ToolStripStatusLabel1.Visible = True
        ToolStripStatusLabel2.Visible = False
        ToolStripProgressBar1.Visible = True

        strPrinterName = oPD.PrinterSettings.PrinterName

        For Each oFind As DataGridViewRow In dgvParts.Rows

            ToolStripStatusLabel1.Text = "Printing " & Progress & "/" & dgvParts.RowCount
            ToolStripProgressBar1.Value = Progress

            dgvParts.CurrentCell = oFind.Cells(1)

            strDwg = oFind.Cells("Part").Value

            If oFind.Cells("Selected").Value Then
                LoadSWDrawing(strDwg)

                My.Application.DoEvents()

                lngWidth = InToTh(eDrwViewer.SheetWidth)
                lngHeight = InToTh(eDrwViewer.SheetHeight)
                intPaperSize = GetPaperSize(lngWidth, lngHeight)

                'MsgBox(strPrinterName)
                'MsgBox(lngWidth & " W X " & lngHeight & " H")
                'MsgBox(intPaperSize)

                If SWDocType(strDwg) = swDocumentTypes_e.swDocDRAWING Then

                    'MsgBox(Replace(eDrwViewer.FileName, ".SLDDRW", "") & ".pdf")

                    eDrwViewer.SetPageSetupOptions(GetDwgOrientation(lngWidth, lngHeight),
                    intPaperSize, 0, 0, 1, 7, strPrinterName, 0, 0, 0, 0)

                    eDrwViewer.Print5(False, eDrwViewer.FileName, False, False, True,
                    EMVPrintType.eScaleToFit, 1.0, 0, 0, False, 1, 1,
                    Replace(eDrwViewer.FileName, ".SLDDRW", "") & ".pdf")

                    'eDrwViewer.Print4(False, eDrwViewer.FileName, False, False, False, _
                    '   IIf(intPaperSize <> 282, EMVPrintType.eOneToOne, EMVPrintType.eScaleToFit), _
                    '    1.0, 0, 0, False, 1, 1)

                    blnWaitToPrint = True

                End If

                Timer2.Interval = 120000
                Timer2.Start()

                While blnWaitToPrint
                    My.Application.DoEvents()
                End While

                Timer2.Stop()

            End If

            Progress += 1
        Next

        If Not isFromCmd Then
            MessageBox.Show("Completed printing all drawings.", "Finished Printing",
            MessageBoxButtons.OK, MessageBoxIcon.Information)
        Else
            My.Computer.FileSystem.WriteAllText(appPath & "\Tmp\complete.txt",
                                                "Completed Drawing Print", True)
        End If

        Try
            Kill(appPath & "\Tmp\*.SLDDRW")
        Catch
            'Do Nothing
        End Try

        Me.Text = WindowCaption

    End Sub

    Private Function PDFinFolder() As List(Of String)

        Dim fileList As New List(Of String)

        If Directory.Exists(appPath & "\Tmp") Then
            Dim di As New DirectoryInfo(appPath & "\Tmp")
            Dim aryFi As FileInfo() = di.GetFiles("*.pdf")
            Dim fi As FileInfo

            For Each fi In aryFi
                fileList.Add(Convert.ToInt32(Replace(fi.Name, fi.Extension, "")).ToString)
            Next
        End If

        Return fileList

    End Function

    Private Sub GetPartNumbersByProj(projNo As String)
        Dim dtTmpList As DataTable
        Dim pType As String = "N"
        Dim strPartList As String = Space(0)
        Dim strTmpList As String = Space(0)
        Dim lngCnt As Long = 1
        Dim arrPartNumbers As String()

        ToolStripStatusLabel1.Visible = True

        pType = isPorJ(projNo)

        ToolStripStatusLabel1.Text = "Getting Fab List Drawings..."
        dtTmpList = GetFabricationList(projNo, 0, pType)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "FabList")
            strPartList &= strTmpList & vbCrLf
        End If

        ToolStripStatusLabel1.Text = "Getting Cut List Drawings..."
        Application.DoEvents()
        dtTmpList = GetCutList(projNo, 0, pType)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "CutList")
            strPartList &= strTmpList & vbCrLf
        End If

        ToolStripStatusLabel1.Text = "Getting Customer BOM Drawings..."
        Application.DoEvents()
        dtTmpList = GetCustomerBOMs(projNo, 0, pType)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "CustBOM")
            strPartList &= strTmpList & vbCrLf
        End If

        arrPartNumbers = strPartList.Trim.Replace(vbCrLf, ",").Split(",")
        Dim aListPN As List(Of String) = New List(Of String)(arrPartNumbers)
        aListPN = aListPN.Distinct().ToList

        'Remove the PDF files that we aleady have
        Dim pdfExist As List(Of String) = PDFinFolder()
        For Each pdf As String In pdfExist
            If aListPN.Contains(pdf) Then
                aListPN.Remove(pdf)
            End If
        Next

        ToolStripStatusLabel1.Visible = True
        ToolStripStatusLabel2.Visible = False
        With ToolStripProgressBar1
            .Minimum = 0
            .Maximum = aListPN.Count
            .Value = 0
            .Visible = True
        End With

        Dim strPNExceptions As String = AddDwgsToList(String.Join(vbCrLf, aListPN.ToArray), 0, lngCnt, "")

        ToolStripStatusLabel1.Visible = False
        ToolStripProgressBar1.Visible = False
        ToolStripStatusLabel2.Visible = True
        ToolStripStatusLabel2.Text = dgvParts.RowCount & " Drawing(s) loaded"

        If dgvParts.Rows.Count > 0 Then dgvParts.Rows(0).Selected = True
        dgvParts.Refresh()

    End Sub

    Private Sub GetPartNumbersByProj_old(projNo As String)
        Dim dtTmpList As DataTable
        Dim strPartList As String = Space(0)
        Dim strTmpList As String = Space(0)
        Dim lngCnt As Long = 1
        Dim arrPartNumbers As String()

        ToolStripStatusLabel1.Visible = True

        ToolStripStatusLabel1.Text = "Getting Fab List Drawings..."
        dtTmpList = GetFabricationList(projNo)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "FabList")
            strPartList &= strTmpList & vbCrLf
        End If

        ToolStripStatusLabel1.Text = "Getting Cut List Drawings..."
        Application.DoEvents()
        dtTmpList = GetCutList(projNo)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "CutList")
            strPartList &= strTmpList & vbCrLf
        End If

        ToolStripStatusLabel1.Text = "Getting Customer BOM Drawings..."
        Application.DoEvents()
        dtTmpList = GetCustomerBOMs(projNo)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "CustBOM")
            strPartList &= strTmpList & vbCrLf
        End If

        ToolStripStatusLabel1.Text = "Getting Weld Drawings..."
        Application.DoEvents()
        dtTmpList = GetJobListDrw(projNo, "WLD-99", 3)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "CustBOM")
            strPartList &= strTmpList & vbCrLf
        End If

        ToolStripStatusLabel1.Text = "Getting PipeWeld Drawings..."
        Application.DoEvents()
        dtTmpList = GetJobListDrw(projNo, "WLP-99", 2)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "CustBOM")
            strPartList &= strTmpList & vbCrLf
        End If

        ToolStripStatusLabel1.Text = "Getting Screen Drawings..."
        Application.DoEvents()
        dtTmpList = GetJobListDrw(projNo, "SCN-99", 2)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "CustBOM")
            strPartList &= strTmpList & vbCrLf
        End If

        ToolStripStatusLabel1.Text = "Getting MG Drawings..."
        Application.DoEvents()
        dtTmpList = GetJobListDrw(projNo, "MG-99", 3)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "CustBOM")
            strPartList &= strTmpList & vbCrLf
        End If

        ToolStripStatusLabel1.Text = "Getting OutProcess Drawings..."
        Application.DoEvents()
        dtTmpList = GetJobListDrw(projNo, "OUT-99", 3)
        If dtTmpList IsNot Nothing Then
            strTmpList = DataTableToString(dtTmpList, "CustBOM")
            strPartList &= strTmpList & vbCrLf
        End If

        arrPartNumbers = strPartList.Trim.Replace(vbCrLf, ",").Split(",")
        Dim aListPN As List(Of String) = New List(Of String)(arrPartNumbers)
        aListPN = aListPN.Distinct().ToList

        'Remove the PDF files that we aleady have
        Dim pdfExist As List(Of String) = PDFinFolder()
        For Each pdf As String In pdfExist
            If aListPN.Contains(pdf) Then
                aListPN.Remove(pdf)
            End If
        Next

        ToolStripStatusLabel1.Visible = True
        ToolStripStatusLabel2.Visible = False
        With ToolStripProgressBar1
            .Minimum = 0
            .Maximum = aListPN.Count
            .Value = 0
            .Visible = True
        End With

        Dim strPNExceptions As String = AddDwgsToList(String.Join(vbCrLf, aListPN.ToArray), 0, lngCnt, "")

        ToolStripStatusLabel1.Visible = False
        ToolStripProgressBar1.Visible = False
        ToolStripStatusLabel2.Visible = True
        ToolStripStatusLabel2.Text = dgvParts.RowCount & " Drawing(s) loaded"

        If dgvParts.Rows.Count > 0 Then dgvParts.Rows(0).Selected = True
        dgvParts.Refresh()

    End Sub

    Private Sub GetPartNumbersByDraw(strDrwList As String)
        Dim lngCnt As Long = 1
        Dim arrPartNumbers As String()

        arrPartNumbers = strDrwList.Trim.Replace(vbCrLf, ",").Split(",")
        Dim aListPN As List(Of String) = New List(Of String)(arrPartNumbers)
        aListPN = aListPN.Distinct().ToList

        'Remove the PDF files that we aleady have
        Dim pdfExist As List(Of String) = PDFinFolder()
        For Each pdf As String In pdfExist
            If aListPN.Contains(pdf) Then
                aListPN.Remove(pdf)
            End If
        Next

        ToolStripStatusLabel1.Visible = True
        ToolStripStatusLabel2.Visible = False
        With ToolStripProgressBar1
            .Minimum = 0
            .Maximum = aListPN.Count
            .Value = 0
            .Visible = True
        End With

        Dim strPNExceptions As String = AddDwgsToList(String.Join(vbCrLf, aListPN.ToArray), 0, lngCnt, "")

        ToolStripStatusLabel1.Visible = False
        ToolStripProgressBar1.Visible = False
        ToolStripStatusLabel2.Visible = True
        ToolStripStatusLabel2.Text = dgvParts.RowCount & " Drawing(s) loaded"

        If dgvParts.Rows.Count > 0 Then dgvParts.Rows(0).Selected = True
        dgvParts.Refresh()
    End Sub

    Private Function DataTableToString(dtPartsList As DataTable, sListType As String) As String

        Dim strPartList As String = Space(0)
        Dim alPartList As ArrayList = New ArrayList()
        Dim strDwgNo As String = vbNullString
        Dim drwCol As String = Space(0)

        drwCol = "drawing_nbr"
        If sListType = "CustBOM" Then drwCol = "BOMDwgNo"

        For Each oRow As DataRow In dtPartsList.Rows
            Select Case oRow("wc")
                Case "EGV-01", "DOC-99", "FBF-99", "PEN-99"
                    ' Do nothing

                Case Else
                    If Not IsDBNull(oRow(drwCol)) Then

                        If Not alPartList.Contains(oRow(drwCol)) Then
                            If Not IsDiePlate(oRow("item")) Then
                                strDwgNo = GetDwgNo(oRow(drwCol))
                                If strDwgNo.Trim.Length > 0 Then
                                    strPartList &= strDwgNo & vbCrLf
                                    alPartList.Add(Convert.ToInt32(strDwgNo))
                                End If
                            End If
                        End If

                    End If
            End Select

        Next

        Return String.Join(vbCrLf, alPartList.ToArray())
    End Function

    Private Sub OpenDrawingsByPartNumberList()
        Dim oGetPartNumbers As New ListPartNumbers

        oGetPartNumbers.ShowDialog()

        If oGetPartNumbers.DialogResult = Windows.Forms.DialogResult.OK Then
            Dim strPartNumbers As String()
            Dim lngCnt As Long = 1

            strPartNumbers = oGetPartNumbers.lstPartNumbers.Text.Trim.Split(Chr(10))

            ToolStripStatusLabel1.Visible = True
            ToolStripStatusLabel2.Visible = False
            With ToolStripProgressBar1
                .Minimum = 0
                .Maximum = strPartNumbers.Length
                .Value = 0
                .Visible = True
            End With

            Dim strPNExceptions As String =
                AddDwgsToList(oGetPartNumbers.lstPartNumbers.Text.Trim, 0, lngCnt, "")

            dgvParts.Refresh()

            If strPNExceptions.Trim.Length > 0 Then
                Dim oPNExceptions As New ListPartNumberExceptions

                oPNExceptions.lstPartNumbers.Text = strPNExceptions

                oPNExceptions.ShowDialog()

            End If

            'm_bsBOMs.Sort = "Parent, Part"

            MessageBox.Show("Completed retrieving all drawings.", "Finished",
                MessageBoxButtons.OK, MessageBoxIcon.Information)

        End If

        ToolStripStatusLabel1.Visible = False
        ToolStripProgressBar1.Visible = False
        ToolStripStatusLabel2.Visible = True
        ToolStripStatusLabel2.Text = dgvParts.RowCount & " Drawing(s) loaded"

        If dgvParts.Rows.Count > 0 Then
            dgvParts.Rows(0).Selected = True

        End If

        dgvParts.Refresh()

    End Sub

    Private Function AddDwgsToList(ByVal DwgList As String,
        ByVal Level As Integer, ByRef Progress As Long,
        Optional ByVal ParentDwg As String = "",
        Optional ByVal JobNo As String = "") As String

        Dim strPNExceptions As String = Space(0)
        'Dim strCSList As String
        Dim strPartNumbers As String()
        Dim intListType As Integer = 0
        Dim oModel As IEdmFile5

        strPartNumbers = DwgList.Trim.Split(Chr(10))

        For Each strPN As String In strPartNumbers
            'Dim blnIsDP As Boolean

            If IsNumeric(strPN) And Val(strPN) < 10000000 Then
                'This is already been checked for when pulling the data
                'If IsDiePlate(strPN) Then
                '    MessageBox.Show("Die plates drawings and models cannot be retrieved by this application!" _
                '        & " Please refer to the die plate department in Eagle Rock for these files.", "Die Plate", _
                '        MessageBoxButtons.OK, MessageBoxIcon.Information)

                '    blnIsDP = True

                'End If

                'If Not blnIsDP Then

                Dim strFilename As String = strPN.Trim.PadLeft(7, "0") + ".slddrw"

                ToolStripStatusLabel1.Text = "Loading " & Progress & "/" & UBound(strPartNumbers)
                ToolStripProgressBar1.Value = Progress

                If Not RetrieveDwg(strFilename, Level, oModel, ParentDwg, JobNo) Then
                    strPNExceptions &= strPN & Chr(13) & Chr(10)
                End If

                'End If

            End If

            My.Application.DoEvents()

            If Level = 0 Then Progress += 1

        Next

        Return strPNExceptions

    End Function

    'Private Function RetrieveDwg1(ByVal strFilename As String, _
    '    ByVal Level As Integer, ByRef Model As IEdmFile5, _
    '    ByVal ParentDwg As String, _
    '    Optional ByVal JobNo As String = "") As Boolean

    '    eDrwViewer.OpenDoc("C:\Users\Public\Documents\SOLIDWORKS\SOLIDWORKS 2017\tutorial\EDraw\claw\claw-mechanism.edrw", False, False, True, "")

    'End Function

    Private Function RetrieveDwg(ByVal strFilename As String,
        ByVal Level As Integer, ByRef Model As IEdmFile5,
        ByVal ParentDwg As String,
        Optional ByVal JobNo As String = "") As Boolean

        Dim blnUnlockWhenDone As Boolean = False

        If Not oVault.IsLoggedIn Then
            oVault.Login("viewer", "viewer", "_PDMWorksVault")

        End If

        If Not oVault.IsLoggedIn Then
            MessageBox.Show("Connection to the PDMWorks Enterprise vault has been broken.",
                            "PDMWE Connection Error", MessageBoxButtons.OK, MessageBoxIcon.Error)

            Return False

        End If

        Dim oSearch As IEdmSearch5 = oVault.CreateSearch

        oSearch.FileName = strFilename
        oSearch.FindFolders = False

        Dim oResult As IEdmSearchResult5 = oSearch.GetFirstResult

        If oResult Is Nothing Then
            Return False
        End If

        Dim oFile As IEdmFile5 = oVault.GetFileFromPath(oResult.Path)

        If oFile IsNot Nothing Then
            Dim strAuthor As String = Space(0)
            Dim strCheckedBy As String = Space(0)
            Dim strDesc As String = Space(0)
            Dim strDwgTitle As String = Space(0)
            Dim strDrawnBy As String = Space(0)
            Dim strDwgSize As String = Space(0)
            Dim strMaterial As String = Space(0)
            Dim strMatlType As String = Space(0)
            Dim strRevision As String = Space(0)
            Dim strRevisionBy As String = Space(0)
            Dim strRevisionChkBy As String = Space(0)
            Dim strPart As String = strFilename & vbCrLf & vbCrLf
            Dim strState As String = Space(0)
            Dim blnNoSWLicense As Boolean = False

            Dim valueList As Array = Nothing
            'Dim oVarMgr As IEdmVariableMgr5

            AddPart(strFilename)

            Dim oRef As IEdmReference5 = oFile.GetReferenceTree(GetIEdmFolderID(oFile), 0)
            Dim oPos As IEdmPos5 = oRef.GetFirstChildPosition(oFile.Name, True, True, 0)
            Dim oSubFile As IEdmFile5 = oFile
            Dim oRefSubFile As IEdmReference5 = oRef

            While Not oPos.IsNull
                Try
                    oRefSubFile = oRef.GetNextChild(oPos)
                    oSubFile = oRefSubFile.File

                    If oSubFile.Name.ToLower Like "*.sldprt" Or oSubFile.Name.ToLower Like "*.sldasm" Then
                        If Not oSubFile.IsLocked Then
                            Try
                                oSubFile.LockFile(GetIEdmFolderID(oSubFile), Me.Handle.ToInt32())
                                blnUnlockWhenDone = True

                            Catch ex As Exception
                                If ex.Message = "The operation is not supported by your SolidWorks Enterprise PDM license." Then
                                    blnNoSWLicense = True

                                Else
                                    'Throw ex

                                End If

                            End Try

                        End If

                        If Not blnNoSWLicense AndAlso blnUnlockWhenDone Then
                            oSubFile.UndoLockFile(Me.Handle.ToInt32())

                        End If

                    End If

                    Model = oRefSubFile.File

                Catch ex As Exception
                    MessageBox.Show(ex.Message + vbCrLf + "File name: " & oSubFile.Name)

                    If blnUnlockWhenDone Then
                        If oSubFile.IsLocked() Then
                            If oSubFile.LockedOnComputer = My.Computer.Name Then
                                oSubFile.UndoLockFile(Me.Handle.ToInt32())

                            End If

                        End If

                    End If

                End Try

            End While

            Return True

        Else
            Return False

        End If

    End Function

    Private Function GetIEdmFolderID(ByVal oFile As IEdmFile5) As Integer
        Dim oPos As IEdmPos5 = oFile.GetFirstFolderPosition
        Dim intID As Integer = oFile.GetNextFolder(oPos).ID

        Return intID

    End Function

    Private Sub PrintSetupToolStripMenuItem_Click(ByVal sender As System.Object,
        ByVal e As System.EventArgs) Handles PrintSetupToolStripMenuItem.Click

        Dim oOptions As New Options

        Options.ShowDialog()

    End Sub

    Private Sub ExitToolStripMenuItem_Click(ByVal sender As System.Object,
        ByVal e As System.EventArgs) Handles ExitToolStripMenuItem.Click

        End

    End Sub

    Private Sub ClearToolStripMenuItem_Click(ByVal sender As System.Object,
        ByVal e As System.EventArgs) Handles ClearToolStripMenuItem.Click

        ClearDwgList()

    End Sub

    Private Sub tbtnClear_Click(sender As System.Object, e As System.EventArgs) Handles tbtnClear.Click
        ClearDwgList()

    End Sub

    Private Sub ClearDwgList()
        m_BOMs.Clear()

        eDrwViewer.CloseActiveDoc("")

        ToolStripStatusLabel2.Text = "No drawings loaded"

    End Sub

    Private Function BuildListTable() As DataTable
        Dim oBOMs As New DataTable
        Dim colItemID As DataColumn
        Dim colSelected As DataColumn
        Dim colPart As DataColumn

        colItemID = oBOMs.Columns.Add("ItemID", Type.GetType("System.Int32"))
        colSelected = oBOMs.Columns.Add("Selected", Type.GetType("System.Boolean"))
        colPart = oBOMs.Columns.Add("Part", Type.GetType("System.String"))

        With colItemID
            .AllowDBNull = False
            .AutoIncrement = True
            .AutoIncrementSeed = 1
            .AutoIncrementStep = 1
            .Unique = True
        End With

        Return oBOMs

    End Function

    Private Sub AddPart(ByVal Part As String)

        'Dim oCol As DataColumn = m_BOMs.Columns("Part")

        'For Each oFind As DataRow In m_BOMs.Rows
        '    If oFind(oCol) = Part Then
        '        Exit Sub

        '    End If
        'Next

        Dim oRow As DataRow = m_BOMs.NewRow

        oRow("Selected") = True
        oRow("Part") = Part

        m_BOMs.Rows.Add(oRow)

        'dgvParts.Refresh()

    End Sub

    Private Sub dgvParts_CellClick1(sender As Object, e As System.Windows.Forms.DataGridViewCellEventArgs) Handles dgvParts.CellClick
        If dgvParts.SelectedRows(0).Cells("Selected").ColumnIndex = e.ColumnIndex Then
            dgvParts.SelectedRows(0).Cells("Selected").Value _
                = Not dgvParts.SelectedRows(0).Cells("Selected").Value

        End If

    End Sub

    Private Sub dgvParts_SelectionChanged1(sender As Object, e As System.EventArgs) Handles dgvParts.SelectionChanged
        If dgvParts.SelectedRows.Count > 0 Then
            LoadSWDrawing(dgvParts.SelectedRows(0).Cells("Part").Value)

        End If

        dgvParts.Select()

    End Sub

    Private Sub OpenToolStripMenuItem_Click(ByVal sender As System.Object,
        ByVal e As System.EventArgs) Handles OpenToolStripMenuItem.Click

        OpenDrawingsByPartNumberList()

    End Sub

    Private Sub tbtnAddToList_Click(sender As System.Object, e As System.EventArgs) Handles tbtnAddToList.Click
        'OpenDrawingsByPartNumberList()
        GetPartNumbersByProj("12200564")
        'PDFinFolder()
    End Sub

    Public ReadOnly Property PartsList() As DataTable
        Get
            Return m_BOMs

        End Get
    End Property

    Public ReadOnly Property PartListBinding() As BindingSource
        Get
            Return m_bsBOMs

        End Get
    End Property

    Private Sub Timer1_Tick(ByVal sender As System.Object,
        ByVal e As System.EventArgs) Handles Timer1.Tick

        blnWaitForDwgToLoad = False

    End Sub

    Private Sub Timer2_Tick(ByVal sender As System.Object,
        ByVal e As System.EventArgs) Handles Timer2.Tick

        blnWaitToPrint = False

    End Sub

    Private Sub eDrwViewer_OnFailedLoadingDocument(FileName As String, ErrorCode As Integer, ErrorString As String) Handles eDrwViewer.OnFailedLoadingDocument

        blnWaitForDwgToLoad = False

        MessageBox.Show("Drawing failed to load!" & vbCrLf _
           & Me.eDrwViewer.FileName & vbCrLf _
            & ErrorCode & " - " & ErrorString)

    End Sub

    Private Sub eDrwViewer_OnFailedPrintingDocument(PrintJobName As String) Handles eDrwViewer.OnFailedPrintingDocument

        blnWaitToPrint = False

        MessageBox.Show("Drawing failed to print!" & vbCrLf & PrintJobName)

    End Sub

    Private Sub eDrwViewer_OnFinishedLoadingDocument(FileName As String) Handles eDrwViewer.OnFinishedLoadingDocument
        blnWaitForDwgToLoad = False
    End Sub

    Private Sub eDrwViewer_OnFinishedPrintingDocument(PrintJobName As String) Handles eDrwViewer.OnFinishedPrintingDocument
        blnWaitToPrint = False
    End Sub

    Private Sub GetPrinterPaperSizes()
        Dim oPD As New PrintDocument
        Dim str As String = ""
        Dim blnContinue As Boolean = True
        Dim intLast As Integer = 0

        oPD.PrinterSettings.PrinterName = "\\" & My.Settings.PrintServerName & "\Plotter02"

        Do While blnContinue
            For intCnt As Integer = intLast To _
                IIf((intLast + 20) < oPD.PrinterSettings.PaperSizes.Count - 1,
                    intLast + 20,
                    oPD.PrinterSettings.PaperSizes.Count - 1)

                str &= oPD.PrinterSettings.PaperSizes(intCnt).RawKind & vbTab _
                    & oPD.PrinterSettings.PaperSizes(intCnt).PaperName & vbCrLf

                intLast = intCnt + 1

            Next

            If str.Length > 0 Then
                MsgBox(str)
                str = ""

            Else
                blnContinue = False

            End If

        Loop


    End Sub

    Private Sub GetPrinterPaperSources()
        Dim oPD As New PrintDocument
        Dim str As String = ""
        Dim blnContinue As Boolean = True
        Dim intLast As Integer = 0

        oPD.PrinterSettings.PrinterName = "\\" & My.Settings.PrintServerName & "\Plotter02"

        Do While blnContinue
            For intCnt As Integer = intLast To _
                IIf((intLast + 20) < oPD.PrinterSettings.PaperSources.Count - 1,
                    intLast + 20,
                    oPD.PrinterSettings.PaperSources.Count - 1)

                str &= oPD.PrinterSettings.PaperSources(intCnt).RawKind & vbTab _
                    & oPD.PrinterSettings.PaperSources(intCnt).SourceName & vbCrLf

                intLast = intCnt + 1

            Next

            If str.Length > 0 Then
                MsgBox(str)
                str = ""

            Else
                blnContinue = False

            End If

        Loop


    End Sub

    Private Sub TestToolStripMenuItem_Click(ByVal sender As System.Object, ByVal e As System.EventArgs)
        GetPrinterPaperSources()
    End Sub

    Private Sub Print_Drawings_FormClosed(sender As Object, e As FormClosedEventArgs) Handles Me.FormClosed
        Application.Exit()
    End Sub
End Class

