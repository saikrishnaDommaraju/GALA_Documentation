#include-once
#Region ADO.au3 - Option, Includes, Setup
#Tidy_Parameters=/sort_funcs /reel
;~ #AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Au3Stripper_Ignore_Funcs=__ADO_EVENT__*
#Au3Stripper_Ignore_Variables=

#include <Array.au3>
#include <AutoItConstants.au3>
#include <Date.au3>
#include <Debug.au3>
#include <Misc.au3>
#include <StringConstants.au3>
#include "ADO_CONSTANTS.au3"

#EndRegion ADO.au3 - Option, Includes, Setup

#Region ADO.au3 - UDF Header
; #INDEX# ========================================================================
; Title .........: ADO.au3
; AutoIt Version : 3.3.10.2++
; Language ......: English
; Description ...: A collection of Function for use with an ADO database like MS SQL, MS Access ...
; Author ........: Chris Lambert, mLipok
; Modified ......: eltorro, Elias Assad Neto, CarlH
; URL ...........: http://www.autoitscript.com/forum/index.php?showtopic=180850
; Date ..........: 2020/11/09
; Version .......: 2.1.19 BETA - Work in progress
; ================================================================================

#cs
	2015/08/18
	.	new collection of Functions for EVENT handling - grouped in #Region ADO.au3 - Functions - Event's Handling

	2015/08/24
	.	using ADO_CONSTANTS.au3

	2015/09/02
	.	removed $oConnection = -1, currently all function use ByRef $oConnection

	2015/09/15
	.	Renamed: $_eSQL_RESULT_ >> $ADOSQL_RESULT_ - mLipok
	.	Renamed: $_eSQL_ERROR_ >> $ADOSQL_ERROR_ - mLipok

	2015/10/04 >> 2015/11/06
	.	Renamed: Enums: $ADOSQL_RESULT_ >> $ADO_RET_- mLipok
	.	Renamed: Enums: $ADOSQL_ERROR_ >> $ADO_ERR_- mLipok
	.	Renamed: Enums: $ADO_RET_ERROR >> $ADO_RET_FAILURE- mLipok
	.	Renamed: Enums: $ADO_RET_OK >> $ADO_RET_SUCCESS- mLipok
	.	Renamed: Enums: $ADO_ERR_PARAMETERS >> $ADO_ERR_INVALIDPARAMETERTYPE - mLipok
	.	Renamed: Enums: $ADO_ERR_OK >> $ADO_ERR_SUCCESS - mLipok
	.	Renamed: Function: _SQLVerison >> _ADO_Version - mLipok
	.	Renamed: Function: _SQL_Close >> _ADO_Connection_Close - mLipok
	.	Renamed: Function: _SQL_Startup >> _ADO_Connection_Create - mLipok
	.	Renamed: Function: _SQL_Execute >> _ADO_Execute - mLipok
	.	Renamed: Function: __SQL_EVENT >> __ADO_EVENT - mLipok
	.	New: Function: __ADO_IsValidObjectType - mLipok
	.	New: Enums: $ADO_EXT_INTERNALFUNCTION - mLipok
	.	New: Function: _ADO_Recordset_ToArray - mLipok
	.	Refactored: _SQL_GetTable2D - mLipok
	.	Remove: $ADO_ERR_OTHER >> $ADO_ERR_GENERAL - mLipok
	.	Changed: Function: _SQL_FetchNames : Parameter $oRecordset is now ByRef - mLipok
	.	Added: Function: Parameter: _ADO_Recordset_ToArray >> $bFieldNamesInFirstRow = True - mLipok
	.			this was a speed issue as the entire table was moved step by step
	.	Added: Enums: $ADO_RS_ARRAY_* for use with Return form _ADO_Recordset_ToArray when $bFieldNamesInFirstRow was used - mLipok
	.	Added: Function: _ADO_Recordset_Display - mLipok
	.	Added: Function: __ADO_RecordsetArray_Display - mLipok
	.	Renamed: Variable: $oADODB_Connection >> $oConnection - mLipok
	.	Added: Function: _ADO_Execute: Validation for $oConnection - mLipok
	.	New: Function: __ADO_Command_IsValid - mLipok
	.	New: Function: __ADO_Connection_IsValid - mLipok
	.	New: Function: __ADO_Recordset_IsValid - mLipok
	.	New: Enums: $ADO_ERR_NOCURRENTRECORD - mLipok
	.	Renamed: $ADO_* >> $ADO_* - mLipok
	.	Renamed: _SQL_CommandTimeout >> _ADO_Connection_CommandTimeout - mLipok
	.
	.
	2015/11/06 >>
	.	Removed: Function: _SQL_GetErrMsg() - mLipok
	.	Removed: Variable: $g__sSQL_ErrorDescription - mLipok
	.	Renamed: Function: _SQL_PROVIDER_VERSION >> _ADO_MSSQL_GetProviderVersion - mLipok
	.	Renamed: Function: _SQL_DRIVER_VERSION >> _ADO_MSSQL_GetDriverVersion - mLipok
	.	Removed: Parameter: Function: _SQL_FetchData() $aRow - mLipok
	.	Removed: Parameter: Function: _SQL_FetchNames() $aRow - mLipok
	.	Refactored: _SQL_FetchNames - mLipok
	.	Refactored: _SQL_FetchData - mLipok
	.	Changed: _ADO_Recordset_Display - parameters order - $iAlternateColors <> $bFieldNamesInFirstRow mLipok
	.	Changed: _ADO_Recordset_Display - $bFieldNamesInFirstRow  now default is = False  - mLipok
	.	Added: Function: _ADO_RecordsetArray_IsValid - mLipok
	.	Refactored: Function: __ADO_RecordsetArray_Display - added _ADO_RecordsetArray_IsValid  - mLipok
	.	New: Function: _ADO_RecordsetArray_GetContent - mLipok
	.	New: Function: _ADO_RecordsetArray_GetFieldNames - mLipok
	.
	.
	2016/02/24
	.	Removed: Function: $__sSQL_Last_ConnectionString - mLipok
	.	Removed: Function: _SQL_QuerySingleRowAsString - mLipok
	.	Removed: Function: _SQL_QuerySingleRow - mLipok
	.	Removed: Function: _SQL_GetTable - mLipok
	.	Removed: Function: _SQL_GetTableAsString - mLipok
	.	Removed: Function: _ADO_SQLConnection_DBName - mLipok
	.	Removed: Function: _SQL_RegisterErrorHandler - mLipok
	.	Removed: Function: _SQL_UnRegisterErrorHandler - mLipok
	.	Removed: Function: _SQL_GetTable2D --> look in _ADO_Execute --> third parameter $bReturnAsArray - mLipok
	.	Added: 	Parameter in function: $bReturnAsArray - mLipok
	.
	.	Changed: Function: _ADO_Recordset_ToArray - Parameter - $bFieldNamesInFirstRow is not optional any more - mLipok
	.			(This is first step to change Behavior)
	.	Renamed: Function: _ADO_RecordsetArray_IsValid >> __ADO_RecordsetArray_IsValid - is now INTERNAL - mLipok
	.	Renamed: Function: _SQL_AccessConnect >> _ADO_Connection_OpenAccess - mLipok
	.	Renamed: Function: _SQL_ExcelConnect >> _ADO_Connection_OpenExcel - mLipok
	.	Renamed: Function: _ADO_Connection_OpenJet >> _ADO_Connection_OpenJet - mLipok
	.	Renamed: Function: _ADO_SQLConnectionOpen >> _ADO_Connection_OpenMSSQL - mLipok
	.	Refactored:	_ADO_Connection_OpenMSSQL : $sAPPNAME - mLipok
	.	Change:	_ADO_Connection_OpenMSSQL : parameter : reordering - mLipok
	.	Added:	_ADO_Connection_OpenMSSQL : parameter : $sWSID - mLipok
	.	Added:	_ADO_Connection_OpenMSSQL : parameter : $bUseProviderInsteadDriver - mLipok
	.	Change:	__ADO_MSSQL_CONNECTION_STRING_SQLAuth : parameter : reordering - mLipok
	.	Added:	__ADO_MSSQL_CONNECTION_STRING_SQLAuth : parameter : $sAPPNAME - mLipok
	.	Added:	Function: _ADO_Connection_PropertiesToArray - mLipok
	.			Thanks to @water for wiki tutorial: https://www.autoitscript.com/wiki/ADO_Tools
	.
	2016/02/24 FIRST PUBLIC RELEASE
	.
	2016/02/24 '2.1.7 BETA'
	.	Changed: Function: _ADO_Recordset_ToArray: Parameter is now Optional: $bFieldNamesInFirstRow = False - mLipok
	.	Removed: Function: _ADO_ExecuteQueryToArray --> look in _ADO_Execute --> third parameter $bReturnAsArray - mLipok
	.	Changed: Enums and constants moved to: ADO_CONSTANTS.au3 - mLipok
	.			Thanks to @BrewManNH
	.	Changed: ADO_CONSTANTS.au3: New region: #Region ADO_CONSTANTS.au3 - ADO.au3 UDF Constants  - mLipok
	.	Changed: ADO_CONSTANTS.au3: New region: #Region ADO_CONSTANTS.au3 - MSDN Enumerated Constants  - mLipok
	.	New: Function: _ADO_UDFVersion() - mLipok
	.	Removed: Global Variable $__sSQL_UDFVersion -->> look for: _ADO_UDFVersion() - mLipok
	.	Added: New example: ADO_EXAMPLE__PostgreSQL.au3 - mLipok
	.	Added: New example: ADO_EXAMPLE.au3 : _Example_Firebird() - Skysnake (https://www.autoitscript.com/forum/profile/59545-skysnake/)
	.
	.
	2016/02/26 '2.1.8 BETA'
	.	Added: Function: _ADO_ConnectionString_Access - mLipok
	.	Added: Function: _ADO_ConnectionString_Excel - mLipok
	.	Removed: Function: _ADO_Connection_OpenAccess - mLipok
	.			Look for: _ADO_Connection_OpenConString and _ADO_ConnectionString_Access
	.	Changed: Example: ADO_EXAMPLE__PostgreSQL.au3 >> ADO_EXAMPLE.au3 - mLipok
	.	ADO_EXAMPLE.au3: New Comments in script - mLipok
	.	ADO_EXAMPLE.au3: New Function: _Example_MSAccess() - mLipok
	.	ADO_EXAMPLE.au3: New Function: _Example_MSExcel() - mLipok
	.	ADO_EXAMPLE.au3: New Function: _Example_MSSQL() - mLipok
	.	ADO_EXAMPLE.au3: Renamed Function: _Example_PostgreSQL() - mLipok
	.
	.
	2016/03/01 '2.1.9 BETA'
	.	ADO_CONSTANTS.au3: CleanUp: $ADO_adErr - mLipok
	.	ADO_CONSTANTS.au3: CleanUp/Fixed: _ADO_ERROR_Description() - mLipok
	.	Moved: Function: _ADO_ERROR_Description - From: ADO_CONSTANTS.au3 To: ADO.au3 - mLipok
	.	Added: Function: _ADO_GetProvidersList - mLipok
	.			Thanks to @water for wiki tutorial: https://www.autoitscript.com/wiki/ADO_Tools
	.	Removed: Function: _SQL_FetchData - mLipok
	.	Removed: Function: _SQL_FetchNames - mLipok
	.	Changed: Function: _ADO_EVENTS_SetUp - Default is Disabled - mLipok
	.	Refactored: Function: __ADO_RecordsetArray_Display - mLipok
	.	ADO_EXAMPLE.au3: New Function: _Example_MySQL() - mLipok
	.
	.
	2016/03/01 '2.1.10 BETA'
	.	New: Function: _ADO_ConnectionString_MySQL() - mLipok
	.	Added: in few function added COM Error Handler - mLipok
	.	ADO_EXAMPLE.au3: Function: _Example_MySQL() - some change - mLipok
	.
	.
	2016/03/08 '2.1.11 BETA'
	.	New: Function: _ADO_OpenSchema_Catalogs - mLipok
	.	New: Function: _ADO_OpenSchema_Tables - mLipok
	.	New: Function: _ADO_OpenSchema_Columns - mLipok
	.	New: Function: _ADO_OpenSchema_Indexes - mLipok
	.	New: Function: _ADO_OpenSchema_Views - mLipok
	.	New: Function: _ADO_Schema_GetAllCatalogs - mLipok
	.	New: Function: _ADO_Schema_GetAllTables - mLipok
	.	New: Function: _ADO_Schema_GetAllViews - mLipok
	.	Removed: Function: _SQL_GetTableName - mLipok
	.	Removed: Function: _ADO_Connection_OpenExcel - mLipok
	.			Look for: _ADO_Connection_OpenConString and _ADO_ConnectionString_Excel
	.	Changed: ADO_EXAMPLE.au3 - _Example_MySQL() - mLipok
	.	Changed: ADO_EXAMPLE.au3 - _Example_PostgreSQL() - mLipok
	.	Renamed: Function: _ADO_Command >> _ADO_Command_Create - mLipok
	.	Changed: Function: _ADO_Command_Create: Parameters removed - $sQuery - mLipok
	.	New: Function: _ADO_Command_CreateParameter - mlipok
	.	New: Function: _ADO_Command_Execute - mlipok
	.	Added: ADO_EXAMPLE.au3 - _Example_MSSQL_COMMAND_StoredProcedure() - mLipok
	.
	.
	2016/03/09 '2.1.12 BETA'
	.	New: Enums: $ADO_ERR_ISCLOSEDOBJECT - mLipok
	.	New: Function: __ADO_Connection_IsOpen - mLipok
	.			__ADO_Connection_IsOpen is a wrapper for __ADO_Connection_IsValid  which also check for $oConnection.state and set $ADO_ERR_ISCLOSEDOBJECT
	.			__ADO_Connection_IsOpen is now used in few functions which uses $oConnection
	.	Changed: Function: __ADO_Recordset_IsNotEmpty - checking $oRecordset.state and return $ADO_ERR_ISCLOSEDOBJECT - mLipok
	.	Changed: Function: _ADO_Command_Execute - mlipok
	.			Now return recordset
	.	Changed: ADO_EXAMPLE.au3 - _Example_MSSQL_COMMAND_StoredProcedure() - mLipok
	.	Removed: Function: _ADO_Connection_OpenJet - mLipok
	.			Look for: _ADO_Connection_OpenConString or _ADO_ConnectionString_Excel
	.
	.
	2016/03/18 '2.1.13 BETA'
	.	Changed: _ADO_COMErrorHandler - now showing also _ADO_UDFVersion()  - mLipok
	.	New: Enums: $ADO_ERR_ISNOTREADYOBJECT - mLipok
	.	Renamed: Function: __ADO_Connection_IsOpen >> __ADO_Connection_IsReady - mLipok
	.	Changed: Function: __ADO_Connection_IsReady : new feature checking connection state and seting  $ADO_ERR_ISNOTREADYOBJECT - mLipok
	.	New: Function: __ADO_Recordset_IsReady - mLipok
	.			__ADO_Recordset_IsReady is a wrapper for __ADO_Recordset_IsValid
	.				which also check for $oRecordset.state and set $ADO_ERR_ISCLOSEDOBJECT also $ADO_ERR_ISNOTREADYOBJECT
	.			__ADO_Recordset_IsReady is now used in few functions which uses $oRecordset
	.	Changed: Function: __ADO_Recordset_IsNotEmpty : now using __ADO_Recordset_IsReady instead __ADO_Recordset_IsValid - mLipok
	.			as __ADO_Recordset_IsReady is wrapper for __ADO_Recordset_IsValid
	.			so now __ADO_Recordset_IsNotEmpty checking old and new feature
	.
	.	!!!!!!!!!!!!!!!!!!!!!!!!
	.	Renamed: _ADO_ERROR_Description >> _ADO_MSDNErrorValueEnum_Description
	.	New: Function: _ADO_GetErrorDescription - mLipok
	.	New: Function: _ADO_ConsoleError - mLipok
	.
	.
	2017/03/20 '2.1.14 BETA'
	.	Changed: Function: _ADO_COMErrorHandler - If @Compiled Then Return ....... - mLipok
	.	Examples: Fixed bug in example for XLS - mLipok
	.		thanks to ViciousXUSMC
	.		https://www.autoitscript.com/forum/topic/180850-adoau3-udf-beta-support-topic/?do=findComment&comment=1307690
	.	Examples: New Function: _ErrFunc($oError) - mLipok
	.		; HowTo: use your own COMErrorHandler instead internal ADO.au3 UDF COMError Handler - _ADO_COMErrorHandler
	.	Examples: New Function: _ErrDescription($sDescription = Default) - mLipok
	.		; store description to use it outsided UDF in your own function
	.	Added: #Au3Stripper_Ignore_Funcs=__ADO_EVENT__*  - mLipok
	.	Changed: _ADO_Execute automaticaly check __ADO_Recordset_IsNotEmpty($oRecordset) - mLipok
	.	Changed: Function: _ADO_ConnectionString_Access() - added support for '.accdb' when $sDriver = Default - mLipok
	.	Chnaged: $aRocordset >> $aRecordset - Skysnake
	.
	.
	.	!!! REMARK - I'm not sure when this following changes was happend
	.	Removed: Function: _ADO_OpenSchema_Views - MS SQL: Object or provider could not perform requested action - mLipok
	.		REF: https://msdn.microsoft.com/en-US/library/ee275169(v=bts.10).aspx
	.			For all DBMS only this four QueryType are common:
	.				adSchemaColumns, adSchemaIndexes, adSchemaTables, adSchemaProviderTypes
	.			The SchemaEnum values supported by the Microsoft® OLE DB Provider for DB2 and the Microsoft® ODBC Driver for DB2 can be one of the following constants:
	.				adSchemaColumns, adSchemaIndexes, adSchemaTables, adSchemaProviderTypes + adSchemaProcedures + adSchemaProcedureParameters + adSchemaPrimaryKeys
	.	Removed: Function: _ADO_Schema_GetAllViews - as _ADO_OpenSchema_Views() is also removed - mLipok
	.	Changed: Function: __ADO_IsValidObjectType - in case of @error occured, @extended always return $ADO_EXT_INTERNALFUNCTION - mLipok
	.	Changed: Function: _ADO_COMErrorHandler() - parameter $oADO_Error is now passed as ByRef - mLipok
	.	Added: Function INDEX - Skysnake
	.
	2017/05/28 '2.1.15 BETA'
	.	Fixed: Function: __ADO_Recordset_IsNotEmpty() - mLipok
	.		Thanks to @Skysnake for reporting
	.	Added: many description to functions - mLipok
	.	Added: many description to functions - thanks to Skysnake
	.	Refactored: _ADO_Recordset_Display - mLipok
	.	Changed: __ADO_Command_IsValid() - return values are now boolean - mLipok
	.	Changed: __ADO_Connection_IsReady() - return values are now boolean - mLipok
	.	Changed: __ADO_Connection_IsValid() - return values are now boolean - mLipok
	.	Changed: __ADO_IsValidObjectType() - return values are now boolean - mLipok
	.	Changed: __ADO_Recordset_IsNotEmpty() - return values are now boolean - mLipok
	.	Changed: __ADO_Recordset_IsReady() - return values are now boolean - mLipok
	.	Changed: __ADO_Recordset_IsValid() - return values are now boolean - mLipok
	.	Changed: __ADO_RecordsetArray_IsValid() - return values are now boolean - mLipok
	.
	2019/08/11 '2.1.16 BETA'
	.	Added: $oRecordset.Supports($ADO_adMovePrevious) in _ADO_Recordset_ToString() - xrxca
	.	Added: __ADO_MSSQL_CONNECTION_STRING_WinAuth() - mLipok
	.	Added: _ADO_GetDSNList() - mLipok
	.	Changed: _ADO_RecordsetArray_GetContent() - on succes @extended = UBound($aContent) - mLipok
	.
	.
	.	!!!!! SCRIPT BREAKING CHANGE !!!!!
	.	Removed: prameter $iAlternateColors from __ADO_RecordsetArray_Display() for compability wiht current AutoIt Version - mLipok
	.	Removed: prameter $iAlternateColors from _ADO_Recordset_Display() for compability wiht current AutoIt Version - mLipok

	2020/10/18 '2.1.17 BETA'
	.	Added: Function: _ADO_Connection_Create() - Assign __ADO_EVENT__* functions by default - mLipok
	. 	Added: Global Const $__g_oADO_EventsHandler - not needed as event function is assigned by default - mLipok
	. 	Added: Function: __ADO_EVENT__ExecuteComplete() - mLipok
	. 	Added: Function: __ADO_RowAffected() - mLipok
	. 	Added: Function: __ADO_EVENTS_ErrorCollectionAnalyzer() - mLipok
	. 	Added: Function: _ADO_EVENTS_ShowOnly_InfoMessages() - mLipok
	. 	Refactored: Function: _ADO_Connection_OpenMSSQL() - mLipok
	. 	Refactored: Function: _ADO_Connection_OpenMSSQL_WinAuth() - mLipok
	.
	.	!!!!! SCRIPT BREAKING CHANGE !!!!!
	. 	Removed: Funcion: __ADO_EVENTS_INIT() - mLipok
	. 	Removed: Funcion: _ADO_EVENTS_SetUp() - mLipok
	. 	Removed: Global $__g_fnFetchProgress - mLipok
	. 	Renamed: Function: _ADO_COMErrorHandler() >>> _ADO_COMErrorHandler_Function() - mLipok

	2020/10/18 '2.1.18 BETA'
	.	Added: New example: ADO_EXAMPLE__EventHandling.au3 - mLipok

	2020/11/09 '2.1.19 BETA'
	. 	Added: Function: __ADO_EVENT_InternalWrapper()  - mLipok
	. 	Added: Function: _ADO_EVENT_Wrapper()  - mLipok
	.	Changed: Function: _ADO_OpenSchema_*  - added checking __ADO_Recordset_IsNotEmpty($oRecordset) - mLipok
	.	Refactored: Function: _ADO_OpenSchema_*  - refactored + cleaned - mLipok
	.	Added: New example: ADO_EXAMPLE__Transactions.au3 - mLipok
	.	Renamed: Function: __ADO_ComErrorHandler_InternalFunction() >> __ADO_ComErrorHandler_WrapperFunction() - mLipok
	.	Removed: #AutoIt3Wrapper_Au3Check_Parameters - as should be only in examples - because should not force user to use Au3Check - mLipok
	.	Changed: suplemented/checked "Function Header's" - mLipok
	.

	@LAST
	. TODO:  Descripition to check:  On Success  - Returns $ADO_RET_SUCCESS

#ce

#EndRegion ADO.au3 - UDF Header

#Region ADO.au3 - Function INDEX ; @TODO 2020-11-08: should be reviewed
#cs
	; complete index of functions in ADO.UDF
	__ADO_RecordsetArray_Display(ByRef $aRecordset, $sTitle = '')
	__ADO_RecordsetArray_IsValid(ByRef $aRecordset)
	_ADO_Recordset_Display(ByRef $vRocordset, $sTitle = '', $bFieldNamesInFirstRow = False)
	_ADO_Recordset_Find(ByRef $oRecordset, $Criteria, $SkipRows = 0, $SearchDirection = $ADO_adSearchForward, $Start = $ADO_adBookmarkCurrent)
	_ADO_Recordset_ToArray(ByRef $oRecordset, $bFieldNamesInFirstRow = False)
	_ADO_Recordset_ToString(ByRef $oRecordset, $sDelim = "|", $bReturnColumnNames = True)
	_ADO_RecordsetArray_GetContent(ByRef $aRecordset)
	_ADO_RecordsetArray_GetFieldNames(ByRef $aRecordset)
	__ADO_Command_IsValid(ByRef $oCommand)
	__ADO_Connection_IsReady(ByRef $oConnection)
	__ADO_Connection_IsValid(ByRef $oConnection)
	__ADO_IsValidObjectType(ByRef $oObjectToCheck, $sRequiredProgID)
	__ADO_MSSQL_CONNECTION_STRING_SQLAuth($sServer, $sDataBase, $sUserName, $sPassword, $sAppName = Default, $bUseProviderInsteadDriver = True)
	__ADO_Recordset_IsNotEmpty(ByRef $oRecordset)
	__ADO_Recordset_IsReady(ByRef $oRecordset)
	__ADO_Recordset_IsValid(ByRef $oRecordset)
	_ADO_Command_Create(ByRef $oConnection, $iCommandType = $ADO_adCmdText)
	_ADO_Command_CreateParameter(ByRef $oCommand, $sName, $iSize, $vValue, $iType = $ADO_adChar, $iDirection = $ADO_adParamInputOutput)
	_ADO_Command_Execute(ByRef $oCommand, $sQuery)
	_ADO_Connection_Close(ByRef $oConnection)
	_ADO_Connection_CommandTimeout(ByRef $oConnection, $iTimeOut = Default)
	_ADO_Connection_Create()
	_ADO_Connection_OpenConString(ByRef $oConnection, $sConnectionString)
	_ADO_Connection_OpenMSSQL(ByRef $oConnection, $sServer, $sDBName, $sUserName, $sPassword, $sAppName = Default, $sWSID = Default, $bSQLAuth = True, $bUseProviderInsteadDriver = True)
	_ADO_Connection_PropertiesToArray(ByRef $oConnection)
	_ADO_Connection_Timeout(ByRef $oConnection, $iTimeOut = Default)
	_ADO_Execute(ByRef $oConnection, $sQuery, $bReturnAsArray = False, $bFieldNamesInFirstRow = False)
	_ADO_GetProvidersList()
	_ADO_MSSQL_GetDriverVersion()
	_ADO_MSSQL_GetProviderVersion()
	_ADO_Recordset_Create()
	_ADO_Version(ByRef $oConnection)
	__ADO_ComErrorHandler_WrapperFunction(ByRef $oCOMError)
	_ADO_COMErrorHandler_Function(ByRef $oADO_Error)
	_ADO_COMErrorHandler_UserFunction($fnUserFunction = Default)
	__ADO_EVENT__BeginTransComplete($iTransactionLevel, ByRef $oError, $i_adStatus, ByRef $oConnection)
	__ADO_EVENT__CommitTransComplete(ByRef $oError, $i_adStatus, ByRef $oConnection)
	__ADO_EVENT__ConnectComplete(ByRef $oError, $i_adStatus, ByRef $oConnection)
	__ADO_EVENT__Disconnect($i_adStatus, ByRef $oConnection)
	__ADO_EVENT__FetchComplete(ByRef $oError, $i_adStatus, ByRef $oRecordset)
	__ADO_EVENT__FetchProgress($iProgress, $iMaxProgress, $i_adStatus, ByRef $oRecordset)
	__ADO_EVENT__InfoMessage(ByRef $oError, $i_adStatus, ByRef $oConnection)
	__ADO_EVENT__RollbackTransComplete(ByRef $oError, $i_adStatus, ByRef $oConnection)
	__ADO_EVENT__WillConnect($sConnection_String, $sUserID, $sPassword, $iOptions, $i_adStatus, ByRef $oConnection)
	__ADO_EVENT__WillExecute($sSource, $iCursorType, $iLockType, $iOptions, $i_adStatus, ByRef $oCommand, ByRef $oRecordset, ByRef $oConnection)
	__ADO_EVENTS_INIT(ByRef $oConnection)
	_ADO_EVENTS_SetUp($bInitializeEvents = Default)
	__ADO_ConsoleWrite_Blue($sText)
	__ADO_ConsoleWrite_Red($sText)
	_ADO_ConsoleError($sDescription = '', $iError = @error, $iExtended = @extended)
	_ADO_GetErrorDescription($sDescription = '', $bShowHumanReadableDescription = True, $iError = @error, $iExtended = @extended)
	_ADO_MSDNErrorValueEnum_Description($iError, $iErrorMacro = @error, $iExtendedMacro = @extended)
	_ADO_UDFVersion()
	_Au3Date_to_SQLDate($sAu3Date)
	_SQLDate_to_Au3Date($sDate, $bOnlyYMD = False)
	_ADO_OpenSchema_Catalogs(ByRef $oConnection, $s_CATALOG_NAME = Default)
	_ADO_OpenSchema_Columns(ByRef $oConnection, $s_TABLE_CATALOG = Default, $s_TABLE_SCHEMA = Default, $s_TABLE_NAME = Default, $s_COLUMN_NAME = Default)
	_ADO_OpenSchema_Indexes(ByRef $oConnection, $s_TABLE_CATALOG = Default, $s_TABLE_SCHEMA = Default, $s_INDEX_NAME = Default, $s_TYPE = Default, $s_TABLE_NAME = Default)
	_ADO_OpenSchema_Procedures(ByRef $oConnection, $s_PROCEDURE_CATALOG = Default, $s_PROCEDURE_SCHEMA = Default, $s_PROCEDURE_NAME = Default, $s_PARAMETER_NAME = Default)
	_ADO_OpenSchema_Tables(ByRef $oConnection, $s_TABLE_CATALOG = Default, $s_TABLE_SCHEMA = Default, $s_TABLE_NAME = Default, $s_TABLE_TYPE = Default)
	_ADO_Schema_GetAllCatalogs(ByRef $oConnection)
	_ADO_Schema_GetAllTables(ByRef $oConnection, $s_TABLE_CATALOG)
	_ADO_ConnectionString_Access($sFileFullPath, $sUser = Default, $sPassword = Default, $sDriver = Default)
	_ADO_ConnectionString_Excel($sFileFullPath = Default, $sProvider = Default, $sExtProperties = Default, $HDR = Default, $IMEX = Default)
	_ADO_ConnectionString_MySQL($sUser, $sPassword, $sDataBase, $sDriver = Default, $sServer = Default, $sPort = Default)
#ce
#EndRegion ADO.au3 - Function INDEX ; @TODO 2020-11-08: should be reviewed

#Region ADO.au3 - Functions

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_RecordsetArray_Display
; Description ...: Displays result array returned by a data set
; Syntax ........: __ADO_RecordsetArray_Display(Byref $aRecordset[, $sTitle = ''])
; Parameters ....: $aRecordset          - [in/out] an array of data - fileds name and records taken from recordset.
;                  $sTitle              - [optional] a string value. Default is ''.
; Return values .: On Success - $ADO_RET_SUCCESS
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......: TODO - description checking
; Related .......:
; Link ..........:
; Example .......: __ADO_RecordsetArray_Display(Byref $aRecordset, 'This is a title', 0xFFFFFF)
; ===============================================================================================================================
Func __ADO_RecordsetArray_Display(ByRef $aRecordset, $sTitle = '')
	If __ADO_RecordsetArray_IsValid($aRecordset) Then
		Local $sArrayHeader = _ArrayToString($aRecordset[$ADO_RS_ARRAY_FIELDNAMES], '|')
		Local $aSelect = _ADO_RecordsetArray_GetContent($aRecordset)
		_ArrayDisplay($aSelect, $sTitle, "", 0, '|', $sArrayHeader)
		If @error Then Return SetError($ADO_ERR_GENERAL, $ADO_EXT_DEFAULT, $ADO_RET_FAILURE)
		Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)
	ElseIf UBound($aRecordset) Then
		_ArrayDisplay($aRecordset, $sTitle, "", 0)
		If @error Then Return SetError($ADO_ERR_GENERAL, $ADO_EXT_DEFAULT, $ADO_RET_FAILURE)
		Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)
	EndIf
	Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM1, $ADO_RET_FAILURE)
