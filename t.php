<?php
require_once('Config.php');

	require_once('common/BikInfo.php');
	BikInfo::genFile(OUTPUT_PATH);
exit;

	echo time();
	exit;
//	echo 11%2;
//	exit;
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
	$pki_man = new PKIManager(array(
			'pkiPath' => PKI_PATH,
			'logPath' => OUTPUT_PATH,
			'crlValidity' => PKI_CRL_VALIDITY,
			'logLevel' => 'debug',
			'tmpPath' => OUTPUT_PATH,
			'opensslPath' => PKI_OPENSSL_PATH
	));	
	/*
	$verif_res = $pki_man->verifySig(
		'/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/НеКвалифицированная/Доверенность № 82, Надеина А.М.pdf.sig',
		'/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/НеКвалифицированная/Доверенность № 82, Надеина А.М.pdf',
		array(
			'noChainVerification' => FALSE,
			'onlineRevocCheck' => TRUE,
			'notRemoveTempFiles' => FALSE,
			'unqualifiedCertTreatAsError' => TRUE
		)
	);
	*/
	$verif_res = $pki_man->verifySig(
		'/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/Expired/299-Д Контракт УКС.pdf.sig',
		'/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/Expired/299-Д Контракт УКС.pdf',
		array(
			'noChainVerification' => TRUE,
			'onlineRevocCheck' => TRUE,
			'notRemoveTempFiles' => TRUE,
			'unqualifiedCertTreatAsError' => TRUE
		)
	);
	
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
