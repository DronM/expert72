<?php
require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtXML.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */


class Mail_Controller extends ControllerSQL{

	const ER_STORAGE_FILE_NOT_FOUND = 'Файл не найден!@1001';
	const ER_INVALID_MAIL_TYPE = 'Invalid mail type!@1002';

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			
		$pm = new PublicMethod('complete_addr_name');
		
				
	$opts=array();
	
		$opts['length']=250;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('addr_name',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	private static function get_mail_type($strType){
		if (strtolower($strType)=='out'){
			return 'out';
		}
		else if (strtolower($strType)=='in'){
			return 'in';
		}
		throw new Exception(ER_INVALID_MAIL_TYPE);
	}
	
	private function delete_attachments($pm){
		$mail_type = self:: get_mail_type($this->getExtVal(pm,'mail_type'));
		
		//Remove files
		$q_id = $this->getDbLinkMaster()->query(sprintf(
			"SELECT file_id  FROM %s_mail_attachments WHERE %s_mail_id=%d",
			$mail_type,$mail_type,
			$this->getExtDbVal($pm,'id')
		));
		
		while($ar = $this->getDbLinkMaster()->fetch_array()){
			if (file_exists($fl=MAIL_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$ar['file_id'])){
				unlink($fl);
			}
		}			

		$this->getDbLinkMaster()->query(sprintf(
			"DELETE FROM %s_mail_attachments WHERE %s_mail_id=%d",
			$mail_type,$mail_type,
			$this->getExtDbVal($pm,'id')
		));
	}
	
	public function remove_file($pm){
		$mail_type = self:: get_mail_type($this->getExtVal(pm,'mail_type'));
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				%s_mail.sent AS sent
			FROM %s_mail_attachments AS at
			LEFT JOIN %s_mail ON %s_mail.id=at.%s_mail_id
			WHERE at.file_id=%s",
			$mail_type,$mail_type,$mail_type,$mail_type,$mail_type,
			$this->getExtDbVal($pm,'id')
		));
		if ($ar['sent']=='t'){
			throw new Exception(self::MAIL_SENT);
		}
		if (!file_exists($fl = MAIL_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$this->getExtVal($pm,'id'))){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			//1) Mark in DB
			$this->getDbLinkMaster()->query_first(sprintf(
				"DELETE FROM %s_mail_attachments
				WHERE file_id=%s",
			$mail_type,
			$this->getExtDbVal($pm,'id')		
			));
		
			//2) Remove file
			unlink($fl);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}	
	
	}
		
	
	public function get_file($pm){
	
		$mail_type = self:: get_mail_type($this->getExtVal(pm,'mail_type'));
	
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				file_name
			FROM %s_mail_attachments
			WHERE file_id=%s",
			$mail_type,
			$this->getExtDbVal($pm,'id')
		));
		if (!file_exists($fl = MAIL_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$this->getExtVal($pm,'id'))){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
	
		$mime = getMimeTypeOnExt($ar['file_name']);
		ob_clean();
		downloadFile($fl, $mime,'attachment;',$ar['file_name']);
		return TRUE;	
	}
	
	public function complete_addr_name($pm){
		$this->addNewModel(sprintf(
			"SELECT * FROM mail_addr_complete(%s,10)"
			,$this->getExtDbVal($pm,'addr_name')
		),
		'Addr_Model');
	}
	


}
?>