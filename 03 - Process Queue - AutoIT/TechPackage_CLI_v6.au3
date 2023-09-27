#pragma compile(Out, TDP_CLI.exe)
#pragma compile(icon, folder_document.ico)
#pragma compile(FileDescription, 'MAAG - Technical Data Package')
#pragma compile(FileVersion, 6.1.0.0)
#pragma compile(CompanyName, 'AXISCADES Technologies Pvt. Ltd.')
#pragma compile(LegalCopyright, '© AXISCADES, 2022')
#pragma compile(LegalTrademarks, 'Built by SudeepJD')

Global Const $TEMPDIR = @ScriptDir & "\resources\Tmp"
Global Const $CONFIG = @ScriptDir & "\resources\config.ini"

#include <Array.au3>
#include <File.au3>
#include "Json.au3"
#include "SyteLine.au3"

OnAutoItExitRegister("_Cleanup")

;SuperGlobals
$pullDrawings = IniRead($CONFIG, "ProcessQueue", "PullDraw", "Yes")
Global Const $PROJSTOR = IniRead($CONFIG, "ProcessQueue", "ProjFol", "")

;Set up logging
Global $LOGHNDL = -1
If @Compiled Then
	$LOGHNDL = FileOpen(@ScriptDir & "\resources\log.txt", 1) ;$FO_APPEND (1)
	If $CmdLine[0] == 0 Then
		ConsoleWriteError("No Project Number Provided")
		Exit
	EndIf
	$projNum = $CmdLine[1]
Else
	$projNum = "S007353943" ;"51897"; "11900369" ;"12030021" ;"11800556" ;12005169; S007331044
EndIf

If $projNum = "-ver" Then 
	ConsoleWrite("MAAG - Technical Data Package" & @CRLF)
	ConsoleWrite("v6.0.0" & @CRLF)
	ConsoleWrite("Built by SudeepJD" & @CRLF)
	ConsoleWrite("AXISCADES Technologies Pvt. Ltd." & @CRLF)
	Exit
EndIf

