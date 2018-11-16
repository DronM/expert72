<?php
require_once(dirname(__FILE__)."/../Config.php");
require_once(FRAME_WORK_PATH.'db/db_pgsql.php');
require_once("EmailSender.php");

class ExpertEmailSender extends EmailSender{

	public static function regMail(
			$dbLink,
			$funcText,
			$attArray=NULL,
			$smsType=NULL
		){
		$ar = $dbLink->query_first(sprintf(
		//throw new Exception(sprintf(
		"SELECT * FROM %s AS (
			body text,
			email text,
			mes_subject text,
			firm text,
			client text)",
		$funcText
		));
		
		$mail_id = NULL;
		if (is_array($ar) && count($ar)){
			$mail_id = EmailSender::addEMail(
				$dbLink,
				EMAIL_FROM_ADDR,EMAIL_FROM_NAME,
				$ar['email'],$ar['client'],
				EMAIL_FROM_ADDR,EMAIL_FROM_NAME,
				EMAIL_FROM_ADDR,
				$ar['mes_subject'],
				$ar['body']	,
				$smsType			
			);
			if (is_array($attArray)){
				foreach ($attArray as $f){
					self::addAttachment($dbLink,$mail_id,$f);
				}
			}
		}
		return $mail_id;
	}
	public static function sendAllMail($delFiles=TRUE,&$db,
			$smtpHost=NULL,$smtpPort=NULL,$smtpUser=NULL,$smtpPwd=NULL){
		
		$smtpHost = is_null($smtpHost)? SMTP_HOST:$smtpHost;
		$smtpPort = is_null($smtpPort)? SMTP_PORT:$smtpPort;
		$smtpUser = is_null($smtpUser)? SMTP_USER:$smtpUser;
		$smtpPwd = is_null($smtpPwd)? SMTP_PWD:$smtpPwd;
		
		parent::sendAllMail($delFiles,$db,
				$smtpHost,$smtpPort,$smtpUser,$smtpPwd
		);
	}
	
}
?>