EndFunc   ;==>__ADO_RecordsetArray_Display

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_RecordsetArray_IsValid
; Description ...: Tests that passed array is valid "ADO UDF RecordsetArray"
; Syntax ........: __ADO_RecordsetArray_IsValid(Byref $aRecordset)
; Parameters ....: $aRecordset          - [in/out] an array of data - fileds name and records taken from recordset.
; Return values .: On Success - True
;                  On Failure - False and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......: TODO - description check
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_RecordsetArray_IsValid(ByRef $aRecordset)
	If _
			UBound($aRecordset, $UBOUND_DIMENSIONS) = 1 _
			And UBound($aRecordset, $UBOUND_ROWS) = $ADO_RS_ARRAY_ENUMCOUNTR _
			And $aRecordset[$ADO_RS_ARRAY_GUID] = $ADO_RS_GUID _
			Then
		Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, True)
	EndIf
	Return SetError($ADO_ERR_INVALIDARRAY, $ADO_EXT_DEFAULT, False)
EndFunc   ;==>__ADO_RecordsetArray_IsValid

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Recordset_Display
; Description ...: Display Recordset content with _ArrayDisplay()
; Syntax ........: _ADO_Recordset_Display(Byref $vRocordset[, $sTitle = ''[, $bFieldNamesInFirstRow = False]])
; Parameters ....: $vRocordset          - [in/out] a variant value. Could be object $oRecordset or Array
;                  $sTitle              - [optional] a string value. Default is ''.
;                  $bFieldNamesInFirstRow- [optional] a boolean value. Default is False.
; Return values .: On Success - $ADO_RET_SUCCESS
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_Recordset_Display(ByRef $vRocordset, $sTitle = '', $bFieldNamesInFirstRow = False)
	Local $vResult = $ADO_RET_FAILURE
	If UBound($vRocordset) Then
		$vResult = __ADO_RecordsetArray_Display($vRocordset, $sTitle)
		Return SetError(@error, @extended, $vResult)
	EndIf

	Local $aRecordset_GetRowsResult = _ADO_Recordset_ToArray($vRocordset, $bFieldNamesInFirstRow)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	$vResult = __ADO_RecordsetArray_Display($aRecordset_GetRowsResult, $sTitle)
	Return SetError(@error, @extended, $vResult)
EndFunc   ;==>_ADO_Recordset_Display

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Recordset_Find
; Description ...: Searches a Recordset for the row that satisfies the specified criteria.
; Syntax ........: _ADO_Recordset_Find(Byref $oRecordset, $Criteria[, $SkipRows = 0[, $SearchDirection = $ADO_adSearchForward[, $Start = $ADO_adBookmarkCurrent]]])
; Parameters ....: $oRecordset          - [in/out] an object representing ADO Recordset.
;                  $Criteria            - An unknown value.
;                  $SkipRows            - [optional] An unknown value. Default is 0.
;                  $SearchDirection     - [optional] An unknown value. Default is $ADO_adSearchForward.
;                  $Start               - [optional] An unknown value. Default is $ADO_adBookmarkCurrent.
; Return values .: On Success - $ADO_RET_SUCCESS + check Remarks
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......: If the criteria is met, the current row position is set on the found record; otherwise, the position is set to the end (or start) of the Recordset.
; Related .......:
; Link ..........: http://msdn.microsoft.com/en-us/library/windows/desktop/ms676117(v=vs.85).aspx
; Link ..........: https://msdn.microsoft.com/en-us/library/ee275542(v=bts.10).aspx
; Example .......: No
; ===============================================================================================================================
Func _ADO_Recordset_Find(ByRef $oRecordset, $Criteria, $SkipRows = 0, $SearchDirection = $ADO_adSearchForward, $Start = $ADO_adBookmarkCurrent)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Recordset_IsNotEmpty($oRecordset)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	$oRecordset.Find($Criteria, $SkipRows, $SearchDirection, $Start)
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)
EndFunc   ;==>_ADO_Recordset_Find

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Recordset_ToArray
; Description ...: Transform $oRecordset to an 2Dimensional Array
; Syntax ........: _ADO_Recordset_ToArray(Byref $oRecordset[, $bFieldNamesInFirstRow = False])
; Parameters ....: $oRecordset          - [in/out] an object representing ADO Recordset.
;                  $bFieldNamesInFirstRow- [optional] a boolean value. Default is False.
; Return values .: On Success - $aResult
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......: $bFieldNamesInFirstRow = False is much more faster when Recordset has many rows
; Related .......: _ADO_Recordset_ToString
; Link ..........: https://msdn.microsoft.com/en-us/library/ee266344(v=bts.10).aspx
; Example .......: No
; ===============================================================================================================================
Func _ADO_Recordset_ToArray(ByRef $oRecordset, $bFieldNamesInFirstRow = False)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler
	
	__ADO_Recordset_IsNotEmpty($oRecordset)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)
	
	; save current Recordset rows position to $oRecordset_Bookmark
	Local $oRecordset_Bookmark = Null
	If $oRecordset.Supports($ADO_adBookmark) Then $oRecordset_Bookmark = $oRecordset.Bookmark

	;$oRecordset.moveFirst()
	Local $aRecordset_GetRowsResult = $oRecordset.GetRows()
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE) ; Trap COM error, report and return
	
	If UBound($aRecordset_GetRowsResult) Then
		Local $aResult[0]

		; Restore Recordset row position from stored $oRecordset_Bookmark
		If $oRecordset_Bookmark = Null Then
			;$oRecordset.moveFirst()
		Else
			$oRecordset.Bookmark = $oRecordset_Bookmark
		EndIf

		Local $iColumns_count = UBound($aRecordset_GetRowsResult, $UBOUND_COLUMNS)
		Local $iRows_count = UBound($aRecordset_GetRowsResult)
		
		If $bFieldNamesInFirstRow Then
			; Adjust the array to fit the column names and move all data down 1 row
			ReDim $aRecordset_GetRowsResult[$iRows_count + 1][$iColumns_count]

			; Move all records down
			For $iRow_idx = $iRows_count To 1 Step -1
				For $y = 0 To $iColumns_count - 1
					$aRecordset_GetRowsResult[$iRow_idx][$y] = $aRecordset_GetRowsResult[$iRow_idx - 1][$y]
				Next
			Next

			; Add the coloumn names
			For $iCol_idx = 0 To $iColumns_count - 1 ; get the column names and put into 0 array element
				$aRecordset_GetRowsResult[0][$iCol_idx] = $oRecordset.Fields($iCol_idx).Name
			Next
			$aResult = $aRecordset_GetRowsResult
			Return SetError($ADO_ERR_SUCCESS, $iRows_count + 1, $aResult)
		EndIf

		ReDim $aResult[$ADO_RS_ARRAY_ENUMCOUNTR]
		Local $aFiledNames_Temp[$iColumns_count]

		For $iCol_idx = 0 To $iColumns_count - 1 ; get the column names and put into 0 array element
			$aFiledNames_Temp[$iCol_idx] = $oRecordset.Fields($iCol_idx).Name
		Next
		$aResult[$ADO_RS_ARRAY_GUID] = $ADO_RS_GUID
		$aResult[$ADO_RS_ARRAY_FIELDNAMES] = $aFiledNames_Temp
		$aResult[$ADO_RS_ARRAY_RSCONTENT] = $aRecordset_GetRowsResult
		Return SetError($ADO_ERR_SUCCESS, $iRows_count, $aResult)

	EndIf

	Return SetError($ADO_ERR_RECORDSETEMPTY, $ADO_EXT_DEFAULT, $ADO_RET_FAILURE)
