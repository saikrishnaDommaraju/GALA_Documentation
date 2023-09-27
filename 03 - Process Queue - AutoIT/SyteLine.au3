#include-once
#include <Array.au3>
#include "ADO\ADO.au3"

Global $oConnection
Global $runType  = Null ;Acts as a cache for the p_or_j function
Global $wcCache = Null ;Cache for the work center pull

#CS
$DBNAME = "CSI_EGR"
Global Const $CONFIG = @ScriptDir & "\resources\config.ini"
$oConnection = openDBConnection()
$ret = _ADO_Connection_CommandTimeout($oConnection)
ConsoleWrite($ret)
;$arr = getPickList("1075878")
;_ArrayDisplay($arr)
closeDBConnection()
Exit
#CE

$DBNAME = IniRead($CONFIG, "CSI", "Database", "")
$BUFF_DAYS = IniRead($CONFIG, "CSI", "BuffDays", "3")
$user = IniRead($CONFIG, "CSI", "Username", "")

Func submitReportTask($user, $taskName, $taskExec, $taskParms)
	
	;Check if the task already exists for this user and return back the task ID if it does
	$sql = "SELECT TOP 1 TaskNumber FROM " & $DBNAME & ".dbo.BGTaskHistory_mst WHERE CompletionStatus = 0 AND TaskName='" & $taskName & "' AND TaskParm='" & $taskParms & "' AND RequestingUser = '" & $user & "' AND DATEDIFF(day, SubmissionDate, CAST(GETDATE() AS DATE)) < " & $BUFF_DAYS & " ORDER BY SubmissionDate DESC"
	
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	If IsArray($aRecords) Then	Return $aRecords[1][0]
	
	;Otherwise Submit the entry to the database
	Local $taskParms1, $taskParms2

	_splitTaskParms($taskParms, $taskParms1, $taskParms2)

	;Insert the data to start the batch process
	$sql = 	"INSERT INTO " & $DBNAME & ".dbo.ActiveBGTasks_mst (SiteRef, TaskName, TaskTypeCode, TaskExecutable, TaskDescription, TaskParms1, TaskParms2, TaskParm, RequestingUser, CreatedBy, ReportType, Initiator) " & _
			"VALUES ('ER', '" & $taskName & "', 'RPTPVW', '" & $taskExec & "','', '" & $taskParms1 & "', '" & $taskParms2 & "', '" & $taskParms & "', '" & $user & "', '" & $user & "', 'FORM', 'Form.Gala_JobPacketReports')"
	_ADO_Execute($oConnection, $sql)

	;Wait for the task to move to the BGTasks Table
	Sleep(1000)

	;Get the TaskNumber form the BG Hist Table.
	$sql = "SELECT TOP 1 TaskNumber FROM " & $DBNAME & ".dbo.BGTaskHistory_mst WHERE TaskName='" & $taskName & "' AND TaskParm='" & $taskParms & "' AND RequestingUser = '" & $user & "' ORDER BY SubmissionDate DESC"
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	If IsArray($aRecords) Then	Return $aRecords[1][0]

EndFunc

Func waitForReports(ByRef $bgTasks)
	
	_DebugOut("Waiting for report tasks to complete...")
	
	;Check if all the reports have been completed.
	Local $taskNums = ""
	For $i = 0 To Ubound($bgTasks) -1
		If $bgTasks[$i].Item("TaskNumber") <> "" Then
			If $taskNums = "" Then 
				$taskNums = $bgTasks[$i].Item("TaskNumber")
			Else
				$taskNums = $taskNums &  "," &  $bgTasks[$i].Item("TaskNumber")
			EndIf
		EndIf
	Next
	
	;Loop until CompletionStatus is not null for all tasks
	$sql = "SELECT TaskNumber FROM " & $DBNAME & ".dbo.BGTaskHistory_mst WHERE CompletionStatus IS NULL AND TaskNumber IN (" & $taskNums & ")"
	$isComplete = False
	While Not $isComplete
		Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
		If Not IsArray($aRecords) Then $isComplete=True
			
		Sleep(2000) ;Wait for 2 seconds before we check again.
	WEnd
	
	;Fetch the outputpath or error
	$sql = "SELECT TaskNumber, CompletionStatus, ReportOutputPath  FROM " & $DBNAME & ".dbo.BGTaskHistory_mst WHERE TaskNumber IN (" & $taskNums & ")"
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	If IsArray($aRecords) Then
		For $i = 0 To Ubound($bgTasks) -1
			For $j = 1 to Ubound($aRecords)-1
				If $bgTasks[$i].Item("TaskNumber") == $aRecords[$j][0] Then
					$bgTasks[$i].Item("TaskStatus") = $aRecords[$j][1]
					$bgTasks[$i].Item("TaskReport") = StringStripWS($aRecords[$j][2], 3)
				EndIf
			Next
		Next
	EndIf

