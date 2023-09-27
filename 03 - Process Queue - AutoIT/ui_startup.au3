#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <GuiEdit.au3>
#include "GUIButtonEx.au3"

Global $g_hBase, $g_hConfig ;Forms
Global Const $configFile = @ScriptDir & "\resources\config.ini"

AutoItSetOption("GUIOnEventMode", 1)

Func LoadBaseUI()

	$g_hBase = GUICreate("Technical Documentation Package", 345, 240, -1, -1, -1)
	GUISetBkColor(0xF0F0F0, $g_hBase)

	GUICtrlCreateLabel("Project No: ", 15, 15, 80, 20)
	GUICtrlCreateLabel("(or)   Job No: ", 170, 15, 80, 20)
	GUICtrlCreateLabel("Ouput Folder : ", 15, 45, 80, 20)
	Global $inputTxtProj  = GUICtrlCreateInput("12030021", 80, 12, 80, 20) ;11800556
	Global $inputTxtJob  = GUICtrlCreateInput("", 240, 12, 85, 20) ;M000011358
	Global $outputTxt = GUICtrlCreateInput("C:\Automation\Output", 100, 42, 200, 20)
	Global $outSelect = GUICtrlCreateButton("...", 305, 42, 20, 20)

	Global $btnStartProcess = _GUIBuildButton(100, 72, 115, 30, "Run", "Initiate Extraction Process", 0)

	Global $configPrint = GUICtrlCreateIcon(@ScriptDir & "\resources\icons.dll", -3, 230, 75, 20, 20)
	GUICtrlSetTip(-1, "Configuration")
	GUICtrlSetCursor(-1, 0)

	Global $txtProgress = GUICtrlCreateEdit("", 15, 120, 310, 100)

	;The Progress Bars
	Global $progStatus = GUICtrlCreateProgress(100, 72, 200, 20)
	GUICtrlSetState(-1, $GUI_HIDE)

	;Events
	GUISetOnEvent($GUI_EVENT_CLOSE , "_Exit")
	GUICtrlSetOnEvent($outSelect   , "btnOutput")
	GUICtrlSetOnEvent($configPrint, "LoadConfigUI")
	;GUICtrlSetOnEvent($btnStartProcess, "_test")

	;Show the UI
	GUISetState(@SW_SHOW)

	If Not FileExists($configFile) Then
		Msgbox($MB_ICONINFORMATION, "Config Not Entered", "Please enter the configuration information.")
		LoadConfigUI()
	EndIf

EndFunc

Func LoadConfigUI()

	;Load the configurations
	If FileExists($configFile) Then
		$csiUsername = IniRead($configFile, "CSI", "Username", "")
		$csiDB       = IniRead($configFile, "CSI", "Database", "")
		$pDrwEXE     = IniRead($configFile, "PrintDraw", "Exe", "")
		$pDrwDef     = IniRead($configFile, "PrintDraw", "DefaultPrint", "")
	Else
		$csiUsername = ""
		$csiDB       = ""
		$pDrwEXE     = ""
		$pDrwDef     = "False"

	EndIf

	$g_hConfig = GUICreate("Configuration", 330, 170, -1, -1)

	;Create the UI Elements
	GUICtrlCreateLabel("CSI Username:"      , 15, 15, 100, 20)
	GUICtrlCreateLabel("CSI Database:"      , 15, 40, 100, 20)
	GUICtrlCreateLabel("Print Drawing .exe:" , 15, 65, 100, 20)

	Global $txtCSIUser = GUICtrlCreateInput($csiUsername, 110, 13, 180, 20)
	Global $txtCSIDB   = GUICtrlCreateInput($csiDB      , 110, 38, 180, 20)
	Global $txtPDEXE   = GUICtrlCreateInput($pDrwEXE    , 110, 63, 180, 20)
	Global $btnSelExe  = GUICtrlCreateButton("...", 293, 62, 22, 22)
	Global $chkDefP    = GUICtrlCreateCheckbox("  Print to Default Printer is Checked",  15, 88, 200, 20)
	If $pDrwDef == "False" Then
		GUICtrlSetState($chkDefP, 0)
	Else
		GUICtrlSetState($chkDefP, 1)
	EndIf

	Global $saveConfig = _GUIBuildButton(205, 120, 100, 30, "Save Config" , "Save Configuration", 3, 6, 16)

	;Add in the Events
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ExitConfig", $g_hConfig)
	GUICtrlSetOnEvent($btnSelExe,  "btnSelExe")
	GUICtrlSetOnEvent($saveConfig, "configSave")

	;Show the Dialog
	GUISetState(@SW_SHOW, $g_hConfig)