EndFunc   ;==>_ADO_Recordset_ToArray

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Recordset_ToString
; Description ...: Convert current recordset Object to String
; Syntax ........: _ADO_Recordset_ToString(Byref $oRecordset[, $sDelim = "|"[, $bReturnColumnNames = True]])
; Parameters ....: $oRecordset          - [in/out] an object representing ADO Recordset.
;                  $sDelim              - [optional] a string value. Default is "|".
;                  $bReturnColumnNames  - [optional] a boolean value. Default is True.
; Return values .: On Success - string
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......: @TODO - $bReturnColumnNames
; Related .......:
; Link ..........: https://msdn.microsoft.com/en-us/library/ms676975(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func _ADO_Recordset_ToString(ByRef $oRecordset, $sDelim = "|", $bReturnColumnNames = True)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, '')
	#forceref $oADO_COMErrorHandler

	__ADO_Recordset_IsNotEmpty($oRecordset)
	If @error Then Return SetError(@error, @extended, '')

	#forceref $bReturnColumnNames ; @TODO no yet implemented

	; save current Recordset rows postion to $oRecordset_Bookmark
	Local $oRecordset_Bookmark = Null
	If $oRecordset.Supports($ADO_adBookmark) Then $oRecordset_Bookmark = $oRecordset.Bookmark

	; GetString Method (ADO)
	Local $sString = $oRecordset.GetString($ADO_adClipString, $oRecordset.RecordCount, $sDelim, @CR, 'Null')
	If @error Then ; Trap COM error, report and return
		Return SetError($ADO_ERR_COMERROR, @error, '')
	ElseIf IsString($sString) Then
		; Restore Recordset row position from stored $oRecordset_Bookmark
		If $oRecordset_Bookmark = Null Then
			If $oRecordset.Supports($ADO_adMovePrevious) Then $oRecordset.moveFirst()
		Else
			$oRecordset.Bookmark = $oRecordset_Bookmark
		EndIf

		Return SetError($ADO_ERR_SUCCESS, $oRecordset.RecordCount, $sString)
	EndIf

	Return SetError($ADO_ERR_RECORDSETEMPTY, $ADO_EXT_DEFAULT, '')
EndFunc   ;==>_ADO_Recordset_ToString

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_RecordsetArray_GetContent
; Description ...: Extract internal "Rows array" from "RecordsetArray"
; Syntax ........: _ADO_RecordsetArray_GetContent(Byref $aRecordset)
; Parameters ....: $aRecordset          - [in/out] an array of unknowns.
; Return values .: On Success - array
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: _ADO_Recordset_ToArray, _ADO_Execute
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_RecordsetArray_GetContent(ByRef $aRecordset)
	__ADO_RecordsetArray_IsValid($aRecordset)
	If @error Then Return SetError(@error, @extended, Null)
	Local $aContent = $aRecordset[$ADO_RS_ARRAY_RSCONTENT]
	Return SetError($ADO_ERR_SUCCESS, UBound($aContent), $aContent)
EndFunc   ;==>_ADO_RecordsetArray_GetContent

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_RecordsetArray_GetFieldNames
; Description ...: Extract internal FiledNames array with from "RecordsetArray"
; Syntax ........: _ADO_RecordsetArray_GetFieldNames(Byref $aRecordset)
; Parameters ....: $aRecordset          - [in/out] an array of arrays - returned from _ADO_Recordset_ToArray or _ADO_Execute
; Return values .: On Success - array
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: _ADO_Recordset_ToArray, _ADO_Execute
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_RecordsetArray_GetFieldNames(ByRef $aRecordset)
	__ADO_RecordsetArray_IsValid($aRecordset)
	If @error Then Return SetError(@error, @extended, Null)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $aRecordset[$ADO_RS_ARRAY_FIELDNAMES])
EndFunc   ;==>_ADO_RecordsetArray_GetFieldNames
#EndRegion ADO.au3 - Functions

#Region ADO.au3 - Functions - Connection & Management

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_Command_IsValid
; Description ...:
; Syntax ........: __ADO_Command_IsValid(Byref $oCommand)
; Parameters ....: $oCommand            - [in/out] an object representing ADO Command.
; Return values .: On Success - True
;                  On Failure - False and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......: TODO - description
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_Command_IsValid(ByRef $oCommand)
	Local $bValidationResult = __ADO_IsValidObjectType($oCommand, 'ADODB.Command')
	Return SetError(@error, @extended, $bValidationResult)
EndFunc   ;==>__ADO_Command_IsValid

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_Connection_IsReady
; Description ...: Check if connection object is in ready state
; Syntax ........: __ADO_Connection_IsReady(Byref $oConnection)
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: On Success - True
;                  On Failure - False and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......: TODO - description
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_Connection_IsReady(ByRef $oConnection)
	Local $bValidationResult = __ADO_Connection_IsValid($oConnection)
	If @error Then
		Return SetError(@error, @extended, False)
	ElseIf $oConnection.state = $ADO_adStateClosed Then
		Return SetError($ADO_ERR_ISCLOSEDOBJECT, $ADO_EXT_DEFAULT, False)
	ElseIf $oConnection.state <> $ADO_adStateOpen Then
		Return SetError($ADO_ERR_ISNOTREADYOBJECT, $ADO_EXT_DEFAULT, False)
	EndIf

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $bValidationResult)
EndFunc   ;==>__ADO_Connection_IsReady

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_Connection_IsValid
; Description ...: Check if object is valid "ADODB.Connection" object
; Syntax ........: __ADO_Connection_IsValid(Byref $oConnection)
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: On Success - True
;                  On Failure - False and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_Connection_IsValid(ByRef $oConnection)
	Local $bValidationResult = __ADO_IsValidObjectType($oConnection, 'ADODB.Connection')
	Return SetError(@error, @extended, $bValidationResult)
EndFunc   ;==>__ADO_Connection_IsValid

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_IsValidObjectType
; Description ...: Check if object is valid object with proper $sRequiredProgID
; Syntax ........: __ADO_IsValidObjectType(Byref $oObjectToCheck, $sRequiredProgID)
; Parameters ....: $oObjectToCheck      - [in/out] an object.
;                  $sRequiredProgID     - a string value.
; Return values .: On Success - True
;                  On Failure - False and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_IsValidObjectType(ByRef $oObjectToCheck, $sRequiredProgID)
	If Not IsString($sRequiredProgID) Then
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_INTERNALFUNCTION, False)
	ElseIf $sRequiredProgID = '' Then
		Return SetError($ADO_ERR_INVALIDPARAMETERVALUE, $ADO_EXT_INTERNALFUNCTION, False)
	ElseIf Not IsObj($oObjectToCheck) Then
		Return SetError($ADO_ERR_ISNOTOBJECT, $ADO_EXT_INTERNALFUNCTION, False)
	ElseIf StringInStr(ObjName($oObjectToCheck, $OBJ_PROGID), $sRequiredProgID) = 0 Then
		Return SetError($ADO_ERR_INVALIDOBJECTTYPE, $ADO_EXT_INTERNALFUNCTION, False)
	EndIf

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, True)
EndFunc   ;==>__ADO_IsValidObjectType

; #FUNCTION# ====================================================================================================================
; Name ..........: __ADO_MSSQL_CONNECTION_STRING_SQLAuth
; Description ...: Create connection string for MS SQL using SQL Authentification
; Syntax ........: __ADO_MSSQL_CONNECTION_STRING_SQLAuth($sServer, $sDataBase, $sUserName, $sPassword[, $sAppName = Default[,
;                  $bUseProviderInsteadDriver = True]])
; Parameters ....: $sServer             - A string value. The server to connect to.
;                  $sDataBase           - A string value. The database name to open.
;                  $sUserName           - A string value. Username for database access.
;                  $sPassword           - A string value. Password for database user.
;                  $sAppName            - [optional] a string value. Default is Default.  AppName for SQL Connection list.
;                  $bUseProviderInsteadDriver- [optional] A binary value. Default is True.
; Return values .: $sConnectionString
; Author ........: mLipok
; Modified ......:
; Remarks .......: If $sAppName is specified, this value is stored in the master.dbo.sysprocesses column program_name and is returned by sp_who and the APP_NAME functions.
; Related .......:
; Link ..........: https://msdn.microsoft.com/pl-pl/library/ms130822(v=sql.110).aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_MSSQL_CONNECTION_STRING_SQLAuth($sServer, $sDataBase, $sUserName, $sPassword, $sAppName = Default, $bUseProviderInsteadDriver = True)
	Local Static $sConnectionString = ''
	Local Static $sLastParameters = Default
	Local $sNewParameters = $sServer & $sDataBase & $sUserName & $sPassword & $sAppName & $bUseProviderInsteadDriver

	If $sLastParameters <> $sNewParameters Then
		If $bUseProviderInsteadDriver Then
			$sConnectionString = "PROVIDER=" & _ADO_MSSQL_GetProviderVersion() & ";SERVER=" & $sServer & ";DATABASE=" & $sDataBase & ";UID=" & $sUserName & ";PWD=" & $sPassword & ";"
			If $sAppName <> Default And $sAppName <> '' Then $sConnectionString &= 'Application Name=' & $sAppName & ';'
		Else
			$sConnectionString = "DRIVER={" & _ADO_MSSQL_GetDriverVersion() & "};SERVER=" & $sServer & ";DATABASE=" & $sDataBase & ";UID=" & $sUserName & ";PWD=" & $sPassword & ";"
			If $sAppName <> Default And $sAppName <> '' Then $sConnectionString &= 'APPNAME=' & $sAppName & ';'
		EndIf
		$sLastParameters = $sNewParameters
	EndIf

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $sConnectionString)

EndFunc   ;==>__ADO_MSSQL_CONNECTION_STRING_SQLAuth

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_MSSQL_CONNECTION_STRING_WinAuth
; Description ...: create connection string for MS SQL using Windows Authentification
; Syntax ........: __ADO_MSSQL_CONNECTION_STRING_WinAuth($sServer, $sDataBase[, $sAppName = Default[,
;                  $bUseProviderInsteadDriver = True]])
; Parameters ....: $sServer             - a string value.
;                  $sDataBase           - a string value.
;                  $sAppName            - [optional] a string value. Default is Default. AppName for SQL Connection list.
;                  $bUseProviderInsteadDriver- [optional] a boolean value. Default is True.
; Return values .: $sConnectionString
; Author ........: mLipok
; Modified ......:
; Remarks .......: If $sAppName is specified, this value is stored in the master.dbo.sysprocesses column program_name and is returned by sp_who and the APP_NAME functions.
; Remarks .......: @TODO FIRST RELEASE IN ADO
; Related .......:
; Link ..........: https://msdn.microsoft.com/pl-pl/library/ms130822(v=sql.110).aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_MSSQL_CONNECTION_STRING_WinAuth($sServer, $sDataBase, $sAppName = Default, $bUseProviderInsteadDriver = True)
	Local Static $sConnectionString = ''
	Local Static $sLastParameters = Default
	Local $sNewParameters = $sServer & $sDataBase & $sAppName & $bUseProviderInsteadDriver

	If $sLastParameters <> $sNewParameters Then
		If $bUseProviderInsteadDriver Then
			$sConnectionString = "PROVIDER={" & _ADO_MSSQL_GetProviderVersion() & "};SERVER=" & $sServer & ";DATABASE=" & $sDataBase & ";"
			$sConnectionString &= "Trusted_Connection=yes;"
			If $sAppName <> Default And $sAppName <> '' Then $sConnectionString &= 'Application Name=' & $sAppName & ';'
		Else
			$sConnectionString = "DRIVER={" & _ADO_MSSQL_GetDriverVersion() & "};SERVER=" & $sServer & ";DATABASE=" & $sDataBase & ";"
			$sConnectionString &= "Trusted_Connection=yes;"
			If $sAppName <> Default And $sAppName <> '' Then $sConnectionString &= 'APPNAME=' & $sAppName & ';'
		EndIf
		$sLastParameters = $sNewParameters
	EndIf

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $sConnectionString)

EndFunc   ;==>__ADO_MSSQL_CONNECTION_STRING_WinAuth

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_Recordset_IsNotEmpty
; Description ...: Check if connection Recordset object content
; Syntax ........: __ADO_Recordset_IsNotEmpty(Byref $oRecordset)
; Parameters ....: $oRecordset          - [in/out] an object representing ADO Recordset.
; Return values .: On Success - True
;                  On Failure - False and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_Recordset_IsNotEmpty(ByRef $oRecordset)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, False)
	#forceref $oADO_COMErrorHandler

	__ADO_Recordset_IsReady($oRecordset)
	If @error Then
		Return SetError(@error, @extended, False)
	ElseIf $oRecordset.bof And $oRecordset.eof Then ; no current record
		Return SetError($ADO_ERR_NOCURRENTRECORD, $ADO_EXT_DEFAULT, False)
	ElseIf $oRecordset.RecordCount = 0 Then
		Return SetError($ADO_ERR_RECORDSETEMPTY, $ADO_EXT_DEFAULT, False)
	EndIf

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, True)
EndFunc   ;==>__ADO_Recordset_IsNotEmpty

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_Recordset_IsReady
; Description ...: Check if connection Recordset object state
; Syntax ........: __ADO_Recordset_IsReady(Byref $oRecordset)
; Parameters ....: $oRecordset         - [in/out] an object.
; Return values .: On Success - True
;                  On Failure - False and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......: TODO - description
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_Recordset_IsReady(ByRef $oRecordset)
	__ADO_Recordset_IsValid($oRecordset)
	
	If @error Then
		Return SetError(@error, @extended, False)
	ElseIf $oRecordset.state = $ADO_adStateClosed Then
		Return SetError($ADO_ERR_ISCLOSEDOBJECT, $ADO_EXT_DEFAULT, False)
	ElseIf $oRecordset.state <> $ADO_adStateOpen Then
		Return SetError($ADO_ERR_ISNOTREADYOBJECT, $ADO_EXT_DEFAULT, False)
;~ 	ElseIf $oRecordset.status <> $ADO_adRecOK Then
;~ 		Return SetError($ADO_ERR_ISNOTREADYOBJECT, $oRecordset.status, False)
	EndIf

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, True)
EndFunc   ;==>__ADO_Recordset_IsReady

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_Recordset_IsValid
; Description ...: Check object is valid "ADODB.Recordset" object
; Syntax ........: __ADO_Recordset_IsValid(Byref $oRecordset)
; Parameters ....: $oRecordset          - [in/out] an object representing ADO Recordset.
; Return values .: On Success - True
;                  On Failure - False and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_Recordset_IsValid(ByRef $oRecordset)
	Local $bValidationResult = __ADO_IsValidObjectType($oRecordset, 'ADODB.Recordset')
	Return SetError(@error, @extended, $bValidationResult)
EndFunc   ;==>__ADO_Recordset_IsValid

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Command_Create
; Description ...: Create Command object
; Syntax ........: _ADO_Command_Create(Byref $oConnection[, $iCommandType = $ADO_adCmdText])
; Parameters ....: $oConnection         - [in/out] an object.
;                  $iCommandType        - [optional] an integer value. Default is $ADO_adCmdText.
; Return values .: On Success - $oCommand
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_Command_Create(ByRef $oConnection, $iCommandType = $ADO_adCmdText)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsReady($oConnection)
	If @error Then
		Return SetError(@error, @extended, $ADO_RET_FAILURE)
	ElseIf Not IsInt($iCommandType) Then
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM2, $ADO_RET_FAILURE)
	EndIf

	Local $oCommand = ObjCreate("ADODB.Command")
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	$oCommand.ActiveConnection = $oConnection
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	$oCommand.CommandType = $iCommandType
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oCommand)
EndFunc   ;==>_ADO_Command_Create

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Command_CreateParameter
; Description ...: Creates a new Parameter object with the specified properties.
; Syntax ........: _ADO_Command_CreateParameter(Byref $oCommand, $sName, $iSize, $vValue[, $iType = $ADO_adChar[, $iDirection = $ADO_adParamInputOutput ]])
; Parameters ....: $oCommand            - [in/out] an object representing ADO Command.
;                  $sName               - a string value.
;                  $iSize               - an integer value.
;                  $vValue              - a variant value.
;                  $iType               - [optional] an integer value. Default is $ADO_adChar.
;                  $iDirection          - [optional] an integer value. Default is $ADO_adParamInputOutput .
; Return values .: On Success - $ADO_RET_SUCCESS
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://msdn.microsoft.com/en-us/library/ms677209(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func _ADO_Command_CreateParameter(ByRef $oCommand, $sName, $iSize, $vValue, $iType = $ADO_adChar, $iDirection = $ADO_adParamInputOutput)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Command_IsValid($oCommand)
	If @error Then
		Return SetError(@error, @extended, $ADO_RET_FAILURE)
	ElseIf Not IsString($sName) Then
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM2, $ADO_RET_FAILURE)
	ElseIf $sName = '' Then
		Return SetError($ADO_ERR_INVALIDPARAMETERVALUE, $ADO_EXT_PARAM2, $ADO_RET_FAILURE)
	ElseIf Not IsInt($iSize) Then
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM3, $ADO_RET_FAILURE)
	ElseIf Not $iSize > 0 Then
		Return SetError($ADO_ERR_INVALIDPARAMETERVALUE, $ADO_EXT_PARAM3, $ADO_RET_FAILURE)
	EndIf

	Local $oParameter = Null
	If $vValue = Default Then
		$oParameter = $oCommand.CreateParameter($sName, $iType, $iDirection, $iSize)
	Else
		$oParameter = $oCommand.CreateParameter($sName, $iType, $iDirection, $iSize, $vValue)
	EndIf
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)

	$oCommand.Parameters.Append($oParameter)
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)
EndFunc   ;==>_ADO_Command_CreateParameter

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Command_Execute
; Description ...: Executes the query, SQL statement, or stored procedure specified in the CommandText or CommandStream property of the Command object.
; Syntax ........: _ADO_Command_Execute(Byref $oCommand, $sQuery)
; Parameters ....: $oCommand            - [in/out] an object representing ADO Command.
;                  $sQuery              - a string value.
; Return values .: On Success - $oRecordset
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://msdn.microsoft.com/en-us/library/ms681559(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func _ADO_Command_Execute(ByRef $oCommand, $sQuery)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Command_IsValid($oCommand)
	If @error Then
		Return SetError(@error, @extended, $ADO_RET_FAILURE)
	ElseIf Not IsString($sQuery) Then
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM2, $ADO_RET_FAILURE)
	ElseIf $sQuery = '' Then
		Return SetError($ADO_ERR_INVALIDPARAMETERVALUE, $ADO_EXT_PARAM2, $ADO_RET_FAILURE)
	EndIf

	$oCommand.CommandText = $sQuery
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Local $iRecordsAffected = -1
	Local $oRecordset = $oCommand.Execute($iRecordsAffected)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)
	; @TODO Support for  __ADO_RowAffected() ?

	Return SetError($ADO_ERR_SUCCESS, $iRecordsAffected, $oRecordset)