EndFunc

Func checkReportError(ByRef $bgTasks)
	$hasErr = False
	
	$errors = "Syteline errors : "
	For $i = 0 To Ubound($bgTasks) -1		
		If $bgTasks[$i].Item("TaskStatus") = -1 Then
			$errors = $errors & $bgTasks[$i].Item("TaskName") & " report failed. "
			$hasErr = True 
		EndIf
	Next
	
	If Not $hasErr Then $errors = "";
	
	Return $errors
EndFunc

Func downloadReports(ByRef $bgTasks, $storPath)
	
	_DebugOut("Fetching Reports...")
	
	Local $report, $downloadLoc

	For $i = 0 To Ubound($bgTasks)-1
		
		$downloadLoc = ""
		$report = $bgTasks[$i].Item('TaskReport')
		If $report <> "" Then
			$report = StringReplace($report, "\", "/")
			$report = StringReplace($report, "C:/Program Files/Infor/CSI", "http://dsvwmagord0006.dover-global.net/ReportPreview")
			$downloadLoc = $storPath & "\" & StringStripWS($bgTasks[$i].Item("TaskName"), 3) & ".pdf"
			InetGet($report, $downloadLoc)
			If @error=0 Then
				$bgTasks[$i].Item('TaskReport') = $downloadLoc
			Else
				$bgTasks[$i].Item('TaskError') = "Download Failed"
			EndIf
		EndIf
	Next
	
	_DebugOut("All Reports Downloaded...")

EndFunc

Func addBGTask(ByRef $bgTasks)

	;Create an Empty Task
	Local $oBGTask = ObjCreate("Scripting.Dictionary")
	$oBGTask.Add("TaskParams", "")
	$oBGTask.Add("TaskNumber", "")
	$oBGTask.Add("TaskName", "")
	$oBGTask.Add("TaskReport", "")
	$oBGTask.Add("TaskStatus", "")
	$oBGTask.Add("TaskError", "")

		
	$index = _ArrayAdd($bgTasks, $oBGTask)

	Return $index
EndFunc

Func getProjectNum($jobNum)
	
	$sql = "SELECT DISTINCT ord_num FROM " & $DBNAME & ".dbo.job_mst WHERE TRIM(job) = '" & StringStripWS($jobNum, 3) & "'";
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	If IsArray($aRecords) Then Return  $aRecords[1][0]
	Return False
	
EndFunc

Func p_or_j($projNo)
	
	If $runType <> Null Then Return $runType
	
	$projNo = StringUpper(StringStripWS($projNo, 3))
	
	$sql = "SELECT TOP 1 TRIM(ord_num) As proj, TRIM(job) AS job FROM " & $DBNAME & ".dbo.job_mst WHERE TRIM(ord_num) = '" & $projNo & "' OR TRIM(job) = '" & $projNo & "'";
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	If IsArray($aRecords) Then 
		If $aRecords[1][0] == $projNo Then
			$runType = "p"
			Return "p"
		ElseIf $aRecords[1][1] == $projNo Then
			$runType = "j"
			Return "j"
		EndIf
	Else
		Return False
	EndIf

EndFunc

Func getJobNum($projNum)
	
	;Do the first check in the program to see if the project or job exists, remaining pulls are cached.
	If p_or_j($projNum) = False Then Return False
	
	If p_or_j($projNum) == "p" Then
		$sql = "SELECT DISTINCT job, stat, description FROM " & $DBNAME & ".dbo.job_mst WHERE TRIM(ord_num) = '" & StringStripWS($projNum, 3) & "' AND suffix=0";
	Else
		$sql = "SELECT DISTINCT job, stat, description FROM " & $DBNAME & ".dbo.job_mst WHERE TRIM(job) = '" & StringStripWS($projNum, 3) & "' AND suffix=0";
	EndIf
	
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	If IsArray($aRecords) Then 
		_ArrayDelete($aRecords, 0)
		Return  $aRecords
	EndIf
	Return False

EndFunc

Func getWorkCenters($projNo)
	
	If $wcCache <> Null Then Return $wcCache
	
	If p_or_j($projNo) == "p" Then
		$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_GalaJobOperationListingSp @CoNum = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, @JobStat = 'FRSCH', @EngineeringDept = N'A', @PageOpera = 1, @ShowInternal = 0, @ShowExternal = 1, @LowestBOMLevel = 1 , @IncludeTopLevel = 1" 
	Else
		$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_GalaJobOperationListingSp @StartJob = '" & $projNo & "', @EndJob = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, @JobStat = 'FRSCH', @EngineeringDept = N'A', @PageOpera = 1, @ShowInternal = 0, @ShowExternal = 1, @LowestBOMLevel = 1 , @IncludeTopLevel = 1" 
	EndIf
	
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	$wcArr_l1 = _ArrayExtract($aRecords, 1, -1, 8, 8)
	_ArrayAdd($wcArr_l1, "OUT-99|MG-99") ;We will process the OUT and MG anyways later
	$wcArr_l1 = _ArrayUnique($wcArr_l1, 0, 0, 0, 0)
	_ArraySort($wcArr_l1)
	
	If p_or_j($projNo) == "p" Then
		$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_GalaJobOperationListingSp @CoNum = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, @JobStat = 'FRSCH', @EngineeringDept = N'A', @PageOpera = 1, @ShowInternal = 0, @ShowExternal = 1, @LowestBOMLevel = 2 , @IncludeTopLevel = 1" 
	Else
		$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_GalaJobOperationListingSp @StartJob = '" & $projNo & "', @EndJob = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, @JobStat = 'FRSCH', @EngineeringDept = N'A', @PageOpera = 1, @ShowInternal = 0, @ShowExternal = 1, @LowestBOMLevel = 2 , @IncludeTopLevel = 1" 
	EndIf
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	$wcArr_l2 = _ArrayExtract($aRecords, 1, -1, 8, 8)
	$wcArr_l2 = _ArrayUnique($wcArr_l2, 0, 0, 0, 0)	
	_ArraySort($wcArr_l2)
	
	Local $wcStr = ""
	$cnt = 0
	For $i = 0 to Ubound($wcArr_l2)-1		
		If _ArrayBinarySearch($wcArr_l1, $wcArr_l2[$i]) = -1 Then $wcStr = $wcStr & "|" & $wcArr_l2[$i]
	Next
	
	;Delete OUT and MG if they exist as they are processed separetly
	$wcStr = StringReplace($wcStr, "|OUT-99", "")
	$wcStr = StringReplace($wcStr, "|MG-99", "")
	
	;Remove Die Plate
	$wcStr = StringRegExpReplace($wcStr, "\|DP-[A-Z]*", "") 
	
	$wcArr = StringSplit($wcStr, "|", 2)
	_ArrayDelete($wcArr, 0)
	
	$wcCache = $wcArr
	Return $wcArr
EndFunc

Func getFabListData($jobNo)
	
	$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_FabricationListSp @StartJob=" & $jobNo & ", @EndJob=" & $jobNo
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	If IsArray($aRecords) Then 
		Local $newArr[Ubound($aRecords)][5]
		For $i = 0 to Ubound($aRecords)-1
			If $i =0 Then
				$newArr[$i][0] = $aRecords[$i][3]
				$newArr[$i][1] = $aRecords[$i][2]
			Else
				$newArr[$i][0] = StringFormat("%07i", $aRecords[$i][3])
				$newArr[$i][1] = StringFormat("%07i", $aRecords[$i][2])
			EndIf
			$newArr[$i][2] = $aRecords[$i][0]
			$newArr[$i][3] = $aRecords[$i][1]
			$newArr[$i][4] = CleanName($aRecords[$i][4])
		Next
		Return  $newArr
	EndIf
	Return False
	
EndFunc

Func getCutListData($projNo)
	
	If p_or_j($projNo) == "p" Then
		$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_CutListSp @StartSuffix = 0, @EndSuffix = 9999, @StartOrdNum = '" & $projNo & "', @EndOrdNum = '" & $projNo & "', @JobStat = N'FRSC-', @EngineeringDept = N'A', @Language = N'EN', @IncludeDwgNo = DEFAULT"
	Else
		$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_CutListSp @StartJob = '" & $projNo & "', @EndJob = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, @JobStat = N'FRSC-', @EngineeringDept = N'A', @Language = N'EN', @IncludeDwgNo = DEFAULT"
	EndIf
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	If IsArray($aRecords) Then
		Local $newArr[Ubound($aRecords)][6]
		For $i = 0 to Ubound($aRecords)-1
			If $i =0 Then
				$newArr[$i][0] = $aRecords[$i][6]
				$newArr[$i][1] = $aRecords[$i][35]
			Else
				$newArr[$i][0] = StringFormat("%07i", $aRecords[$i][6])
				$newArr[$i][1] = StringFormat("%07i", $aRecords[$i][35])
			EndIf
			$newArr[$i][2] = $aRecords[$i][1]
			$newArr[$i][3] = $aRecords[$i][2]
			$newArr[$i][4] = $aRecords[$i][10]
			If StringInStr($aRecords[$i][10], "-") Then
				$wc = StringSplit($aRecords[$i][10], "-", 2)
				$newArr[$i][4] = $wc[0]
			EndIf
			$newArr[$i][5] = CleanName($aRecords[$i][7])
		Next
		
		;Merge the Array to make it Unique
		Local $mArr[Ubound($newArr)]
		For $i = 0 to Ubound($newArr)-1
			$mArr[$i] = $newArr[$i][0] & "|" & $newArr[$i][1] & "|" & $newArr[$i][2] & "|" & $newArr[$i][3] & "|" & $newArr[$i][4] & "|" & $newArr[$i][5]
		Next
		$mArr = _ArrayUnique($mArr, 0, 0, 0, 0)
		
		;Split the array
		Local $new2Arr[Ubound($mArr)][6]
		For $i = 0 to Ubound($mArr)-1
			$tmp = StringSplit($mArr[$i], "|", 2)
			$new2Arr[$i][0] = $tmp[0]
			$new2Arr[$i][1] = $tmp[1]
			$new2Arr[$i][2] = $tmp[2]
			$new2Arr[$i][3] = $tmp[3]
			$new2Arr[$i][4] = $tmp[4]
			$new2Arr[$i][5] = $tmp[5]
		Next
		
		;Delete DOC
		For $i = Ubound($new2Arr)-1 to 1 Step -1
			If $new2Arr[$i][4] == "DOC" Then _ArrayDelete($new2Arr, $i)
		Next
			
		Return  $new2Arr
	EndIf
	Return False
	
EndFunc

Func getJobListData($projNo, $WC, $bomLevel, $return = Default, $bomExclude = Default)
	
	$WCStr = ""
	If $WC <> "" Then $WCStr = "@StartWC = '" & $WC & "', @EndWC = '" & $WC & "', "
	
	If p_or_j($projNo) == "j" Then ;Run at job level
		$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_GalaJobOperationListingSp @StartJob = '" & $projNo & "', @EndJob = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, " & $WCStr & "@JobStat = 'FRSCH', @EngineeringDept = N'A', @PageOpera = 1, @ShowInternal = 0, @ShowExternal = 1, @LowestBOMLevel = " & $bomLevel & " , @IncludeTopLevel = 1" 
	Else
		$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_GalaJobOperationListingSp @CoNum = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, " & $WCStr & "@JobStat = 'FRSCH', @EngineeringDept = N'A', @PageOpera = 1, @ShowInternal = 0, @ShowExternal = 1, @LowestBOMLevel = " & $bomLevel & " , @IncludeTopLevel = 1" 
	EndIf
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	If IsArray($aRecords) Then
		
		If $return = "Jobs" Then
			
			Local $newArr[Ubound($aRecords)]
			For $i = 1 to  Ubound($aRecords)-1
				If $bomExclude = Default Then
					$newArr[$i] = $aRecords[$i][4]
				Else
					If $aRecords[$i][15]>$bomExclude Then $newArr[$i] = $aRecords[$i][4] & "-" & $aRecords[$i][5]
				EndIf
			Next
			
			$newArr = _ArrayUnique($newArr, 0, 0, 0, 0)
			For $i = Ubound($newArr)-1 to 0 Step -1
				If StringStripWS($newArr[$i], 7) = "" Then _ArrayDelete($newArr, $i)
			Next
			$newArr = _ArrayUnique($newArr, 0, 0, 0 , 0)
			
			Return $newArr
		Else
			
			Local $newArr[Ubound($aRecords)]
			For $i = 1 to Ubound($aRecords)-1
				If $bomExclude = Default Then
					If Asc($aRecords[$i][21]) > 0 Then $newArr[$i] = StringFormat("%07i", $aRecords[$i][21]) & "-" & $aRecords[$i][4] & "-" & $aRecords[$i][5] & "-" & $aRecords[$i][18]
				Else
					If Asc($aRecords[$i][21]) > 0 And $aRecords[$i][15]>$bomExclude Then 
						$newArr[$i] = StringFormat("%07i", $aRecords[$i][21]) & "-" & $aRecords[$i][4] & "-" & $aRecords[$i][5] & "-" & $aRecords[$i][18]
					EndIf
				EndIf	
			Next
			$newArr = _ArrayUnique($newArr, 0, 0, 0, 0)
			For $i = Ubound($newArr)-1 to 0 Step -1
				If StringStripWS($newArr[$i], 7) = "" Then _ArrayDelete($newArr, $i)
			Next
			$newArr = _ArrayUnique($newArr, 0, 0, 0 , 0)
			
			;Split the array
			Local $new2Arr[Ubound($newArr)][4]
			For $i = 0 to Ubound($newArr)-1
				$tmp = StringSplit($newArr[$i], "-", 2)
				$new2Arr[$i][0] = $tmp[0]
				$new2Arr[$i][1] = $tmp[1]
				$new2Arr[$i][2] = $tmp[2]
				$new2Arr[$i][3] = CleanName($tmp[3])
			Next
			
			Return  $new2Arr
			
		EndIf
	EndIf
	
EndFunc

Func CleanName($name)
	
	If StringLen($name)<50 Then Return $name
	
	$name = StringLeft($name, 50)
	
	If StringInStr($name, ";") Then
		$aTmp = StringSplit($name, ";", 2)
		Return $aTmp[0]
	ElseIf StringInStr($name, ",") Then
		$pos = StringInStr($name, ",", 0, -1)
		$name = StringLeft($name, $pos-1)
		Return $name
	Else
		$pos = StringInStr($name, " ", 0, -1)
		$name = StringLeft($name, $pos-1)
		Return $name
	EndIf
	
	Return $name
	
EndFunc

Func getPickList($projNo, $return = Default)
	
	$sql = "SET NOCOUNT ON;"
	If p_or_j($projNo) == "p" Then
		$sql &= "EXEC " & $DBNAME &".dbo.GIRpt_JobMaterialPickListSp @StartOrdNum = '" & $projNo & "', @EndOrdNum = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, @JobStat = N'FRSC', @MatlLst132 = 0, @MatlLstDate = 0, @PickByLoc = 1, @PrintSN = 0, @PrintBCFmt = 0, @PageOpera = 1, @PrintSecLoc = 0, @ExtScrapFact = 0, @ReprintPick = N'A', @DisplayRefFields = 0, @DisplayHeader = 0, @StockBack = 1, @MPLBOMLevel = 3, @pSite = ER, @SendVidmarOrder = 0;"
	Else
		$sql &= "EXEC " & $DBNAME & ".dbo.GIRpt_JobMaterialPickListSp @StartJob = '" & $projNo & "', @EndJob = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, @JobStat = N'FRSC', @MatlLst132 = 0, @MatlLstDate = 0, @PickByLoc = 1, @PrintSN = 0, @PrintBCFmt = 0, @PageOpera = 1, @PrintSecLoc = 0, @ExtScrapFact = 0, @ReprintPick = N'A', @DisplayRefFields = 0, @DisplayHeader = 0, @StockBack = 1, @MPLBOMLevel = 3, @pSite = ER, @SendVidmarOrder = 0;"
	EndIf
	$sql &= "SET NOCOUNT OFF;"
	
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)	
	
	If IsArray($aRecords) Then		
		_ArrayDelete($aRecords, 0)
		
		If $return == "Jobs" Then
			Local $newArr[Ubound($aRecords)]
			For $i = 0 to Ubound($aRecords)-1
				$newArr[$i] = $aRecords[$i][1]
			Next
			
			$newArr = _ArrayUnique($newArr, 0, 0, 0, 0)
			For $i = Ubound($newArr)-1 to 0 Step -1
				If StringStripWS($newArr[$i], 7) = "" Then _ArrayDelete($newArr, $i)
			Next
			$newArr = _ArrayUnique($newArr, 0, 0, 0 , 0)
			
			Return $newArr
		ElseIf $return == "Drawings" Then
			Local $newArr[Ubound($aRecords)]
			For $i = 0 to Ubound($aRecords)-1
				$newArr[$i] = StringFormat("%07i", $aRecords[$i][8]) & "-" & $aRecords[$i][1] & "-" & $aRecords[$i][2] & "-" & $aRecords[$i][10]
			Next
			
			$newArr = _ArrayUnique($newArr, 0, 0, 0, 0)
			For $i = Ubound($newArr)-1 to 0 Step -1
				If StringStripWS($newArr[$i], 7) = "" Then _ArrayDelete($newArr, $i)
			Next
			$newArr = _ArrayUnique($newArr, 0, 0, 0 , 0)
			
			;Split the array
			Local $new2Arr[Ubound($newArr)][4]
			For $i = 0 to Ubound($newArr)-1
				$tmp = StringSplit($newArr[$i], "-", 2)
				$new2Arr[$i][0] = $tmp[0]
				$new2Arr[$i][1] = $tmp[1]
				$new2Arr[$i][2] = $tmp[2]
				$new2Arr[$i][3] = CleanName($tmp[3])
			Next
			
			Return  $new2Arr
			
		Else
			Local $newArr[Ubound($aRecords)][6]
			For $i = 0 to Ubound($aRecords)-1
				$newArr[$i][0] = $aRecords[$i][1]
				$newArr[$i][1] = $aRecords[$i][2]
				$newArr[$i][2] =  StringFormat("%07i", $aRecords[$i][8])
				$newArr[$i][3] =  StringFormat("%07i", $aRecords[$i][24])
				$newArr[$i][4] =  $aRecords[$i][31]
				$newArr[$i][5] =  $aRecords[$i][28]
			Next
			
			Return $newArr
		EndIf
	EndIf
	
	Return False
