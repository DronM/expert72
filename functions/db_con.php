<?php
require_once(dirname(__FILE__).'/../Config.php');
require_once(FRAME_WORK_PATH.'db/db_pgsql.php');

$dbLink = new DB_Sql();
$dbLink->appname = APP_NAME;
$dbLink->technicalemail = TECH_EMAIL;
$dbLink->reportError = DEBUG;
$dbLink->productionConnectError = 'Ошибка подключения к серверу базы данных.@105';
$dbLink->productionSQLError	= 'Ошибка при выполнении запроса к базе данных.@106';		
if (defined('QUERY_LOG_FILE'))$dbLink->logfile = QUERY_LOG_FILE;

/*conneсtion*/
if (
	(!isset($_SESSION['LOGGED'])&&LK)
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
	$dbLink->database = DB_NAME_LK;
}
else{
	//не клиент, здесь доступ с главного
	$db_server = DB_SERVER_OFFICE;
	$db_user = DB_USER_OFFICE;
	$db_password = DB_PASSWORD_OFFICE;						
	$port = DB_PORT_OFFICE;
	$dbLink->database = DB_NAME;
}
$dbLink->connect($db_server, $db_user, $db_password, $port);

?>