EndFunc   ;==>_ADO_Command_Execute

; #FUNCTION# ===================================================================
; Name ..........: _ADO_Connection_Close
; Description ...: Closes an open ADODB.Connection
; Syntax.........:  _ADO_Connection_Close (ByRef $oConnection)
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: On Success - $ADO_RET_SUCCESS
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: Chris Lambert
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; no
; ==============================================================================
Func _ADO_Connection_Close(ByRef $oConnection)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsValid($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	$oConnection.Close
	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)
EndFunc   ;==>_ADO_Connection_Close

; #FUNCTION# ===================================================================
; Name ..........: _ADO_Connection_CommandTimeout
; Description ...: Sets and retrieves SQL CommandTimeout
; Syntax.........:  _ADO_Connection_CommandTimeout(ByRef $oConnection,$iTimeout)
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
;                  $iTimeout   			- The timeout period to set if left blank the current value will be retrieved
; Return values .: On Success - SQL Command timeout period
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: Chris Lambert
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........; https://msdn.microsoft.com/en-us/library/ms678265(v=vs.85).aspx
; Example .......; no
; ==============================================================================
Func _ADO_Connection_CommandTimeout(ByRef $oConnection, $iTimeOut = Default)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsValid($oConnection)
	If @error Then
		Return SetError(@error, @extended, $ADO_RET_FAILURE)
	ElseIf $iTimeOut = Default Then
		Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oConnection.CommandTimeout)
	ElseIf Not IsInt($iTimeOut) Then
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_DEFAULT, $ADO_RET_FAILURE)
	Else
		$oConnection.CommandTimeout = $iTimeOut
		Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oConnection.CommandTimeout)
	EndIf
EndFunc   ;==>_ADO_Connection_CommandTimeout

; #FUNCTION# ===================================================================
; Name ..........: _ADO_Connection_Create
; Description ...: Creates ADODB.Connection object
; Syntax.........:  _ADO_Connection_Create()
; Parameters ....: None
; Return values .: On Success - $oConnection Object
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: Chris Lambert
; Modified ......: mLipok
; Remarks .......: this function automaticaly add event handling for created connection object
; Related .......: _ADO_EVENT_Wrapper
; Link ..........;
; Example .......; no
; ==============================================================================
Func _ADO_Connection_Create()
	Local $oConnection = ObjCreate("ADODB.Connection")
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)

	Local $oADO_EventsHandler = ObjEvent($oConnection, "__ADO_EVENT__")
	#forceref $oADO_EventsHandler
	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oConnection)
EndFunc   ;==>_ADO_Connection_Create

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Connection_OpenConString
; Description ...: Open Connection based on Connection String passed to the function
; Syntax ........: _ADO_Connection_OpenConString(Byref $oConnection, $sConnectionString)
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
;                  $sConnectionString   - a string value.
; Return values .: On Success - $ADO_RET_SUCCESS
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......: @TODO - description
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_Connection_OpenConString(ByRef $oConnection, $sConnectionString)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsValid($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	If @error Or $oConnection.State <> $ADO_adStateOpen Then _
			Return SetError($ADO_ERR_CONNECTION, @error, $ADO_RET_FAILURE)
	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)
EndFunc   ;==>_ADO_Connection_OpenConString

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Connection_OpenMSSQL
; Description ...: Starts a Database Connection to Microsoft SQL Server
; Syntax ........: _ADO_Connection_OpenMSSQL(Byref $oConnection, $sServer, $sDBName, $sUserName, $sPassword[, $sAppName = Default[,
;                  $sWSID = Default[, $bSQLAuth = True [, $bUseProviderInsteadDriver = True]]]])
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
;                  $sServer             - a string value. The server to connect to.
;                  $sDBName             - a string value. The database name to open.
;                  $sUserName           - a string value. Username for database access.
;                  $sPassword           - a string value. Password for database user.
;                  $sAppName            - [optional] a string value. Default is Default.  AppName for SQL Connection list.
;                  $sWSID               - [optional] a string value. Default is Default.
;                  $bSQLAuth            - [optional] a boolean value. Default is True.
;                  $bUseProviderInsteadDriver- [optional] a boolean value. Default is True.
; Return values .: On Success - $ADO_RET_SUCCESS
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: Chris Lambert
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........: https://msdn.microsoft.com/pl-pl/library/ms130822(v=sql.110).aspx
; Example .......: No
; ===============================================================================================================================
Func _ADO_Connection_OpenMSSQL(ByRef $oConnection, $sServer, $sDBName, $sUserName, $sPassword, $sAppName = Default, $sWSID = Default, $bSQLAuth = True, $bUseProviderInsteadDriver = True)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsValid($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	If $oConnection.State = $ADO_adStateOpen Then _
			Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)

	Local $sConnectionString = ''
	If $bSQLAuth = True Then
		$sConnectionString = __ADO_MSSQL_CONNECTION_STRING_SQLAuth($sServer, $sDBName, $sUserName, $sPassword, $sAppName, $bUseProviderInsteadDriver)
	Else
;~ 		$oConnection.Properties("Integrated Security").Value = "SSPI"
;~ 		$oConnection.Properties("User ID") = $sUserName
;~ 		$oConnection.Properties("Password") = $sPassword
		$sConnectionString = __ADO_MSSQL_CONNECTION_STRING_WinAuth($sServer, $sDBName, $sAppName, $bUseProviderInsteadDriver)
	EndIf

	If $sWSID <> Default And $sWSID <> "" Then $sConnectionString &= "WSID=" & $sWSID & ";"

	$oConnection.Open($sConnectionString)
	If @error Then Return SetError($ADO_ERR_CONNECTION, @error, $ADO_RET_FAILURE)

	If @error Or $oConnection.State <> $ADO_adStateOpen Then _
			Return SetError($ADO_ERR_CONNECTION, @error, $ADO_RET_FAILURE)
EndFunc   ;==>_ADO_Connection_OpenMSSQL

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Connection_OpenMSSQL_WinAuth
; Description ...: Starts a Database Connection to Microsoft SQL Server using Windows Authorization
; Syntax ........: _ADO_Connection_OpenMSSQL_WinAuth(Byref $oConnection, $sServer, $sDBName[, $sAppName = Default[, $sWSID = Default[,
;                  $bUseProviderInsteadDriver = True]]])
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
;                  $sServer             - a string value. The server to connect to.
;                  $sDBName             - a string value. The database name to open.
;                  $sAppName            - [optional] a string value. Default is Default.  AppName for SQL Connection list.
;                  $sWSID               - [optional] a string value. Default is Default.
;                  $bUseProviderInsteadDriver- [optional] a boolean value. Default is True.
; Return values .: On Success - $ADO_RET_SUCCESS
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: Chris Lambert
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........: https://msdn.microsoft.com/pl-pl/library/ms130822(v=sql.110).aspx
; Example .......: No
; ===============================================================================================================================
Func _ADO_Connection_OpenMSSQL_WinAuth(ByRef $oConnection, $sServer, $sDBName, $sAppName = Default, $sWSID = Default, $bUseProviderInsteadDriver = True)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsValid($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	If $oConnection.State = $ADO_adStateOpen Then _
			Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)

	Local $sConnectionString = __ADO_MSSQL_CONNECTION_STRING_WinAuth($sServer, $sDBName, $sAppName, $bUseProviderInsteadDriver)

	If $sWSID <> Default And $sWSID <> "" Then $sConnectionString &= "WSID=" & $sWSID & ";"
	
	$oConnection.Open($sConnectionString)
	If @error Or $oConnection.State <> $ADO_adStateOpen Then _
			Return SetError($ADO_ERR_CONNECTION, @error, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)

EndFunc   ;==>_ADO_Connection_OpenMSSQL_WinAuth

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Connection_PropertiesToArray
; Description ...: List all Connection Properties
; Syntax ........: _ADO_Connection_PropertiesToArray(Byref $oConnection)
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: On Success - $aProperties
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: water
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........: https://www.autoitscript.com/wiki/ADO_Tools
; Example .......: No
; ===============================================================================================================================
Func _ADO_Connection_PropertiesToArray(ByRef $oConnection)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsReady($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	; Property Object (ADO)
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms677577(v=vs.85).aspx
	Local $oProperties_coll = $oConnection.Properties
	Local $aProperties[$oProperties_coll.count][4]
	Local $iIndex = 0

	; @TODO ENUMS for RETURN TABLE COLUMN INDEX
	For $oProperty_enum In $oProperties_coll
		$aProperties[$iIndex][0] = $oProperty_enum.Name
		$aProperties[$iIndex][1] = $oProperty_enum.Type
		$aProperties[$iIndex][2] = $oProperty_enum.Value
		$aProperties[$iIndex][3] = $oProperty_enum.Attributes
		$iIndex += 1
	Next

	$oProperties_coll = Null
	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $aProperties)

EndFunc   ;==>_ADO_Connection_PropertiesToArray

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Connection_Timeout
; Description ...: Sets and retrieves SQL ConnectionTimeout
; Syntax ........: _ADO_Connection_Timeout(Byref $oConnection[, $iTimeOut = Default])
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
;                  $iTimeOut            - [optional] an integer value. Default is Default. The timeout period to set if left blank the current value will be retrieved
; Return values .: On Success - Connection timeout period
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: Chris Lambert
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_Connection_Timeout(ByRef $oConnection, $iTimeOut = Default)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsValid($oConnection)
	If @error Then
		Return SetError(@error, @extended, $ADO_RET_FAILURE)
	ElseIf $iTimeOut = Default Then
		Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oConnection.ConnectionTimeout)
	ElseIf Not IsInt($iTimeOut) Then
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_DEFAULT, $ADO_RET_FAILURE)
	Else
		$oConnection.Close
		$oConnection.ConnectionTimeout = $iTimeOut
		Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)
	EndIf

EndFunc   ;==>_ADO_Connection_Timeout

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Execute
; Description ...: Executes an SQL Query
; Syntax ........: _ADO_Execute(Byref $oConnection, $sQuery[, $bReturnAsArray = False[, $bFieldNamesInFirstRow = False]])
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
;                  $sQuery              - a string value. SQL Statement to be executed.
;                  $bReturnAsArray      - [optional] a boolean value. Default is False.
;                  $bFieldNamesInFirstRow- [optional] a boolean value. Default is False.
; Return values .: On Success - $oRecordset object or $aRecordsetAsArray
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: Chris Lambert
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; no
; ===============================================================================================================================
Func _ADO_Execute(ByRef $oConnection, $sQuery, $bReturnAsArray = False, $bFieldNamesInFirstRow = False)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsReady($oConnection)
	If @error Then
		Return SetError(@error, @extended, $ADO_RET_FAILURE)
	ElseIf Not IsString($sQuery) Then
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM2, $ADO_RET_FAILURE)
	ElseIf $sQuery = '' Then
		Return SetError($ADO_ERR_INVALIDPARAMETERVALUE, $ADO_EXT_PARAM2, $ADO_RET_FAILURE)
	ElseIf Not IsBool($bReturnAsArray) Then
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM3, $ADO_RET_FAILURE)
	ElseIf Not IsBool($bFieldNamesInFirstRow) Then
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM4, $ADO_RET_FAILURE)
	EndIf
	
	__ADO_RowAffected(0)
	Local $oRecordset = $oConnection.Execute($sQuery)
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)
	
	If $bReturnAsArray Then
		Local $aRecordsetAsArray = _ADO_Recordset_ToArray($oRecordset, $bFieldNamesInFirstRow)
		Return SetError(@error, @extended, $aRecordsetAsArray)
	EndIf

	Return SetError($ADO_ERR_SUCCESS, __ADO_RowAffected(), $oRecordset)

