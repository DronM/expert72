<?php
require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInterval.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtArray.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtXML.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */



require_once('common/downloader.php');
require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');

class DocFlow_Controller extends ControllerSQL{

	const ER_STORAGE_FILE_NOT_FOUND = 'Файл не найден!@1001';
	const ER_INVALID_DOC_FLOW_TYPE = 'Invalid document type!@1002';
	const ER_EMPLOYEE_NOT_DEFINED = 'К пользователю не привязан сотрудник!@1003';
	const ER_ALLOWED_TO_ADMIN = 'Действие разрешено только администратору!@1004';
	const ER_NOT_FOUND = 'Document not found!';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			
		$pm = new PublicMethod('remove_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	public static function getDefAppDir($type){
		$res = NULL;
		if ($type=='out'){
			$res = 'Исходящие';
		}
		else if ($type=='in'){
			$res = 'Входящие';
		}
		else if ($type=='inside'){
			$res = 'Внутренние';
		}
		else{
			$res = 'UndefinedType';
		}
		return $res;
	}

	public function delete_attachments($pm,$type){
		$old_state = $this->get_state($this->getExtDbVal($pm,'id'),$type);
		if ($old_state!='dirt_copy' && $_SESSION['role_id']!='admin'){
			throw new Exception(self:: ER_ALLOWED_TO_ADMIN);
		}
	
		try{
			$this->getDbLinkMaster()->query("BEGIN");
		
			//**************
			if ($type=='inside'){
				$q_id = $this->getDbLink()->query(sprintf(
					"SELECT
						at.file_id,
						at.file_signed,
						at.file_path,
						ct.application_id AS to_application_id
					FROM doc_flow_attachments AS at
					LEFT JOIN doc_flow_inside AS ins ON at.doc_type='doc_flow_inside' AND at.doc_id=ins.id
					LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
					WHERE doc_id=%d AND doc_type='doc_flow_inside'::data_types",
					$this->getExtDbVal($pm,'id')
				));
			}
			else if ($type=='out'){
				$q_id = $this->getDbLink()->query(sprintf(
					"SELECT
						at.file_id,
						at.file_signed,
						at.file_path,
						out.to_application_id
					FROM doc_flow_attachments AS at
					LEFT JOIN doc_flow_out AS out ON at.doc_type='doc_flow_out' AND at.doc_id=out.id
					WHERE doc_id=%d AND doc_type='doc_flow_out'::data_types",
					$this->getExtDbVal($pm,'id')
				));
			}		
			else{
				$q_id = $this->getDbLink()->query(sprintf(
					"SELECT
						at.file_id,
						at.file_signed,
						at.file_path,
						NULL AS to_application_id
					FROM doc_flow_attachments AS at
					WHERE doc_id=%d AND doc_type='doc_flow_in'::data_types",
					$this->getExtDbVal($pm,'id')
				));
			}		
			while($ar = $this->getDbLink()->fetch_array()){
				$fl = NULL;
				if ($ar['to_application_id']){
					//Файл из папки заявления
					$fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'];
				}
				else{
					//Общий документооборот
					$fl = DOC_FLOW_FILE_STORAGE_DIR;
				}
				$fl.= DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id');
			
				if (file_exists($fl)){
					unlink($fl);
				}
				if ($ar['file_signed'] && file_exists($fl.='.sig')){
					unlink($fl);			
				}
			}			

			$this->getDbLinkMaster()->query(sprintf(
				"DELETE FROM doc_flow_attachments WHERE doc_id=%d AND doc_type='doc_flow_%s'::data_types",
				$this->getExtDbVal($pm,'id'),
				$type
			));			
			//**************
			
			parent::delete($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}		
	}
	
	public function remove_afile($pm,$type){
		
		$state = $this->get_state($id,$type);
		if ($state=='registered' && $_SESSION['role_id']!='admin'){
			throw new Exception(self::ER_ALLOWED_TO_ADMIN);
		}
		
		$this->getDbLinkMaster()->query('BEGIN');
		try{
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
				"DELETE FROM doc_flow_attachments
				WHERE doc_id=%d AND file_id=%s
				RETURNING file_id,file_signed,doc_type,file_path,file_name",
				$this->getExtDbVal($pm,'doc_id'),
				$this->getExtDbVal($pm,'file_id')
			));
			if (!count($ar)){
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			}
			
			$fl = NULL;
			if (
			($type=='out' && $ar['doc_type']=='doc_flow_out')
			||($type=='inside' && $ar['doc_type']=='doc_flow_inside')
			){
				$q = '';
				if ($type=='out'){
					$q = sprintf(
						"SELECT to_application_id
						FROM doc_flow_out
						WHERE id=%d",
						$this->getExtDbVal($pm,'doc_id')
					);
				}
				else{
					$q = sprintf(
						"SELECT ct.application_id AS to_application_id
						FROM doc_flow_inside AS ins
						LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
						WHERE ins.id=%d",
						$this->getExtDbVal($pm,'doc_id')
					);
				}
				$app_ar = $this->getDbLink()->query_first($q);
				if (count($app_ar) && $app_ar['to_application_id']){
					$fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$app_ar['to_application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'].DIRECTORY_SEPARATOR.$ar['file_id'];
				}
			}
			
			if (!$fl){
				$fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$ar['file_id'];
			}
			
			
			if (file_exists($fl)){
				unlink($fl);
			}
			if ($ar['file_signed'] && file_exists($fl.='.sig')){
				unlink($fl);			
			}
			
			$this->getDbLinkMaster()->query("COMMIT");
			
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}	
	}
		
	
	public function get_state($id,$type){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT state
			FROM doc_flow_%s_processes
			WHERE doc_flow_%s_id = %d
			ORDER BY date_time DESC
			LIMIT 1",
		$type,$type,
		$id
		));
		return $ar['state'];
	}

	private function get_afile($pm,$sigFile){
		try{
			$er_st = 500;
			
			$posf = $sigFile? '.sig':'';
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					at.file_name,
					at.file_path,
					CASE
						WHEN at.doc_type='doc_flow_out' THEN out.to_application_id
						WHEN at.doc_type='doc_flow_inside' THEN ct.application_id
						ELSE NULL
					END AS to_application_id
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out AS out ON at.doc_type='doc_flow_out' AND at.doc_id=out.id
				LEFT JOIN doc_flow_inside AS ins ON at.doc_type='doc_flow_inside' AND at.doc_id=ins.id
				LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
				WHERE at.file_id=%s AND at.doc_id=%d",
				$this->getExtDbVal($pm,'file_id'),
				$this->getExtDbVal($pm,'doc_id')
			));
		
			if (!count($ar)){
				$er_st = 404;
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			}
		
			$fl = NULL;
			if ($ar['to_application_id']){
				//Файл из папки заявления
				$fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
					Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
					$ar['file_path'];
			}
			else{
				//Общий документооборот
				$fl = DOC_FLOW_FILE_STORAGE_DIR;
			}
			$fl.= DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id').$posf;
		
			if (!file_exists($fl)){
				$er_st = 404;
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			}
	
			ob_clean();
			downloadFile($fl, 'application/octet-stream','attachment;',$ar['file_name'].$posf);
			return TRUE;	
		}
		catch(Exception $e){
			$this->setHeaderStatus($er_st);
			throw $e;
		}	
	}
	
	public function get_file($pm){
		return $this->get_afile($pm,FALSE);
	}

	public function get_file_sig($pm){
		return $this->get_afile($pm,TRUE);
	}
	
	protected function get_next_num_on_type($docFlowType,$typeId){
		$this->addNewModel(
			sprintf("SELECT doc_flow_%s_next_num(%d) AS num",$docFlowType,$typeId),
			'NewNum_Model'
		);
	}
	

}
?>