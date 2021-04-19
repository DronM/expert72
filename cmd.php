<?php
require_once('Config.php');
require_once(FRAME_WORK_PATH.'Constants.php');
require_once('db/SessManager.php');
require_once(FRAME_WORK_PATH.'db/db_pgsql.php');

require_once(FRAME_WORK_PATH.'basic_classes/Controller.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelServResponse.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');

try{
	//Session connection 
	$dbLinkSess = new DB_Sql();
	$dbLinkSess->persistent = TRUE;
	$dbLinkSess->appname = APP_NAME;
	$dbLinkSess->technicalemail = TECH_EMAIL;
	$dbLinkSess->reportError = DEBUG;	
	$dbLinkSess->productionConnectError = ERR_SQL_SERVER_CON;
	$dbLinkSess->productionSQLError = ERR_SQL_QUERY;	
	$dbLinkSess->detailedError = defined('DETAILED_ERROR')? DETAILED_ERROR:DEBUG;
	if (defined('QUERY_SHOW'))$dbLinkSess->showqueries = QUERY_SHOW;
	if (defined('QUERY_LOG'))$dbLinkSess->logQueries = QUERY_LOG;	
	if (defined('QUERY_LOG_FILE'))$dbLinkSess->logFile = QUERY_LOG_FILE;
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
	
	$expSec = (defined('SESSION_EXP_SEC'))? SESSION_EXP_SEC:0;
	$session = new SessManager();
	$session->start_session('_s', $dbLinkSess,$dbLinkSess,FALSE,$expSec);
	
	//===================== EXPERT72 ========================================
	$sess_expired =  (isset($_SESSION['sess_discard_after']) && time() > $_SESSION['sess_discard_after']);
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
		$dbLinkMaster = $dbLinkSess;
	}
	else{
		// connection for reading
		$dbLinkMaster = new DB_Sql();
		$dbLinkMaster->persistent=true;
		$dbLinkMaster->appname = APP_NAME;
		$dbLinkMaster->technicalemail = TECH_EMAIL;
		$dbLinkMaster->reportError = DEBUG;
		$dbLinkMaster->database= $db_name;			
		$dbLinkMaster->productionConnectError = ERR_SQL_SERVER_CON;
		$dbLinkMaster->productionSQLError = ERR_SQL_QUERY;		
		if (defined('QUERY_SHOW'))$dbLinkMaster->showqueries = QUERY_SHOW;
		if (defined('QUERY_LOG_FILE'))$dbLinkMaster->logfile = QUERY_LOG_FILE;
		if (defined('QUERY_EXPLAIN'))$dbLinkMaster->explain = QUERY_EXPLAIN;		
		$dbLinkMaster->connect(
			$db_server,
			$db_user,
			$db_password,
			$port
		);		
	}
	//=======================================================================
	

	if (defined('PARAM_TOKEN')
	&& defined('TOKEN_AFTER_EXPIR_METHODS')
	&& isset($token)
	&& $session_ar['expired']=='t'
	&& !in_array($_REQUEST[PARAM_METHOD],explode(',',TOKEN_AFTER_EXPIR_METHODS))
	){		
		//session_destroy();
		//$_SESSION = array();		
		throw new Exception(ERR_AUTH_EXP);
	}		
		
	//setting locale
	if (isset($_SESSION['user_time_locale'])){			
		$q = sprintf("SET TIME ZONE '%s'",
			$_SESSION['user_time_locale']
		);
		$dbLinkMaster->query($q);
		if (!$sess_same_loc){
			$dbLinkSess->query($q);
		}
		
		//php locale		
		date_default_timezone_set($_SESSION['user_time_locale']);
	}
	
	if (isset($_SESSION['LOGGED'])){
		$now = time();
		//$sess_len = (isset($_SESSION['sess_len']))? $_SESSION['sess_len'] : ( (defined('SESSION_EXP_SEC'))? SESSION_EXP_SEC : 0);
		//throw new Exception("Now=".$now.' sess_discard_after='.$_SESSION['sess_discard_after'].' len='.$sess_len);
		if (isset($_SESSION['sess_discard_after']) && $now > $_SESSION['sess_discard_after']) {
			session_unset();
			session_destroy();
			session_start();
			throw new Exception(ERR_AUTH_EXP);
		}
		$sess_len = (isset($_SESSION['sess_len']))? $_SESSION['sess_len'] : ( (defined('SESSION_EXP_SEC'))? SESSION_EXP_SEC : 0);
		if ($sess_len){
			$_SESSION['sess_discard_after'] = $now + $sess_len;
		}
	}
			
	if (!isset($_SESSION['scriptId'])){
		$_SESSION['scriptId'] = md5(session_id());
	}

	//*****************************
	//default page params
	if (!isset($_SESSION['LOGGED'])){			
		if (!isset($_REQUEST[PARAM_CONTROLLER])){
			$_REQUEST[PARAM_CONTROLLER] = UNLOGGED_DEF_CONTROLLER;
		}
		if (!isset($_REQUEST[PARAM_VIEW])){
			$_REQUEST[PARAM_VIEW] = UNLOGGED_DEF_VIEW;
			unset($_REQUEST[PARAM_METHOD]);
		}
	}
	
	$contr = (isset($_REQUEST[PARAM_CONTROLLER]) && strlen($_REQUEST[PARAM_CONTROLLER]))? $_REQUEST[PARAM_CONTROLLER]:null;
	$meth = (isset($_REQUEST[PARAM_METHOD]) && strlen($_REQUEST[PARAM_METHOD]))? $_REQUEST[PARAM_METHOD]:null;	
	$view = (isset($_REQUEST[PARAM_VIEW]) && strlen($_REQUEST[PARAM_VIEW]))? $_REQUEST[PARAM_VIEW]:DEF_VIEW;
	//throw new Exception("contr=".$contr.' meth='.$meth.' view='.$view);
	/* controller checking*/
	if (!is_null($contr) && !file_exists($script=USER_CONTROLLERS_PATH.$contr.'.php')){	
		if (!isset($_SESSION['LOGGED'])){			
			throw new Exception(ERR_AUTH_NOT_LOGGED);
		}
		else{		
			throw new Exception(ERR_COM_NO_CONTROLLER);
		}
	}
	else if (is_null($contr) && defined('CUSTOM_CONTROLLER') && file_exists($script=USER_CONTROLLERS_PATH.CUSTOM_CONTROLLER.'.php')){	
		$contr = CUSTOM_CONTROLLER;
	}
	else if (is_null($contr)){
		$contr = 'Controller';
		$script=FRAME_WORK_PATH.'basic_classes/Controller.php'; 
	}
	//checking if method is allowed
	if (isset($_REQUEST['redir'])){
		$contr = UNLOGGED_DEF_CONTROLLER;
		$view = UNLOGGED_DEF_VIEW;			
	}
	else if (!is_null($meth)){
		$role_id = (isset($_SESSION['LOGGED']) && isset($_SESSION['role_id']))? $_SESSION['role_id'] : 'guest';
		require(PERM_PATH.'permission_'.$role_id.'.php');
		//throw new Exception($contr.'__'.$meth.'__'.$role_id);
		
		if (!method_allowed($contr,$meth,$role_id)){
			if (!isset($_SESSION['LOGGED'])){
				throw new Exception(ERR_AUTH_NOT_LOGGED);
			}
			else{		
				throw new Exception(ERR_COM_METH_PROHIB);
			}
		}
		
	}
	
	/* including controller */	
	require_once($script);
	$contrObj = new $contr($dbLinkMaster,$dbLinkMaster);

	/* view checking*/
	if (is_null($view)){
		$def_view = $contrObj->getDefaultView();
		$view = (isset($def_view))? $def_view:DEF_VIEW;
		if (!isset($view)){
			throw new Exception(ERR_COM_NO_VIEW);
		}	
	}
	$view_class = $view;
	if (!file_exists($v_script=USER_VIEWS_PATH.$view.'.php')){	
		$pathArray = explode(PATH_SEPARATOR, get_include_path());	
		$v_script = (count($pathArray)>=1)?
			$pathArray[1].'/'.FRAME_WORK_PATH.'basic_classes/'.$view.'.php' :
			USER_VIEWS_PATH.$view.'.php';
		
		if (!file_exists($v_script)){	
			if (file_exists($v_script=USER_VIEWS_PATH.DEF_VIEW.'.php')){
				$view_class = DEF_VIEW;
			}
			else{
				throw new Exception(ERR_COM_NO_VIEW);
			}
		}
	}
	
	require_once($v_script);
	
	if (!$contrObj->runPublicMethod($meth,$_REQUEST)){
		/*if nothing has been sent yet - default output*/
		$contrObj->write($view_class,$view);
	}
}
catch (Exception $e){

	if (defined('PARAM_TEMPLATE')){
		unset($_REQUEST[PARAM_TEMPLATE]);
	}
	$contrObj = new Controller();	
	$resp = new ModelServResponse();				
	$contrObj->addModel($resp);	
	$ar = explode('@',$e->getMessage());
	$resp->result = (count($ar)>1)? intval($ar[1]) : 1;
	if ($resp->result==0){
		$resp->result = 1;
	}
	if (count($ar)){		
		//$resp->descr = htmlspecialchars(str_replace("exception 'Exception' with message",'','111='.$ar[0]));		
		$er_s = str_replace('ОШИБКА: ','',$ar[0]);//ошибки postgre
		$er_s = str_replace("exception 'Exception' with message '",'',$er_s);
		$resp->descr = $er_s;//htmlspecialchars($er_s,ENT_XML1,'UTF-8',FALSE);//
	}
	else{
		$resp->descr = $e->getMessage();//htmlspecialchars($e->getMessage(),ENT_XML1,'UTF-8',FALSE);
	}
	
	$view = (isset($_REQUEST[PARAM_VIEW]))? $_REQUEST[PARAM_VIEW]:DEF_VIEW;
	
	//throw new Exception("v=".USER_VIEWS_PATH.$view.'.php');
	if (!isset($v_script)){
		//not included yet
		if (!file_exists($v_script=USER_VIEWS_PATH.$view.'.php')){	
			$pathArray = explode(PATH_SEPARATOR, get_include_path());	
			$v_script = (count($pathArray)>=1)?
				$pathArray[1].'/'.FRAME_WORK_PATH.'basic_classes/'.$view.'.php' :
				USER_VIEWS_PATH.$view.'.php';
		}
		if (file_exists($v_script)){
			require_once($v_script);		
		}
	}
	
	$contrObj->write($view,$view,$resp->result);
	
}
?>