EndFunc

Func getBOM($projNo)
	
	If p_or_j($projNo) == "p" Then
		$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_GalaJobOperationListingSp @CoNum = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, @JobStat = 'FRSCH', @EngineeringDept = N'A', @PageOpera = 1, @ShowInternal = 0, @ShowExternal = 1, @LowestBOMLevel = 3 , @IncludeTopLevel = 1" 
	Else
		$sql = "EXEC " & $DBNAME & ".dbo.GIRpt_GalaJobOperationListingSp @StartJob = '" & $projNo & "', @EndJob = '" & $projNo & "', @StartSuffix = 0, @EndSuffix = 9999, @JobStat = 'FRSCH', @EngineeringDept = N'A', @PageOpera = 1, @ShowInternal = 0, @ShowExternal = 1, @LowestBOMLevel = 3 , @IncludeTopLevel = 1" 
	EndIf
	
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	If IsArray($aRecords) Then
		_ArrayDelete($aRecords, 0)
		Local $newArr[Ubound($aRecords)][9]
		$cnt = 0
		For $i = 0 to Ubound($aRecords)-1
			If Asc($aRecords[$i][10]) > 0 Then
				$newArr[$cnt][0] = $aRecords[$i][4]
				$newArr[$cnt][1] = $aRecords[$i][5]
				$newArr[$cnt][2] = StringFormat("%07i", $aRecords[$i][6])
				If StringIsDigit($aRecords[$i][10]) Then
					$newArr[$cnt][3] = StringFormat("%07i", $aRecords[$i][10])
				Else
					$newArr[$cnt][3] =  $aRecords[$i][10]
				EndIf
				$newArr[$cnt][4] = $aRecords[$i][34]
				$newArr[$cnt][5] = $aRecords[$i][9]
				$newArr[$cnt][6] = $aRecords[$i][29]
				$newArr[$cnt][7] = $aRecords[$i][30]
				$tmp = StringSplit($aRecords[$i][8], "-")
				$newArr[$cnt][8] = $tmp[1]				
				$cnt = $cnt + 1
			EndIf
		Next
		
		If $cnt<Ubound($newArr) Then
			$newArr = _ArrayExtract($newArr, -1, $cnt-1)
		EndIf
		
		Return  $newArr
	EndIf
	
	Return False
	
