<?php
	require_once('db_con.php');
	require_once(USER_CONTROLLERS_PATH.'ClientPayment_Controller.php');	
	
	$contr = new ClientPayment_Controller($dbLink);
	$contr->get_from_1c($contr->getPublicMethod('get_from_1c'));
?>
