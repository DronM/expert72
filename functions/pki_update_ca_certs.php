<?php
	//require_once(dirname(__FILE__).'/../Config.php');
	require_once('PKIManager.php');
	require_once("ExpertEmailSender.php");
	
	$pki_man = new PKIManager(PKI_PATH);
	$pki_man->update_ca_certs();
	/*
	try{
		$pki_man->update_ca_certs();
	}
	catch(Exception $e){
		ExpertEmailSender::regMail($dbLink,sprintf("email_ca_update_error('%s')",$e->getMessage()),NULL,'ca_update_error');
	}
	*/
?>
