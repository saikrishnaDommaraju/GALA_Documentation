;~ #AutoIt3Wrapper_UseX64=Y

#include "ADO.au3"
#Tidy_Parameters=/sort_funcs /reel
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#AutoIt3Wrapper_Run_Au3Stripper=Y
#Au3Stripper_Parameters=/RM

#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>


; You can use internal ADO.au3 UDF COMError Handler
;~ _ADO_ComErrorHandler_UserFunction(_ADO_COMErrorHandler_Function)

; You can use your own COMErrorHandler instead internal ADO.au3 UDF COMError Handler
;~ _ADO_ComErrorHandler_UserFunction(_User_COMErrorHandler_Function)

; Uncomment one of the following examples
;
;~ _Example_MSAccess()
;~ _Example_MSExcel()

_Example_MSSQL_SQLServerAuthorization()
If @error Then ConsoleWrite('! ---> @error=' & @error & '  @extended=' & @extended & ' : _Example_MSSQL_SQLServerAuthorization()' & @CRLF)

;~ _Example_MSSQL_WindowsAuthorization()
;~ _Example_MSSQL_COMMAND_StoredProcedure()
;~ _Example_MySQL()
;~ _Example_PostgreSQL()
;~ _Example_Firebird

Func _Example_MSAccess()

	Local $sMDB_FileFullPath = Default ;'Here put FileFullPath to your Access File'
	Local $sDriver = Default
	Local $sUser = Default
	Local $sPassword = Default

	Local $sConnectionString = _ADO_ConnectionString_Access($sMDB_FileFullPath, $sUser, $sPassword, $sDriver)

	_Example_1_RecordsetToConsole($sConnectionString, "Select * from SOME_TABLE")
	_Example_2_RecordsetDisplay($sConnectionString, "Select * from SOME_TABLE")
	_Example_3_ConnectionProperties($sConnectionString)

EndFunc   ;==>_Example_MSAccess

Func _Example_MSExcel()

	Local $sFileFullPath = Default ; Here put FileFullPath to your Excel File or use Default to open FileOpenDialog
	Local $sProvider = Default
	Local $sExtProperties = Default
	Local $HDR = Default
	Local $IMEX = Default

	Local $sConnectionString = _ADO_ConnectionString_Excel($sFileFullPath, $sProvider, $sExtProperties, $HDR, $IMEX)

	_Example_1_RecordsetToConsole($sConnectionString, "select * from [Sheet1$]")
	_Example_2_RecordsetDisplay($sConnectionString, "select * from [Sheet1$]")
	_Example_3_ConnectionProperties($sConnectionString)

EndFunc   ;==>_Example_MSExcel

Func _Example_MSSQL_SQLServerAuthorization()
	Local $sDriver = 'SQL Server'
	Local $sDatabase = 'YourBASENAME' ; change this string to YourDatabaseName
	Local $sServer = 'localhost\SQLExpress' ; change this string to YourServerLocation
	Local $sUser = 'sa' ; change this string to YourUserName
	Local $sPassword = 'AutoIt' ; change this string to YourPassword

	Local $sConnectionString = 'DRIVER={' & $sDriver & '};SERVER=' & $sServer & ';DATABASE=' & $sDatabase & ';UID=' & $sUser & ';PWD=' & $sPassword & ';'

	_Example_1_RecordsetToConsole($sConnectionString, "Select * from SOME_TABLE")
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	_Example_2_RecordsetDisplay($sConnectionString, "Select * from SOME_TABLE")
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	_Example_3_ConnectionProperties($sConnectionString)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	_Example_4_MSSQL_SQLAuth($sServer, $sDatabase, $sUser, $sPassword, "Select * from SOME_TABLE")

EndFunc   ;==>_Example_MSSQL

Func _Example_MSSQL_WindowsAuthorization()
	Local $sDatabase = 'YourBASENAME' ; change this string to YourDatabaseName
	Local $sServer = 'localhost\SQLExpress' ; change this string to YourServerLocation

	_Example_5_MSSQL_WinAuth($sServer, $sDatabase, "Select * from SOME_TABLE")

EndFunc   ;==>_Example_MSSQL

