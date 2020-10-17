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
require_once(USER_CONTROLLERS_PATH.'User_Controller.php');

//ЭТО НУЖНО ДЛЯ ПОДПИСАНИЯ ВНУТРЕННИМ СЕРТИФИКАТОМ
//ОТКЛЮЧЕНО, ТАК КАК НЕ ПРОВЕРЕНО
//require_once(ABSOLUTE_PATH.'functions/file_upload_functions.php');

require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

class DocFlow_Controller extends ControllerSQL{

	const CLIENT_OUT_FOLDER = 'Исходящие заявителя';

	const ER_STORAGE_FILE_NOT_FOUND = 'Файл не найден!@1001';
	const ER_INVALID_DOC_FLOW_TYPE = 'Invalid document type!@1002';
	const ER_EMPLOYEE_NOT_DEFINED = 'К пользователю не привязан сотрудник!@1003';
	const ER_ALLOWED_TO_ADMIN = 'Действие разрешено только администратору!@1004';
	const ER_NOT_FOUND = 'Document not found!';
	const ER_SIG_NOT_FOUND = 'ЭЦП не найдена!';
	const ER_SIG_OTHER_OWNER = 'Владелец ЭЦП %s. Вам запрещено удалять чужую подпись';
	const ER_SIGNATURE_NOT_FOUND = 'У сотрудника нет облачной подписи!@1005';

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
			$res = 'Исходящие заявителя';
		}
		else if ($type=='inside'){
			$res = 'Внутренние';
		}
		else{
			$res = 'UndefinedType';
		}
		return $res;
	}

	/**
	 * $ar app_id,file_id,file_path,
	 */
	private function remove_file_with_all_sigs(&$ar){
		$rel_dir = ($ar['app_id'])? (Application_Controller::APP_DIR_PREF.$ar['app_id'].DIRECTORY_SEPARATOR.$ar['file_path']) : '';
		$rel_file = ( (strlen($rel_dir))? ($rel_dir.DIRECTORY_SEPARATOR) : '') .$ar['file_id'];
	
		$this->remove_file_from_all_servers($ar['app_id'],$rel_file);
		
		if ($ar['file_signed']){
			$this->remove_file_from_all_servers($ar['app_id'],$rel_file.'.sig');
			//all temp sig.s(1)
			$max_index = 0;
			Application_Controller::getMaxIndexSigFile($rel_dir,$ar['file_id'],$max_index);
			for($i=1;$i<=$max_index; $i++){
				$this->remove_file_from_all_servers($ar['app_id'],$rel_file.'.sig.s'.$i);
			}
		}	
	}

	/**
	 * Called from DocFlowOut_Controller->delete,DocFlowInside_Controller->delete
	 */
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
						ct.application_id AS app_id
					FROM doc_flow_attachments AS at
					LEFT JOIN doc_flow_inside AS ins ON at.doc_type='doc_flow_inside' AND at.doc_id=ins.id
					LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
					WHERE doc_id=%d AND doc_type='doc_flow_inside'::data_types",
					$this->getExtDbVal($pm,'id')
				));
			}
			else if ($type=='out'){
				//проверка на отправленное письмо клиента с подписанным документом
				$q_id = $this->getDbLink()->query(sprintf(
					"SELECT
						at.file_id,
						at.file_signed,
						at.file_path,
						out.to_application_id AS app_id,
						coalesce(app_f.file_signed_by_client,FALSE) AS file_signed_by_client,
						coalesce(cl_doc.sent,FALSE) AS client_doc_sent
					FROM doc_flow_attachments AS at
					LEFT JOIN doc_flow_out AS out ON at.doc_type='doc_flow_out' AND at.doc_id=out.id
					LEFT JOIN application_document_files AS app_f ON app_f.file_id=at.file_id
					LEFT JOIN doc_flow_out_client_document_files AS cl_f ON cl_f.file_id=at.file_id
					LEFT JOIN doc_flow_out_client AS cl_doc ON cl_doc.id=cl_f.doc_flow_out_client_id
					WHERE doc_id=%d AND doc_type='doc_flow_out'::data_types",
					$this->getExtDbVal($pm,'id')
				));
				while($ar = $this->getDbLink()->fetch_array()){
					if ($ar['client_doc_sent']=='t'){
						throw new Exception('Один из файлов подписан и отправлен клиентом!');
					}
				}
				$this->getDbLink()->data_seek(0,$q_id);
			}		
			else{
				$q_id = $this->getDbLink()->query(sprintf(
					"SELECT
						at.file_id,
						at.file_signed,
						at.file_path,
						NULL AS app_id
					FROM doc_flow_attachments AS at
					WHERE doc_id=%d AND doc_type='doc_flow_in'::data_types",
					$this->getExtDbVal($pm,'id')
				));
			}		
			while($ar = $this->getDbLink()->fetch_array()){
				$this->remove_file_with_all_sigs($ar);
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
	
	protected function remove_file_from_all_servers($appId,$relFile){
		if ($appId){
			if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relFile))unlink($fl);
			if (defined('FILE_STORAGE_DIR_MAIN') && file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relFile))unlink($fl);
		}
		else{
			if (file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relFile))unlink($fl);
			if (defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN') && file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relFile))unlink($fl);
		}	
	}
	
	/**
	 * Удаление ЭЦП
	 * Разрешено:
	 *	- админу любую ЭЦП
	 *	- сотруднику только последнюю ЭЦП, если: сотрудник=владец ЭЦП или владелец ЭЦП не определен (поле employee_id пустое)
	 * @param {PublicMethod} pm Public method
	 * @param {string} type in|out|inside
	 */
	protected function remove_asig($pm,$type){
		
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
			"SELECT
				att.file_id,
				att.file_path,
				att.file_name,
				(SELECT count(*) FROM file_signatures AS sig WHERE sig.file_id=att.file_id) AS sig_cnt,
				(SELECT count(*) FROM file_verifications AS v WHERE v.file_id=att.file_id) AS ver_cnt,
				CASE
					WHEN att.doc_type='doc_flow_out' THEN out.to_application_id
					WHEN att.doc_type='doc_flow_inside' THEN ct.application_id
					ELSE NULL
				END AS app_id
				
			FROM doc_flow_attachments AS att
			LEFT JOIN doc_flow_out AS out ON att.doc_type='doc_flow_out' AND att.doc_id=out.id
			LEFT JOIN doc_flow_inside AS ins ON att.doc_type='doc_flow_inside' AND att.doc_id=ins.id
			LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
			WHERE att.doc_id=%d AND att.file_id=%s AND att.doc_type='doc_flow_%s'",
			$this->getExtDbVal($pm,'doc_id'),
			$this->getExtDbVal($pm,'file_id'),
			$type
		));
		if (!count($ar) || $ar['ver_cnt']==0){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		
		$rel_dir = ($ar['app_id'])? (Application_Controller::APP_DIR_PREF.$ar['app_id'].DIRECTORY_SEPARATOR.$ar['file_path']) : '';
		$data_rel_file = ((strlen($rel_dir))? ($rel_dir.DIRECTORY_SEPARATOR):'') .$ar['file_id'];
		$sig_rel_file = $data_rel_file.'.sig';
		
		//Data file
		if(
		($ar['app_id']
		&& !file_exists($file_doc=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$data_rel_file)
		&&
			(!defined('FILE_STORAGE_DIR_MAIN')
			||
			!file_exists($file_doc=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$data_rel_file)
			)
		)
		|| (
			!$ar['app_id']
			&& !file_exists($file_doc = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$data_rel_file)
			&&
			(!defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')
				||
				!file_exists($file_doc=DOC_FLOW_FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$data_rel_file)
			)			
		)
		){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}				

		if ($_SESSION['role_id']!='admin'){
			$state = $this->get_state($id,$type);
			if ($state=='registered' && $_SESSION['role_id']!='admin'){
				throw new Exception(self::ER_ALLOWED_TO_ADMIN);
			}
		
			//Определим владельца последней подписи
			$sig_owner_ar = $this->getDbLinkMaster()->query_first(sprintf(
				"WITH
				doc_files AS
					(SELECT
						json_array_elements(files) AS files
					FROM doc_flow_%s_dialog
					WHERE id=%d
					),
				file_sigs AS 
					(SELECT
						json_array_elements(att2.files->'signatures') AS signature
					FROM (
						SELECT
							json_array_elements(doc_files.files->'files') AS files
						FROM doc_files
					) AS att2	
					WHERE att2.files->>'file_id'=%s
					)
				SELECT
					file_sigs.signature->'owner'->>'Фамилия'|| ' '||coalesce(file_sigs.signature->'owner'->>'Имя','') AS owner_name,
					(file_sigs.signature->>'employee_id')::int AS owner_employee_id
	
				FROM file_sigs
				ORDER BY (file_sigs.signature->>'verif_date_time')::timestampTZ DESC
				LIMIT 1",
			$type,
			$this->getExtDbVal($pm,'doc_id'),
			$this->getExtDbVal($pm,'file_id')
			));
		
			if(!count($sig_owner_ar)){
				throw new Exception(self::ER_SIG_NOT_FOUND);
			}
		
			if (
			isset($sig_owner_ar['owner_employee_id'])
			&& intval($sig_owner_ar['owner_employee_id'])
			&& intval(json_decode($_SESSION['employees_ref'])->keys->id)!=intval($sig_owner_ar['owner_employee_id'])
			){
				throw new Exception(sprintf(self::ER_SIG_OTHER_OWNER,$sig_owner_ar['owner_name']));
			}
		}
		
		$all_sigs_deleted = FALSE;
		
		//можно удалить последнюю ЭЦП
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			if ($ar['sig_cnt']==1){
				//current sig from all servers
				$this->remove_file_from_all_servers($ar['app_id'],$sig_rel_file);
				
				$all_sigs_deleted = TRUE;
			}
			else{						
				//find previous sig
				$max_ind = NULL;
				$prev_sig = Application_Controller::getMaxIndexSigFile($rel_dir,$ar['file_id'],$max_ind);
				if (!$ar['app_id']){
					$new_cur_sig = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$sig_rel_file;
				}
				else{
					$new_cur_sig = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$sig_rel_file;
				}

				//current sig from all servers
				$this->remove_file_from_all_servers($ar['app_id'],$sig_rel_file);
				
				if ($max_ind && file_exists($prev_sig)){
					//found sig with index sig.s(1)
					//sig.s(1) -> .sig
					exec(sprintf('mv -f "%s" "%s"',$prev_sig,$new_cur_sig));
					
					$pki_man = pki_create_manager();
					$db_link = $this->getDbLinkMaster();
					pki_log_sig_check($new_cur_sig, $file_doc, $this->getExtDbVal($pm,'file_id'), $pki_man, $db_link,TRUE);
				}
				else if (!$max_ind){
					//no index file					
					$all_sigs_deleted = TRUE;
				}
				
			}

			if ($all_sigs_deleted){
				$this->getDbLinkMaster()->query(sprintf(
					"UPDATE doc_flow_attachments
					SET
						file_signed=FALSE
					WHERE file_id=%s",
					$this->getExtDbVal($pm,'file_id')
				));
				
				$this->getDbLinkMaster()->query(sprintf(
					"DELETE FROM file_verifications
					WHERE file_id=%s",
				$this->getExtDbVal($pm,'file_id'))
				);
			}
			
			$this->getDbLinkMaster()->query("COMMIT");
			
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
		if ($all_sigs_deleted){
			$this->addModel(new ModelVars(
				array('name'=>'Vars',
					'id'=>'SigRemoveResult_Model',
					'values'=>array(
						new Field('all_sigs_deleted',DT_BOOL,
							array('value'=>TRUE)
						)
					)
				)
			));		
		}
	}
	
		
	protected function remove_afile($pm,$type){
		
		$state = $this->get_state($this->getExtDbVal($pm,'doc_id'),$type);
		if ($state=='registered' && $_SESSION['role_id']!='admin'){
			throw new Exception(self::ER_ALLOWED_TO_ADMIN);
		}
		
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				att.file_id,
				att.file_name,
				att.file_path,
				att.file_signed,
				CASE
					WHEN att.doc_type='doc_flow_out' THEN out.to_application_id
					WHEN att.doc_type='doc_flow_inside' THEN ct.application_id
					ELSE NULL
				END AS app_id				
			FROM doc_flow_attachments AS att
			LEFT JOIN doc_flow_out AS out ON att.doc_type='doc_flow_out' AND att.doc_id=out.id
			LEFT JOIN doc_flow_inside AS ins ON att.doc_type='doc_flow_inside' AND att.doc_id=ins.id
			LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
			WHERE att.file_id=%s AND att.doc_id=%d AND doc_type='doc_flow_%s'",
			$this->getExtDbVal($pm,'file_id'),
			$this->getExtDbVal($pm,'doc_id'),
			$type
		));
		
		if (!count($ar)){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		
		$this->getDbLinkMaster()->query('BEGIN');
		try{		
			$this->getDbLinkMaster()->query(sprintf(
				"DELETE FROM doc_flow_attachments
				WHERE doc_id=%d AND file_id=%s AND doc_type='doc_flow_%s'",
				$this->getExtDbVal($pm,'doc_id'),
				$this->getExtDbVal($pm,'file_id'),
				$type
			));
			
			$this->remove_file_with_all_sigs($ar);
			
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
			if (
			(
				$ar['to_application_id']
				&& (!file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'].
						DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id').$posf)
						&&(
							!defined('FILE_STORAGE_DIR_MAIN')
							||(
								!file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
								$ar['file_path'].
								DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id').$posf)
							)
						)
					)
			)
			|| (
				!$ar['to_application_id']
				&& (!file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id').$posf)
					&&(
						!defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')
						||(
							!file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id').$posf)
						)
					)
				)
			)
			){
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
	
	protected function get_next_num_on_type($docFlowType,$typeId,$extContractDbVal){
		$model = new ModelSQL($this->getDbLinkMaster(),array('id'=>'NewNum_Model'));
		$model->query(
			sprintf(
				"SELECT doc_flow_%s_next_num(%d,%s) AS num"
				,$docFlowType
				,$typeId
				,$extContractDbVal
			)
		,TRUE);
		$this->addModel($model);	
	}
	
	public static function signFile(&$controller,&$pm,&$uploadedFile,$docType){
		prolongate_session();
		
		//Определим файл для подписания		
		$upload_data = array(
			'file_path' => $controller->getExtVal($pm,'file_path'),
			'doc_id' => $controller->getExtDbVal($pm,'doc_id'),
			'file_id_par' => $controller->getExtVal($pm,'file_id')			
		);
		
		$db_link = $controller->getDbLinkMaster();
							
		$upload_data['file_signed'] = 'true';
		
		if($docType=='application'){
			$sig_add = $controller->getExtVal($pm,'sig_add');
			$upload_data['sig_add'] = (isset($sig_add)&&$sig_add=='true');		
			$upload_data['original_file_id'] = $controller->getExtVal($pm,'original_file_id');
			$upload_data['doc_flow_out_client_id'] = $controller->getExtVal($pm,'doc_flow_out_client_id');
			$upload_data['db_app_id'] = $controller->getExtDbVal($pm,'application_id');
			//$upload_data['file_signed'] = $controller->getExtVal($pm,'file_signed');
			$upload_data['doc_type'] = $controller->getExtVal($pm,'doc_type');			
			
			$upload_data['file_path_par'] = $upload_data['file_path'];						
			if ($upload_data['sig_add']){
				check_app_folder($db_link,$upload_data['file_path']);
				$upload_data['file_path'] = $upload_data['file_path_par'];
			}
			else if ($upload_data['doc_type']=='documents'){
				//исх.письмо
				$upload_data['file_path'] = CLIENT_OUT_FOLDER;
				$upload_data['file_path_par'] = CLIENT_OUT_FOLDER;
			}
			else{
				//раздел документации
				//Нет никакой проверки?!
				$upload_data['file_path'] = intval($upload_data['doc_id']);
			}
			
			$upload_data['rel_dir'] = Application_Controller::APP_DIR_PREF.$upload_data['db_app_id'].DIRECTORY_SEPARATOR.
				(($upload_data['doc_type']=='documents')? '':Application_Controller::dirNameOnDocType($upload_data['doc_type']).DIRECTORY_SEPARATOR).
				$upload_data['file_path'];			
				
			$upload_data['upload_path'] = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$upload_data['rel_dir'].DIRECTORY_SEPARATOR;
		}
		else{
			$upload_data['sig_add'] = 'true';
			$upload_data['doc_type'] = $docType;
			$upload_data['db_id'] = $controller->getExtDbVal($pm,'doc_id');
		}		
		
		$file_id = $controller->getExtVal($pm,'file_id');
		
		if (isset($uploadedFile)&&count($uploadedFile['tmp_name'])&&is_uploaded_file($uploadedFile['tmp_name'][0])){
			$upload_data['resumableFilename'] = $uploadedFile['name'][0];//md5($uploadedFile['tmp_name'][0]).'.'.pathinfo($uploadedFile['name'][0], PATHINFO_EXTENSION);
			$file_uploaded = $upload_data['upload_path'].$upload_data['resumableFilename'];
			$file_for_sign = $upload_data['upload_path'].$file_id;
		
			/** Загрузка файла разными функциями в зависимости от типа документа 
			 *
			 */
			mkdir_or_error(dirname($file_uploaded));
			if(!move_uploaded_file($uploadedFile['tmp_name'][0],$file_uploaded)){
				throw_common_error('DocFlow_Controller->signFile: move_uploaded_file error');
			}
			 
			if($docType=='application'){
				process_application_file($upload_data,$db_link);
			}
			else{
				process_document_file($upload_data,$db_link);
			}
		}
		else{
			//подписание уже загруженного файла
			$ar = $db_link->query_first(sprintf(
				"SELECT
					at.file_name,
					at.file_signed,
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
				WHERE at.file_id=%s AND at.doc_id=%d AND at.doc_type='%s'",
				$controller->getExtDbVal($pm,'file_id'),
				$controller->getExtDbVal($pm,'doc_id'),
				($docType=='out'||$docType=='inside')? 'doc_flow_'.$docType:'applications'
			));
			if(!is_array($ar) || !count($ar)){
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			}
						
			if (
			(
				$ar['to_application_id']
				&& (!file_exists($file_for_sign = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'].
						DIRECTORY_SEPARATOR.$file_id)
						&&(
							!defined('FILE_STORAGE_DIR_MAIN')
							||(
								!file_exists($file_for_sign = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
								$ar['file_path'].
								DIRECTORY_SEPARATOR.$file_id)							
							)
						)
					)
			)
			|| (
				!$ar['to_application_id']
				&& (!file_exists($file_for_sign = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$file_id)
					&&(
						!defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')
						||(
							!file_exists($file_for_sign = DOC_FLOW_FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$file_id)
						)
					)
				)
			)
			|| is_dir($file_for_sign)
			){
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			}
			
			if (isset($upload_data['file_path'])){
				check_app_folder($db_link,$upload_data['file_path']);
			}
			else{
				$upload_data['file_path'] = self::getDefAppDir($docType);
			}
			
			if(isset($ar['to_application_id'])){
				$upload_data['rel_dir'] = Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.$upload_data['file_path'];
				
				if (defined('FILE_STORAGE_DIR_MAIN')){
					$upload_data['upload_folder_main'] = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$upload_data['rel_dir'];
				}

				//удалить zip
				Application_Controller::removeAllZipFile($ar['to_application_id']);
			}
			else{
				if (defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')){
					$upload_data['upload_folder_main'] = DOC_FLOW_FILE_STORAGE_DIR_MAIN;
				}
				$upload_data['rel_dir'] = '';				
			}
			$upload_data['upload_path'] = dirname($file_for_sign).DIRECTORY_SEPARATOR;
						
		}
		
		//Подпись файла $file_for_sign
		$ar = $db_link->query_first(sprintf(
			"SELECT
				private_pem,
				cert_pem
			FROM users
			WHERE id=%d",
			$_SESSION['user_id']
		));
		if(!is_array($ar) || !count($ar) || !isset($ar['private_pem'])){
			throw new Exception(self::ER_SIGNATURE_NOT_FOUND);
		}
		
		$upload_data['signature'] = 'true';
		$upload_data['resumableFilename'] = md5(uniqid());
		
		try{
			$pki_m = pki_create_manager();
			$private_pem = $pki_m->tmpPath.md5(uniqid());
			$cert_pem = $pki_m->tmpPath.md5(uniqid());
			file_put_contents($private_pem,User_Controller::decrypt($ar['private_pem'], file_get_contents(PKI_PATH.'pki.1')));
			file_put_contents($cert_pem,User_Controller::decrypt($ar['cert_pem'], file_get_contents(PKI_PATH.'pki.1')));
			$pki_m->signFile($private_pem,$cert_pem,$file_for_sign,$upload_data['upload_path'].$upload_data['resumableFilename'],TRUE);
		}
		finally{
			if(file_exists($private_pem)){
				unlink($private_pem);
			}
			if(file_exists($cert_pem)){
				unlink($cert_pem);
			}
			
		}
		
		//обработка подписи		
		try{
			if($docType=='application'){
				process_application_file($upload_data,$db_link);
			}
			else{
				process_document_file($upload_data,$db_link);
			}
		}
		catch(Exception $e){		
		}
		
		//вернуть модель Signature_Model с информацией по подписи
		$ar = $db_link->query_first(sprintf(
		"SELECT
			f_sig.id,
			u_cert.subject_cert AS owner,
			u_cert.date_time_from AS cert_from,
			u_cert.date_time_to AS cert_to,
			f_sig.sign_date_time,
			ver.check_result AS check_result,
			ver.check_time,
			ver.error_str	
		FROM file_signatures f_sig
		LEFT JOIN user_certificates AS u_cert ON u_cert.id=f_sig.user_certificate_id
		LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
		WHERE f_sig.file_id=%s
		ORDER BY f_sig.sign_date_time DESC
		LIMIT 1",
		$controller->getExtDbVal($pm,'file_id')
		));

		if(is_array($ar) && count($ar)){
			$m_fields = array();
			foreach($ar as $f_id=>$f_val){
				array_push(
					$m_fields,
					new FieldXML($f_id,DT_STRING,array('value'=>$f_val))
				);
			}
			$controller->addModel(
				new ModelVars(
					array('name'=>'Signature',
						'id'=>'Signature_Model',
						'values'=>$m_fields
				))
			);
		}
		else if(!is_null($e)){
			throw $e;
		}
	}
	

}
?>