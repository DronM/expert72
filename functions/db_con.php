<?php
require_once(dirname(__FILE__).'/../Config.php');
require_once(FRAME_WORK_PATH.'db/db_pgsql.php');
require_once(dirname(__FILE__).'/../db/SessManager.php');
require_once(FRAME_WORK_PATH.'Constants.php');

	//Session connection 
	$dbLinkSess = new DB_Sql();
	$dbLinkSess->persistent = TRUE;
	$dbLinkSess->appname = APP_NAME;
	$dbLinkSess->technicalemail = TECH_EMAIL;
	$dbLinkSess->reportError = DEBUG;	
	$dbLinkSess->productionConnectError = ERR_SQL_SERVER_CON;
	$dbLinkSess->productionSQLError = ERR_SQL_QUERY;	
	if (defined('QUERY_SHOW'))$dbLinkSess->showqueries = QUERY_SHOW;
	if (defined('QUERY_LOG_FILE'))$dbLinkSess->logfile = QUERY_LOG_FILE;
	if (defined('QUERY_EXPLAIN'))$dbLinkSess->explain = QUERY_EXPLAIN;
	$dbLinkSess->database = LK? DB_NAME_LK:DB_NAME;
	$sess_db_server = LK? DB_SERVER_LK:DB_SERVER_OFFICE;
	$sess_port = LK? DB_PORT_LK:DB_PORT_OFFICE;
	
	$dbLinkSess->connect(
		$sess_db_server,
		LK? DB_USER_LK:DB_USER_OFFICE,
		LK? DB_PASSWORD_LK:DB_PASSWORD_OFFICE,
		$sess_port
	);
	
	//$expSec = (defined('SESSION_EXP_SEC'))? SESSION_EXP_SEC:0;
	$session = new SessManager();
	$session->start_session('_s', $dbLinkSess,$dbLinkSess);
	
	//===================== EXPERT72 ========================================
	$sess_expired =  FALSE;//(isset($_SESSION['sess_discard_after']) && time() > $_SESSION['sess_discard_after']);
	if (
		($sess_expired&&LK)
		|| (!isset($_SESSION['LOGGED'])&&LK)
		|| (
			isset($_SESSION['LOGGED'])
			&& isset($_SESSION['role_id'])
			&& (
				$_SESSION['role_id']=='client'
				||($_SESSION['role_id']=='admin' && $_SESSION['user_name']=='adminlk')
			)
		)
	){
		//Клиент - всегда доступ ТОЛЬКО клиентский с любого сервера
		$db_server = DB_SERVER_LK;
		$db_user = DB_USER_LK;
		$db_password = DB_PASSWORD_LK;
		$port = DB_PORT_LK;
		$db_name = DB_NAME_LK;
	}
	else{
		//не клиент, здесь доступ из офиса
		$db_server = DB_SERVER_OFFICE;
		$db_user = DB_USER_OFFICE;
		$db_password = DB_PASSWORD_OFFICE;						
		$port = DB_PORT_OFFICE;
		$db_name = DB_NAME;
	}
	
	$sess_same_loc = ($db_server==$sess_db_server && $port==$sess_port);
	if ($sess_same_loc){
		$dbLink = $dbLinkSess;
	}
	else{
		// connection for reading
		$dbLink = new DB_Sql();
		$dbLink->persistent=true;
		$dbLink->appname = APP_NAME;
		$dbLink->technicalemail = TECH_EMAIL;
		$dbLink->reportError = DEBUG;
		$dbLink->database= $db_name;			
		$dbLink->productionConnectError = ERR_SQL_SERVER_CON;
		$dbLink->productionSQLError = ERR_SQL_QUERY;		
		if (defined('QUERY_SHOW'))$dbLink->showqueries = QUERY_SHOW;
		if (defined('QUERY_LOG_FILE'))$dbLink->logfile = QUERY_LOG_FILE;
		if (defined('QUERY_EXPLAIN'))$dbLink->explain = QUERY_EXPLAIN;		
		$dbLink->connect(
			$db_server,
			$db_user,
			$db_password,
			$port
		);		
	}
	//=======================================================================
	//setting locale
	if (isset($_SESSION['user_time_locale'])){			
		$q = sprintf("SET TIME ZONE '%s'",
			$_SESSION['user_time_locale']
		);
		$dbLink->query($q);
		if (!$sess_same_loc){
			$dbLinkSess->query($q);
		}
		
		//php locale		
		date_default_timezone_set($_SESSION['user_time_locale']);
	}

?>
