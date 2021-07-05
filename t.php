<?php
require_once('Config.php');


	require_once('functions/PKIManager.php');
	$pki_man = new PKIManager(array(
			'pkiPath' => PKI_PATH,
			'logPath' => OUTPUT_PATH,
			'crlValidity' => PKI_CRL_VALIDITY,
			'logLevel' => 'debug',
			'tmpPath' => OUTPUT_PATH,
			'opensslPath' => PKI_OPENSSL_PATH
	));	
/*
$newName = '/home/andrey/www/htdocs/expert72/client_files/Заявление№3047/Договорные документы/Акт выполненных работ/aac59e1e-d0bd-4bfc-9adb-7a293c11036d.sig';
$der_file = '/home/andrey/www/htdocs/expert72/output/aac59e1e-d0bd-4bfc-9adb-7a293c11036d.der';
$merged_sig = '/home/andrey/www/htdocs/expert72/client_files/Заявление№3047/Договорные документы/Акт выполненных работ/aac59e1e-d0bd-4bfc-9adb-7a293c11036d.mrg';
$pki_man->mergeSigs($newName,$der_file,$merged_sig);

?>