EndFunc   ;==>_ADO_Execute

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_GetDSNList
; Description ...: Get list of all available DSN on the computer
; Syntax ........: _ADO_GetDSNList()
; Parameters ....: None
; Return values .: On Success - $aResult - a list of all available DSN on the computer
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok ?
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_GetDSNList()
	Local $sKey = "HKCR\CLSID"
	Local $iIndexReg = 1, $iIndexResult = 0
	Local $iMax = 100000, $iMin = 1, $iPrevious = $iMin, $iCurrent = $iMax / 2
	Local $aResult[200][3]

	ProgressOn("ODBC DSN", "Processing the Registry", "", Default, Default, $DLG_MOVEABLE)

	; Count the number of keys
	While 1
		RegEnumKey($sKey, $iCurrent)
		If @error = -1 Then ; Requested subkey (key instance) out of range
			$iMax = $iCurrent
			$iCurrent = Int(($iMin + $iMax) / 2)
			$iPrevious = $iMax
		Else
			If $iPrevious <= ($iCurrent + 1) And $iPrevious >= ($iCurrent - 1) Then ExitLoop
			$iMin = $iCurrent
			$iCurrent = Int(($iMin + $iMax) / 2)
			$iPrevious = $iMin
		EndIf
	WEnd

	Local $iPercent = 0
	Local $sKeyValue = '', $sSubKey = ''
	; Process registry
	While 1
		If Mod($iIndexReg, 10) = 0 Then
			$iPercent = Int($iIndexReg * 100 / $iCurrent)
			ProgressSet($iPercent, $iIndexReg & " keys of " & $iCurrent & " processed (" & $iPercent & "%)")
		EndIf
		$sSubKey = RegEnumKey($sKey, $iIndexReg)
		If @error Then ExitLoop

		$sKeyValue = RegRead($sKey & "\" & $sSubKey, "OLEDB_SERVICES")
		If @error = 0 Then
			$aResult[$iIndexResult][0] = $sKey & "\" & $sSubKey
			$aResult[$iIndexResult][1] = RegRead($sKey & "\" & $sSubKey, "")
			$aResult[$iIndexResult][2] = RegRead($sKey & "\" & $sSubKey & "\OLE DB Provider", "")
			$iIndexResult += 1
		EndIf

		$iIndexReg += 1
	WEnd

	ProgressOff()
	ReDim $aResult[$iIndexResult][3]

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $aResult)
	#forceref $sKeyValue
EndFunc   ;==>_ADO_GetDSNList

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_GetProvidersList
; Description ...: Get lists of available providers installed on the computer
; Syntax ........: _ADO_GetProvidersList()
; Parameters ....: None
; Return values .: On Success - $aResult - a list of all available providers installed on the computer
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: water
; Modified ......: mLipok
; Remarks .......: based on: _ADO_OLEDBProvidersList
; Related .......:
; Link ..........: https://www.autoitscript.com/wiki/ADO_Tools
; Example .......: No
; ===============================================================================================================================
Func _ADO_GetProvidersList()
	Local $sKey = "HKCR\CLSID"
	Local $iIndexReg = 1, $iIndexResult = 0
	Local $iMax = 100000, $iMin = 1, $iPrevious = $iMin, $iCurrent = $iMax / 2
	Local $aResult[200][3]

	ProgressOn("OLE DB Providers", "Processing the Registry", "", Default, Default, $DLG_MOVEABLE)

	; Count the number of keys
	While 1
		RegEnumKey($sKey, $iCurrent)
		If @error = -1 Then ; Requested subkey (key instance) out of range
			$iMax = $iCurrent
			$iCurrent = Int(($iMin + $iMax) / 2)
			$iPrevious = $iMax
		Else
			If $iPrevious <= ($iCurrent + 1) And $iPrevious >= ($iCurrent - 1) Then ExitLoop
			$iMin = $iCurrent
			$iCurrent = Int(($iMin + $iMax) / 2)
			$iPrevious = $iMin
		EndIf
	WEnd

	Local $iPercent = 0
	Local $sKeyValue = '', $sSubKey = ''
	While 1 ; Process registry
		If Mod($iIndexReg, 10) = 0 Then
			$iPercent = Int($iIndexReg * 100 / $iCurrent)
			ProgressSet($iPercent, $iIndexReg & " keys of " & $iCurrent & " processed (" & $iPercent & "%)")
		EndIf
		$sSubKey = RegEnumKey($sKey, $iIndexReg)
		If @error Then ExitLoop

		$sKeyValue = RegRead($sKey & "\" & $sSubKey, "OLEDB_SERVICES")
		If @error = 0 Then
			$aResult[$iIndexResult][0] = $sKey & "\" & $sSubKey
			$aResult[$iIndexResult][1] = RegRead($sKey & "\" & $sSubKey, "")
			$aResult[$iIndexResult][2] = RegRead($sKey & "\" & $sSubKey & "\OLE DB Provider", "")
			$iIndexResult += 1
		EndIf

		$iIndexReg += 1
	WEnd

	ProgressOff()
	ReDim $aResult[$iIndexResult][3]

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $aResult)
	#forceref $sKeyValue
EndFunc   ;==>_ADO_GetProvidersList

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_MSSQL_GetDriverVersion
; Description ...: check for newer DRIVER parameter for CONNECTIONSTRING
; Syntax ........: _ADO_MSSQL_GetDriverVersion()
; Parameters ....: none.
; Return values .: On Success - $s_ADO_MSSQL_GetDriverVersion
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_MSSQL_GetDriverVersion()
	Local Static $sADO_MSSQL_DriverVersion = Default
	If $sADO_MSSQL_DriverVersion = Default Then
		; @DPilar - will check/review for new NCLI versions
;~ 		Local  $sSQL_NCLI_2014 = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Native Client 11.0\CurrentVersion', 'Version') ; For SQL Server 2008/SQL Server 2008 R2
		Local $sSQL_NCLI_2012 = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Native Client 11.0\CurrentVersion', 'Version') ; For SQL Server 2008/SQL Server 2008 R2
		Local $sSQL_NCLI_2008 = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Native Client 10.0\CurrentVersion', 'Version') ; For SQL Server 2008/SQL Server 2008 R2
		Local $sSQL_NCLI_2005 = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Native Client\CurrentVersion', 'Version') ; For SQL Server 2005
		Select
;~ 			Case  $sSQL_NCLI_2014 <> ''
;~ 				$sADO_MSSQL_DriverVersion = 'SQL Server Native Client 11.0'
			Case $sSQL_NCLI_2012 <> ''
				$sADO_MSSQL_DriverVersion = 'SQL Server Native Client 11.0'
			Case $sSQL_NCLI_2008 <> ''
				$sADO_MSSQL_DriverVersion = 'SQL Server Native Client 10.0'
			Case $sSQL_NCLI_2005 <> ''
				$sADO_MSSQL_DriverVersion = 'SQL Native Client'
			Case Else
				$sADO_MSSQL_DriverVersion = 'SQL Server'
		EndSelect
	EndIf
	Return $sADO_MSSQL_DriverVersion

EndFunc   ;==>_ADO_MSSQL_GetDriverVersion

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_MSSQL_GetProviderVersion
; Description ...: check for newer PROVIDER parameter for CONNECTIONSTRING
; Syntax ........: _ADO_MSSQL_GetProviderVersion()
; Parameters ....: none.
; Return values .: On Success - $s_ADO_MSSQL_GetProviderVersion
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_MSSQL_GetProviderVersion()
	Local Static $s_ADO_MSSQL_GetProviderVersion = Default
	If $s_ADO_MSSQL_GetProviderVersion = Default Then
		; @DPilar - check/review for new NCLI versions
;~ 		Local  $sSQL_NCLI_2014 = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Native Client 11.0\CurrentVersion', 'Version') ; For SQL Server 2008/SQL Server 2008 R2
		Local $sSQL_NCLI_2012 = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Native Client 11.0\CurrentVersion', 'Version') ; For SQL Server 2008/SQL Server 2008 R2
		Local $sSQL_NCLI_2008 = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Native Client 10.0\CurrentVersion', 'Version') ; For SQL Server 2008/SQL Server 2008 R2
		Local $sSQL_NCLI_2005 = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Native Client\CurrentVersion', 'Version') ; For SQL Server 2005
		Select
;~ 			Case  $sSQL_NCLI_2014 <> ''
;~ 				$s_ADO_MSSQL_GetProviderVersion = 'SQL Server Native Client 11.0'
			Case $sSQL_NCLI_2012 <> ''
				$s_ADO_MSSQL_GetProviderVersion = 'SQLNCLI11'
			Case $sSQL_NCLI_2008 <> ''
				$s_ADO_MSSQL_GetProviderVersion = 'SQLNCLI10'
			Case $sSQL_NCLI_2005 <> ''
				$s_ADO_MSSQL_GetProviderVersion = 'SQLNCLI'
			Case Else
				$s_ADO_MSSQL_GetProviderVersion = 'sqloledb'
		EndSelect
	EndIf
	Return $s_ADO_MSSQL_GetProviderVersion

EndFunc   ;==>_ADO_MSSQL_GetProviderVersion

; #FUNCTION# ===================================================================
; Name ..........: _ADO_Recordset_Create
; Description ...: Creates ADODB.Recordset object
; Syntax.........:  _ADO_Recordset_Create()
; Parameters ....: None
; Return values .: On Success - $oRecordset Object
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; no
; ==============================================================================
Func _ADO_Recordset_Create()
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	Local $oRecordset = ObjCreate("ADODB.Recordset")
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oRecordset)
EndFunc   ;==>_ADO_Recordset_Create

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Version
; Description ...: Get ADO version
; Syntax ........: _ADO_Version([ByRef $oConnection])
; Parameters ....: $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: On Success - $oConnection.Version
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: Chris Lambert
; Modified ......: mLipok
; Remarks .......: https://docs.microsoft.com/en-us/sql/ado/guide/ado-history?view=sql-server-ver15
; Related .......:
; Link ..........: https://docs.microsoft.com/en-us/sql/ado/reference/ado-api/version-property-ado?view=sql-server-ver15
; Example .......: No
; ===============================================================================================================================
Func _ADO_Version(ByRef $oConnection)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsValid($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oConnection.Version)
EndFunc   ;==>_ADO_Version
#EndRegion ADO.au3 - Functions - Connection & Management

#Region ADO.au3 - Functions - ADDON - COM ERROR HANDLER
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_ComErrorHandler_WrapperFunction
; Description ...: calls USER ComErrorHandler defined by _ADO_COMErrorHandler_UserFunction() if not defined call _ADO_COMErrorHandler_Function()
; Syntax ........: __ADO_ComErrorHandler_WrapperFunction(Byref $oCOMError)
; Parameters ....: $oCOMError           - [in/out] an object.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: _ADO_COMErrorHandler_UserFunction(), _ADO_COMErrorHandler_Function()
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_ComErrorHandler_WrapperFunction(ByRef $oCOMError)
	Local $sUserFunction = _ADO_COMErrorHandler_UserFunction(Default)
	If @error Then Return
	ConsoleWrite('! ' & @ScriptLineNumber & ' == ' &@error & @CRLF)
	$sUserFunction($oCOMError)
EndFunc   ;==>__ADO_ComErrorHandler_WrapperFunction

; #FUNCTION# ===================================================================
; Name ..........: _ADO_COMErrorHandler_Function
; Description ...: Autoit COM Error handler function
; Syntax ........: _ADO_COMErrorHandler_Function(Byref $oADO_Error)
; Parameters ....: $oADO_Error          - [in/out] an object.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......: This COMErrorHandler function will show the ouptut only when not @Compiled
; Related .......:
; Link ..........:
; Example .......: no
; ================================================================================
Func _ADO_COMErrorHandler_Function(ByRef $oADO_Error)
	If @Compiled Then _
			Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $ADO_RET_SUCCESS)

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

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_COMErrorHandler_UserFunction
; Description ...: Set up USER function to get COM Error Handler outside ADO.au3 UDF
; Syntax ........: _ADO_COMErrorHandler_UserFunction([$fnUserFunction = Default])
; Parameters ....: $fnUserFunction      - [optional] a floating point value. Default is Default.
; Return values .: On Success - $fnFunction_Static
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_COMErrorHandler_UserFunction($fnUserFunction = Default)
	; in case when user do not set his own function UDF must use internal function to avoid AutoItError
	Local Static $fnFunction_Static = ''

	If $fnUserFunction = Default Then
		; just return stored static variable
		If IsFunc($fnFunction_Static) Then Return SetExtended($ADO_EXT_DEFAULT, $fnFunction_Static)
		; return '' setting @extended in case where there was not set COMErrorHandler user funtcion
		Return SetError($ADO_ERR_COMHANDLER, 101, '')
	ElseIf IsFunc($fnUserFunction) Then
		; set and return static variable
		$fnFunction_Static = $fnUserFunction
		Return SetExtended(102, $fnFunction_Static)
	Else
		; incorrect parameter ... reset static variable
		$fnFunction_Static = ''
		Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM1, $fnFunction_Static)
	EndIf
EndFunc   ;==>_ADO_COMErrorHandler_UserFunction
#EndRegion ADO.au3 - Functions - ADDON - COM ERROR HANDLER

#Region ADO.au3 - Functions - ADDON - COM EVENT HANDLER

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENT__BeginTransComplete
; Description ...: BeginTransComplete is called after the BeginTrans operation
; Syntax ........: __ADO_EVENT__BeginTransComplete($iTransactionLevel, Byref $oError, $i_adStatus, Byref $oConnection)
; Parameters ....: $iTransactionLevel   - an integer value. A Long value that contains the new transaction level of the BeginTrans that caused this event.
;                  $oError              - [in/out] an object. An Error object. It describes the error that occurred if the value of EventStatusEnum is adStatusErrorsOccurred; otherwise it is not set.
;                  $i_adStatus          - an integer value. An EventStatusEnum status value. When any of these events is called, this parameter is set to adStatusOK if the operation that caused the event was successful, or to adStatusErrorsOccurred if the operation failed.
;											These events can prevent subsequent notifications by setting this parameter to adStatusUnwantedEvent before the event returns.
;                  $oConnection         - [in/out] an object representing ADO Connection. The Connection object for which this event occurred.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: __ADO_EVENTS_ErrorCollectionAnalyzer
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms681493%28v=vs.85%29.aspx
; Link ..........: https://msdn.microsoft.com/en-us/library/ms681493(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT__BeginTransComplete($iTransactionLevel, ByRef $oError, $i_adStatus, ByRef $oConnection)
	Local $oConnection_param1 = $oConnection, $oCommand_param2 = Null, $oRecordset_param3 = Null, $oError_param4 = $oError
	__ADO_EVENT_InternalWrapper('BeginTransComplete', $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, $i_adStatus, $iTransactionLevel)

	If @Compiled Then Return
	If _ADO_EVENTS_ShowOnly_InfoMessages() Then Return

	__ADO_ConsoleWrite_Blue(" ADO EVENT fired function: __ADO_EVENT__BeginTransComplete:")
	__ADO_ConsoleWrite_Blue("   $iTransactionLevel=" & $iTransactionLevel)
	__ADO_ConsoleWrite_Blue("   $i_adStatus=" & $i_adStatus)
	#forceref $oError, $oConnection

;~ 	If False Then __ADO_EVENTS_ErrorCollectionAnalyzer($oConnection)
EndFunc   ;==>__ADO_EVENT__BeginTransComplete

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENT__CommitTransComplete
; Description ...: CommitTransComplete is called after the CommitTrans operation.
; Syntax ........: __ADO_EVENT__CommitTransComplete(Byref $oError, $i_adStatus, Byref $oConnection)
; Parameters ....: $oError              - [in/out] an object.
;                  $i_adStatus          - an integer value.
;                  $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: __ADO_EVENTS_ErrorCollectionAnalyzer
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms681493%28v=vs.85%29.aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT__CommitTransComplete(ByRef $oError, $i_adStatus, ByRef $oConnection)
	Local $oConnection_param1 = $oConnection, $oCommand_param2 = Null, $oRecordset_param3 = Null, $oError_param4 = $oError
	__ADO_EVENT_InternalWrapper('CommitTransComplete', $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, $i_adStatus)

	If @Compiled Then Return
	If _ADO_EVENTS_ShowOnly_InfoMessages() Then Return

	__ADO_ConsoleWrite_Blue(" ADO EVENT fired function: __ADO_EVENT__CommitTransComplete:")
	__ADO_ConsoleWrite_Blue("   $i_adStatus=" & $i_adStatus)
	If $i_adStatus = $ADO_adStatusErrorsOccurred Then
		If False Then __ADO_ConsoleWrite_Red("   $i_adStatus=$ADO_adStatusErrorsOccurred=" & $i_adStatus)
		If False Then __ADO_ConsoleWrite_Red("   STARTING:  $oConnection.RollbackTrans")
		$oConnection.RollbackTrans
	EndIf
	#forceref $oError, $oConnection

;~ 	__ADO_EVENTS_ErrorCollectionAnalyzer($oConnection)
;~ 	$oConnection.errors.clear
EndFunc   ;==>__ADO_EVENT__CommitTransComplete

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENT__ConnectComplete
; Description ...: ConnectComplete Events (ADO)
; Syntax ........: __ADO_EVENT__ConnectComplete(Byref $oError, $i_adStatus, Byref $oConnection)
; Parameters ....: $oError              - [in/out] an object.
;                  $i_adStatus          - an integer value.
;                  $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: __ADO_EVENTS_ErrorCollectionAnalyzer
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms676126(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT__ConnectComplete(ByRef $oError, $i_adStatus, ByRef $oConnection)
	Local $oConnection_param1 = $oConnection, $oCommand_param2 = Null, $oRecordset_param3 = Null, $oError_param4 = $oError
	__ADO_EVENT_InternalWrapper('ConnectComplete', $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, $i_adStatus)

	If @Compiled Then Return
	If _ADO_EVENTS_ShowOnly_InfoMessages() Then Return

	__ADO_ConsoleWrite_Blue(" ADO EVENT fired function: __ADO_EVENT__ConnectComplete:")
	__ADO_ConsoleWrite_Blue("   $i_adStatus=" & $i_adStatus)

;~ 	If False Then __ADO_EVENTS_ErrorCollectionAnalyzer($oConnection)
;~ 	$oConnection.errors.clear

	#forceref $oError
EndFunc   ;==>__ADO_EVENT__ConnectComplete

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENT__Disconnect
; Description ...: Disconnect Events (ADO)
; Syntax ........: __ADO_EVENT__Disconnect($i_adStatus, Byref $oConnection)
; Parameters ....: $i_adStatus          - an integer value.
;                  $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......: __ADO_EVENTS_ErrorCollectionAnalyzer
; Related .......:
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms676126(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT__Disconnect($i_adStatus, ByRef $oConnection)
	Local $oConnection_param1 = $oConnection, $oCommand_param2 = Null, $oRecordset_param3 = Null, $oError_param4 = Null
	__ADO_EVENT_InternalWrapper('Disconnect', $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, $i_adStatus)

	If @Compiled Then Return
	If _ADO_EVENTS_ShowOnly_InfoMessages() Then Return

	__ADO_ConsoleWrite_Blue(" ADO EVENT fired function: __ADO_EVENT__Disconnect:")
	__ADO_ConsoleWrite_Blue("   $i_adStatus=" & $i_adStatus)

;~ 	If False Then __ADO_EVENTS_ErrorCollectionAnalyzer($oConnection)
;~ 	$oConnection.errors.clear
EndFunc   ;==>__ADO_EVENT__Disconnect

Func __ADO_EVENT__ExecuteComplete($iRecordsAffected, ByRef $oError, $i_adStatus, ByRef $oCommand, ByRef $oRecordset, ByRef $oConnection)
	__ADO_RowAffected($iRecordsAffected)

	Local $oConnection_param1 = $oConnection, $oCommand_param2 = $oCommand, $oRecordset_param3 = $oRecordset, $oError_param4 = $oError
	__ADO_EVENT_InternalWrapper('ExecuteComplete', $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, $i_adStatus, $iRecordsAffected)

	If @Compiled Then Return
	If _ADO_EVENTS_ShowOnly_InfoMessages() Then Return

	__ADO_ConsoleWrite_Blue(" ADO EVENT fired function: __ADO_EVENT__ExecuteComplete:")
	__ADO_ConsoleWrite_Blue("   $iRecordsAffected=" & $iRecordsAffected)
;~ 	__ADO_ConsoleWrite_Blue("   VarGetType($oError)=" & VarGetType($oError))
	__ADO_ConsoleWrite_Blue("   $i_adStatus=" & $i_adStatus)

	__ADO_EVENTS_ErrorCollectionAnalyzer($oConnection)
;~ 	$oConnection.errors.clear

	#forceref $oCommand, $oRecordset, $oError
EndFunc   ;==>__ADO_EVENT__ExecuteComplete

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENT__FetchComplete
; Description ...: FetchComplete Event (ADO)
; Syntax ........: __ADO_EVENT__FetchComplete(Byref $oError, $i_adStatus, Byref $oRecordset)
; Parameters ....: $oError              - [in/out] an object.
;                  $i_adStatus          - an integer value.
;                  $oRecordset          - [in/out] an object representing ADO Recordset.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms677512(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT__FetchComplete(ByRef $oError, $i_adStatus, ByRef $oRecordset)
	Local $oConnection_param1 = Null, $oCommand_param2 = Null, $oRecordset_param3 = $oRecordset, $oError_param4 = $oError
	__ADO_EVENT_InternalWrapper('FetchComplete', $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, $i_adStatus)

	If @Compiled Then Return
	If _ADO_EVENTS_ShowOnly_InfoMessages() Then Return

	__ADO_ConsoleWrite_Blue(" ADO EVENT fired function: __ADO_EVENT__FEtchComplete:")
	__ADO_ConsoleWrite_Blue("   $i_adStatus=" & $i_adStatus)

	#forceref $oError, $oRecordset
EndFunc   ;==>__ADO_EVENT__FetchComplete

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENT__FetchProgress
; Description ...: FetchProgress Event (ADO)
; Syntax ........: __ADO_EVENT__FetchProgress($iProgress, $iMaxProgress, $i_adStatus, Byref $oRecordset)
; Parameters ....: $iProgress           - an integer value.
;                  $iMaxProgress        - an integer value.
;                  $i_adStatus          - an integer value.
;                  $oRecordset          - [in/out] an object representing ADO Recordset.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms675535(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT__FetchProgress($iProgress, $iMaxProgress, $i_adStatus, ByRef $oRecordset)
	Local $oConnection_param1 = Null, $oCommand_param2 = Null, $oRecordset_param3 = $oRecordset, $oError_param4 = Null
	__ADO_EVENT_InternalWrapper('FetchProgress', $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, $i_adStatus, $iProgress, $iMaxProgress)

	If @Compiled Then Return
	If _ADO_EVENTS_ShowOnly_InfoMessages() Then Return

	__ADO_ConsoleWrite_Blue(" ADO EVENT fired function: __ADO_EVENT__FetchProgress:")
	__ADO_ConsoleWrite_Blue("   $iProgress=" & $iProgress)
	__ADO_ConsoleWrite_Blue("   $iMaxProgress=" & $iMaxProgress)
	__ADO_ConsoleWrite_Blue("   $i_adStatus=" & $i_adStatus)

	#forceref $oRecordset
EndFunc   ;==>__ADO_EVENT__FetchProgress

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENT__InfoMessage
; Description ...:
; Syntax ........: __ADO_EVENT__InfoMessage(Byref $oError, $i_adStatus, Byref $oConnection)
; Parameters ....: $oError              - [in/out] an object.
;                  $i_adStatus          - an integer value.
;                  $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......: TODO - description
; Related .......: __ADO_EVENTS_ErrorCollectionAnalyzer
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms675859(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT__InfoMessage(ByRef $oError, $i_adStatus, ByRef $oConnection)
	Local $oConnection_param1 = $oConnection, $oCommand_param2 = Null, $oRecordset_param3 = Null, $oError_param4 = $oError
	__ADO_EVENT_InternalWrapper('InfoMessage', $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, $i_adStatus)

	If @Compiled Then Return
	__ADO_ConsoleWrite_Blue(' [ADO InfoMessage]=' & $oError.description)
EndFunc   ;==>__ADO_EVENT__InfoMessage

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENT__RollbackTransComplete
; Description ...: RollbackTransComplete is called after the RollbackTrans operation.
; Syntax ........: __ADO_EVENT__RollbackTransComplete(Byref $oError, $i_adStatus, Byref $oConnection)
; Parameters ....: $oError              - [in/out] an object.
;                  $i_adStatus          - an integer value.
;                  $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......: __ADO_EVENTS_ErrorCollectionAnalyzer
; Related .......:
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms681493%28v=vs.85%29.aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT__RollbackTransComplete(ByRef $oError, $i_adStatus, ByRef $oConnection)
	Local $oConnection_param1 = $oConnection, $oCommand_param2 = Null, $oRecordset_param3 = Null, $oError_param4 = $oError
	__ADO_EVENT_InternalWrapper('RollbackTransComplete', $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, $i_adStatus)

	If @Compiled Then Return
	If _ADO_EVENTS_ShowOnly_InfoMessages() Then Return

	__ADO_ConsoleWrite_Blue(" ADO EVENT fired function: __ADO_EVENT__RollbackTransComplete:")
	__ADO_ConsoleWrite_Blue("   $i_adStatus=" & $i_adStatus)

;~ 	If False Then __ADO_EVENTS_ErrorCollectionAnalyzer($oConnection)
;~ 	$oConnection.errors.clear

	#forceref $oError
EndFunc   ;==>__ADO_EVENT__RollbackTransComplete

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENT__WillConnect
; Description ...: WillConnect Event (ADO)
; Syntax ........: __ADO_EVENT__WillConnect($sConnection_String, $sUserID, $sPassword, $iOptions, $i_adStatus, Byref $oConnection)
; Parameters ....: $sConnection_String   - a string value.
;                  $sUserID             - a string value.
;                  $sPassword           - a string value.
;                  $iOptions            - an integer value.
;                  $i_adStatus          - an integer value.
;                  $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: __ADO_EVENTS_ErrorCollectionAnalyzer
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms680962(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT__WillConnect($sConnection_String, $sUserID, $sPassword, $iOptions, $i_adStatus, ByRef $oConnection)
	Local Static $oCommand_param2 = Null, $oRecordset_param3 = Null, $oError_param4 = Null
	__ADO_EVENT_InternalWrapper('WillConnect', $oConnection, $oCommand_param2, $oRecordset_param3, $oError_param4, $i_adStatus, $sConnection_String, $sUserID, $sPassword, $iOptions)

	If @Compiled Then Return
	If _ADO_EVENTS_ShowOnly_InfoMessages() Then Return

	__ADO_ConsoleWrite_Blue(@CRLF)
	__ADO_ConsoleWrite_Blue(" ADO EVENT fired function: __ADO_EVENT__WillConnect:")
;~  __ADO_ConsoleWrite_Blue("   $sConnection_String=" & $sConnection_String) ; for security reason should not be populated to output
	__ADO_ConsoleWrite_Blue("   $sConnection_String=" & StringLen($sConnection_String)) ; for security reason should not be populated to output
	__ADO_ConsoleWrite_Blue("   $sUserID=" & $sUserID)
;~ 	__ADO_ConsoleWrite_Blue("   $sPassword=" & $sPassword) ; for security reason should not be populated to output
	__ADO_ConsoleWrite_Blue("   $iOptions=" & $iOptions)
	__ADO_ConsoleWrite_Blue("   $i_adStatus=" & $i_adStatus)

;~ 	If False Then __ADO_EVENTS_ErrorCollectionAnalyzer($oConnection)
;~ 	$oConnection.errors.clear

	#forceref $sConnection_String, $sPassword ; For security reason should Not be populated To output
EndFunc   ;==>__ADO_EVENT__WillConnect

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENT__WillExecute
; Description ...: WillExecute Event (ADO)
; Syntax ........: __ADO_EVENT__WillExecute($sSource, $iCursorType, $iLockType, $iOptions, $i_adStatus, Byref $oCommand,
;                  Byref $oRecordset, Byref $oConnection)
; Parameters ....: $sSource             - a string value.
;                  $iCursorType         - an integer value.
;                  $iLockType           - an integer value.
;                  $iOptions            - an integer value.
;                  $i_adStatus          - an integer value.
;                  $oCommand            - [in/out] an object representing ADO Command.
;                  $oRecordset          - [in/out] an object representing ADO Recordset.
;                  $oConnection         - [in/out] an object representing ADO Connection.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: __ADO_EVENTS_ErrorCollectionAnalyzer
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms680993(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT__WillExecute($sSource, $iCursorType, $iLockType, $iOptions, $i_adStatus, ByRef $oCommand, ByRef $oRecordset, ByRef $oConnection)
	Local Static $oError_param4 = Null
	__ADO_EVENT_InternalWrapper('WillExecute', $oConnection, $oCommand, $oRecordset, $oError_param4, $i_adStatus, $sSource, $iCursorType, $iLockType, $iOptions)

	If @Compiled Then Return
	If _ADO_EVENTS_ShowOnly_InfoMessages() Then Return

	__ADO_ConsoleWrite_Blue(" ADO EVENT fired function: __ADO_EVENT__WillExecute:")
	__ADO_ConsoleWrite_Blue("   $sSource=" & StringRegExpReplace($sSource, '\R', ' '))
	__ADO_ConsoleWrite_Blue("   $iCursorType=" & $iCursorType)
	__ADO_ConsoleWrite_Blue("   $iLockType=" & $iLockType)
	__ADO_ConsoleWrite_Blue("   $iOptions=" & $iOptions)
	__ADO_ConsoleWrite_Blue("   $i_adStatus=" & $i_adStatus)

;~ 	If False Then __ADO_EVENTS_ErrorCollectionAnalyzer($oConnection)
;~ 	$oConnection.errors.clear

	#forceref $oCommand, $oRecordset
EndFunc   ;==>__ADO_EVENT__WillExecute

; #FUNCTION# ====================================================================================================================
; Name ..........: __ADO_EVENT_InternalWrapper
; Description ...: @TODO
; Syntax ........: __ADO_EVENT_InternalWrapper($param0, Byref $oConnection_param1, Byref $oCommand_param2, Byref $oRecordset_param3,
;                  Byref $oError_param4[, $param5_adStatus = Null[, $param6 = Null[, $param7 = Null[, $param8 = Null[,
;                  $param9 = Null]]]]])
; Parameters ....: $param0              - a pointer value.
;                  $oConnection_param1  - [in/out] an object.
;                  $oCommand_param2     - [in/out] an object.
;                  $oRecordset_param3   - [in/out] an object.
;                  $oError_param4       - [in/out] an object.
;                  $param5_adStatus     - [optional] a pointer value. Default is Null.
;                  $param6              - [optional] a pointer value. Default is Null.
;                  $param7              - [optional] a pointer value. Default is Null.
;                  $param8              - [optional] a pointer value. Default is Null.
;                  $param9              - [optional] a pointer value. Default is Null.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......: @TODO Description / Return Value ?
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENT_InternalWrapper($param0, ByRef $oConnection_param1, ByRef $oCommand_param2, ByRef $oRecordset_param3, ByRef $oError_param4, $param5_adStatus = Null, $param6 = Null, $param7 = Null, $param8 = Null, $param9 = Null)
	Local Static $sUserFunction_ADOEventHandler = Null
	If IsFunc($param0) And $oConnection_param1 = Null And $oCommand_param2 = Null And $oRecordset_param3 = Null And $oError_param4 = Null Then    ; Setting Up UserFunction
		$sUserFunction_ADOEventHandler = $param0
		Return
	ElseIf Not IsFunc($sUserFunction_ADOEventHandler) Then ; UserFunction is not set, so just leave function
		Return
	EndIf

	Local $result = $sUserFunction_ADOEventHandler($param0, $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, $param5_adStatus, $param6, $param7, $param8, $param9)
	Return SetError(@error, @extended, $result)
EndFunc   ;==>__ADO_EVENT_InternalWrapper

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_EVENTS_ErrorCollectionAnalyzer
; Description ...: Function to analyze ErrorCollection
; Syntax ........: __ADO_EVENTS_ErrorCollectionAnalyzer(Byref $oConnection)
; Parameters ....: $oConnection         - [in/out] an object.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_EVENTS_ErrorCollectionAnalyzer(ByRef $oConnection, $bFull = False)
	Local $iErrorCol_Max = $oConnection.errors.Count
	If $iErrorCol_Max = 0 Then Return
	Local $oError
	For $iErrorCol_idx = 0 To $iErrorCol_Max - 1
		If $iErrorCol_idx = 0 Then __ADO_ConsoleWrite_Blue("> ==> ADO Error Collection: .errors.Count = " & $iErrorCol_Max)
		$oError = $oConnection.errors.Item($iErrorCol_idx)
		If ($oError.NativeError Or $oError.number) Then
			__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").number is: " & @TAB & @TAB & "0x" & Hex($oError.number))
			__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").NativeError is: " & @TAB & @TAB & $oError.NativeError)
			__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").lastdllerror is: " & @TAB & $oError.lastdllerror)
			__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").retcode is: " & @TAB & @TAB & "0x" & Hex($oError.retcode))
			__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").windescription:" & @TAB & @TAB & $oError.windescription)
		EndIf
		__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").description is: " & @TAB & @TAB & $oError.description)

		If $bFull Then
			; Wondering if this 4 following line are needed in case when no error was fired
			__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").source is: " & @TAB & @TAB & $oError.source)
			__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").SQLState is: " & @TAB & @TAB & $oError.SQLState)
			__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").helpfile is: " & @TAB & @TAB & $oError.helpfile)
			__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").helpcontext is: " & @TAB & $oError.helpcontext)

			; AutoIt is not showing LineNumber when is compiled.
			If Not @Compiled Then _ ; @TODO REWRITE/REFACTOR/CHANGE ?
					__ADO_ConsoleWrite_Blue(@TAB & "$oError.Item(" & $iErrorCol_idx & ").scriptline is: " & @TAB & @TAB & $oError.scriptline)
		EndIf
	Next
