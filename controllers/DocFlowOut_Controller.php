<?php
require_once(USER_CONTROLLERS_PATH.'DocFlow_Controller.php');
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



require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

class DocFlowOut_Controller extends DocFlow_Controller{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtDateTimeTZ('date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('reg_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_type_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('signed_by_employee_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('to_addr_names'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('to_user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('to_application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('to_contract_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('to_client_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('subject'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('content'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_in_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('new_contract_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('allow_new_file_add'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('allow_edit_sections'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
			$f_params = array();
			
			$param = new FieldExtEnum('expertise_result',',','positive,negative'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtInt('expertise_reject_type_id'
			,$f_params);
		$pm->addParam($param);		
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DocFlowOut_Model');

			
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
		$param = new FieldExtString('reg_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('signed_by_employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('to_addr_names'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('to_user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('to_application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('to_contract_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('to_client_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('subject'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('content'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_in_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('new_contract_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('allow_new_file_add'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('allow_edit_sections'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
			$f_params = array();
			
			$param = new FieldExtEnum('expertise_result',',','positive,negative'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtInt('expertise_reject_type_id'
			,$f_params);
		$pm->addParam($param);		
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocFlowOut_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DocFlowOut_Model');

			
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
		
		$this->setListModelId('DocFlowOutList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DocFlowOutDialog_Model');		

			
		$pm = new PublicMethod('remove_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('remove_sig');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_file_hash');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_file_sig');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_next_num');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_flow_type_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('reg_number'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('DocFlowOutList_Model');

			
		$pm = new PublicMethod('get_app_state');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_next_contract_number');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('alter_file_folder');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('new_folder_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_flow_out_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('add_sig_to_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtText('sig_data',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_sig_details');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('sign_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('file_data',$opts));
	
				
	$opts=array();
	
		$opts['length']=250;				
		$pm->addParam(new FieldExtString('file_path',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	private function find_afile($fileId,$fileIdDb,$docIdDb,$sigFile,&$fl,&$fileName,&$exception){
		$ar = $this->getDbLink()->query_first(sprintf(
			"(SELECT
				app_f.file_name,
				app_f.document_type,
				CASE
					WHEN app_f.document_type='documents' THEN app_f.file_path
					ELSE app_f.document_id::text
				END AS file_path,
				TRUE AS is_application,
				application_id AS application_id
			FROM doc_flow_out_client_document_files AS t
			LEFT JOIN doc_flow_in ON doc_flow_in.from_doc_flow_out_client_id=t.doc_flow_out_client_id
			LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id				
			WHERE t.file_id=%s AND doc_flow_in.id=%d)
			UNION ALL
			(SELECT
				t.file_name,
				'documents' AS document_type,
				t.file_path AS file_path,
				TRUE AS is_application,
				out.to_application_id AS application_id
			FROM doc_flow_attachments AS t
			LEFT JOIN doc_flow_out AS out ON t.doc_id=out.id
			WHERE t.doc_type='doc_flow_out'::data_types AND t.doc_id=%d AND t.file_id=%s)				
			",
			$fileIdDb,
			$docIdDb,
			$docIdDb,
			$fileIdDb
		));
	
		if (!count($ar)){
			$exception = new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			return FALSE;
		}
	
		$postf = $sigFile? '.sig':'';
		$document_type_path = Application_Controller::dirNameOnDocType($ar['document_type']);
		$document_type_path.= ($document_type_path=='')? '':DIRECTORY_SEPARATOR;
		if (
		(
			$ar['is_application']=='t'
			&& (!file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
					Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
					$document_type_path.
					$ar['file_path'].DIRECTORY_SEPARATOR.
					$fileId.$postf)
					&&(
						defined('FILE_STORAGE_DIR_MAIN') &&
						!file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
						$document_type_path.
						$ar['file_path'].DIRECTORY_SEPARATOR.
						$fileId.$postf)							
					)
				)
		)
		|| (
			$ar['is_application']!='t'
			&& !file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$fileId.$postf)
		)
		){
			$exception = new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			return FALSE;
		}
	
		$fileName = $ar['file_name'].$postf;
	
		return TRUE;
	}

	private function get_afile($pm,$sigFile){
		try{
			$er_st = 500;
			
			$exception = NULL;
			$fl = NULL;
			$file_name = NULL;
			if (!$this->find_afile(
				$this->getExtVal($pm,'file_id'),
				$this->getExtDbVal($pm,'file_id'),
				$this->getExtDbVal($pm,'doc_id'),
				$sigFile,
				$fl,
				$file_name,
				$exception
			)){
				$er_st = 404;
				throw $exception;
			}
		
			$mime = getMimeTypeOnExt($file_name);
			ob_clean();
			downloadFile($fl, $mime,'attachment;',$file_name);
			return TRUE;	
		}
		catch(Exception $e){
			$this->setHeaderStatus($er_st);
			throw $e;
		}	
	}

	public static function isDocSent($docId,&$dbLink){
		$ar = $dbLink->query_first(sprintf(
			"SELECT state
			FROM doc_flow_out_processes
			WHERE doc_flow_out_id=%d
			ORDER BY date_time DESC
			LIMIT 1",
			$docId
		));
		
		return (is_array($ar) && count($ar) && $ar['state']=='registered');
	}

	public function remove_file($pm){
	
		$is_sent = self::isDocSent($this->getExtDbVal($pm,'doc_id'),$this->getDbLink());
		if ($_SESSION['role_id']!='admin' && $is_sent){
			throw new Exception('Forbidden!');
		}
		
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			
			$this->remove_afile($pm,'out');
			
			if ($is_sent){
				$this->getDbLinkMaster()->query(sprintf(
					"INSERT INTO doc_flow_out_corrections
					(doc_flow_out_id,file_id,date_time,employee_id,is_new)
					VALUES (%d,%s,now(),%d,FALSE)",
					$this->getExtDbVal($pm,'doc_id'),
					$this->getExtDbVal($pm,'file_id'),
					intval(json_decode($_SESSION['employees_ref'])->keys->id)
				));
			}
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}		
	}

	public function remove_sig($pm){
		$this->remove_asig($pm,'out');
	}

	public function delete($pm){
		$this->delete_attachments($pm,'out');
	}
	
	public function get_next_num($pm){
		$this->get_next_num_on_type('out', $this->getExtDbVal($pm,'doc_flow_type_id'));
	}

	public function get_next_contract_number($pm){
		$model = new ModelSQL($this->getDbLinkMaster(),array('id'=>'NewNum_Model'));
		$model->query(
			sprintf(
			"SELECT
				contracts_next_number(
					CASE
					WHEN applications.expertise_type IS NOT NULL THEN 'pd'::document_types
					WHEN applications.cost_eval_validity THEN 'cost_eval_validity'::document_types
					WHEN applications.modification THEN 'modification'::document_types
					WHEN applications.audit THEN 'audit'::document_types						
					END,
					now()::date
				) AS num
			FROM applications
			WHERE id=%d",
			$this->getExtDbVal($pm,'application_id')
			)		
		,TRUE);
		$this->addModel($model);	
	}
	
	public function get_app_state($pm){
		$this->addNewModel(
			sprintf(
				"SELECT
					doc_flow_out.to_application_id,
					st.state
				FROM doc_flow_out
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=doc_flow_out.to_application_id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time				
				WHERE doc_flow_out.id=%d",
				$this->getExtDbVal($pm,'id')
			),
			'AppState_Model'
		);
	}
	
	private function update_contract_data($pm){
		$fld = NULL;
		$app_id = 0;
		if ($pm->getParamValue('expertise_result')){
			$fld = sprintf('expertise_result=%s',$this->getExtDbVal($pm,'expertise_result'));
		}
		if ($pm->getParamValue('expertise_reject_type_id') && $this->getExtDbVal($pm,'expertise_reject_type_id')>0){
			$fld = (is_null($fld))? '':($fld.',');
			$fld.= sprintf('expertise_reject_type_id=%d',$this->getExtDbVal($pm,'expertise_reject_type_id'));
		}
		
		if (!is_null($fld)){
			if ($pm->getParamValue('to_application_id')){
				$app_id = $this->getExtDbVal($pm,'to_application_id');
			}
			else if ($pm->getParamValue('old_id')){
				$app_id = $this->getDbLink()->query_first_col(sprintf("SELECT to_application_id FROM doc_flow_out WHERE id=%d",
				$this->getExtDbVal($pm,'old_id')
				));
			
			}
			if ($app_id){
				$this->getDbLinkMaster()->query(sprintf("UPDATE contracts SET %s WHERE application_id=%d",
				$fld,$app_id
				));
			}
		}
	}


	public function insert($pm){
		//throw new Exception($this->getExtVal($pm,"allow_edit_sections"));
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			$this->update_contract_data($pm);
			
			parent::insert($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}
	
	public function update($pm){
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			$this->update_contract_data($pm);
			
			parent::update($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}

	public function get_file($pm){
		return $this->get_afile($pm,FALSE);
	}

	public function get_file_sig($pm){
		return $this->get_afile($pm,TRUE);
	}

	private function move_file($oldFile,$newFile){
		$dir = dirname($newFile);
		if(!file_exists($dir))mkdir($dir,0777,TRUE);
		if (!rename($oldFile, $newFile))throw new Exception('Не удалось переместить файл.');
	}

	public function alter_file_folder($pm){
		if (!$pm->getParamValue('new_folder_id') || $pm->getParamValue('new_folder_id')=='0'){
			$new_folder = 'Исходящие';
		}
		else{
			$ar = $this->getDbLink()->query_first(sprintf("SELECT name FROM application_doc_folders WHERE id=%d",$this->getExtDbVal($pm,'new_folder_id')));
			if (!count($ar)){
				throw new Exception('Folder not found!');
			}
			$new_folder = $ar['name'];
		}
		
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT
			att.file_path,
			d_out.to_application_id AS application_id
		FROM doc_flow_attachments AS att
		LEFT JOIN doc_flow_out AS d_out ON att.doc_type='doc_flow_out' AND att.doc_id=d_out.id
		WHERE att.file_id=%s AND d_out.id=%d",
		$this->getExtDbVal($pm,'file_id'),
		$this->getExtDbVal($pm,'doc_flow_out_id')
		));
		if (!count($ar)){
			throw new Exception('Document not found!');
		}
		
		$old_rel_file = Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
					$ar['file_path'].DIRECTORY_SEPARATOR.
					$this->getExtVal($pm,'file_id');

		$new_rel_file = Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
					$new_folder.DIRECTORY_SEPARATOR.
					$this->getExtVal($pm,'file_id');

		try{
			$this->getDbLinkMaster()->query('BEGIN');
			
			$this->getDbLinkMaster()->query(sprintf(
			"UPDATE doc_flow_attachments
			SET file_path = '%s'
			WHERE file_id=%s",
			$new_folder,
			$this->getExtDbVal($pm,'file_id')			
			));
			$moved = FALSE;
			if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$old_rel_file)){
				$this->move_file($fl,FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$new_rel_file);
				$moved = TRUE;
			}
			if (defined('FILE_STORAGE_DIR_MAIN') && file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$old_rel_file)){
				$this->move_file($fl,FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$new_rel_file);
				$moved = TRUE;
			}
			//sig
			if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$old_rel_file.'.sig')){
				$this->move_file($fl,FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$new_rel_file.'.sig');
				$moved = TRUE;
			}
			if (defined('FILE_STORAGE_DIR_MAIN') && file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$old_rel_file.'.sig')){
				$this->move_file($fl,FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$new_rel_file.'.sig');
				$moved = TRUE;
			}
			
			if (!$moved){
				throw new Exception('Файл не найден!');
			}
			
			$this->getDbLinkMaster()->query('COMMIT');
		
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}
	}
	
	public function add_sig_to_file($pm){
		$doc_id = $this->getExtDbVal($pm,'doc_id');
		
		$state = $this->get_state($doc_id,"out");
		if (
			($state=='registered'||$state=='approved'||$state=='approved_with_notes'||$state=='not_approved')
			&& $_SESSION['role_id']!='admin'){
			throw new Exception(self::ER_ALLOWED_TO_ADMIN);
		}
		
		
		if (isset($_FILES['sig_data'])){
			$exception = NULL;
			$fl = NULL;
			$file_name = NULL;
			if (!$this->find_afile(
				$this->getExtVal($pm,'file_id'),
				$this->getExtDbVal($pm,'file_id'),
				$this->getExtDbVal($pm,'doc_id'),
				$sigFile,
				$fl,
				$file_name,
				$exception
			)){
				throw $exception;
			}
			
			//$_FILES['sig_data']['tmp_name']
			
		}
	}

	public function get_file_hash($pm){
		$exception = NULL;
		$fl = NULL;
		$file_name = NULL;
		if (!$this->find_afile(
			$this->getExtVal($pm,'file_id'),
			$this->getExtDbVal($pm,'file_id'),
			$this->getExtDbVal($pm,'doc_id'),
			FALSE,
			$fl,
			$file_name,
			$exception
		)){
			throw $exception;
		}
		
		$pki_man = pki_create_manager();
		$hash = pki_get_hash(
			$fl,
			$this->getExtDbVal($pm,'file_id'),
			$pki_man,$this->getDbLinkMaster()
		);
		if (is_null($hash)){
			throw new Exception('Ошибка чтения файла');
		}
		
		ob_clean();
		header('Content-Type: text/plain');
		echo $hash;
		return TRUE;
	}

	public function get_sig_details($pm){
		if ($_SESSION['role_id']=='client'){
			//открывает только свои заявления!!!
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					CASE WHEN af.file_id IS NOT NULL THEN TRUE ELSE FALSE END AS user_check_passed
				FROM application_document_files AS af
				LEFT JOIN applications AS a ON a.id=af.application_id
				WHERE af.file_id=%s AND a.user_id=%d",
			$this->getExtDbVal($pm,'id'),
			$_SESSION['user_id']
			));			
			if (!count($ar) || $ar['user_check_passed']!='t'){
				throw new Exception(self::ER_OTHER_USER_APP);
			}			
		}
				
	
		$this->addNewModel(
			Application_Controller::getSigDetailsQuery($this->getExtDbVal($pm,'id')),
			'FileSignatures_Model'
		);
	
	}

	public function get_object($pm){
		if (!is_null($pm->getParamValue("id"))){
			parent::get_object($pm);
		}
		else{
			//new document
			$this->addNewModel(
			"SELECT json_agg(fld.files) As files
			FROM (
				SELECT
					json_build_object(
						'fields',
						json_build_object(
							'id',id,
							'descr',name,
							'required',false,
							'require_client_sig',require_client_sig
						),
						'files','[]'::json
					) AS files
				FROM application_doc_folders
				ORDER BY name
			) AS fld",
			'DocFlowOutDialog_Model'
			);			
		}
	}
	
	public function sign_file($pm){		
		$file_data = NULL;
		if(isset($_FILES) && isset($_FILES['file_data'])){
			$file_data = $_FILES['file_data'];
		}
	
		DocFlow_Controller::signFile(
			$this,
			$pm,
			$file_data,
			'out'
		);
	}


}
?>
