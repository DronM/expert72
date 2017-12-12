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



require_once('functions/ExpertEmailSender.php');
require_once('common/downloader.php');

class OutMail_Controller extends ControllerSQL{
	
	const STORAGE_FILE_NOT_FOUND = 'Файл не найден!';
	const MAIL_SENT = 'Письмо отправлено!';

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtDateTimeTZ('date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('to_user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('to_addr_name'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('subject'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('reg_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('content'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('sent'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('OutMail_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('to_user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('to_addr_name'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('subject'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('reg_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('content'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('sent'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('OutMail_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('OutMail_Model');

			
		/* get_list */
		$pm = new PublicMethod('get_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

		$this->addPublicMethod($pm);
		
		$this->setListModelId('OutMailList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtInt('browse_mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('OutMailDialog_Model');		

			
		$pm = new PublicMethod('remove_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('complete_addr_name');
		
				
	$opts=array();
	
		$opts['length']=250;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('to_addr_name',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	public function reg_for_sending($outMailId){
		$attach = array();
		$this->getDbLink()->query(sprintf("SELECT file_name FROM out_mail_attachments WHERE out_mail_id=%d",$outMailId));
		while($ar = $this->getDbLink()->fetch_array()){
			array_push($attach,$ar['file_name']);
		}
		ExpertEmailSender::addEMail(
			$this->getDbLinkMaster(),
			sprintf("email_reg_out_mail(%d)",
				$outMailId
			),
			$attach,
			'out_mail'
		);
	
	}

	public function insert($pm){
		$link = $this->getDbLinkMaster();
		try{
			$link->query('BEGIN');
			$ar = parent::insert($pm);
			if ($this->getExtVal($pm,'sent')){
				$this->reg_for_sending($ar['id']);
			}
			
			$link->query('COMMIT');
		}
		catch(Exception $e){
			$link->query('ROLLBACK');
			throw $e;
		}
		return $ar;
	}
	public function update($pm){
		$link = $this->getDbLinkMaster();
		try{
			$link->query('BEGIN');
			parent::update($pm);
			if ($this->getExtVal($pm,'sent')){
				$this->reg_for_sending($this->getExtVal($pm,'old_id'));
			}
			
			$link->query('COMMIT');
		}
		catch(Exception $e){
			$link->query('ROLLBACK');
			throw $e;
		}
	}
	
	public function delete($pm){
		$ar = $this->getDbLink()->query_first(sprintf("SELECT sent FROM out_mail WHERE id=%d",$this->getExtDbVal($pm,'id')));
		if (!is_array($ar) || !count($ar)){
			throw new Exception('Не найден документ!');
		}
		
		if ($ar['sent']=='t'){
			throw new Exception('Невозможно удалять отправленное письмо!');
		}
		
		parent::delete($pm);
	
	}
	
	public function get_file($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				file_name
			FROM out_mail_attachments
			WHERE file_id=%s",
			$this->getExtDbVal($pm,'id')
		));
		if (!file_exists($fl = MAIL_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$this->getExtVal($pm,'id'))){
			throw new Exception(self::STORAGE_FILE_NOT_FOUND);
		}
	
		$mime = getMimeTypeOnExt($ar['file_name']);
		ob_clean();
		downloadFile($fl, $mime,'attachment;',$ar['file_name']);
		return TRUE;
	
	}
	
	public function remove_file($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				out_mail.sent AS sent
			FROM out_mail_attachments AS at
			LEFT JOIN out_mail ON out_mail.id=at.out_mail_id
			WHERE at.file_id=%s",
			$this->getExtDbVal($pm,'id')
		));
		if ($ar['sent']=='t'){
			throw new Exception(self::MAIL_SENT);
		}
		if (!file_exists($fl = MAIL_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$this->getExtVal($pm,'id'))){
			throw new Exception(self::STORAGE_FILE_NOT_FOUND);
		}
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			//1) Mark in DB
			$this->getDbLinkMaster()->query_first(sprintf(
				"DELETE FROM out_mail_attachments
				WHERE file_id=%s",
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
	
	public function complete_addr_name($pm){
		$this->addNewModel(sprintf(
			"SELECT DISTINCT to_addr_name
			FROM out_mail
			WHERE lower(to_addr_name) LIKE '%%'||lower(%s)||'%%'
			LIMIT 10"
			,$this->getExtDbVal($pm,'to_addr_name')
		),
		'Addr_Model');
	}
	

}
?>