Func _Example_MSSQL_COMMAND_StoredProcedure()
	Local $sDriver = 'SQL Server'
	Local $sDatabase = 'baza' ; change this string to YourDatabaseName
	Local $sServer = 'localhost\SQLExpress' ; change this string to YourServerLocation
	Local $sUser = 'sa' ; change this string to YourUserName
	Local $sPassword = 'AutoIt' ; change this string to YourPassword

	Local $sConnectionString = 'DRIVER={' & $sDriver & '};SERVER=' & $sServer & ';DATABASE=' & $sDatabase & ';UID=' & $sUser & ';PWD=' & $sPassword & ';'

	; Create connection object
	Local $oConnection = _ADO_Connection_Create()

	; Open connection with $sConnectionString
	_ADO_Connection_OpenConString($oConnection, $sConnectionString)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Local $oCommand = _ADO_Command_Create($oConnection, $ADO_adCmdStoredProc)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Create procedure (local temp procedure	)
	; https://msdn.microsoft.com/pl-pl/library/ms188655(v=sql.110).aspx
	Local $sQUERY1 = _
			"CREATE PROCEDURE #testing1 @Param1 varchar(1), @Result1 varchar(1000) OUTPUT" & @CRLF & _
			"AS" & @CRLF & _
			"	SET @Param1 =1" & @CRLF & _
			"	SET @Result1 = 'Starting @@TRANCOUNT=' +  CAST(@@TRANCOUNT AS VARCHAR(10)) + CHAR(10)" & @CRLF & _
			"IF @Param1 = 1" & @CRLF & _
			"BEGIN" & @CRLF & _
			"	SET @Result1 = @Result1 + '@Param1 = ' + @Param1 + CHAR(10)" & @CRLF & _
			"END" & @CRLF & _
			""
	_ADO_Execute($oConnection, $sQUERY1)

	_ADO_Command_CreateParameter($oCommand, '@Param1', 1, 1, $ADO_adChar, $ADO_adParamInput)
	If @error Then MsgBox($MB_ICONERROR, '@Param1', _
			'@error = ' & @error & @CRLF & '@extended = ' & @extended)

	_ADO_Command_CreateParameter($oCommand, '@Result1', 1000, Default, $ADO_adChar, $ADO_adParamOutput)
	If @error Then MsgBox($MB_ICONERROR, '@Result1', _
			'@error = ' & @error & @CRLF & '@extended = ' & @extended)

	Local $oParameters_coll = $oCommand.parameters
	If @error Then MsgBox($MB_ICONERROR, 'Parameters', '@error = ' & @error & @CRLF & '@extended = ' & @extended)

	; Enumerate parameters to check if are properly added
	; Local $iParam_count = $oParameters_coll.count
	For $oParameter In $oParameters_coll
		ConsoleWrite($oParameter.name & @CRLF)
	Next

	Local $oRecordset = _ADO_Command_Execute($oCommand, "#testing1")

	MsgBox($MB_ICONINFORMATION, '@Result1', $oCommand.Parameters.Item("@Result1").Value)

	Return $oRecordset

EndFunc   ;==>_Example_MSSQL_COMMAND_StoredProcedure

Func _Example_MySQL()
	; Link to Windows MySQL ODBC drivers
	; https://dev.mysql.com/downloads/connector/odbc/

	Local $sDriver = 'MySQL ODBC 5.3 ANSI Driver' ; 'MySQL ODBC 5.3 UNICODE Driver'
	Local $sServer = 'localhost' ; change this string to YourServerLocation
	Local $sDatabase = 'world' ; change this string to YourDatabaseName
	Local $sPort = '3306' ; change this string to If your Server use non standard PORT
	Local $sUser = 'AutoIt' ; change this string to YourUserName
	Local $sPassword = 'AutoIt' ; change this string to YourPassword

	; Local $sConnectionString = 'Driver={' & $sDriver & '};SERVER=' & $sServer & ';PORT=' & $sPort & ';DATABASE=' & $sDatabase & ';User=' & $sUser & ';Passwd=' & $sPassword & ';'
	Local $sConnectionString = _ADO_ConnectionString_MySQL($sUser, $sPassword, $sDatabase, $sDriver, $sServer, $sPort)

;~ 	_Example_1_RecordsetToConsole($sConnectionString, "SELECT * FROM city")
;~ 	_Example_2_RecordsetDisplay($sConnectionString, "SELECT * FROM country WHERE `region` LIKE '%Europe%'")
	_Example_2_RecordsetDisplay($sConnectionString, "SELECT Name , CountryCode , District , Population FROM city WHERE name='Cary'")
	_Example_3_ConnectionProperties($sConnectionString)

EndFunc   ;==>_Example_MySQL