EndFunc   ;==>__ADO_EVENTS_ErrorCollectionAnalyzer

Func __ADO_EVENTS_ErrorCollectionAnalyzer_Information(ByRef $oConnection)
	Local $iErrorCol_Max = $oConnection.errors.Count
	If $iErrorCol_Max = 0 Then Return
	Local $oError
	For $iErrorCol_idx = 0 To $iErrorCol_Max - 1
		$oError = $oConnection.errors.Item($iErrorCol_idx)
		If $oError.description Then __ADO_ConsoleWrite_Blue($iErrorCol_idx & ' / ' & $iErrorCol_Max & " [ADO InfoMessage]=" & $oError.description)
	Next
EndFunc   ;==>__ADO_EVENTS_ErrorCollectionAnalyzer_Information

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_RowAffected
; Description ...: in __EVENT__* function stores the #of affected rows and restore in _ADO_Execute()
; Syntax ........: __ADO_RowAffected([$iRowCount = Default[, $iError = @error[, $iExtended = @extended]]])
; Parameters ....: $iRowCount           - [optional] an integer value. Default is Default.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: #of affected rows
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: _ADO_Execute, _ADO_Command_Execute
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_RowAffected($iRowCount = Default, $iError = @error, $iExtended = @extended)
	Local Static $Storage = Null
	If @NumParams = 0 Then Return SetError($iError, $iExtended, $Storage)
	$Storage = $iRowCount
	Return SetError($iError, $iExtended, $ADO_RET_SUCCESS)
EndFunc   ;==>__ADO_RowAffected

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_EVENT_Wrapper
; Description ...: Assign user "special event handler function" to take care about the events - outside ADO.au3 UDF
; Syntax ........: _ADO_EVENT_Wrapper($fnEvent_UserFunctionHandler)
; Parameters ....: $fnEvent_UserFunctionHandler      - a floating point value.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: _ADO_Connection_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ADO_EVENT_Wrapper($fnEvent_UserFunctionHandler)
	If Not IsFunc($fnEvent_UserFunctionHandler) Then _
			Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM1, $ADO_RET_FAILURE)
	; this following 4 param's must be defined as are passed to __ADO_EVENT_InternalWrapper() as ByRef
	Local $oConnection_param1 = Null, $oCommand_param2 = Null, $oRecordset_param3 = Null, $oError_param4 = Null
	__ADO_EVENT_InternalWrapper($fnEvent_UserFunctionHandler, $oConnection_param1, $oCommand_param2, $oRecordset_param3, $oError_param4, Null, Null, Null, Null, Null)
EndFunc   ;==>_ADO_EVENT_Wrapper

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_EVENTS_ShowOnly_InfoMessages
; Description ...: Choose if Events should show only InfoMessages
; Syntax ........: _ADO_EVENTS_ShowOnly_InfoMessages($bChoice[, $iError = @error[, $iExtended = @extended]])
; Parameters ....: $bChoice             - a boolean value.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: None @TODO
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_EVENTS_ShowOnly_InfoMessages($bChoice = Default, $iError = @error, $iExtended = @extended)
	Local Static $bChosen = True
	Local $bPrevious = $bChosen
	If $bChoice = Default Then _
			Return SetError($iError, $iExtended, $bChosen)

	If Not IsBool($bChosen) Then _
			Return SetError($ADO_ERR_INVALIDPARAMETERTYPE, $ADO_EXT_PARAM1, $bPrevious)

	$bChosen = $bChoice
	Return SetError($iError, $iExtended, $bPrevious)
EndFunc   ;==>_ADO_EVENTS_ShowOnly_InfoMessages
#EndRegion ADO.au3 - Functions - ADDON - COM EVENT HANDLER

#Region ADO.au3 - Functions - MISC

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_ConsoleWrite_Blue
; Description ...: Wrapper for output logs - especially as Blue to SciTE console pane
; Syntax ........: __ADO_ConsoleWrite_Blue($sText)
; Parameters ....: $sText               - a string value.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......: TODO - description
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_ConsoleWrite_Blue($sText)
	_ADO_ConsoleOutput('>>' & $sText)
EndFunc   ;==>__ADO_ConsoleWrite_Blue

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __ADO_ConsoleWrite_Red
; Description ...: Wrapper for output logs - especially as Red to SciTE console pane
; Syntax ........: __ADO_ConsoleWrite_Red($sText)
; Parameters ....: $sText               - a string value.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......: TODO - description
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __ADO_ConsoleWrite_Red($sText)
	Local Static $sFunction = ConsoleWrite
;~ 	If IsFunc($sText) Then
;~ 	EndIf
	$sFunction(BinaryToString(StringToBinary('!!!!!!!!!' & $sText & @CRLF, $SB_UTF8), $SB_ANSI))
;~ 	$sFunction(BinaryToString(StringToBinary('!!!!!!!!!' & $sText & @CRLF, 4), 1))
EndFunc   ;==>__ADO_ConsoleWrite_Red

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_ConsoleError
; Description ...: Wrapper for output Logs - especially @error description to SciTE console pane
; Syntax ........: _ADO_ConsoleError([$sDescription = ''[, $iError = @error[, $iExtended = @extended]]])
; Parameters ....: $sDescription        - [optional] a string value. Default is ''.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: $sDescription_Result and stored @error @extended
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_ConsoleError($sDescription = '', $iError = @error, $iExtended = @extended)
	Local $sDescription_Result = _ADO_GetErrorDescription($sDescription, True, $iError, $iExtended)
	_ADO_ConsoleOutput('!!!!!!!!!' & $sDescription_Result)
	Return SetError($iError, $iExtended, $sDescription_Result)
EndFunc   ;==>_ADO_ConsoleError

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_ConsoleOutput
; Description ...: Wrapper for output logs - especially to SciTE console pane
; Syntax ........: _ADO_ConsoleOutput($sData[, $iError = @error[, $iExtended = @extended]])
; Parameters ....: $sData               - a string value.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: $ADO_RET_SUCCESS and stored @error @extended
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_ConsoleOutput($sData, $iError = @error, $iExtended = @extended)
	If Not @Compiled Then ConsoleWrite(BinaryToString(StringToBinary($sData, $SB_UTF8), $SB_ANSI) & @CRLF)
	Return SetError($iError, $iExtended, $ADO_RET_SUCCESS)
EndFunc   ;==>_ADO_ConsoleOutput

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_GetErrorDescription
; Description ...: Get description for @ADO_ERR_*
; Syntax ........: _ADO_GetErrorDescription([$sUserUniqueDescription = ''[, $bShowHumanReadableDescription = True[, $iError = @error[,
;                  $iExtended = @extended]]]])
; Parameters ....: $sUserUniqueDescription        - [optional] a string value. Default is ''.
;                  $bShowHumanReadableDescription- [optional] a boolean value. Default is True.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: $sInfo and stored @error @extended
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_GetErrorDescription($sUserUniqueDescription = '', $bShowHumanReadableDescription = True, $iError = @error, $iExtended = @extended)
	Local $sInfo = ''
	If $iError Then
		$sInfo = '! ADO ERROR  [ ' & $iError & ' / ' & $iExtended & ' ]  ' & $sUserUniqueDescription
		If $bShowHumanReadableDescription Then
			$sInfo &= @CRLF
			$sInfo &= '!    @ERROR=' & $iError & '='
			Switch $iError
				Case $ADO_ERR_SUCCESS
					$sInfo &= 'No Error'
				Case $ADO_ERR_GENERAL
					$sInfo &= 'General - some ADO Error - Not classified type of error'
				Case $ADO_ERR_COMERROR
					$sInfo &= 'COM Error - check your COM Error Handler'
				Case $ADO_ERR_COMHANDLER
					$sInfo &= 'COM Error Handler Registration'
				Case $ADO_ERR_CONNECTION
					$sInfo &= '$oConection.Open - Opening error'
				Case $ADO_ERR_ISNOTOBJECT
					$sInfo &= 'Function Parameters error - Expected/Required Object'
				Case $ADO_ERR_ISCLOSEDOBJECT
					$sInfo &= 'Object state error - Expected/Required state is $ADO_adStateOpen - is $ADO_adStateClosed'
				Case $ADO_ERR_ISNOTREADYOBJECT
					$sInfo &= 'Object state error - Expected/Required state is $ADO_adStateOpen - is $ADO_adStateConnecting or $ADO_adStateExecuting or $ADO_adStateFetching'
				Case $ADO_ERR_INVALIDOBJECTTYPE
					$sInfo &= 'Function Parameters error - Expected/Required different Object Type'
				Case $ADO_ERR_INVALIDPARAMETERTYPE
					$sInfo &= 'Function Parameters error - Invalid Variable type passed to the function'
				Case $ADO_ERR_INVALIDPARAMETERVALUE
					$sInfo &= 'Function Parameters error - Invalid value passed to the function'
				Case $ADO_ERR_INVALIDARRAY
					$sInfo &= 'Function Parameters error - Invalid Recordset Array'
				Case $ADO_ERR_RECORDSETEMPTY
					$sInfo &= 'The Recordset is Empty - this not always mean error but in this case will not be returned any data'
				Case $ADO_ERR_NOCURRENTRECORD
					$sInfo &= 'The Recordset has no current record - but in this case will not be returned any data'
				Case $ADO_ERR_ENUMCOUNTER
					$sInfo &= 'not used in UDF - just for other/future testing'
				Case Else
					$sInfo &= 'UNKNOWN @ERROR'
			EndSwitch

			$sInfo &= @CRLF & '    @EXTENDED=' & $iExtended & '='
			Switch $iExtended
				Case $ADO_EXT_DEFAULT
					$sInfo &= 'default Extended Value'
				Case $ADO_EXT_PARAM1
					$sInfo &= 'Error Occurs in 1-Parameter'
				Case $ADO_EXT_PARAM2
					$sInfo &= 'Error Occurs in 2-Parameter'
				Case $ADO_EXT_PARAM3
					$sInfo &= 'Error Occurs in 3-Parameter'
				Case $ADO_EXT_PARAM4
					$sInfo &= 'Error Occurs in 4-Parameter'
				Case $ADO_EXT_PARAM5
					$sInfo &= 'Error Occurs in 5-Parameter'
				Case $ADO_EXT_PARAM6
					$sInfo &= 'Error Occurs in 6-Parameter'
				Case $ADO_EXT_INTERNALFUNCTION
					$sInfo &= 'Error Related to internal Function - should not happend - UDF Developer make something wrong ???'
				Case $ADO_EXT_ENUMCOUNTER
					$sInfo &= 'not used in UDF - just for other/future testing'
				Case Else
					$sInfo &= 'UNKNOWN @EXTENDED'
			EndSwitch
		EndIf
		$sInfo &= @CRLF
	EndIf
	Return SetError($iError, $iExtended, $sInfo)
