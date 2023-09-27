#pragma compile(Out, TDP_Queue.exe)
#pragma compile(icon, queue.ico)
#pragma compile(FileDescription, 'MAAG - Technical Data Package Process Queue')
#pragma compile(FileVersion, 1.1.0.0)
#pragma compile(CompanyName, 'AXISCADES Technologies Pvt. Ltd.')
#pragma compile(LegalCopyright, '© AXISCADES, 2023')
#pragma compile(LegalTrademarks, 'Built by SudeepJD')
#pragma compile(UPX, False)

#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <Timers.au3>
#include <Array.au3>
#include <Misc.au3>
#include <File.au3>
#include "HTTP.au3"
#include "Json.au3"

If _Singleton("TD_Process_Queue", 1) = 0 Then
	WinActivate("TechDoc Process Queue")
    Exit
EndIf

Global Const $CONFIG = @ScriptDir & "\resources\config.ini"
Const $BASE_URL = IniRead($CONFIG, "ProcessQueue", "BaseURL", "")
Const $DRW = IniRead($CONFIG, "ProcessQueue", "PullDraw", "Yes")
Const $PROJ_FLD = IniRead($CONFIG, "ProcessQueue", "ProjFol", "")
Const $DOC_FLD = IniRead($CONFIG, "ProcessQueue", "DocFol", "")
Const $INTERVAL = IniRead($CONFIG, "ProcessQueue", "Interval", "")

Global $hGUI = GUICreate("TechDoc Process Queue", 400, 280)
Global $timerHndl

$timerHndl = _Timer_SetTimer($hGUI, $INTERVAL * 1000, "_CheckQueue")
$intervalHndl = _Timer_SetTimer($hGUI, 1000, "_TimerCounter")

Global $listView = GUICtrlCreateListView("Update Type|Project No|Params|Status",10, 10, 380, 200)
_GUICtrlListView_SetColumnWidth($listView, 0, 80)
_GUICtrlListView_SetColumnWidth($listView, 1, 80)
_GUICtrlListView_SetColumnWidth($listView, 2, 140)
Global $refreshBtn = GUICtrlCreateButton("Refresh", 10, 215, 80, 25)
Global $lastUpdate = GUICtrlCreateLabel("", 100, 220, 20, 20)
$wSize = WinGetClientSize($hGUI)
Global $hStatus = GUICtrlCreateLabel("  Waiting for Queue...", 0, $wSize[1]-25, $wSize[0], 25, 0x1000+0x0200)
GUISetState(@SW_SHOW, $hGUI)
_PopulateQueue()

; Loop until the user exits.
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $refreshBtn
			_PopulateQueue()
	EndSwitch
	
	If _GUICtrlListView_GetItemCount($listView)>0 Then
		If _GUICtrlListView_GetItemText($listView, 0, 3) == "new" Then
			_StartProcess()
		EndIf
	EndIf
	
WEnd

GUIDelete($hGUI)

Func _CheckQueue($hWnd, $iMsg, $iIDTimer, $iTime)
    #forceref $hWnd, $iMsg, $iIDTimer, $iTime
    _PopulateQueue()	
EndFunc   ;==>_CheckQueue

Func _TimerCounter($hWnd, $iMsg, $iIDTimer, $iTime)
    #forceref $hWnd, $iMsg, $iIDTimer, $iTime
    GUICtrlSetData($lastUpdate, GUICtrlRead($lastUpdate)-1)
EndFunc   ;==>_CheckQueue

