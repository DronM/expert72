<?php
/*
	$s = '1.2.643.100.1 = 1097746293886 1.2.643.3.131.1.1 = 007729633131 countryName = RU stateOrProvinceName = 77 \U0433.\U041C\U043E\U0441\U043A\U0432\U0430 localityName = \U041C\U043E\U0441\U043A\U0432\U0430 streetAddress = \U041B\U0435\U043D\U0438\U043D\U0441\U043A\U0438\U0435 \U0433\U043E\U0440\U044B, \U0434.1, \U0441\U0442\U0440.77 organizationalUnitName = \U0423\U0434\U043E\U0441\U0442\U043E\U0432\U0435\U0440\U044F\U044E\U0449\U0438\U0439 \U0446\U0435\U043D\U0442\U0440 organizationName = \U041E\U0431\U0449\U0435\U0441\U0442\U0432\U043E \U0441 \U043E\U0433\U0440\U0430\U043D\U0438\U0447\U0435\U043D\U043D\U043E\U0439 \U043E\U0442\U0432\U0435\U0442\U0441\U0442\U0432\U0435\U043D\U043D\U043E\U0441\U0442\U044C\U044E "\U042D\U043B\U0435\U043A\U0442\U0440\U043E\U043D\U043D\U044B\U0439 \U044D\U043A\U0441\U043F\U0440\U0435\U0441\U0441" commonName = \U041E\U041E\U041E "\U042D\U043B\U0435\U043A\U0442\U0440\U043E\U043D\U043D\U044B\U0439 \U044D\U043A\U0441\U043F\U0440\U0435\U0441\U0441" ';
	echo ucode2str($s);
	echo '</br>';
	echo 'Это русский';
	exit;
*/	
	require_once('functions/PKIManager.php');
	$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,'note');
	//echo $pki_man->getIssuier(OUTPUT_PATH.'test.pdf.sig')['CN'];
	//$$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/ЛСР №02-01-01 демонтажные работы.xlsx.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Ошибки/ЛСР №02-01-01 демонтажные работы.xlsx');
	//$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Заключение.pdf.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/Заключение.pdf');
	$verif_res = $pki_man->verifySig('/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/ИсхДанСмета.pdf.sig','/home/andrey/www/htdocs/expert72/build/ФайлыЭЦП/ИсхДанСмета.pdf');
	
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