EndFunc   ;==>_ADO_GetErrorDescription

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_MSDNErrorValueEnum_Description
; Description ...: Change ErrorValueEnum to Human Readable description
; Syntax ........: _ADO_MSDNErrorValueEnum_Description($iError[, $iErrorMacro = @error[, $iExtendedMacro = @extended]])
; Parameters ....: $iError              - an integer value. ErrorValueEnum
;                  $iErrorMacro         - [optional] an integer value. Default is @error.
;                  $iExtendedMacro      - [optional] an integer value. Default is @extended.
; Return values .: $sDescription
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://msdn.microsoft.com/en-us/library/windows/desktop/ms681549(v=vs.85).aspx
; Example .......: No
; ===============================================================================================================================
Func _ADO_MSDNErrorValueEnum_Description($iError, $iErrorMacro = @error, $iExtendedMacro = @extended)
	Local $sDescription = ''
	If StringLeft($iError, 2) = '0x' Then _
			$iError = Number(Dec(StringRight($iError, 4)))

	Switch $iError
		Case $ADO_adErrProviderFailed
			$sDescription = "Provider failed to perform the requested operation."
		Case $ADO_adErrInvalidArgument
			$sDescription = "Arguments are of the wrong type, are out of acceptable range, or are in conflict with one another. This error is often caused by a typographical error in an SQL SELECT statement. For example, a misspelled field name or table name can generate this error. This error can also occur when a field or table named in a SELECT statement does not exist in the data store."
		Case $ADO_adErrOpeningFile
			$sDescription = "File could not be opened. A misspelled file name was specified, or a file has been moved, renamed, or deleted. Over a network, the drive might be temporarily unavailable or network traffic might be preventing a connection."
		Case $ADO_adErrReadFile
			$sDescription = "File could not be read. The name of the file is specified incorrectly, the file might have been moved or deleted, or the file might have become corrupted."
		Case $ADO_adErrWriteFile
			$sDescription = "Write to file failed. You might have closed a file and then tried to write to it, or the file might be corrupted. If the file is located on a network drive, transient network conditions might prevent writing to a network drive."
		Case $ADO_adErrIllegalOperation
			$sDescription = "Operation is not allowed in this context."
		Case $ADO_adErrNoCurrentRecord
			$sDescription = "Either BOF or EOF is True, or the current record has been deleted. Requested operation requires a current record."
		Case $ADO_adErrCantChangeProvider
			$sDescription = "Supplied provider is different from the one already in use."
		Case $ADO_adErrInTransaction
			$sDescription = "Connection object cannot be explicitly closed while in a transaction. A Recordset or Connection object that is currently participating in a transaction cannot be closed. Call either RollbackTrans or CommitTrans before closing the object."
		Case $ADO_adErrFeatureNotAvailable
			$sDescription = "The object or provider is not capable of performing the requested operation. Some operations depend on a particular provider version."
		Case $ADO_adErrItemNotFound
			$sDescription = "Item cannot be found in the collection corresponding to the requested name or ordinal. An incorrect field or table name has been specified."
		Case $ADO_adErrObjectInCollection
			$sDescription = "Object is already in collection. Cannot append. An object cannot be added to the same collection twice."
		Case $ADO_adErrObjectNotSet
			$sDescription = "Object is no longer valid."
		Case $ADO_adErrDataConversion
			$sDescription = "Application uses a value of the wrong type for the current operation. You might have supplied a string to an operation that expects a stream, for example."
		Case $ADO_adErrObjectClosed
			$sDescription = "Operation is not allowed when the object is closed. TheConnection or Recordset has been closed. For example, some other routine might have closed a global object. You can prevent this error by checking the State property before you attempt an operation."
		Case $ADO_adErrObjectOpen
			$sDescription = "Operation is not allowed when the object is open. An object that is open cannot be opened. Fields cannot be appended to an open Recordset."
		Case $ADO_adErrProviderNotFound
			$sDescription = "Provider cannot be found. It may not be properly installed."
		Case $ADO_adErrBoundToCommand
			$sDescription = "The ActiveConnection property of a Recordset object, which has a Command object as its source, cannot be changed. The application attempted to assign a newConnection object to a Recordset that has a Commandobject as its source."
		Case $ADO_adErrInvalidParamInfo
			$sDescription = "Parameter object is improperly defined. Inconsistent or incomplete information was provided."
		Case $ADO_adErrInvalidConnection
			$sDescription = "The connection cannot be used to perform this operation. It is either closed or invalid in this context."
		Case $ADO_adErrNotReentrant
			$sDescription = "Operation cannot be performed while processing event. An operation cannot be performed within an event handler that causes the event to fire again. For example, navigation methods should not be called from within aWillMove event handler."
		Case $ADO_adErrStillExecuting
			$sDescription = "Operation cannot be performed while executing asynchronously."
		Case $ADO_adErrOperationCancelled
			$sDescription = "Operation has been canceled by the user. The application has called the CancelUpdate or CancelBatch method and the current operation has been canceled."
		Case $ADO_adErrStillConnecting
			$sDescription = "Operation cannot be performed while connecting asynchronously."
		Case $ADO_adErrInvalidTransaction
			$sDescription = "Coordinating transaction is invalid or has not started."
		Case $ADO_adErrNotExecuting
			$sDescription = "Operation cannot be performed while not executing."
		Case $ADO_adErrUnsafeOperation
			$sDescription = "Safety settings on this computer prohibit accessing a data source on another domain."
		Case $ADO_adWrnSecurityDialog
			$sDescription = "For internal use only. Don't use. (Entry was included for the sake of completeness. This error should not appear in your code.)"
		Case $ADO_adWrnSecurityDialogHeader
			$sDescription = "For internal use only. Don't use. (Entry included for the sake of completeness. This error should not appear in your code.)"
		Case $ADO_adErrIntegrityViolation
			$sDescription = "Data value conflicts with the integrity constraints of the field. A new value for a Field would cause a duplicate key. A value that forms one side of a relationship between two records might not be updatable."
		Case $ADO_adErrPermissionDenied
			$sDescription = "Insufficient permission prevents writing to the field. The user named in the connection string does not have the proper permissions to write to a Field."
		Case $ADO_adErrDataOverflow
			$sDescription = "Data value is too large to be represented by the field data type. A numeric value that is too large for the intended field was assigned. For example, a long integer value was assigned to a short integer field."
		Case $ADO_adErrSchemaViolation
			$sDescription = "Data value conflicts with the data type or constraints of the field. The data store has validation constraints that differ from the Field value."
		Case $ADO_adErrSignMismatch
			$sDescription = "Conversion failed because the data value was signed and the field data type used by the provider was unsigned."
		Case $ADO_adErrCantConvertvalue
			$sDescription = "Data value cannot be converted for reasons other than sign mismatch or data overflow. For example, conversion would have truncated data."
		Case $ADO_adErrCantCreate
			$sDescription = "Data value cannot be set or retrieved because the field data type was unknown, or the provider had insufficient resources to perform the operation."
		Case $ADO_adErrColumnNotOnThisRow
			$sDescription = "Record does not contain this field. An incorrect field name was specified or a field not in the Fields collection of the current record was referenced."
		Case $ADO_adErrURLDoesNotExist
			$sDescription = "Either the source URL or the parent of the destination URL does not exist. There is a typographical error in either the source or destination URL. You might havehttp://mysite/photo/myphoto.jpg when you should actually have http://mysite/photos/myphoto.jpginstead. The typographical error in the parent URL (in this case, photo instead of photos) has caused the error."
		Case $ADO_adErrTreePermissionDenied
			$sDescription = "Permissions are insufficient to access tree or subtree. The user named in the connection string does not have the appropriate permissions."
		Case $ADO_adErrInvalidURL
			$sDescription = "URL contains invalid characters. Make sure the URL is typed correctly. The URL follows the scheme registered to the current provider (for example, Internet Publishing Provider is registered for http)."
		Case $ADO_adErrResourceLocked
			$sDescription = "Object represented by the specified URL is locked by one or more other processes. Wait until the process has finished and attempt the operation again. The object you are trying to access has been locked by another user or by another process in your application. This is most likely to arise in a multi-user environment."
		Case $ADO_adErrResourceExists
			$sDescription = "Copy operation cannot be performed. Object named by destination URL already exists. Specify adCopyOverwriteto replace the object. If you do not specifyadCopyOverwrite when copying the files in a directory, the copy fails when you try to copy an item that already exists in the destination location."
		Case $ADO_adErrCannotComplete
			$sDescription = "The server cannot complete the operation. This might be because the server is busy with other operations or it might be low on resources."
		Case $ADO_adErrVolumeNotFound
			$sDescription = "Provider cannot locate the storage device indicated by the URL. Make sure the URL is typed correctly. The URL of the storage device might be incorrect, but this error can occur for other reasons. The device might be offline or a large volume of network traffic might prevent the connection from being made."
		Case $ADO_adErrOutOfSpace
			$sDescription = "Operation cannot be performed. Provider cannot obtain enough storage space. There might not be enough RAM or hard-drive space for temporary files on the server."
		Case $ADO_adErrResourceOutOfScope
			$sDescription = "Source or destination URL is outside the scope of the current record."
		Case $ADO_adErrUnavailable
			$sDescription = "Operation failed to complete and the status is unavailable. The field may be unavailable or the operation was not attempted. Another user might have changed or deleted the field you are trying to access."
		Case $ADO_adErrURLNamedRowDoesNotExist
			$sDescription = "Record named by this URL does not exist. While attempting to open a file using a Record object, either the file name or the path to the file was misspelled."
		Case $ADO_adErrDelResOutOfScope
			$sDescription = "The URL of the object to be deleted is outside the scope of the current record."
		Case $ADO_adErrCatalogNotSet
			$sDescription = "Operation requires a valid ParentCatalog."
		Case $ADO_adErrCantChangeConnection
			$sDescription = "Connection was denied. The new connection you requested has different characteristics than the one already in use."
		Case $ADO_adErrFieldsUpdateFailed
			$sDescription = "Fields update failed. For further information, examine theStatus property of individual field objects. This error can occur in two situations: when changing a Field object's value in the process of changing or adding a record to the database; and when changing the properties of the Fieldobject itself."
		Case $ADO_adErrDenyNotSupported
			$sDescription = "Provider does not support sharing restrictions. An attempt was made to restrict file sharing and your provider does not support the concept."
		Case $ADO_adErrDenyTypeNotSupported
			$sDescription = "Provider does not support the requested kind of sharing restriction. An attempt was made to establish a particular type of file-sharing restriction that is not supported by your provider. See the provider's documentation to determine what file-sharing restrictions are supported."
	EndSwitch
	Return SetError($iErrorMacro, $iExtendedMacro, '[ ' & $iErrorMacro & ' / ' & $iExtendedMacro & ' ] ' & $sDescription)
EndFunc   ;==>_ADO_MSDNErrorValueEnum_Description

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_UDFVersion
; Description ...: Get ADO UDFVersion number
; Syntax ........: _ADO_UDFVersion()
; Parameters ....: none
; Return values .: UDF Version
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_UDFVersion()
	Return '2.1.19 BETA'
EndFunc   ;==>_ADO_UDFVersion

; #FUNCTION# ====================================================================================================================
; Name ..........: _Au3Date_to_SQLDate
; Description ...: Convert date in _DateIsValid() to MS SQL Format
; Syntax ........: _Au3Date_to_SQLDate($sAu3Date)
; Parameters ....: $sAu3Date            - a string value.
; Return values .: On Success - string - MS SQL date Format
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: _SQLDate_to_Au3Date
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Au3Date_to_SQLDate($sAu3Date) ; IN: 1970/01/01 12:30:15  OUT: 1970-01-01T12:30:15.000
	If Not _DateIsValid($sAu3Date) Then _
			Return SetError($ADO_ERR_GENERAL, $ADO_EXT_PARAM1, $ADO_RET_FAILURE)

	; if only date then add time
	If StringRegExpReplace($sAu3Date, '(\d{4}\/\d{2}\/\d{2})', '') = '' Then $sAu3Date &= ' 00:00:00' ; @TODO ??? - support for $sAu3Date &= ' 23:59:59'
	; replace "/" to "-"    and add miliseconds
	Local $sSQLDate = StringReplace($sAu3Date, '/', '-') & '.000'
	; change the space (separator for date and time) for SQL equivalent T char
	$sSQLDate = StringReplace($sSQLDate, ' ', 'T')

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $sSQLDate)
EndFunc   ;==>_Au3Date_to_SQLDate

; #FUNCTION# ====================================================================================================================
; Name ..........: _SQLDate_to_Au3Date
; Description ...: Convert date in MS SQL Format to _DateIsValid()
; Syntax ........: _SQLDate_to_Au3Date($sDate[, $bOnlyYMD = False])
; Parameters ....: $sDate               - a string value.
;                  $bOnlyYMD            - [optional] a boolean value. Default is False.
; Return values .: On Success - string - Date in _DateIsValid() format
;                  On Failure - $ADO_RET_FAILURE and set @error to $ADO_ERR_*
; Author ........: mLipok
; Modified ......:
; Remarks .......: @TODO - REFACTORING should automaticaly validate SQL format and know if it is or not $bOnlyYMD
; Related .......: _Au3Date_to_SQLDate
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SQLDate_to_Au3Date($sDate, $bOnlyYMD = False)  ; IN: 1970-01-01T12:30:15.000  OUT: 1970/01/01 12:30:15
	Local $sParam = ($bOnlyYMD = True) ? '$1\/$2\/$3' : '$1\/$2\/$3\ $4:$5:$6'
	Return StringRegExpReplace($sDate, '(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})', $sParam)
EndFunc   ;==>_SQLDate_to_Au3Date
#EndRegion ADO.au3 - Functions - MISC

#Region ADO.au3 - Functions - OpenSchema

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_OpenSchema_Catalogs
; Description ...: @TODO
; Syntax ........: _ADO_OpenSchema_Catalogs(Byref $oConnection[, $s_CATALOG_NAME = Default])
; Parameters ....: $oConnection         - [in/out] an object.
;                  $s_CATALOG_NAME      - [optional] a string value. Default is Default.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://docs.microsoft.com/en-us/office/client-developer/access/desktop-database-reference/openschema-method-ado
; Example .......: No
; ===============================================================================================================================
Func _ADO_OpenSchema_Catalogs(ByRef $oConnection, $s_CATALOG_NAME = Default)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsReady($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Local $aCriteria_Catalog[1]
	If IsString($s_CATALOG_NAME) And $s_CATALOG_NAME <> Default Then $aCriteria_Catalog[0] = $s_CATALOG_NAME

	Local $oRecordset = $oConnection.OpenSchema($ADO_adSchemaCatalogs, $aCriteria_Catalog)
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)

	__ADO_Recordset_IsNotEmpty($oRecordset)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oRecordset)

EndFunc   ;==>_ADO_OpenSchema_Catalogs

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_OpenSchema_Columns
; Description ...: @TODO
; Syntax ........: _ADO_OpenSchema_Columns(Byref $oConnection[, $s_TABLE_CATALOG = Default[, $s_TABLE_SCHEMA = Default[,
;                  $s_TABLE_NAME = Default[, $s_COLUMN_NAME = Default]]]])
; Parameters ....: $oConnection         - [in/out] an object.
;                  $s_TABLE_CATALOG     - [optional] a string value. Default is Default.
;                  $s_TABLE_SCHEMA      - [optional] a string value. Default is Default.
;                  $s_TABLE_NAME        - [optional] a string value. Default is Default.
;                  $s_COLUMN_NAME       - [optional] a string value. Default is Default.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://docs.microsoft.com/en-us/office/client-developer/access/desktop-database-reference/openschema-method-ado
; Example .......: No
; ===============================================================================================================================
Func _ADO_OpenSchema_Columns(ByRef $oConnection, $s_TABLE_CATALOG = Default, $s_TABLE_SCHEMA = Default, $s_TABLE_NAME = Default, $s_COLUMN_NAME = Default)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsReady($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Local $aCriteria_Column[4]
	If IsString($s_TABLE_CATALOG) And $s_TABLE_CATALOG <> Default Then $aCriteria_Column[0] = $s_TABLE_CATALOG
	If IsString($s_TABLE_SCHEMA) And $s_TABLE_SCHEMA <> Default Then $aCriteria_Column[1] = $s_TABLE_SCHEMA
	If IsString($s_TABLE_NAME) And $s_TABLE_NAME <> Default Then $aCriteria_Column[2] = $s_TABLE_NAME
	If IsString($s_COLUMN_NAME) And $s_COLUMN_NAME <> Default Then $aCriteria_Column[3] = $s_COLUMN_NAME

	Local $oRecordset = $oConnection.OpenSchema($ADO_adSchemaColumns, $aCriteria_Column)
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)

	__ADO_Recordset_IsNotEmpty($oRecordset)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oRecordset)
EndFunc   ;==>_ADO_OpenSchema_Columns

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_OpenSchema_Indexes
; Description ...: @TODO
; Syntax ........: _ADO_OpenSchema_Indexes(Byref $oConnection[, $s_TABLE_CATALOG = Default[, $s_TABLE_SCHEMA = Default[,
;                  $s_INDEX_NAME = Default[, $s_TYPE = Default[, $s_TABLE_NAME = Default]]]]])
; Parameters ....: $oConnection         - [in/out] an object.
;                  $s_TABLE_CATALOG     - [optional] a string value. Default is Default.
;                  $s_TABLE_SCHEMA      - [optional] a string value. Default is Default.
;                  $s_INDEX_NAME        - [optional] a string value. Default is Default.
;                  $s_TYPE              - [optional] a string value. Default is Default.
;                  $s_TABLE_NAME        - [optional] a string value. Default is Default.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://docs.microsoft.com/en-us/office/client-developer/access/desktop-database-reference/openschema-method-ado
; Example .......: No
; ===============================================================================================================================
Func _ADO_OpenSchema_Indexes(ByRef $oConnection, $s_TABLE_CATALOG = Default, $s_TABLE_SCHEMA = Default, $s_INDEX_NAME = Default, $s_TYPE = Default, $s_TABLE_NAME = Default)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsReady($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Local $aCriteria_Index[5]
	If IsString($s_TABLE_CATALOG) And $s_TABLE_CATALOG <> Default Then $aCriteria_Index[0] = $s_TABLE_CATALOG
	If IsString($s_TABLE_SCHEMA) And $s_TABLE_SCHEMA <> Default Then $aCriteria_Index[1] = $s_TABLE_SCHEMA
	If IsString($s_INDEX_NAME) And $s_INDEX_NAME <> Default Then $aCriteria_Index[2] = $s_INDEX_NAME
	If IsString($s_TYPE) And $s_TYPE <> Default Then $aCriteria_Index[3] = $s_TYPE
	If IsString($s_TABLE_NAME) And $s_TABLE_NAME <> Default Then $aCriteria_Index[4] = $s_TABLE_NAME

	Local $oRecordset = $oConnection.OpenSchema($ADO_adSchemaIndexes, $aCriteria_Index)
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)

	__ADO_Recordset_IsNotEmpty($oRecordset)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oRecordset)

