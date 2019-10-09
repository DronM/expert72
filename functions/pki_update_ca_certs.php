<?php
	//require_once(dirname(__FILE__).'/../Config.php');
	require_once('PKIManager.php');
	require_once("ExpertEmailSender.php");
	
	$pki_man = new PKIManager(array("pkiPath"=>PKI_PATH));
	$pki_man->makeCACertificates();
	/*
	try{
		$pki_man->makeCACertificates();
	}
	catch(Exception $e){
		ExpertEmailSender::regMail($dbLink,sprintf("email_ca_update_error('%s')",$e->getMessage()),NULL,'ca_update_error');
	}
	*/
?>