EndFunc

Func getProjName($projNo)
	
	$sql = "SELECT [dbo].GIGetFullCustomerAccountPathFn('" & StringStripWS($projNo, 3) & "')"
	Local $aRecords = _ADO_Execute($oConnection, $sql, True, True)
	Return $aRecords[1][0]
	
EndFunc


#Region Utility Functions

Func openDBConnection()

	_ADO_ComErrorHandler_UserFunction(_ADO_MG_COMErrorHandler_Function)
	
	$DB_SERVER = IniRead($CONFIG, "CSI", "Server", "")
	$DB_USER = IniRead($CONFIG, "CSI", "DB_User", "")
	$DB_PASS = IniRead($CONFIG, "CSI", "DB_Pass", "")
	
	If $DB_SERVER = "" Or $DB_USER = "" Or $DB_PASS = "" Then
		Return SetError(1, 0, "DB Credentials Not set in config file")
	EndIf
	
	Local $sDatabase  = $DBNAME          ; change this string to YourDatabaseName
	Local $sServer      = $DB_SERVER     ; change this string to YourServerLocation
	Local $sUser         = $DB_USER         ; change this string to YourUserName
	Local $sPassword  = $DB_PASS         ; change this string to YourPassword

	Local $oConnection = _ADO_Connection_Create()
	$ret = _ADO_Connection_OpenMSSQL($oConnection, $sServer, $sDatabase, $sUser, $sPassword)
	;$ret = _ADO_Connection_OpenMSSQL_WinAuth($oConnection, $sServer, $sDatabase, Default, Default, False)
	If $ret = $ADO_RET_FAILURE Then
	    FileWrite($TEMPDIR & "\error.txt", "Could not connect to CSI Syteline Database")
	   Return SetError(2, 0, "Could not connect to CSI Syteline Database")
	EndIf
	
	;Set the timeout to 120
	_ADO_Connection_CommandTimeout($oConnection, 500)
	
	;Set up the Context on the DB
	$sql = "BEGIN; DECLARE @C VARBINARY(128), @S NCHAR(8); SET @S = N'ER' + SPACE(8); SET @C = CAST(@S AS VARBINARY(128)); SET CONTEXT_INFO @C; END;"
	_ADO_Execute($oConnection, $sql)

	Return SetError(0, 0, $oConnection)