EndFunc   ;==>_ADO_OpenSchema_Indexes

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_OpenSchema_Procedures
; Description ...: @TODO
; Syntax ........: _ADO_OpenSchema_Procedures(Byref $oConnection[, $s_PROCEDURE_CATALOG = Default[, $s_PROCEDURE_SCHEMA = Default[,
;                  $s_PROCEDURE_NAME = Default[, $s_PARAMETER_NAME = Default]]]])
; Parameters ....: $oConnection         - [in/out] an object.
;                  $s_PROCEDURE_CATALOG - [optional] a string value. Default is Default.
;                  $s_PROCEDURE_SCHEMA  - [optional] a string value. Default is Default.
;                  $s_PROCEDURE_NAME    - [optional] a string value. Default is Default.
;                  $s_PARAMETER_NAME    - [optional] a string value. Default is Default.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://docs.microsoft.com/en-us/office/client-developer/access/desktop-database-reference/openschema-method-ado
; Example .......: No
; ===============================================================================================================================
Func _ADO_OpenSchema_Procedures(ByRef $oConnection, $s_PROCEDURE_CATALOG = Default, $s_PROCEDURE_SCHEMA = Default, $s_PROCEDURE_NAME = Default, $s_PARAMETER_NAME = Default)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsReady($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Local $aCriteria_Procedure[4]
	If IsString($s_PROCEDURE_CATALOG) And $s_PROCEDURE_CATALOG <> Default Then $aCriteria_Procedure[0] = $s_PROCEDURE_CATALOG
	If IsString($s_PROCEDURE_SCHEMA) And $s_PROCEDURE_SCHEMA <> Default Then $aCriteria_Procedure[1] = $s_PROCEDURE_SCHEMA
	If IsString($s_PROCEDURE_NAME) And $s_PROCEDURE_NAME <> Default Then $aCriteria_Procedure[2] = $s_PROCEDURE_NAME
	If IsString($s_PARAMETER_NAME) And $s_PARAMETER_NAME <> Default Then $aCriteria_Procedure[3] = $s_PARAMETER_NAME

	Local $oRecordset = $oConnection.OpenSchema($ADO_adSchemaProcedureParameters, $aCriteria_Procedure)
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)

	__ADO_Recordset_IsNotEmpty($oRecordset)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oRecordset)

EndFunc   ;==>_ADO_OpenSchema_Procedures

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_OpenSchema_Tables
; Description ...: @TODO
; Syntax ........: _ADO_OpenSchema_Tables(Byref $oConnection[, $s_TABLE_CATALOG = Default[, $s_TABLE_SCHEMA = Default[,
;                  $s_TABLE_NAME = Default[, $s_TABLE_TYPE = Default]]]])
; Parameters ....: $oConnection         - [in/out] an object.
;                  $s_TABLE_CATALOG     - [optional] a string value. Default is Default.
;                  $s_TABLE_SCHEMA      - [optional] a string value. Default is Default.
;                  $s_TABLE_NAME        - [optional] a string value. Default is Default.
;                  $s_TABLE_TYPE        - [optional] a string value. Default is Default.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://docs.microsoft.com/en-us/office/client-developer/access/desktop-database-reference/openschema-method-ado
; Example .......: No
; ===============================================================================================================================
Func _ADO_OpenSchema_Tables(ByRef $oConnection, $s_TABLE_CATALOG = Default, $s_TABLE_SCHEMA = Default, $s_TABLE_NAME = Default, $s_TABLE_TYPE = Default)
	Local Const $oADO_COMErrorHandler = ObjEvent("AutoIt.Error", __ADO_ComErrorHandler_WrapperFunction)
	If @error Then Return SetError($ADO_ERR_COMHANDLER, @error, $ADO_RET_FAILURE)
	#forceref $oADO_COMErrorHandler

	__ADO_Connection_IsReady($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Local $aCriteria_Table[4]
	If IsString($s_TABLE_CATALOG) And $s_TABLE_CATALOG <> Default Then $aCriteria_Table[0] = $s_TABLE_CATALOG
	If IsString($s_TABLE_SCHEMA) And $s_TABLE_SCHEMA <> Default Then $aCriteria_Table[1] = $s_TABLE_SCHEMA
	If IsString($s_TABLE_NAME) And $s_TABLE_NAME <> Default Then $aCriteria_Table[2] = $s_TABLE_NAME
	If IsString($s_TABLE_TYPE) And $s_TABLE_TYPE <> Default Then $aCriteria_Table[3] = $s_TABLE_TYPE

	Local $oRecordset = $oConnection.OpenSchema($ADO_adSchemaTables, $aCriteria_Table)
	If @error Then Return SetError($ADO_ERR_COMERROR, @error, $ADO_RET_FAILURE)

	__ADO_Recordset_IsNotEmpty($oRecordset)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $oRecordset)

EndFunc   ;==>_ADO_OpenSchema_Tables

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Schema_GetAllCatalogs
; Description ...:
; Syntax ........: _ADO_Schema_GetAllCatalogs(Byref $oConnection)
; Parameters ....: $oConnection         - [in/out] an object.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_Schema_GetAllCatalogs(ByRef $oConnection)
	Local $oRecordset = _ADO_OpenSchema_Catalogs($oConnection)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Local $aSchema_Catalogs = _ADO_Recordset_ToArray($oRecordset)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	$oRecordset.Close
	$oRecordset = Null

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $aSchema_Catalogs)
EndFunc   ;==>_ADO_Schema_GetAllCatalogs

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_Schema_GetAllTables
; Description ...:
; Syntax ........: _ADO_Schema_GetAllTables(Byref $oConnection, $s_TABLE_CATALOG)
; Parameters ....: $oConnection         - [in/out] an object.
;                  $s_TABLE_CATALOG     - a string value.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_Schema_GetAllTables(ByRef $oConnection, $s_TABLE_CATALOG)
	Local $oRecordset = _ADO_OpenSchema_Tables($oConnection, $s_TABLE_CATALOG)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	Local $aSchema_Tables = _ADO_Recordset_ToArray($oRecordset)
	If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)

	$oRecordset.Close
	$oRecordset = Null

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $aSchema_Tables)
EndFunc   ;==>_ADO_Schema_GetAllTables
#EndRegion ADO.au3 - Functions - OpenSchema

#Region ADO.au3 - Functions - Connection Strings

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_ConnectionString_Access
; Description ...: Create Connection string for MS Access file
; Syntax ........: _ADO_ConnectionString_Access($sFileFullPath[, $sUser = Default[, $sPassword = Default[, $sDriver = Default]]])
; Parameters ....: $sFileFullPath   - a string value.
;                  $sUser               - [optional] a string value. Default is Default.
;                  $sPassword           - [optional] a string value. Default is Default.
;                  $sDriver             - [optional] a string value. Default is Default.
; Return values .: connection string
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_ConnectionString_Access($sFileFullPath, $sUser = Default, $sPassword = Default, $sDriver = Default)

	If $sUser = Default Then
		$sUser = ''
	Else
		$sUser = 'Uid=' & $sUser & ';'
	EndIf

	If $sPassword = Default Then
		$sPassword = ''
	Else
		$sPassword = 'PWD=' & $sPassword & ';'
	EndIf

	If $sDriver = Default Then
		If StringRight($sFileFullPath, 6) = '.accdb' Then
			$sDriver = 'Microsoft Access Driver (*.mdb, *.accdb)'
		Else
			$sDriver = 'Microsoft Access Driver (*.mdb)'
		EndIf
	EndIf
	Local $sConnectionString = 'Driver={' & $sDriver & '};Dbq="' & $sFileFullPath & '";' & $sUser & $sPassword

	If Not StringRegExp($sConnectionString, '(?i)(Microsoft Access Driver \(*.mdb\)|Microsoft Access Driver \(*.mdb, *.accdb\))', $STR_REGEXPMATCH) Then
		$sConnectionString = StringReplace($sConnectionString, ';Dbq=', ' ;Data Source=')
	EndIf

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $sConnectionString)
EndFunc   ;==>_ADO_ConnectionString_Access

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_ConnectionString_Excel
; Description ...: Create Connection string for MS Excel file
; Syntax ........: _ADO_ConnectionString_Excel([$sFileFullPath = Default[, $sProvider = Default[, $sExtProperties = Default[,
;                  $HDR = Default[, $IMEX = 0]]]]])
; Parameters ....: $sFileFullPath   - [optional] a string value. Default is Default.
;                  $sProvider           - [optional] a string value. Default is Default.
;                  $sExtProperties        - [optional] a string value. Default is Default.
;                  $HDR                 - [optional] an unknown value. Default is Default.
;                  $IMEX                - [optional] an unknown value. Default is 0.
; Return values .: Connection String
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_ConnectionString_Excel($sFileFullPath = Default, $sProvider = Default, $sExtProperties = Default, $HDR = Default, $IMEX = Default)

	; Parameter #1 Validation
	If $sFileFullPath = Default Then
		$sFileFullPath = FileOpenDialog('Select XLS File', @ScriptDir, 'XLS file (*.xls)', $FD_FILEMUSTEXIST + $FD_PATHMUSTEXIST)
		If @error Then Return SetError(@error, @extended, $ADO_RET_FAILURE)
	EndIf

	; Parameter #2 Validation
	If $sProvider = Default Then $sProvider = 'Microsoft.Jet.OLEDB.4.0'
;~ 	If $sProvider = Default Then $sProvider = 'Provider=Microsoft.ACE.OLEDB.12.0'

	; Parameter #3 Validation
	If $sExtProperties = Default Then $sExtProperties = 'Excel 8.0'

	; Parameter #4 Validation
	If $HDR = Default Or $HDR = True Or $HDR = 'yes' Then
		$HDR = 'yes'
	Else
		$HDR = 'no'
	EndIf

	; Parameter #5 Validation
	If $IMEX = Default Then $IMEX = 0

	Local $sXLS_ConnectionString = _
			'Provider=' & $sProvider & ';' & _
			'Data Source="' & $sFileFullPath & '";' & _
			'Extended Properties="' & $sExtProperties & ';' & _
			'HDR=' & $HDR & ';' & _
			'IMEX=' & $IMEX & '";'

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $sXLS_ConnectionString)
EndFunc   ;==>_ADO_ConnectionString_Excel

; #FUNCTION# ====================================================================================================================
; Name ..........: _ADO_ConnectionString_MySQL
; Description ...: Create Connection string for MySQL database
; Syntax ........: _ADO_ConnectionString_MySQL($sUser, $sPassword, $sDatabase[, $sDriver = Default [, $sServer = Default [,
;                  $sPort = Default]]])
; Parameters ....: $sUser               - a string value.
;                  $sPassword           - a string value.
;                  $sDatabase           - a string value.
;                  $sDriver             - [optional] a string value. Default is Default .
;                  $sServer             - [optional] a string value. Default is Default .
;                  $sPort               - [optional] a string value. Default is Default.
; Return values .: Connection String
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ADO_ConnectionString_MySQL($sUser, $sPassword, $sDataBase, $sDriver = Default, $sServer = Default, $sPort = Default)
	; https://dev.mysql.com/doc/connector-net/en/connector-net-connection-options.html

	If $sDriver = Default Then $sDriver = 'MySQL ODBC 5.3 ANSI Driver'
	If $sServer = Default Then $sServer = 'localhost'
	If $sPort = Default Then $sPort = '3306'

	Local $sConnectionString = 'Driver={' & $sDriver & '};SERVER=' & $sServer & ';PORT=' & $sPort & ';DATABASE=' & $sDataBase & ';User=' & $sUser & ';Password=' & $sPassword & ';'

	Return SetError($ADO_ERR_SUCCESS, $ADO_EXT_DEFAULT, $sConnectionString)
EndFunc   ;==>_ADO_ConnectionString_MySQL
#EndRegion ADO.au3 - Functions - Connection Strings

#Region ADO.au3 - TODO and Help/Docs

#cs
	SQLState Property
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms681570(v=vs.85).aspx

	NativeError Property (ADO)
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms678049(v=vs.85).aspx

	Programming ADO SQL Server Applications
	https://technet.microsoft.com/en-us/library/aa905875(v=sql.80).aspx
	https://technet.microsoft.com/en-us/library/aa214053(v=sql.80).aspx

	ADO API Reference
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms678086(v=vs.85).aspx

	ADO Code Examples
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms681484(v=vs.85).aspx

	Microsoft OLE DB Provider for SQL Server
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms677227(v=vs.85).aspx

	OpenSchema Method Example (VB)
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms675853(v=vs.85).aspx

	Errors Collection Properties, Methods, and Events
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms676176(v=vs.85).aspx

	ErrorValueEnum
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms677004(v=vs.85).aspx

	ADO Code Examples VBScript
	https://msdn.microsoft.com/en-us/library/ms676589(v=vs.85).aspx

	ADO Code Examples in Visual Basic
	https://msdn.microsoft.com/en-us/library/ms675104(v=vs.85).aspx
#ce

#cs ADO Events some reference

	Handling ADO Events
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms681467(v=vs.85).aspx
	https://docs.microsoft.com/en-us/sql/ado/reference/ado-api/ado-events?view=sql-server-ver15

	ADO Event Handler Summary
	https://msdn.microsoft.com/en-us/library/ms677579(v=vs.85).aspx

	Handling Errors and Messages in ADO
	https://technet.microsoft.com/en-us/library/aa905919(v=sql.80).aspx

	ExecuteComplete Event (ADO)
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms676183(v=vs.85).aspx


	ADO Error Reference
	https://msdn.microsoft.com/en-us/library/ms681549(v=vs.85).aspx

	ADO Collections
	https://msdn.microsoft.com/en-us/library/ms677591(v=vs.85).aspx

	WillChangeRecordset and RecordsetChangeComplete Events (ADO)
	https://msdn.microsoft.com/en-us/library/ms680919(v=vs.85).aspx


	Handling Errors and Messages in ADO
	https://technet.microsoft.com/en-us/library/aa905919(v=sql.80).aspx

	Performing Transactions in ADO
	https://technet.microsoft.com/en-us/library/aa905921(v=sql.80).aspx

	An ADO Transaction
	https://msdn.microsoft.com/en-us/library/aa227162(v=vs.60).aspx

	ADO BeginTrans, CommitTrans, and RollbackTrans Methods
	http://www.w3schools.com/asp/met_conn_begintrans.asp

	BeginTrans, CommitTrans, and RollbackTrans Methods Example (VB)
	https://msdn.microsoft.com/en-us/library/windows/desktop/ms677538%28v=vs.85%29.aspx

#ce ADO Events some reference

#cs
	View Object (ADOX)
	https://msdn.microsoft.com/en-us/library/ms676503(v=vs.85).aspx

	Views Collection (ADOX)
	https://msdn.microsoft.com/en-us/library/ms677523(v=vs.85).aspx

	Views Collection, CommandText Property Example (VB)
	https://msdn.microsoft.com/en-us/library/ms677503(v=vs.85).aspx

	Views and Fields Collections Example (VB)
	https://msdn.microsoft.com/en-us/library/ms680939(v=vs.85).aspx


	How To Determine Number of Records Affected by an ADO UPDATE
	https://support.microsoft.com/en-us/kb/195048

	ADO Programmer's Guide
	https://msdn.microsoft.com/en-us/library/ms681025(v=vs.85).aspx

	ADO Programmer's Reference
	https://msdn.microsoft.com/en-us/library/ms676539(v=vs.85).aspx

	ADO Objects and Interfaces
	https://msdn.microsoft.com/en-us/library/ms679836(v=vs.85).aspx

	ADOX Programming Code Examples
	http://allenbrowne.com/func-adox.html

	ADO Programming Code Examples
	http://allenbrowne.com/func-ADO.html

	Driver Specification Subkeys
	https://msdn.microsoft.com/en-us/library/ms714538(v=vs.85).aspx
	Local $key = "HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers"

	The SQL Server Native Client...
	https://msdn.microsoft.com/pl-pl/sqlserver/aa937733.aspx

	Get Started Developing with the SQL Server Native Client
	https://msdn.microsoft.com/pl-pl/sqlserver/ff658533

	Building Applications with SQL Server Native Client
	https://msdn.microsoft.com/en-us/library/ms130904.aspx

	When to Use SQL Server Native Client
	https://msdn.microsoft.com/en-us/library/ms130828.aspx

	What's New in SQL Server Native Client
	https://msdn.microsoft.com/en-us/library/cc280510.aspx

	SQL Server Native Client Features
	https://msdn.microsoft.com/en-us/library/ms131456.aspx

	SQL Server Native Client Programming
	https://msdn.microsoft.com/en-us/library/ms130892.aspx

	Native API for SQL Server FAQ
	https://msdn.microsoft.com/en-us/sqlserver/aa937707.aspx

	Examlple of Connection Strings
	https://www.connectionstrings.com/


	HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers

	ADO Command Strategies
	https://msdn.microsoft.com/en-us/library/aa260835(v=vs.60).aspx

	Command Object (ADO)
	https://msdn.microsoft.com/en-us/library/ms677502(v=vs.85).aspx

	CreateParameter Method (ADO)
	https://msdn.microsoft.com/en-us/library/ms677209(v=vs.85).aspx


	; How To Determine Number of Records Affected by an ADO UPDATE
	; https://support.microsoft.com/en-us/kb/195048
	; Use the command object to perform an UPDATE and return the count of affected records.

	XSLT Transformations (Recordset XML >> HTML)
	https://msdn.microsoft.com/en-us/library/ms675135(v=vs.85).aspx

	XML Recordset Persistence Scenario
	https://msdn.microsoft.com/en-us/library/ms675780(v=vs.85).aspx

	Persisting Data
	https://msdn.microsoft.com/en-us/library/ms675273(v=vs.85).aspx

	Saving to the XML DOM Object
	https://msdn.microsoft.com/en-us/library/ms675954(v=vs.85).aspx

	Persisting Records in XML Format
	https://msdn.microsoft.com/en-us/library/ms681538(v=vs.85).aspx


	MS PROJECT
	https://officetechsupport.wordpress.com/2010/05/21/export-ms-project-data-to-excel/

#ce
#EndRegion ADO.au3 - TODO and Help/Docs
