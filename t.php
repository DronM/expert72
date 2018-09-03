<?php
/*
$d = strtotime('Aug 28 07:23:50 2018 GMT');
echo date('d/m/Y H:i:s',$d);
return;	
*/
	require_once('functions/PKIManager.php');
	$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,'debug');
	$der_file = '/home/andrey/www/htdocs/expert72/client_files/Заявление№1532/Исходящие/3a453276-a31e-4691-be43-8a7d0cfcea4a.der';
	$new_name = '/home/andrey/www/htdocs/expert72/client_files/Заявление№1532/Исходящие/3a453276-a31e-4691-be43-8a7d0cfcea4a.sig';
	$merged_sig = '/home/andrey/www/htdocs/expert72/client_files/Заявление№1532/Исходящие/3a453276-a31e-4691-be43-8a7d0cfcea4a.mrg';
	//$pki_man->mergeSigs($der_file,$new_name,$merged_sig);
	
	//$res = $pki_man->getSigAttributes('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/09-01-01 Утилизация ТБО 40(48).xlsx.sig',FALSE);
	//$res = $pki_man->getSigAttributes('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/1/1.sig',FALSE);
	/*
	$res = $pki_man->getSigAttributes('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Заключение/Z -72-1-0169-18.pdf.sig',FALSE);
	var_dump($res);
	echo '</BR></BR>';
	foreach($res as $cert){
		echo '<div>New Signature</div>';
		echo 'Date='.date('d/m/Y h:i',$cert->signedDate).'</BR>';
		echo 'Algorithm='.$cert->algorithm.'</BR>';
		echo '</BR></BR>';
	}
	exit;
	*/
	//echo $pki_man->getIssuier(OUTPUT_PATH.'test.pdf.sig')['CN'];
	$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/1.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/1');
	//$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Заключение.pdf.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Заключение.pdf');
	//$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/client_files/Заявление№1532/Исходящие/170f26b7-1571-48bf-b976-903b02860f36.sig','/home/andrey/www/htdocs/expert72/client_files/Заявление№1532/Исходящие/170f26b7-1571-48bf-b976-903b02860f36');
	
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
