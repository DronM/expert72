<?php
	require_once('db_con.php');
	require_once(USER_CONTROLLERS_PATH.'ClientPayment_Controller.php');	
	
	$contr = new Contrcat_Controller($dbLink);
	$contr->get_payments($contr->getPublicMethod('get_from_1c'));
?>
