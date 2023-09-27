#include-once
#include <GuiImageList.au3>
#include <GuiButton.au3>

Global Const $iconDLL = @ScriptDir & "\resources\icons.dll"

; Build a Button with 1 line of code
Func _GUIBuildButton($iLeft, $iRight, $iWidth, $iHeight, $sText = "", $sTip = "", $iIcon = -1, $iMargin = 10, $iSize=16, $bDisabled = False, $sDock = "Auto")
	$newBtn = GUICtrlCreateButton($sText, $iLeft, $iRight, $iWidth, $iHeight)
	If $sDock = "Auto" Then
		GUICtrlSetResizing(-1, $GUI_DOCKAUTO)
	Else
		GUICtrlSetResizing(-1, $sDock)
	EndIf
	If $bDisabled Then GUICtrlSetState(-1, $GUI_DISABLE)
	If $sTip <> "" Then GUICtrlSetTip(-1, $sTip)
	If $iIcon > -1 Then _GUICtrlSetImage($newBtn, $iconDLL, $iIcon, $iMargin, $iSize)
	Return $newBtn
EndFunc   ;==>_GUIBuildButton

; Set the Icons for the buttons
Func _GUICtrlSetImage($hButton, $sFileIco, $iIndIco = 0, $iMargin = 10, $iSize=16)
	Local $hImage = _GUIImageList_Create($iSize, $iSize, 5, 3, 6)
	_GUIImageList_AddIcon($hImage, $sFileIco, $iIndIco)
	_GUICtrlButton_SetImageList($hButton, $hImage, 0, $iMargin)
	Return $hImage
EndFunc   ;==>_GUICtrlSetImage