Func _Example_PostgreSQL()
	; http://www.tutorialspoint.com/postgresql/index.htm

;~ 	Local $sDriver = 'PostgreSQL ODBC Driver(ANSI)'
	Local $sDriver = 'PostgreSQL ANSI'
	Local $sDatabase = 'postgres' ; change this string to YourDatabaseName
	Local $sServer = 'localhost' ; change this string to YourServerLocation
	Local $sPort = '5432' ; change this string to If your Server use non standard PORT
	Local $sUser = 'postgres' ; change this string to YourUserName
	Local $sPassword = 'AutoIt' ; change this string to YourPassword

	#cs
		Local $sDSN = 'PostgreSQL35W'
		Local $sConnectionString = 'DSN=' & $sDSN & ';DATABASE=' & $sDatabase & ';SERVER=' & $sServer & ';PORT=' & $sPort & ';UID=' & $sUser & ';PWD=' & $sPassword & ';'
	#ce
	Local $sConnectionString = 'Driver={' & $sDriver & '};DATABASE=' & $sDatabase & ';SERVER=' & $sServer & ';PORT=' & $sPort & ';UID=' & $sUser & ';PWD=' & $sPassword & ';'

	Local $oConnection = _ADO_Connection_Create()
	_ADO_Connection_OpenConString($oConnection, $sConnectionString)
	Local $aSchema_Catalogs = _ADO_Schema_GetAllCatalogs($oConnection)
	_ADO_Recordset_Display($aSchema_Catalogs, '$aSchema_Catalogs')

	Local $oRecordset_Tables = _ADO_OpenSchema_Tables($oConnection, 'postgres')
	_ADO_Recordset_Display($oRecordset_Tables)
	If @error Then MsgBox($MB_ICONERROR, '_ADO_Recordset_Display OpenSchema_Tables', _
			'@error = ' & @error & @CRLF & '@extended = ' & @extended)

	_Example_1_RecordsetToConsole($sConnectionString, 'Select * from "SOME_TABLE"')
	_Example_2_RecordsetDisplay($sConnectionString, 'Select * from "SOME OTHER TABLE"')
	_Example_3_ConnectionProperties($sConnectionString)

EndFunc   ;==>_Example_PostgreSQL

Func _Example_Firebird()

    ; http://firebirdsql.org/pdfmanual/Firebird-2.5-QuickStart.pdf
	; https://www.autoitscript.com/forum/topic/180850-adoau3-udf-beta-support-topic/?do=findComment&comment=1319831

    Local $sDSN = 'Firebird' ; Default
    Local $sDatabase = @ScriptDir & '\firebird\showDB_ado.fdb' ; db name
    Local $sServer = 'localhost' ; Server IP
    Local $sPort = '3050' ; Port
    Local $sUser = 'sysdba' ; DEFAULT Username
    Local $sPassword = 'masterkey' ; DEFAULT Password

    Local $sConnectionString = 'DSN=' & $sDSN & ';DATABASE=' & $sDatabase & ';SERVER=' & $sServer & ';PORT=' & $sPort & ';UID=' & $sUser & ';PWD=' & $sPassword & ';'

    ConsoleWrite("_Example_Firebird " & $sConnectionString & @CRLF)
;   _ADO_Execute("create database " & $sDatabase & " page_size 8192 " & $sUser & $sPassword)
    _Example_3_ConnectionProperties($sConnectionString)

EndFunc   ;==>_Example_Firebird

#Region Common / internal
Func _Example_1_RecordsetToConsole($sConnectionString, $sQUERY)

	; Create connection object
	Local $oConnection = _ADO_Connection_Create()

	; Open connection with $sConnectionString
	_ADO_Connection_OpenConString($oConnection, $sConnectionString)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Executing some query
	Local $oRecordset = _ADO_Execute($oConnection, $sQUERY)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Get recordset to array of arrays (Conent and ColumnNames)
	Local $aRecordsetAsArray = _ADO_Recordset_ToArray($oRecordset, False)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Get inner array - only conent of Recordset
	Local $aRecordsetContent = _ADO_RecordsetArray_GetContent($aRecordsetAsArray)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Go through the array variable (Recorset Conent)
	Local $iColumn_count = UBound($aRecordsetContent, $UBOUND_COLUMNS)
	For $iRecord_idx = 0 To UBound($aRecordsetContent) - 1
		ConsoleWrite('==================================================================' & @CRLF)
		For $iColumn_idx = 0 To $iColumn_count - 1
			ConsoleWrite($aRecordsetContent[$iRecord_idx][$iColumn_idx] & @CRLF)
		Next
	Next

	; Clean Up
	$oRecordset = Null
	_ADO_Connection_Close($oConnection)
	$oConnection = Null

