<?php
/*
function dec2hex($number){
    $hexvalues = array('0','1','2','3','4','5','6','7',
               '8','9','A','B','C','D','E','F');
    $hexval = '';
     while($number != '0'){
        $hexval = $hexvalues[bcmod($number,'16')].$hexval;
        $number = bcdiv($number,'16',0);
    }
    return $hexval;
}
echo dec2hex('2429033231916172176376404571619655682');
return;
*/
	require_once('functions/PKIManager.php');
	$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,'debug');
	//$certData = new stdClass();
	//$pki_man->getCertInf('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/5bcbfc353d0b3.1',$certData);
	//var_dump($certData);
	//exit;
	//$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/744000cf-3b5f-42eb-8dfa-1fda59b88871.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/744000cf-3b5f-42eb-8dfa-1fda59b88871',TRUE,FALSE,FALSE);
	//$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/260-Д Договор Тюменгипроводхоз одновременно.pdf.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/260-Д Договор Тюменгипроводхоз одновременно.pdf');
	$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/1/Z -72-1-0223-18.pdf.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/1/Z -72-1-0223-18.pdf',FALSE,FALSE,FALSE);
	//$pki_man->makeCACertificates();
	//exit;
	
	/*
	$verif_res = pki_log_sig_check(
		'/home/andrey/www/htdocs/expert72/client_files/Заявление№1566/Договорные документы/Контракт/9f1357af-d7cf-4dbb-813f-a15c5b4a833b.sig',
		'/home/andrey/www/htdocs/expert72/client_files/Заявление№1566/Договорные документы/Контракт/9f1357af-d7cf-4dbb-813f-a15c5b4a833b',
		'9f1357af-d7cf-4dbb-813f-a15c5b4a833b',
		$pki_man,
		$dbLink
	);
	*/
	
	//$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/222/Ответы на замечания_11.10.2018.pdf.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/222/Ответы на замечания_11.10.2018.pdf',TRUE);
	
	//$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Заключение.pdf.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Заключение.pdf');
	//$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/client_files/Заявление№1560/ПД/1/1a740690-5894-40d3-867a-68dfb65ff00a.sig','/home/andrey/www/htdocs/expert72/client_files/Заявление№1560/ПД/1/1a740690-5894-40d3-867a-68dfb65ff00a');
	
	//hash = 8b134d3d947e774a5f76acc3b84e9a2372a3923ade675508db1f9fb3e9908c3f
	/* openssl crl2pkcs7 -nocrl -certfile cert1.cer -certfile cert2.cer -out outfile.p7b
	If you wish to provide DER encoded input files (or have DER output) you can use the -inform DER or -outform DER directives
	*/
	//$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Заключение/Z -72-1-0169-18.pdf.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Заключение/Z -72-1-0169-18.pdf');
	//echo $pki_man->getFileHash('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Заключение/Z -72-1-0169-18.pdf');
	//exit;
	
	var_dump($verif_res);
	
	echo '</BR></BR></BR></BR></BR>';
	echo ($verif_res->checkPassed? 'PASSED':'NOT passed').'</br>';
	if (!$verif_res->checkPassed)echo 'Ошибка='.$verif_res->checkError.'<br>';
	
	/*
	
	echo 'From='.date('d/m/Y',$certData->dateFrom).'<br>';
	echo 'To='.date('d/m/Y',$certData->dateTo).'<br>';
	//echo 'СНИЛС='.$certData->subject['СНИЛС'].'<br>';
	//echo 'Фамилия='.$certData->subject['Фамилия'].'<br>';
	*/
	echo 'Время проверки='.$verif_res->checkTime.'<br>';
	echo '</BR></BR>';

?>