Func _PopulateQueue()
	
	GUICtrlSetData($lastUpdate, $INTERVAL)
	
	$returnData = _HTTP_Get($BASE_URL & "/projects/processlist")
	If @error>0 Then Return
	
	$q = Json_Decode($returnData)
	$projects = Json_ObjGet($q, "projects")
	
	For $i = 0 to Ubound($projects)-1
		$proj = $projects[$i]
		$stat = "new"
		
		;Check if the item is not in queue before adding it
		$add = True
		For $j = 0 to _GUICtrlListView_GetItemCount($listView)-1
			$type = _GUICtrlListView_GetItemText($listView, $j, 0)
			$projI = _GUICtrlListView_GetItemText($listView, $j, 1)
			If $type == "project" And $projI == $proj Then 
				$add = False
				ExitLoop
			EndIf
		Next
		
		If $add Then GUICtrlCreateListViewItem("project|" & $proj & "||" & $stat, $listView)
	Next
	
	;Delete the items not there in the incoming queue
	For $i = 0 to _GUICtrlListView_GetItemCount($listView)-1
		$projNo = _GUICtrlListView_GetItemText($listView, $i, 1)
		$projExists = False
		For $j = 0 to Ubound($projects)-1
			If $projNo = $projects[$j] Then
				$projExists = True
				ExitLoop
			EndIf
		Next
		If Not $projExists Then _GUICtrlListView_DeleteItem($listView, $i)
	Next
	
	$drawings = Json_ObjGet($q, "drawings")
	$keys = Json_ObjGetKeys($drawings)
	For $i = 0 to UBound($keys)-1
		$proj = $keys[$i]
		$stat = "new"
		$aDrw = StringSplit($drawings.Item($keys[$i]), ",", 2)
		
		For $j = 0 to Ubound($aDrw)-1
			$find = _GUICtrlListView_FindInText ($listView, $aDrw[$j])
			If $find == -1 Then
				;Check if we have a project 
				$projInd = -1
				For $k = 0 to _GUICtrlListView_GetItemCount($listView)	
					If _GUICtrlListView_GetItemText($listView, $k, 0) == "drawing" And _GUICtrlListView_GetItemText($listView, $k, 1) == $proj And _GUICtrlListView_GetItemText($listView, $k, 3) == "new" Then
						$projInd = $k
						ExitLoop
					EndIf
				Next
				
				;If we dont have a project that add in a new project line, otherwise edit it
				If $projInd = -1 Then
					GUICtrlCreateListViewItem("drawing|" & $proj & "|" & $aDrw[$j] & "|" & $stat, $listView)
				Else
					$drwL = _GUICtrlListView_GetItemText($listView, $projInd, 2) & "," & $aDrw[$j]
					_GUICtrlListView_SetItemText($listView, $projInd, $drwL, 2)
				EndIf
			EndIf
		Next
	Next
	
	;If there are subfolders in the DOCSTORE then add in a queue item if it does not exist
	If $DOC_FLD <> "" Then
		$find = _GUICtrlListView_FindInText ($listView, "files")
		If $find == -1 Then
			$folArr = _FileListToArray($DOC_FLD, "*", 2) ;2-$FLTA_FOLDERS
			If @error==0 Then
				$ret = GUICtrlCreateListViewItem("files|||new", $listView)
			EndIf
		EndIf
	EndIf
EndFunc