EndFunc

Func closeDBConnection()
	_ADO_Connection_Close($oConnection)
EndFunc

Func _ADO_MG_COMErrorHandler_Function(ByRef $oADO_Error)
	If @Compiled Then
		FileWrite($TEMPDIR & "\error.txt", $oADO_Error.description)
		ConsoleWriteError("CSI Syteline Database Error : " & $oADO_Error.description)
		;Msgbox($MB_ICONERROR, "CSI Syteline Database Error", $oADO_Error.description)
		Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)
	EndIf
	; Error Object
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms677507(v=vs.85).aspx

	; Error Object Properties, Methods, and Events
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms678396(v=vs.85).aspx

	Local $HexNumber = Hex($oADO_Error.number, 8)
	Local $sSQL_ComErrorDescription = ''
	$sSQL_ComErrorDescription &= "ADO.au3 v." & _ADO_UDFVersion() & " (" & $oADO_Error.scriptline & ") : ==> COM Error intercepted !" & @CRLF
	$sSQL_ComErrorDescription &= "$oADO_Error.description is: " & @TAB & $oADO_Error.description & @CRLF
	$sSQL_ComErrorDescription &= "$oADO_Error.windescription: " & @TAB & $oADO_Error.windescription & @CRLF
	$sSQL_ComErrorDescription &= "$oADO_Error.number is: " & @TAB & $HexNumber & @CRLF
	$sSQL_ComErrorDescription &= "$oADO_Error.lastdllerror is: " & @TAB & $oADO_Error.lastdllerror & @CRLF
	$sSQL_ComErrorDescription &= "$oADO_Error.scriptline is: " & @TAB & $oADO_Error.scriptline & @CRLF

	; Source Property (ADO Error)
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms675830(v=vs.85).aspx
	$sSQL_ComErrorDescription &= "$oADO_Error.source is: " & @TAB & $oADO_Error.source & @CRLF
	$sSQL_ComErrorDescription &= "$oADO_Error.helpfile is: " & @TAB & $oADO_Error.helpfile & @CRLF
	$sSQL_ComErrorDescription &= "$oADO_Error.helpcontext is: " & @TAB & $oADO_Error.helpcontext & @CRLF