;Add in the project folder to fix an issue of print drawing crashing of the folder does not exist
;I dont know how this helps, but Don says this fixes it.
DirCreate($PROJSTOR & "\" & $projNum)

FileDelete($TEMPDIR & "\error.txt")

_DebugWrite("Starting Project " & $projNum)

;Create the Final Project Folder
Global $PROJDIR = $TEMPDIR & "\" & $projNum

;Connect to the Database
$oConnection = openDBConnection()
If @error > 0 Then
	_DebugWrite($oConnection)
	FileWrite($TEMPDIR & "\error.txt", "Could not connect to the database")
	_DebugWrite($oConnection)
	TrayTip("TechData Package", $oConnection & ", Exiting.", 5, 3)
	Sleep(5000)
	Exit
EndIf

_DebugWrite("Database Connected")

;Get the jobnumbers under the project
Local $jobNumbers = getJobNum($projNum)
If $jobNumbers = False Then
	closeDBConnection()
	_DebugWrite("No Job numbers")
	TrayTip("TechDoc Package", "No Job Numbers", 5, 3)
	FileWrite($TEMPDIR & "\error.txt", "Project does not exist in Syteline")
	ConsoleWriteError("Project does not exist in Syteline")
	Sleep(5000)
	Exit
EndIf

;If print_Drawings was open from a previous run kill it before we start
If ProcessExists("Print Drawings.exe") Then
	$cnt = 0
	While ProcessExists("Print Drawings.exe") And $cnt<10
		ProcessClose("Print Drawings.exe")
		$cnt = $cnt + 1
	WEnd
	
	If $cnt>9 Then
		_DebugWrite("Print Drawings.exe is open, could not close it.")
		FileWrite($TEMPDIR & "\error.txt", "Could not close Print Drawings")
		Exit
	EndIf
EndIf

;Trigger the Drawing Download Script in Parallel to pulling the data
If $pullDrawings = "Yes" Then
	If FileExists(@ScriptDir & "\resources\PrintDrawings\Tmp\complete.txt") Then
		FileDelete(@ScriptDir & "\resources\PrintDrawings\Tmp\*.*")
	EndIf
	
	;If the Drawing Exists copy them into the PrintDrawings Tmp.
	; So when the project print runs, it will exclude these drawings as they already exist
	If FileExists($PROJSTOR & "\" & $projNum &  "\Drawings") Then
		_DebugWrite("Copying Drawings...")
		FileCopy($PROJSTOR & "\" & $projNum &  "\Drawings\*.*", @ScriptDir & "\resources\PrintDrawings\Tmp", 1)
	EndIf
	ShellExecute(@ScriptDir & "\resources\PrintDrawings\Print Drawings.exe", "project " & $projNum)
	
	;Recreate the project directory if it exists
	DirRemove($PROJDIR, 1)
	prepFolder($PROJDIR)
Else
	
	If FileExists($PROJDIR & "\Drawings") Then
		DirCopy($PROJDIR & "\Drawings", $TEMPDIR & "\Drawings_" & $projNum)
		DirRemove($PROJDIR, 1)
		prepFolder($PROJDIR)
		DirMove($TEMPDIR & "\Drawings_" & $projNum, $PROJDIR & "\Drawings")
		
		;If we are not pulling Drawings and the drawings have been previously pulled them we copy them into the Drawings Directory so we don't lose them when the folder is overwritten
		If FileExists($PROJSTOR & "\" & $projNum &  "\Drawings") Then
			FileCopy($PROJSTOR & "\" & $projNum &  "\Drawings\*.pdf", $PROJDIR & "\Drawings", 1)
		EndIf
	Else
		prepFolder($PROJDIR)
	EndIf
EndIf

;Get the reports, check for errors, proceed accordingly.
$ret = getReports($projNum, $jobNumbers)
If @error>0 Then 
	FileWrite($TEMPDIR & "\error.txt", $ret)
	ConsoleWriteError("Syteline Report Errors")
	TrayTip("TechData Package", "Syteline Report has errors, Exiting.", 5, 3)
	Sleep(5000)
	
	;Kill Print Drawings if opened
	If $pullDrawings = "Yes" And ProcessExists("Print Drawings.exe") Then ProcessClose("Print Drawings.exe")

	Exit
EndIf

;Process the Lists
processCutList()

_DebugWrite("Copying Reports to Folders...")
$aWC = getWorkCenters($projNum)
For $i = 0 to Ubound($aWC)-1
	$aWCTmp = StringSplit($aWC[$i], "-", 2)
	$aWC[$i] = $aWCTmp[0]
Next
Local $rNames[8] = ["CUST", "FAB", "MGI", "MGF", "OUTI", "OUTF", "PICK", "ORDV"]
_ArrayAdd($rNames, $aWC)
For $r = 0 to Ubound($rNames)-1
	$fileList = _FileListToArray($PROJDIR, "*-" & $rNames[$r] & ".pdf")
	If @error == 0 Then
		prepFolder($PROJDIR & "\" & $rNames[$r])
		For $i = 0 to Ubound($fileList)-1
			FileMove($PROJDIR & "\" & $fileList[$i], $PROJDIR & "\" & $rNames[$r] & "\" & StringReplace($fileList[$i], "-" & $rNames[$r], ""))
		Next
	EndIf
Next

;Combine the FAB reports to single PDFs
Local $rNames[2] = ["MGF", "OUTF"]
For $r = 0 to Ubound($rNames)-1
	If FileExists($PROJDIR & "\" & $rNames[$r]) Then
		$fileList = _FileListToArray($PROJDIR & "\" & $rNames[$r], "*.pdf")	
		If @error == 0 Then
			For $i = 1 to $fileList[0]
				$s = StringSplit($fileList[$i], "-", 2)
				$fileList[$i] = $s[0]
			Next
			_ArrayDelete($fileList, 0)
			
			;Combine the Files
			$fileList = _ArrayUnique($fileList)
			For $j = 0 to $fileList[0]
				$params = '"' & $PROJDIR & '\' & $rNames[$r] & '\' & $fileList[$j] & '-*.pdf" cat output "' & $PROJDIR & '\' & $rNames[$r] & '\' & $fileList[$j] & '.pdf"'
				ShellExecuteWait(@ScriptDir & "\resources\pdftk.exe", $params, "", "", @SW_HIDE)
			Next
			
			;Delete the parts
			FileDelete($PROJDIR & "\" & $rNames[$r] & "\*-*.pdf")
		EndIf
	EndIf
Next

;Order Verification Report
If FileExists($PROJDIR & "\ORDV.pdf") Then
	prepFolder($PROJDIR & "\ORDV")
	FileMove($PROJDIR & "\ORDV.pdf", $PROJDIR & "\ORDV\ORDV.pdf")
EndIf

createJSON($projNum, $jobNumbers)

closeDBConnection()

;Create the FILES directory and copy from PROJSTOR if files exist
DirCreate($PROJDIR & "\FILES")
If FileExists($PROJSTOR & "\" & $projNum &  "\FILES") Then
	FileCopy($PROJSTOR & "\" & $projNum &  "\FILES\*.pdf", $PROJDIR & "\FILES", 1)
EndIf

;Process the Drawings
DirCreate($PROJDIR & "\Drawings")

If $pullDrawings = "Yes" Then 
	;Wait for the Download process the Complete, restart if crashes
	_DebugWrite("Waiting for PrintDrawing to Complete")
	$nRestarts = 0
	While Not FileExists(@ScriptDir & "\resources\PrintDrawings\Tmp\complete.txt") And $nRestarts < 5
		$nRCount = 0
		While ProcessExists("Print Drawings.exe") 
			Sleep(1000)
			
			;Check if the app is not responding
			$hWnd = WinGetHandle("Print Drawings")
			$aCall = DllCall('user32.dll', 'bool', 'IsHungAppWindow', 'hwnd', $hWnd)
			If @error == 0 Then
				If $aCall[0] == 1 Then 
					$nRCount = $nRCount + 1
					If $nRCount > 60 Then ProcessClose("Print Drawings.exe")
				Else
					$nRCount = 0
				EndIf
			Else			
				$nRCount = 0
			EndIf
			
			;Sometimes Print Drawings stays open.. We need to kill it
			If FileExists(@ScriptDir & "\resources\PrintDrawings\Tmp\complete.txt") Then
				While ProcessExists("Print Drawings.exe") 
					ProcessClose("Print Drawings.exe")
				WEnd
			EndIf
		WEnd
		_DebugWrite("Print Drawing Closed" & $nRestarts)
		
		;If it is not complete, the the app has crashed, restart it.
		If Not FileExists(@ScriptDir & "\resources\PrintDrawings\Tmp\complete.txt") Then
			_DebugWrite("Print Drawing Crashed")
			ShellExecute(@ScriptDir & "\resources\PrintDrawings\Print Drawings.exe", "project " & $projNum)
			$nRestarts = $nRestarts + 1
			Sleep(5000)
		Else
			$nRestarts = 10 ;This will exit the loop
		EndIf
	WEnd
	
	If Not FileExists(@ScriptDir & "\resources\PrintDrawings\Tmp\complete.txt") Then
		FileWrite($PROJDIR & "\Drawings\DRWCRASH.txt", "")
	EndIf
	
	FileCopy(@ScriptDir & "\resources\PrintDrawings\Tmp\*.pdf", $PROJDIR & "\Drawings")
	FileDelete(@ScriptDir & "\resources\PrintDrawings\Tmp\*.*")
Else
	FileWrite($PROJDIR & "\Drawings\NODRWPULL.txt", "")
EndIf

;Everything should be done by now...Check if Print_Drawings is still open and kill it
While ProcessExists("Print Drawings.exe") 
	ProcessClose("Print Drawings.exe")
WEnd

FileWrite($PROJDIR & "\complete.txt", "Process Complete")

Func getReports($projNum, $jobNumbers)
	
	_DebugWrite("Building Tasks for Syteline...")
	Local $bgTasks[0]
	
	If p_or_j($projNum) == "p" Then $projNum = StringFormat("%10s", $projNum)
	
	;Cut List Report
	$clTmp = getCutListData($projNum)
	If IsArray($clTmp) Then
		$ind = addBGTask($bgTasks)
		If p_or_j($projNum) == "j" Then
			$taskParms = "SETVARVALUES(JobStarting=~LIT~(" & $projNum & "),JobEnding=~LIT~(" & $projNum & "),SuffixStarting=~LIT~(0),SuffixEnding=~LIT~(9999),WCStarting=~LIT~(),WCEnding=~LIT~(),CoNum=~LIT~(),CoLine=~LIT~(),JobStatus=~LIT~(F)~LIT~(R)~LIT~(S)~LIT~(C)~LIT~(-),EngDept=~LIT~(A),Language=EN)"
		Else
			$taskParms = "SETVARVALUES(JobStarting=~LIT~(),JobEnding=~LIT~(),SuffixStarting=~LIT~(0),SuffixEnding=~LIT~(9999),WCStarting=~LIT~(),WCEnding=~LIT~(),CoNum=~LIT~(" & $projNum & "),CoLine=~LIT~(),JobStatus=~LIT~(F)~LIT~(R)~LIT~(S)~LIT~(C)~LIT~(-),EngDept=~LIT~(A),Language=EN)"
		EndIf
		$bgTasks[$ind].Item('TaskName') = "CUT"
		Local $tP[3] = ["GICutListReport", "Gala_CutListReportViewer", $taskParms]
		$bgTasks[$ind].Item('TaskParams') = $tP
	EndIf
		
	;Cust BOM Report
	$fJobs = getJobListData($projNum, "", 1, "Jobs")
	For $jCnt = 0 to Ubound($fJobs)-1
		$ind = addBGTask($bgTasks)
		$taskParms = "SETVARVALUES(CoNum=~LIT~(),CoLine=~LIT~(),JobStarting=~LIT~(" & $fJobs[$jCnt] & "),JobEnding=~LIT~(" & $fJobs[$jCnt] & "),SuffixStarting=~LIT~(0),SuffixEnding=~LIT~(9999),ItemStarting=~LIT~(),ItemEnding=~LIT~(),OperationStarting=~LIT~(),OperationEnding=~LIT~(),GIWCStarting=~LIT~(),GIWCEnding=~LIT~(),ParmJobStatus=,EngDept=~LIT~(A),PageBetweenOperations=~LIT~(1),OperationListingPrintInternal=~LIT~(0),OperationListingPrintExternal=~LIT~(1),LowestLevel=~LIT~(1),IncludeTopLvl=~LIT~(1))"
		$bgTasks[$ind].Item('TaskName') = $fJobs[$jCnt] & "-CUST"
		Local $tp[3] = ["GIGalaJobOperationListingReport", "Gala_JobOperationListingReportViewer", $taskParms]
		$bgTasks[$ind].Item('TaskParams') = $tp
		;$bgTasks[$ind].Item('TaskNumber') = submitReportTask($user, "GIGalaJobOperationListingReport", "Gala_JobOperationListingReportViewer", $taskParms)
	Next
	
	;Fab Reports
	For $jCnt = 0 to Ubound($jobNumbers)-1
		$jobNum = $jobNumbers[$jCnt][0]
		$jTmp = getFabListData($jobNum)
		If IsArray($jTmp) Then
			$ind = addBGTask($bgTasks)
			$taskParms = "SETVARVALUES(JobStarting=~LIT~(" & $jobNum & "),JobEnding=~LIT~(" & $jobNum & "),SuffixStarting=~LIT~(0),SuffixEnding=~LIT~(9999),WCStarting=~LIT~(),WCEnding=~LIT~(),CoNum=~LIT~(),CoLine=~LIT~(),JobStatus=~LIT~(F)~LIT~(R)~LIT~(S)~LIT~(C)~LIT~(-),EngDept=~LIT~(A),Language=EN)"
			$bgTasks[$ind].Item('TaskName') = $jobNum & "-FAB"
			Local $tp[3] = ["GIFabListReport", "Gala_FabricationListReportViewer", $taskParms]
			$bgTasks[$ind].Item('TaskParams') = $tp
		EndIf
	Next
	
	;Get the WC for which we need to pull the data
	$aWC = getWorkCenters($projNum)
	For $wcCnt = 0 to Ubound($aWC)-1
		$wcName = StringSplit($aWC[$wcCnt], "-", 2)
		$wcName = $wcName[0]
		$fJobs = getJobListData($projNum, $aWC[$wcCnt] , 2, "Jobs")
		For $jCnt = 0 to Ubound($fJobs)-1
			$ind = addBGTask($bgTasks)
			$taskParms = "SETVARVALUES(CoNum=~LIT~(),CoLine=~LIT~(),JobStarting=~LIT~(" & $fJobs[$jCnt] & "),JobEnding=~LIT~(" & $fJobs[$jCnt] & "),SuffixStarting=~LIT~(0),SuffixEnding=~LIT~(9999),ItemStarting=~LIT~(),ItemEnding=~LIT~(),OperationStarting=~LIT~(),OperationEnding=~LIT~(),GIWCStarting=~LIT~(" & $aWC[$wcCnt] & "),GIWCEnding=~LIT~(" & $aWC[$wcCnt] & "),ParmJobStatus=,EngDept=~LIT~(A),PageBetweenOperations=~LIT~(1),OperationListingPrintInternal=~LIT~(0),OperationListingPrintExternal=~LIT~(1),LowestLevel=~LIT~(2),IncludeTopLvl=~LIT~(1))"
			$bgTasks[$ind].Item('TaskName') = $fJobs[$jCnt] & "-" & $wcName
			Local $tp[3] = ["GIGalaJobOperationListingReport", "Gala_JobOperationListingReportViewer", $taskParms]
			$bgTasks[$ind].Item('TaskParams') = $tp
		Next
	Next
	
	;Material Gathering Inv
	$fJobs = getJobListData($projNum, "MG-99", 1, "Jobs")
	For $jCnt = 0 to Ubound($fJobs)-1
		$ind = addBGTask($bgTasks)
		$bgTasks[$ind].Item('TaskName') = $fJobs[$jCnt] & "-MGI"
		$taskParms = "SETVARVALUES(CoNum=~LIT~(),CoLine=~LIT~(),JobStarting=~LIT~(" & $fJobs[$jCnt] & "),JobEnding=~LIT~(" & $fJobs[$jCnt] & "),SuffixStarting=~LIT~(0),SuffixEnding=~LIT~(9999),ItemStarting=~LIT~(),ItemEnding=~LIT~(),OperationStarting=~LIT~(),OperationEnding=~LIT~(),GIWCStarting=~LIT~(MG-99),GIWCEnding=~LIT~(MG-99),ParmJobStatus=,EngDept=~LIT~(A),PageBetweenOperations=~LIT~(1),OperationListingPrintInternal=~LIT~(0),OperationListingPrintExternal=~LIT~(1),LowestLevel=~LIT~(1),IncludeTopLvl=~LIT~(1))"
		Local $tp[3] = ["GIGalaJobOperationListingReport", "Gala_JobOperationListingReportViewer", $taskParms]
		$bgTasks[$ind].Item('TaskParams') = $tp
	Next
	
	;Material Gathering Fab
	$fJobs = getJobListData($projNum, "MG-99", 3, "Jobs", 1)
	For $jCnt = 0 to Ubound($fJobs)-1
		$ind = addBGTask($bgTasks)
		$s = StringSplit($fJobs[$jCnt], "-", 2)
		$bgTasks[$ind].Item('TaskName') = $fJobs[$jCnt] & "-MGF"
		$taskParms = "SETVARVALUES(CoNum=~LIT~(),CoLine=~LIT~(),JobStarting=~LIT~(" & $s[0] & "),JobEnding=~LIT~(" & $s[0] & "),SuffixStarting=~LIT~(" & $s[1] & "),SuffixEnding=~LIT~(" & $s[1] & "),ItemStarting=~LIT~(),ItemEnding=~LIT~(),OperationStarting=~LIT~(),OperationEnding=~LIT~(),GIWCStarting=~LIT~(MG-99),GIWCEnding=~LIT~(MG-99),ParmJobStatus=,EngDept=~LIT~(A),PageBetweenOperations=~LIT~(1),OperationListingPrintInternal=~LIT~(0),OperationListingPrintExternal=~LIT~(1),LowestLevel=~LIT~(3),IncludeTopLvl=~LIT~(1))"
		Local $tp[3] = ["GIGalaJobOperationListingReport", "Gala_JobOperationListingReportViewer", $taskParms]
		$bgTasks[$ind].Item('TaskParams') = $tp
	Next
	
	;Outside Process Inv
	$fJobs = getJobListData($projNum, "OUT-99", 1, "Jobs")
	For $jCnt = 0 to Ubound($fJobs)-1
		$ind = addBGTask($bgTasks)
		$bgTasks[$ind].Item('TaskName') = $fJobs[$jCnt] & "-OUTI"
		$taskParms = "SETVARVALUES(CoNum=~LIT~(),CoLine=~LIT~(),JobStarting=~LIT~(" & $fJobs[$jCnt] & "),JobEnding=~LIT~(" & $fJobs[$jCnt] & "),SuffixStarting=~LIT~(0),SuffixEnding=~LIT~(9999),ItemStarting=~LIT~(),ItemEnding=~LIT~(),OperationStarting=~LIT~(),OperationEnding=~LIT~(),GIWCStarting=~LIT~(OUT-99),GIWCEnding=~LIT~(OUT-99),ParmJobStatus=,EngDept=~LIT~(A),PageBetweenOperations=~LIT~(1),OperationListingPrintInternal=~LIT~(0),OperationListingPrintExternal=~LIT~(1),LowestLevel=~LIT~(1),IncludeTopLvl=~LIT~(1))"
		Local $tp[3] = ["GIGalaJobOperationListingReport", "Gala_JobOperationListingReportViewer", $taskParms]
		$bgTasks[$ind].Item('TaskParams') = $tp
	Next
	
	;Outside Process Fab
	$fJobs = getJobListData($projNum, "OUT-99", 3, "Jobs", 1)
	For $jCnt = 0 to Ubound($fJobs)-1
		$ind = addBGTask($bgTasks)
		$s = StringSplit($fJobs[$jCnt], "-", 2)
		$bgTasks[$ind].Item('TaskName') = $fJobs[$jCnt] & "-OUTF"
		$taskParms = "SETVARVALUES(CoNum=~LIT~(),CoLine=~LIT~(),JobStarting=~LIT~(" & $s[0] & "),JobEnding=~LIT~(" & $s[0] & "),SuffixStarting=~LIT~(" & $s[1] & "),SuffixEnding=~LIT~(" & $s[1] & "),ItemStarting=~LIT~(),ItemEnding=~LIT~(),OperationStarting=~LIT~(),OperationEnding=~LIT~(),GIWCStarting=~LIT~(OUT-99),GIWCEnding=~LIT~(OUT-99),ParmJobStatus=,EngDept=~LIT~(A),PageBetweenOperations=~LIT~(1),OperationListingPrintInternal=~LIT~(0),OperationListingPrintExternal=~LIT~(1),LowestLevel=~LIT~(3),IncludeTopLvl=~LIT~(1))"
		Local $tp[3] = ["GIGalaJobOperationListingReport", "Gala_JobOperationListingReportViewer", $taskParms]
		$bgTasks[$ind].Item('TaskParams') = $tp
	Next
	
	;Material Pick List
	$fJobs = getPickList($projNum, "Jobs")
	For $jCnt = 0 to Ubound($fJobs)-1
		$jobNum = $fJobs[$jCnt]
		$ind = addBGTask($bgTasks)
		$bgTasks[$ind].Item('TaskName') = $jobNum & "-PICK"
		$taskParms = "SETVARVALUES(StartJob=~LIT~(" & $jobNum & "),EndJob=~LIT~(" & $jobNum & "),StartSuffix=~LIT~(0),EndSuffix=~LIT~(9999),JobStat=~LIT~(F)~LIT~(R)~LIT~(S)~LIT~(C)~LIT~(-),StartItem=~LIT~(),EndItem=~LIT~(),StartProdMix=,EndProdMix=,StartJobDate=,EndJobDate=,StartOpera=~LIT~(),EndOpera=~LIT~(),MatlLst132=~LIT~(0),MatlLstDate=~LIT~(0),PickByLoc=~LIT~(1),PrintSN=~LIT~(0),PrintBCFmt=~LIT~(0),PageOpera=~LIT~(1),PrintSecLoc=~LIT~(0),ExtScrapFact=~LIT~(0),ReprintPick=~LIT~(A),DisplayRefFields=~LIT~(0),StartJobDateOffset=,EndJobDateOffset=,DisplayHeader=~LIT~(0),GIWCStarting=~LIT~(),GIWCEnding=~LIT~(),GIStockBack=~LIT~(1),GIStartingCoNum=~LIT~(),GIEndingCoNum=~LIT~(),GIStartingCoLine=~LIT~(),GIEndingCoLine=~LIT~(),GIMPLBOMLevel=~LIT~(3),BGSessionID=,pSite=~LIT~(ER),GISendVidmarOrder=~LIT~(0))"
		Local $tp[3] = ["GIJobMaterialPickListReport80", "JobMaterialPickList80ReportViewer", $taskParms]
		$bgTasks[$ind].Item('TaskParams') = $tp
	Next
	
	;For S jobs get the Order Verification Report
	If StringLeft($projNum, 1) == "S" Then
		$ind = addBGTask($bgTasks)
		$bgTasks[$ind].Item('TaskName') = "ORDV"
		$taskParms = "SETVARVALUES(CoTypeRegular=~LIT~(1),CoTypeBlanket=~LIT~(1), CoStatus=~LIT~(P)~LIT~(O),CoLineReleaseStat=~LIT~(P)~LIT~(O)~LIT~(F)~LIT~(C), PrintItemCustItem=~LIT~(IC),PrintOrderText=~LIT~(1),PrintStandardOrderText=~LIT~(1),PrintCompanyName=~LIT~(1),DisplayDate=~LIT~(D),DateToAppear=~LIT~ (" & @YEAR & "-" & @MON & "-" & @MDAY & " 00:00:00.00),DateToAppearOffset=,PrintBlanketLineText=~LIT~(1),PrintBlanketLineDes=~LIT~(1), PrintLineReleaseNotes=~LIT~(1),PrintLineReleaseDes=~LIT~(1),PrintShipToNotes=~LIT~(1), printBillToNotes=~LIT~(1),PrintPlanningItemMaterials=~LIT~(0),IncludeSerialNumbers=~LIT~(1),PrintEuroValue=~LIT~(0),PrintPrice=~LIT~(1),Sortby=~LIT~(C),OrderStarting=~LIT~(" & $projNum & "),OrderEnding=~LIT~(" & $projNum & "),SalespersonStarting=,SalespersonEnding=,OrderLineStarting=~LIT~(), OrderReleaseStarting=~LIT~(),OrderLineEnding=~LIT~(),OrderReleaseEnding=~LIT~(), PrintInternalNotes=~LIT~(0),PrintExternalNotes=~LIT~(1),PrintItemOverview=~LIT~(0), DisplayHeader=~LIT~(0),ConfigDetails=~LIT~(E),BG_TASKID=BG~TASKID~,PrintDrawingNumber=~LIT~(0),PrintTax=~LIT~(0), PrintDeliveryIncoTerms=~LIT~(0),PrintEUCode=~LIT~(0),PrintCommodityCode=~LIT~(0), PrintOriginCode=~LIT~(0),PrintCurrencyCode=~LIT~(0),PrintHeaderOnAllPages=~LIT~(0),PrintEndUserItem=~LIT~(0),pSite=~LIT~(ER))"
		Local $tp[3] = ["OrderVerificationReport", "OrderVerificationReportViewer", $taskParms]
		$bgTasks[$ind].Item('TaskParams') = $tp
	EndIf
	
	;Submit and start tasks
	_DebugWrite("Submitting Tasks to Syteline...")
	For $jCnt = 0 to Ubound($bgTasks)-1
		$tp = $bgTasks[$jCnt].Item('TaskParams')
		$bgTasks[$jCnt].Item('TaskNumber') = submitReportTask($user, $tp[0], $tp[1], $tp[2])
	Next
	
	waitForReports($bgTasks)
	
	$err = checkReportError($bgTasks)
	If $err <> "" Then Return SetError(1, 0, $err)
		
	downloadReports($bgTasks, $PROJDIR)
	Return SetError(0, 0, "")
EndFunc

Func processCutList()
	
	If Not FileExists($PROJDIR & "\CUT.pdf") Then Return
	
	_DebugWrite("Processing the CutList...")
	prepFolder($PROJDIR & "\CutList_tmp")
	$parms = '"' & $PROJDIR & '\CUT.pdf" burst output "' & $PROJDIR & '\CutList_tmp\CutList-%02d.pdf"'
	ShellExecuteWait(@ScriptDir & "\resources\pdftk.exe", $parms, "", "", @SW_HIDE)
	FileDelete($PROJDIR & "\CutList_tmp\*.txt")
	
	;Get the WorkCenters in the split files and rename the PDF Files
	$fileList = _FileListToArray($PROJDIR & "\CutList_tmp", "*.pdf")
	For $i = 1 to $fileList[0]
	   $parms = '-layout "' & $PROJDIR & '\CutList_tmp\' & $fileList[$i] & '" "' & $PROJDIR & '\CutList_tmp\out.txt"'
	   ShellExecuteWait(@ScriptDir & "\resources\pdftotext.exe", $parms, "", "", @SW_HIDE)
	   $fileLines = FileReadToArray($PROJDIR & "\CutList_tmp\out.txt")
	   $index = _ArraySearch($fileLines, "Work Center:", 0, 0, 0, 1)
	   If $index>-1 Then
		  $wc = StringStripWS($fileLines[$index], 7)
		  $wc = StringSplit($wc, " ")
		  $wc = $wc[3]
		  FileMove($PROJDIR & "\CutList_tmp\" & $fileList[$i], $PROJDIR & "\CutList_tmp\" & $wc & "_" & $fileList[$i])
	   EndIf
	Next
	FileDelete($PROJDIR & "\CutList_tmp\out.txt")
	
	;Combine them together based on the Operation
	$wcList = _FileListToArray($PROJDIR & "\CutList_tmp", "*.pdf")
	For $i = 1 to $wcList[0]
		$wcArr = StringSplit($wcList[$i], "-", 2)
		$wcList[$i] = $wcArr[0]
	Next
	$wcList = _ArrayUnique($wcList, 0, 1)
	
	$outFolder = $PROJDIR & "\CUT"
	prepFolder($outFolder)
	For $i = 1 to $wcList[0]
		$params = '"' & $PROJDIR & '\CutList_tmp\' & $wcList[$i] & '-*.pdf" cat output "' & $outFolder & '\' & $wcList[$i] & '.pdf"'
		ShellExecuteWait(@ScriptDir & "\resources\pdftk.exe", $params, "", "", @SW_HIDE)
	Next
	
	;Delete DOC as it is not required.
	FileDelete($outFolder & "\DOC.pdf")
	
	;Remove the temp directory
	DirRemove($PROJDIR & "\CutList_tmp", 1)
	FileDelete($PROJDIR & "\CUT.pdf")
	
EndFunc

Func createJSON($projNum, $jobNos)
	
	If p_or_j($projNum) == "p" Then $projNum = StringFormat("%10s", $projNum)
	
	_DebugWrite("Fetching Project Name...")
	If p_or_j($projNum) == "p" Then
		$pName = getProjName($projNum)
	Else
		$pName = $jobNos[0][2]
	EndIf
	FileWrite($PROJDIR & "\ProjectName.txt", $pName)
	
	_DebugWrite("Job Numbers...")
	Local $jobArr[Ubound($jobNos)]
	For $i = 0 to Ubound($jobNos)-1
		$jObjTmp = Json_ObjCreate()
		Json_ObjPut($jObjTmp, "Job", StringStripWS($jobNos[$i][0], 3))
		Json_ObjPut($jObjTmp, "State", $jobNos[$i][1])
		Json_ObjPut($jObjTmp, "Name", $jobNos[$i][2])
		$jobArr[$i] = $jObjTmp
	Next
	$jStr = Json_Encode($jobArr, $JSON_PRETTY_PRINT)
	FileWrite($PROJDIR & "\dataJobs.json", $jStr)
	
	Local $listArr[100]
	Local $lCnt = 0
	Local $drwArr[0]
	
	;CutListDrawings
	If FileExists($PROJDIR & "\CUT") Then
		_DebugWrite("Fetching CutList Drawings...")
		$aDraw = getCutListData($projNum)
		Local $tmpArr[Ubound($aDraw)-1]
		
		;Prepare the DrawingTable
		For $i = 1 to Ubound($aDraw)-1
			$jObjTmp = Json_ObjCreate()
			Json_ObjPut($jObjTmp, "DrawNo", $aDraw[$i][0])
			Json_ObjPut($jObjTmp, "DrawTitle", $aDraw[$i][5])
			Json_ObjPut($jObjTmp, "Parent", $aDraw[$i][1])
			Json_ObjPut($jObjTmp, "Job", StringStripWS($aDraw[$i][2], 3))
			Json_ObjPut($jObjTmp, "Suffix", Int($aDraw[$i][3]))
			Json_ObjPut($jObjTmp, "ListStr", "CUT - " & StringStripWS($aDraw[$i][4], 3))
			$tmpArr[$i-1] = $jObjTmp
		Next		
		_ArrayConcatenate($drwArr, $tmpArr)
		
		;CutList
		_DebugWrite("Creating CutList...")
		$files = _FileListToArray($PROJDIR & "\CUT", "*.pdf")
		If @error == 0 Then
			For $i = 1 to $files[0]
				$type = StringReplace($files[$i], ".pdf", "") 
				
				$jObjTmp = Json_ObjCreate()
				Json_ObjPut($jObjTmp, "Type", "CUT")
				Json_ObjPut($jObjTmp, "JobNumber", $type)
				
				$listArr[$lCnt] = $jObjTmp
				$lCnt = $lCnt + 1
			Next
		EndIf
	EndIf
	
	;Fab
	_DebugWrite("Creating Fab List...")
	For $i = 0 to Ubound($jobNos)-1
		$addList = True
		
		If FileExists($PROJDIR & "\FAB\" & StringStripWS($jobNos[$i][0], 3) & ".pdf") Then
			$aDrw = getFabListData(StringStripWS($jobNos[$i][0], 3))
			If IsArray($aDrw) Then
				;Add drawings to the $drwArr
				Local $aTmpF[Ubound($aDrw)-1]
				For $j = 1 to Ubound($aDrw)-1
					$jObjTmp = Json_ObjCreate()
					Json_ObjPut($jObjTmp, "DrawNo", $aDrw[$j][0])
					Json_ObjPut($jObjTmp, "DrawTitle", $aDrw[$j][4])
					Json_ObjPut($jObjTmp, "Parent", $aDrw[$j][1])
					Json_ObjPut($jObjTmp, "Job", StringStripWS($aDrw[$j][2], 3))
					Json_ObjPut($jObjTmp, "Suffix", Int($aDrw[$j][3]))
					Json_ObjPut($jObjTmp, "ListStr", "FAB - " & StringStripWS($aDrw[$j][2], 3))
					$aTmpF[$j-1] = $jObjTmp
				Next
				_ArrayConcatenate($drwArr, $aTmpF)
				
			Else
				;If the job is firm we need to add it, even if there are not drawings
				; For the others, leave it out
				If $jobNos[$i][1] <> "F" Then $addList = False
					
				FileDelete($PROJDIR & "\FAB\" & $jobNos[$i][0] & ".pdf")	
			EndIf
		Else
			$addList = False
		EndIf
		
		If $addList Then
			$jObjTmpFab = Json_ObjCreate()
			Json_ObjPut($jObjTmpFab, "Type", "FAB")
			Json_ObjPut($jObjTmpFab, "JobNumber", StringStripWS($jobNos[$i][0], 3))
			$listArr[$lCnt] = $jObjTmpFab
			$lCnt = $lCnt + 1
		EndIf
	Next
	
	;JobOperation Reports
	Local $bomArrComp[0]
	$aWC = getWorkCenters($projNum)
	Local $rNames[Ubound($aWC)][4]
	For $wCnt = 0 to Ubound($aWC)-1
		$wTmp = StringSplit($aWC[$wCnt], "-", 2)
		$rNames[$wCnt][0] = $wTmp[0]
		$rNames[$wCnt][1] =  $aWC[$wCnt]
		$rNames[$wCnt][2] = 2
		$rNames[$wCnt][3] = Default
	Next
	$wcLen = Ubound($rNames)-1  ;Upto this point are the ones which need the completions BOM items
	
	Local $rNames2[5][4] = [ _
		["MGI", "MG-99", 1, Default], _ 
		["MGF", "MG-99", 3, 1], _ 
		["OUTI", "OUT-99", 1, Default], _
		["OUTF", "OUT-99", 3, 1], _
		["CUST", "", 1, Default] _
	]
	
	_ArrayConcatenate($rNames, $rNames2)
	
	For $i = 0 to Ubound($rNames)-1
		If FileExists($PROJDIR & "\" & $rNames[$i][0]) Then
			
			_DebugWrite("Creating " & $rNames[$i][0] & " List...")
			$files = _FileListToArray($PROJDIR & "\" & $rNames[$i][0], "*.pdf")
			If @error == 0 Then
				For $j = 1 to $files[0]
					$jNum = StringReplace($files[$j], ".pdf", "") 
					
					$jObjTmp = Json_ObjCreate()
					Json_ObjPut($jObjTmp, "Type", $rNames[$i][0])
					Json_ObjPut($jObjTmp, "JobNumber", StringStripWS($jNum, 3))
					
					$listArr[$lCnt] = $jObjTmp
					$lCnt = $lCnt + 1
				Next
			EndIf
			
			$aDrw = getJobListData($projNum, $rNames[$i][1], $rNames[$i][2], Default, $rNames[$i][3])
			Local $aTmp[Ubound($aDrw)]
			Local $aTmp2[Ubound($aDrw)]
			For $j = 0 to Ubound($aDrw)-1
				$jObjTmp = Json_ObjCreate()
				Json_ObjPut($jObjTmp, "DrawNo", $aDrw[$j][0])
				Json_ObjPut($jObjTmp, "DrawTitle", $aDrw[$j][3])
				Json_ObjPut($jObjTmp, "Parent", "")
				Json_ObjPut($jObjTmp, "Job", StringStripWS($aDrw[$j][1], 3))
				Json_ObjPut($jObjTmp, "Suffix", Int($aDrw[$j][2]))
				Json_ObjPut($jObjTmp, "ListStr", $rNames[$i][0] & " - " & StringStripWS($aDrw[$j][1], 3))
				$aTmp[$j] = $jObjTmp
				
				;BOM Array for Completions
				If $i<=$wcLen Then
					$jObjTmp = Json_ObjCreate()
					Json_ObjPut($jObjTmp, "JobNumber", StringStripWS($aDrw[$j][1], 3))
					Json_ObjPut($jObjTmp, "Suffix", Int($aDrw[$j][2]))
					Json_ObjPut($jObjTmp, "Parent", $aDrw[$j][0])
					Json_ObjPut($jObjTmp, "Child", "Complete")
					Json_ObjPut($jObjTmp, "ChildDesc", "")
					Json_ObjPut($jObjTmp, "SeqNo", 999)
					Json_ObjPut($jObjTmp, "Qty", 0)
					Json_ObjPut($jObjTmp, "UM", "")
					Json_ObjPut($jObjTmp, "WC", $rNames[$i][0])
					Json_ObjPut($jObjTmp, "Picklist", False)
					Json_ObjPut($jObjTmp, "PQty", 0)
					$aTmp2[$j] = $jObjTmp
				EndIf
			Next
			_ArrayConcatenate($drwArr, $aTmp)
			If $i<=$wcLen Then _ArrayConcatenate($bomArrComp, $aTmp2)
		EndIf
	Next
	
	;Pick List PDF File List
	For $i = 0 to Ubound($jobNos)-1
		If FileExists($PROJDIR & "\PICK\" & StringStripWS($jobNos[$i][0], 3) & ".pdf") Then
			$jObjTmp = Json_ObjCreate()
			Json_ObjPut($jObjTmp, "Type", "PICK")
			Json_ObjPut($jObjTmp, "JobNumber", StringStripWS($jobNos[$i][0], 3))
			$listArr[$lCnt] = $jObjTmp
			$lCnt = $lCnt + 1
		EndIf
	Next
	
	$aDrw = getPickList($projNum, "Drawings")
	Local $aTmp[Ubound($aDrw)]
	For $i = 0 to Ubound($aDrw)-1
		$jObjTmp = Json_ObjCreate()
		Json_ObjPut($jObjTmp, "DrawNo", $aDrw[$i][0])
		Json_ObjPut($jObjTmp, "DrawTitle", $aDrw[$i][3])
		Json_ObjPut($jObjTmp, "Parent", "")
		Json_ObjPut($jObjTmp, "Job", StringStripWS($aDrw[$i][1], 3))
		Json_ObjPut($jObjTmp, "Suffix", Int($aDrw[$i][2]))
		Json_ObjPut($jObjTmp, "ListStr", "PICK - " & StringStripWS($aDrw[$i][1], 3))
		$aTmp[$i] = $jObjTmp
	Next
	_ArrayConcatenate($drwArr, $aTmp)
	
	;Order Verification File for Spare parts reports
	If FileExists($PROJDIR & "\ORDV\ORDV.pdf") Then
		$jObjTmp = Json_ObjCreate()
		Json_ObjPut($jObjTmp, "Type", "ORDV")
		Json_ObjPut($jObjTmp, "JobNumber", "ORDV")
		$listArr[$lCnt] = $jObjTmp
		$lCnt = $lCnt + 1
	EndIf
	
	;Delete the remaining data
	_ArrayDelete($listArr, $lCnt & "-" & Ubound($listArr)-1)
	
	$jStr = Json_Encode($listArr, $JSON_PRETTY_PRINT)	
	FileWrite($PROJDIR & "\dataList.json", $jStr)
	
	$jStr = Json_Encode($drwArr, $JSON_PRETTY_PRINT)
	FileWrite($PROJDIR & "\dataDrw.json", $jStr)
	
	;Get the BOM list
	_DebugWrite("Fetching BOM...")
	$aDrw = getBOM($projNum)
	$aPick = getPickList($projNum)
	Local $bomArr[Ubound($aDrw)]
	For $j = 0 to Ubound($aDrw)-1
		$jObjTmp = Json_ObjCreate()
		Json_ObjPut($jObjTmp, "JobNumber", StringStripWS($aDrw[$j][0], 3))
		Json_ObjPut($jObjTmp, "Suffix", Int($aDrw[$j][1]))
		Json_ObjPut($jObjTmp, "Parent", $aDrw[$j][2])
		Json_ObjPut($jObjTmp, "Child", $aDrw[$j][3])
		Json_ObjPut($jObjTmp, "ChildDesc", $aDrw[$j][4])
		Json_ObjPut($jObjTmp, "SeqNo", $aDrw[$j][5])
		Json_ObjPut($jObjTmp, "Qty", $aDrw[$j][6])
		Json_ObjPut($jObjTmp, "UM", $aDrw[$j][7])
		Json_ObjPut($jObjTmp, "WC", $aDrw[$j][8])
		Json_ObjPut($jObjTmp, "Picklist", False)
		Json_ObjPut($jObjTmp, "PQty", 0)
		Json_ObjPut($jObjTmp, "PLoc", "")
		
		;Add in the Picklist info
		For $pCnt = 0 to Ubound($aPick)-1
			If StringStripWS($aDrw[$j][0], 3) == StringStripWS($aPick[$pCnt][0], 3) And $aDrw[$j][1] == $aPick[$pCnt][1] And $aDrw[$j][2] == $aPick[$pCnt][2] And $aDrw[$j][3] == $aPick[$pCnt][3] Then
				Json_ObjPut($jObjTmp, "Picklist", True)
				Json_ObjPut($jObjTmp, "PQty", Number($aPick[$pCnt][4]))
				Json_ObjPut($jObjTmp, "PLoc", $aPick[$pCnt][5])
				ExitLoop
			EndIf
		Next
		
		$bomArr[$j] = $jObjTmp
	Next
	
	;Add in the completion
	_ArrayConcatenate($bomArr, $bomArrComp)
	
	$jStr = Json_Encode($bomArr, $JSON_PRETTY_PRINT)
	FileWrite($PROJDIR & "\dataBOM.json", $jStr)
	
EndFunc

Func prepFolder($fol)
   If Not FileExists($fol) Then DirCreate($fol)
   FileDelete($fol & "\*.*")
EndFunc

Func _DebugWrite($text)
	$date = @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
	If $LOGHNDL > -1 Then	FileWriteLine($LOGHNDL, $date & "  " & $text)
	ConsoleWrite($text & @CRLF)
EndFunc

Func _Cleanup()
	If $LOGHNDL > -1 Then	FileClose($LOGHNDL)
EndFunc
	