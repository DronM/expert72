<?php
	require_once('db_con.php');
	require_once(USER_CONTROLLERS_PATH.'ClientPayment_Controller.php');	
	
	$contr = new ClientPayment_Controller($dbLink);
	$pm = $contr->getPublicMethod('get_from_1c');
	if (count($argv)>=2){
		$pm->setParamValue('date_from',$argv[1]);
	}
	if (count($argv)>=3){
		$pm->setParamValue('date_to',$argv[2]);
	}
	
	$contr->get_from_1c($pm);
?>