Func _StartProcess()
	
	$type = _GUICtrlListView_GetItemText($listView, 0, 0)
	$proj = _GUICtrlListView_GetItemText($listView, 0, 1)
	$params = _GUICtrlListView_GetItemText($listView, 0, 2)
	
	If $type == "project" Then
		;Check if the state is still new or update as users can cancel
		$projState = _HTTP_Get($BASE_URL & "/projects/getstate/" & $proj)
		If @error>0 Then $projState = "new"
		
		If $projState <> "new" and $projState <> "inprogress" And $projState <> "update" Then 
			_GUICtrlListView_DeleteItem($listView, 0)
			Return
		EndIf
		
		;Change the state of the project to inprogress
		_HTTP_Post($BASE_URL & "/projects/changestate", "ProjectNo=" & $proj & "&state=inprogress")
		_GUICtrlListView_SetItemText($listView, 0, "inprogress", 3)
		
		;Initiate the data pull
		$PID = Run(@ScriptDir & "\TDP_CLI.exe " & $proj, @ScriptDir, @SW_HIDE, $STDOUT_CHILD)

		While ProcessExists($PID)
			$out = StdoutRead($PID)
			If $out <> "" Then GUICtrlSetData($hStatus, " " & $out)
			
			$error = StderrRead($PID)
			If $error <> "" Then
				TrayTip("TechData Package", $error, 5, 3)
				ExitLoop
			EndIf
		WEnd
		Sleep(1000)
		
		;After it completes process the project
		If FileExists(@ScriptDir & "\resources\Tmp\error.txt") Then
			$msg = FileRead(@ScriptDir & "\resources\Tmp\error.txt")
			_HTTP_Post($BASE_URL & "/projects/changestate", "ProjectNo=" & $proj & "&state=error&message=" & $msg)
			DirRemove(@ScriptDir & "\resources\Tmp\" & $proj, 1)
		Else
			If FileExists(@ScriptDir & "\resources\Tmp\" & $proj & "\complete.txt") Then
				GUICtrlSetData($hStatus, " Copying Files...")
				If FileExists($PROJ_FLD & "\" & $proj) Then	DirRemove($PROJ_FLD & "\" & $proj, 1)
				DirMove(@ScriptDir & "\resources\Tmp\" & $proj, $PROJ_FLD & "\" & $proj)
				Sleep(1000)
				GUICtrlSetData($hStatus, " Processing Project...")
				_HTTP_Get($BASE_URL & "/projects/process/" & $proj)
				FileDelete(@ScriptDir & "\resources\Tmp\" & $proj & "\complete.txt")
			Else
				_HTTP_Post($BASE_URL & "/projects/changestate", "ProjectNo=" & $proj & "&state=error&message=Project Packaging did not complete")
			EndIf
		EndIf
	EndIf
	
	If $type == "drawing" Then
		;Change the state of the drawings to inprogress
		_HTTP_Post($BASE_URL & "/drw/changestate", "ProjectNo=" & $proj & "&DrwList=" & $params & "&state=2")
		_GUICtrlListView_SetItemText($listView, 0, "inprogress", 3)
		
		;Start the process to fetch drawings
		GUICtrlSetData($hStatus, " Fetching Drawings...")
		ShellExecute(@ScriptDir & "\resources\PrintDrawings\Print Drawings.exe", "drawing " & $params)
		Sleep(1000)
		
		While ProcessExists("Print Drawings.exe")
			GUICtrlSetData($hStatus, " Print Drawing In Progress")
			Sleep(1000)
			
			;Sometimes Print Drawings stays open.. We need to kill it
			If FileExists(@ScriptDir & "\resources\PrintDrawings\Tmp\complete.txt") Then
				While ProcessExists("Print Drawings.exe") 
					ProcessClose("Print Drawings.exe")
				WEnd
			EndIf
		WEnd
		
		;Copy the drawings to the project folders
		GUICtrlSetData($hStatus, " Copying Drawings...")
		$drwList = StringSplit($params, ",", 2)
		For $i = 0 to Ubound($drwList)-1
			If FileExists(@ScriptDir & "\resources\PrintDrawings\Tmp\" & $drwList[$i] & ".pdf") Then
				FileCopy(@ScriptDir & "\resources\PrintDrawings\Tmp\" & $drwList[$i] & ".pdf", $PROJ_FLD & "\" & $proj & "\Drawings\" & $drwList[$i] & ".pdf", 1)
				_HTTP_Post($BASE_URL & "/drw/changestate", "ProjectNo=" & $proj & "&DrwList=" & $drwList[$i] & "&state=0")
			Else
				_HTTP_Post($BASE_URL & "/drw/changestate", "ProjectNo=" & $proj & "&DrwList=" & $drwList[$i] & "&state=3")
			EndIf
		Next
		
		FileDelete(@ScriptDir & "\resources\PrintDrawings\Tmp\*.*")
	EndIf
	
	If $type == "files" Then
		_GUICtrlListView_SetItemText($listView, 0, "inprogress", 3)
		$projList = _FileListToArray($DOC_FLD, "*", 2)
		For $i = 1 to $projList[0]
			If FileExists($PROJ_FLD & "\" & $projList[$i]) Then
				If Not FileExists($PROJ_FLD & "\" & $projList[$i] & "\FILES") Then DirCreate($PROJ_FLD & "\" & $projList[$i] & "\FILES")
				$ret = FileCopy($DOC_FLD & "\" & $projList[$i] & "\*.*", $PROJ_FLD & "\" & $projList[$i] & "\FILES", 1)
				If $ret Then DirRemove($DOC_FLD & "\" & $projList[$i], 1)
			EndIf
		Next
	EndIf
	
	_GUICtrlListView_DeleteItem($listView, 0)
	
	GUICtrlSetData($hStatus, " Waiting for Queue...")
EndFunc