EndFunc   ;==>_Example_1_RecordsetToConsole

Func _Example_2_RecordsetDisplay($sConnectionString, $sQUERY)

	; Create connection object
	Local $oConnection = _ADO_Connection_Create()

	; Open connection with $sConnectionString
	_ADO_Connection_OpenConString($oConnection, $sConnectionString)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Executing some query directly to Array of Arrays (instead to $oRecordset)
	Local $aRecordset = _ADO_Execute($oConnection, $sQUERY, True)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Clean Up
	_ADO_Connection_Close($oConnection)
	$oConnection = Null

	; Display Array Content with column names as headers
	_ADO_Recordset_Display($aRecordset, 'Recordset content')
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

EndFunc   ;==>_Example_2_RecordsetDisplay

Func _Example_3_ConnectionProperties($sConnectionString)

	; Create connection object
	Local $oConnection = _ADO_Connection_Create()

	; Open connection with $sConnectionString
	_ADO_Connection_OpenConString($oConnection, $sConnectionString)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Get all connection properties to Array
	Local $aProperties = _ADO_Connection_PropertiesToArray($oConnection)

	; Clean Up
	_ADO_Connection_Close($oConnection)
	$oConnection = Null

	; Show connection properties
	_ArrayDisplay($aProperties, "ADO connection - List of properties", "", 0, Default, "Name|Type|Value|Attributes")

EndFunc   ;==>_Example_3_ConnectionProperties

Func _Example_4_MSSQL_SQLAuth($sServer, $sDatabase, $sUser, $sPassword, $sQUERY)

	; Create connection object
	Local $oConnection = _ADO_Connection_Create()

	; Open connection with $sConnectionString
	_ADO_Connection_OpenMSSQL($oConnection, $sServer, $sDatabase, $sUser, $sPassword, 'YourAppName', @ComputerName & '_' & 'YourProgram_UID')
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Executing some query directly to Array of Arrays (instead to $oRecordset)
	Local $aRecordset = _ADO_Execute($oConnection, $sQUERY, True)

	; Clean Up
	_ADO_Connection_Close($oConnection)
	$oConnection = Null

	; Display Array Content with column names as headers
	_ADO_Recordset_Display($aRecordset, 'Recordset content')

EndFunc   ;==>_Example_4_MSSQL_SQLAuth

Func _Example_5_MSSQL_WinAuth($sServer, $sDatabase, $sQUERY)

	; Create connection object
	Local $oConnection = _ADO_Connection_Create()

	; Open connection with $sConnectionString
	_ADO_Connection_OpenMSSQL($oConnection, $sServer, $sDatabase, '', '', 'YourAppName', @ComputerName & '_' & 'YourProgram_UID', False)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Executing some query directly to Array of Arrays (instead to $oRecordset)
	Local $aRecordset = _ADO_Execute($oConnection, $sQUERY, True)

	; Clean Up
	_ADO_Connection_Close($oConnection)
	$oConnection = Null

	; Display Array Content with column names as headers
	_ADO_Recordset_Display($aRecordset, 'Recordset content')

EndFunc   ;==>_Example_4_MSSQL_SQLAuth
#EndRegion Common / internal

Func _COMErrorDescription_UserStore($sDescription = Default)
	Local Static $sDescription_static = ''
	If $sDescription <> Default Then $sDescription_static = $sDescription
	Return $sDescription_static
EndFunc   ;==>_COMErrorDescription_UserStore

Func _User_COMErrorHandler_Function($oError)
	ConsoleWrite( _
			@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & _
			"$oError.description is: " & @TAB & $oError.description & @CRLF & _
			"$oError.windescription: " & @TAB & $oError.windescription & @CRLF & _
			"$oError.number is: " & @TAB & Hex($oError.number, 8) & @CRLF & _
			"$oError.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			"$oError.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			"$oError.source is : " & @TAB & $oError.source & @CRLF & _
			"$oError.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			"$oError.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF _
			)
	_COMErrorDescription_UserStore($oError.description) ; store description to use it outsided UDF in your own function
EndFunc   ;==>_User_COMErrorHandler_Function
