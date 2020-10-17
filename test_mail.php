<?php
//php /home/andrey/www/htdocs/expert72/test_mail.php katrenplus wimmdii171003 /home/andrey/www/htdocs/expert72/test_mail.ini

require("common/PHPMailer_5.2.4/class.phpmailer.php");
require("common/imap.php");

if(count($argv)<4){
	die('result:0'.PHP_EOL.'descr:Необходимы аргументы: login pwd inifile'.PHP_EOL);
}
$smtpUser = trim($argv[1]);
$smtpPwd = trim($argv[2]);
$iniFile = trim($argv[3]);

if(!file_exists($iniFile)){
	die('result:0'.PHP_EOL.'descr:ini не найден!'.PHP_EOL);
}

$attachments = [];

$iniFile_s = file_get_contents($iniFile);
$iniFile_l = explode(PHP_EOL,$iniFile_s);
foreach($iniFile_l as $l){
	$l_params = explode('=',$l);
	if(count($l_params)==2){
		$p = trim($l_params[0]);
		$v = trim($l_params[1]);
		if($p == 'smtpHost'){
			$smtpHost = $v;
		}
		else if($p == 'smtpPort'){
			$smtpPort = intval($v);
		}
		else if($p == 'toAddr'){
			$to_addr = $v;
		}
		else if($p == 'toName'){
			$to_name = $v;
		}
		else if($p == 'subject'){
			$subject = $v;
		}
		else if($p == 'body'){
			$body = $v;
		}
		else if($p == 'fromAddr'){
			$from_addr = $v;
		}
		else if($p == 'fromName'){
			$from_name = $v;
		}
		
		else if($p == 'toAddr'){
			$to_addr = $v;
		}
		else if($p == 'toName'){
			$to_name = $v;
		}
		else if($p == 'imapHost'){
			$imap_host = $v;
		}
		else if($p == 'imapPort'){
			$imap_port = $v;
		}
		else if($p == 'imapParam'){
			$imap_param = $v;
		}
		else if($p == 'imapFolder'){
			$imap_folder = $v;
		}
		else if($p == 'attachment'){
			array_push($attachments,$v);
		}
		
	}
}
/*
echo('smtpHost='.$smtpHost.PHP_EOL);
echo('smtpPort='.$smtpPort.PHP_EOL);
echo('smtpUser='.$smtpUser.PHP_EOL);
echo('to_addr='.$to_addr.PHP_EOL);
echo('to_name='.$to_name.PHP_EOL);
echo('subject='.$subject.PHP_EOL);
echo('body='.$body.PHP_EOL);
echo('from_addr='.$from_addr.PHP_EOL);
echo('from_name='.$from_name.PHP_EOL);
echo('to_addr='.$to_addr.PHP_EOL);
echo('to_name='.$to_name.PHP_EOL);
die('STOP'.PHP_EOL);
*/

$reply_addr = $from_addr;
$reply_name = $from_name;

	$mail= new PHPMailer();
	$mail->IsSMTP();
	$mail->Mailer = 'smtp';
	$mail->SMTPDebug 		= FALSE;
	$mail->CharSet			='UTF-8';				
	$mail->Host  			= $smtpHost;
	$mail->Port			= $smtpPort;
	$mail->SMTPAuth			= TRUE;
	$mail->AuthType			= 'LOGIN';
	$mail->Username			= $smtpUser;
	$mail->Password			= $smtpPwd;
	$mail->SMTPSecure		= 'ssl';
	//header
	//$mail->SetEncodedEmailHeader("To",$row['to_addr'],'andrey');//$row['to_name']
	//$mail->From				= $row['from_addr'];
	$mail->setFrom($from_addr,$from_name);
	$to_addr_ar = explode(';',$to_addr);
	$to_name_ar = explode(';',$to_name);
	$i = 0;
	foreach($to_addr_ar as $to_addr){
		$mail->addAddress($to_addr,$to_name_ar[$i]);
		$i++;
	}

	$mail->AddReplyTo($reply_addr,$reply_name);
	$mail->Subject			= $subject;
	$mail->Body			= $body;

	foreach($attachments as $att){
		if(!file_exists($att)){
			die("result:0".PHP_EOL.'descr:Файл не найден '.$att.PHP_EOL);
		}
		$mail->AddAttachment($att);
	}

	//$error_str = ($mail->Send())? 'NULL':"'".$mail->ErrorInfo."'";
	
	if($mail->Send()){
		$imap = new IMAP();
		$imap->open($from_addr, $mail->Password,$imap_folder,$imap_param,$imap_host,$imap_port);
		$imap->append($imap_folder,$mail->getSentMIMEMessage());
		$imap->close();
		
		echo 'result:1'.PHP_EOL;
	}
	else{
		die("result:0".PHP_EOL.'descr: '.$mail->ErrorInfo.$att.PHP_EOL);	
	}
?>