;~ 	$g_AdoErrDesc = $oADO_Error.description ; SkySnake

	#cs
		; NativeError Property (ADO)
		; https://msdn.microsoft.com/en-us/library/windows/desktop/ms678049(v=vs.85).aspx
		$sSQL_ComErrorDescription &= "$oADO_Error.NativeError is: " & @TAB & $oADO_Error.NativeError & @CRLF

		; SQLState Property
		; https://msdn.microsoft.com/en-us/library/windows/desktop/ms681570(v=vs.85).aspx
		$sSQL_ComErrorDescription &= "$oADO_Error.SQLState is: " & @TAB & $oADO_Error.SQLState & @CRLF
	#ce
	_ADO_ConsoleOutput("###############################" & @CRLF & $sSQL_ComErrorDescription & "###############################")
	; SetError($ADO_ERR_GENERAL, $ADO_EXT_DEFAULT, $sSQL_ComErrorDescription)
EndFunc   ;==>_ADO_COMErrorHandler_Function

Func _splitTaskParms(ByRef $taskParms, ByRef $taskParms1, ByRef $taskParms2)

	$taskParms1 = $taskParms
	$taskParms2 = ""
	If StringLen($taskParms) > 1100 Then
		$taskParms1 = StringLeft($taskParms, 1100)
		$taskParms2 = StringRight($taskParms, StringLen($taskParms)-1100)
	EndIf

EndFunc

#EndRegion Utility Functions