EndFunc

#Region MainFunctions

Func btnOutput()
	$inp = FileSelectFolder("Select the Output Folder...", "", 0, "", $g_hBase)
	GUICtrlSetData($outputTxt, $inp)
EndFunc

Func progressUpdate($percent)
	GUICtrlSetData($progStatus, $percent)
EndFunc

Func ControlHideShow($status)
	If $status = "begin" Then
		GUICtrlSetState($btnStartProcess, $GUI_HIDE)
		GUICtrlSetState($configPrint, $GUI_HIDE)
		GUICtrlSetState($progStatus, $GUI_SHOW)

	Else
		GUICtrlSetState($btnStartProcess, $GUI_SHOW)
		GUICtrlSetState($configPrint, $GUI_SHOW)
		GUICtrlSetState($progStatus, $GUI_HIDE)
	EndIf
EndFunc

Func _test()

	ControlHideShow("begin")

	For $iFile = 1 to 10
		_DebugWrite("File " & $iFile)
		progressUpdate($iFile/10 * 100)
		Sleep(500)
	Next

	ControlHideShow("end")
EndFunc

Func _DebugWrite($line, $space = False)
	If $line <> "" Then	$line = @HOUR & ":" & @MIN & ":" & @SEC & " - " & $line

	If GUICtrlRead($txtProgress) = "" Then
		GUICtrlSetData($txtProgress, $line)
	Else
		If $space Then
			GUICtrlSetData($txtProgress, GUICtrlRead($txtProgress) & @CRLF & @CRLF & $line)
		Else
			GUICtrlSetData($txtProgress, GUICtrlRead($txtProgress) & @CRLF & $line)
		EndIf
	EndIf

	_GUICtrlEdit_Scroll($txtProgress, 4) ;1 - $SB_CARETPOS
EndFunc

Func _Exit()
	Exit
EndFunc

#EndRegion MainFunctions

#Region ConfigFunctions

Func btnSelExe()
	$inp = FileOpenDialog("Select the Print Drawing Application...", "", "Print Drawings (*.exe)", 1, "", $g_hConfig)
	GUICtrlSetData($txtPDEXE, $inp)
EndFunc

Func configSave()

	;Validate the data
	If GUICtrlRead($txtCSIUser) = "" Then
		Msgbox($MB_ICONWARNING, "Config Validation", "Please Enter the Username used in CSI Syteline")
		Return
	EndIf

	If GUICtrlRead($txtCSIDB) = "" Then
		Msgbox($MB_ICONWARNING, "Config Validation", "Please Enter the CSI Syteline DB Name")
		Return
	EndIf

	If GUICtrlRead($txtPDEXE) == "" Then
		Msgbox($MB_ICONWARNING, "Config Validation", "Please select the Print Drawings.exe file")
		Return
	EndIf

	If Not FileExists(GUICtrlRead($txtPDEXE)) Then
		Msgbox($MB_ICONWARNING, "Config Validation", "The selected Print Drawing.exe file could not be found")
		Return
	EndIf

	IniWrite($configFile, "CSI", "Username", GUICtrlRead($txtCSIUser))
	IniWrite($configFile, "CSI", "Database",  GUICtrlRead($txtCSIDB))
	IniWrite($configFile, "PrintDraw", "Exe",  GUICtrlRead($txtPDEXE))

	If GUICtrlRead($chkDefP) = $GUI_CHECKED Then
		IniWrite($configFile, "PrintDraw", "DefaultPrint", "True")
	Else
		IniWrite($configFile, "PrintDraw", "DefaultPrint", "False")
	EndIf

	Msgbox($MB_ICONINFORMATION, "Config Saved", "The Configurations have been updated sucessfully.", 0, $g_hConfig)
EndFunc

Func _ExitConfig()
   GUIDelete($g_hConfig)
EndFunc

#EndRegion