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



require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');
require_once('common/file_func.php');

require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

class DocFlowOutClient_Controller extends ControllerSQL{
	
	const ER_NO_DOC = 'Document not found!';
	const ER_DOC_SENT = 'Документ отправлен!';
	const ER_WRONG_STATE = 'Невозможно отправить исходящий документ по заявлению с данным статусом!';
	const ER_NO_ATTACHMENTS = 'Вложенные файлы отсутствуют!';
	const ER_NO_DOC_FILE = 'Файл с данными не найден!';
	const ER_VERIF_SIG = 'Ошибка проверки подписи:%s';
	const ER_UNSENT_DOC_EXISTS = 'По данному заявлению уже есть неотправленный документ с таким видом письма от %s';
	const ER_CLIENT_OUT_DOC_BANNED = 'С %s по данному контракту запрещена отправка ответов на замечания!';
	const ER_COULD_NOT_REMOVE_SIG = 'Ошибка при удалении подписи заказчика!';
	const ER_NO_SIG_ATTACHMENTS = 'Нет подписанных Вами документов!';
	const ER_DEL_NOT_ALLOWED = 'Удаление файлов запрещено!@1010';

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
		$param = new FieldExtText('comment_text'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('application_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtText('subject'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('content'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('sent'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('doc_flow_out_client_type',',','app,contr_resp,contr_return,contr_other,date_prolongate,app_contr_revoke'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('admin_correction'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DocFlowOutClient_Model');

			
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
		$param = new FieldExtText('comment_text'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
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
		$param = new FieldExtText('content'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('sent'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('doc_flow_out_client_type',',','app,contr_resp,contr_return,contr_other,date_prolongate,app_contr_revoke'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('admin_correction'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocFlowOutClient_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DocFlowOutClient_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DocFlowOutClientDialog_Model');		

			
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
		
		$this->setListModelId('DocFlowOutClientList_Model');
		
			
		$pm = new PublicMethod('get_application_dialog');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
				
	$opts=array();
			
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('remove_file');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('remove_document_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_flow_out_client_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_files_for_signing');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_all_attachments');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
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

			
		$pm = new PublicMethod('check_type');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('doc_flow_out_client_type',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('doc_flow_out_client_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_correction_list');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_doc_flow_out_attrs');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('admin_enable_edit');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	/*
	private function check_reg_number($regNumberForDb){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				TRUE AS reg_number_exists
			FROM doc_flow_out_client
			WHERE reg_number=%s",
			$regNumberForDb
		));
	
	}
	*/
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
	
	public function insert($pm){
		//check app state
		$app_id = $this->getExtDbVal($pm,'application_id');
		
		//Проверка на существование других неотправленных писем в таким же типом
		$this->check_unsent_doc($app_id, $this->getExtDbVal($pm,'doc_flow_out_client_type'));
		
		$this->check_resp_doc($app_id, $this->getExtVal($pm,'doc_flow_out_client_type'));
					
		$ar = $this->getDbLink()->query_first(sprintf("SELECT
			application_processes_last(%d) AS state,
			(SELECT ap.user_id=%d FROM applications AS ap WHERE ap.id=%d) AS user_check_passed
			",
			$app_id,
			$_SESSION['user_id'],
			$app_id
		));
	
		Application_Controller::checkApp($ar);
		if ($ar['user_check_passed']!='t'){
			throw new Exception(self::ER_NO_DOC);
		}
		
		if (
			$ar['state']=='archive'
		||
			($ar['state']=='closed' && $this->getExtVal($pm,'doc_flow_out_client_type')!='contr_return')
		){
			throw new Exception(self::ER_WRONG_STATE);
		}
		
		
		if ($this->getExtVal($pm,'sent')=='true'){
			throw new Exception(self::ER_NO_ATTACHMENTS);
		}
		
		$pm->setParamValue("user_id",$_SESSION['user_id']);
		$inserted_id_ar = parent::insert($pm);
		return $inserted_id_ar;
	}	

	public function update($pm){
		if ($pm->getParamValue('user_id')){
			$pm->setParamValue("user_id",$_SESSION['user_id']);
		}
		
		$doc_flow_out_client_type = $pm->getParamValue('doc_flow_out_client_type')? $this->getExtVal($pm,'doc_flow_out_client_type'):NULL;
		
		$app_id = NULL;
		if ($pm->getParamValue('application_id')){
			$app_id = $this->getExtDbVal('application_id');
			$ar = $this->getDbLink()->query_first(sprintf(
			"WITH
			doc AS
				(SELECT
					t.user_id,
					t.doc_flow_out_client_type
				FROM doc_flow_out_client t WHERE t.id=%d)
			SELECT
				user_id,
				(SELECT doc.user_id FROM doc) AS doc_user_id,
				(SELECT doc.doc_flow_out_client_type FROM doc) AS doc_flow_out_client_type
			FROM applications
			WHERE id=%d",
			$this->getExtDbVal($pm,'old_id'),
			$app_id
			));
			if (!count($ar)||$ar['user_id']!=$_SESSION['user_id']||$ar['doc_user_id']!=$_SESSION['user_id']){
				throw new Exception(self::ER_NO_DOC);
			}			
		}
		else{
			//no app_id
			$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				d.application_id,
				d.user_id,
				d.doc_flow_out_client_type
			FROM doc_flow_out_client AS d
			WHERE d.id=%d",
			$this->getExtDbVal($pm,'old_id')
			));
			if (!count($ar)){
				throw new Exception(self::ER_NO_DOC);
			}
			$app_id = $ar['application_id'];
		}
		
		if(is_null($doc_flow_out_client_type)){
			$doc_flow_out_client_type = $ar['doc_flow_out_client_type'];
		}
		
		if ($this->getExtVal($pm,'sent')=='true'){
		
			$this->check_resp_doc($app_id, $doc_flow_out_client_type);
		
			$old_id = $this->getExtDbVal($pm,'old_id');
			$ar_cnt = $this->getDbLink()->query_first(sprintf(
				"SELECT
					(SELECT count(*) FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=%d) AS cnt,
					(SELECT count(*) FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=%d AND signature) AS cnt_sig,
					(SELECT TRUE FROM doc_flow_out_client_files_for_signing(%d) AS cl_files WHERE NOT cl_files->>'files'='null') AS docs_for_sig
				",
				$old_id,
				$old_id,
				$app_id
			
			));
			if (!count($ar_cnt)||!intval($ar_cnt['cnt'])){
				throw new Exception(self::ER_NO_ATTACHMENTS);
			}
			
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					application_processes_last(%d) AS state,
					(SELECT ap.user_id=%d FROM applications AS ap WHERE ap.id=%d) AS user_check_passed,
					(SELECT d.doc_flow_out_client_type FROM doc_flow_out_client d WHERE d.id=%d) AS doc_flow_out_client_type,
					(SELECT d.sent FROM doc_flow_out_client d WHERE d.id=%d) AS doc_flow_out_client_sent					
				",
				$app_id,
				$_SESSION['user_id'],
				$app_id,
				$old_id,
				$old_id
			));
	
			Application_Controller::checkApp($ar);
			if ($_SESSION['role_id']!='admin' && $ar['user_check_passed']!='t'){
				throw new Exception(self::ER_NO_DOC);
			}

			if ($ar['doc_flow_out_client_sent']=='t'){
				throw new Exception(self::ER_DOC_SENT);
			}	
			
			/**
			 * Возврат контракта, нет подписанных клиентом, хотя для подписания есть
			 */
			if ($ar['doc_flow_out_client_type']=='contr_return' && !intval($ar_cnt['cnt_sig']) && $ar_cnt['docs_for_sig']=='t'){
				throw new Exception(self::ER_NO_SIG_ATTACHMENTS);
			}
			
			if (
			$ar['state']=='archive'
			|| (	$ar['state']=='closed'
				&& ($ar['doc_flow_out_client_type']!='contr_return' || $this->getExtVal($pm,'doc_flow_out_client_type')=='contr_return')
				)
			){
				throw new Exception(self::ER_WRONG_STATE);
			}
		
			if ($ar['doc_flow_out_client_type']=='contr_resp'){
				$db_link = $this->getDbLink();
				Application_Controller::checkIULs($db_link,$app_id,$old_id);
			}		
			/*
			if ($ar['doc_flow_out_client_type']=='contr_return' && $ar['state']!='expertise'){
				throw new Exception(self::ER_WRONG_STATE);
			}
			*/	
			
		}		
		parent::update($pm);
	}	



	private function add_application($applicationId,$docId){
		$document_exists = FALSE;
		
		if (!is_null($applicationId)){		
		
			//Клиент видит только СВОЕ!!!
			$client_q_t = '';
			if ($_SESSION['role_id']=='client'){
				$client_q_t = ' AND app.user_id='.$_SESSION['user_id'];
			}
			
			$ar_obj = $this->getDbLink()->query_first(sprintf(
			"SELECT
				app.id,				
				app.cost_eval_validity,
				app.modification,
				app.audit,
				app.construction_types_ref,
				app.documents,
				app.document_exists,
				
				CASE WHEN app.service_type='modified_documents'
					THEN app.modified_documents_expertise_type
					ELSE app.expertise_type
				END AS expertise_type,

				CASE WHEN app.service_type='modified_documents'
					THEN app.modified_documents_service_type
					ELSE app.service_type
				END AS service_type
			
			FROM applications_dialog AS app
			WHERE app.id=%d".$client_q_t,
			$applicationId
			));
		
			if (!is_array($ar_obj) || !count($ar_obj)){
				throw new Exception(ER_NO_DOC);
			
			}
			
			if (!is_null($docId)){
				$files_q_id = Application_Controller::attachmentsQuery(
					$this->getDbLink(),
					$applicationId,
					'AND coalesce(adf.deleted,FALSE)=FALSE'
				);
						
				//fl.file_id IN (SELECT ofl.file_id FROM doc_flow_out_client_document_files AS ofl WHERE ofl.doc_flow_out_client_id=%d)	
			}
						
			$document_exists = ( $ar_obj['document_exists']=='t' && !is_null($docId) );
		}
		
		$documents = NULL;
		if($document_exists){
			$documents_json = json_decode($ar_obj['documents']);
			if($documents_json){
				foreach($documents_json as $doc){
					Application_Controller::addDocumentFiles($doc->document,$this->getDbLink(),$doc->document_type,$files_q_id);
				}
				$documents = json_encode($documents_json);
			}
			else{
				$document_exist = FALSE;
			}
		}
		if (!$document_exists){
			$this->addNewModel("SELECT * FROM document_templates_all_json_list",'DocumentTemplateAllList_Model');			
			
		}		
		
		if (!is_null($applicationId)){		
			$this->addModel(new ModelVars(
				array('name'=>'Vars',
					'id'=>'ApplicationDialog_Model',
					'values'=>array(
						new Field('id',DT_INT,array('value'=>$ar_obj['id']))
						,new Field('expertise_type',DT_STRING,array('value'=>$ar_obj['expertise_type']))
						,new Field('service_type',DT_STRING,array('value'=>$ar_obj['service_type']))
						,new Field('cost_eval_validity',DT_STRING,array('value'=>$ar_obj['cost_eval_validity']))
						,new Field('modification',DT_STRING,array('value'=>$ar_obj['modification']))
						,new Field('audit',DT_STRING,array('value'=>$ar_obj['audit']))
						,new Field('construction_types_ref',DT_STRING,array('value'=>$ar_obj['construction_types_ref']))
						,new Field('documents',DT_STRING,array('value'=>$documents))
						)
					)
				)
			);		
		}
	}	

	public function get_application_dialog($pm){
		$this->add_application($this->getExtDbVal($pm,'application_id'),$this->getExtDbVal($pm,'id'));
		$this->add_files_for_signing($this->getExtDbVal($pm,'application_id'));
	}

	public function get_object($pm){
	
		parent::get_object($pm);
		
		if (!is_null($pm->getParamValue('id'))){		
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT t.application_id
				FROM doc_flow_out_client AS t
				WHERE t.id=%d",
			$this->getExtDbVal($pm,'id')
			));
			$application_id = $ar['application_id'];
			$doc_id = $this->getExtDbVal($pm,'id');
		}
		else{
			$application_id = NULL;
			$doc_id = NULL;
		}			
		$this->add_application($application_id,$doc_id);
	}
	
	public function remove_file($pm){
		$file_id_for_db = $this->getExtDbVal($pm,'file_id');
		
		//checking
		//Файла может не быть в DocFlowOutClientDocuments!!!
		
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT
			app.id AS application_id,
			app.user_id,
			app_f.file_signed_by_client,
			(contr_docs.file_id IS NOT NULL) AS contr_return,
			app_f.file_path,
			app_f.file_id,
			(doc_files.file_id IS NOT NULL) AS this_app_file,
			doc_files.signature,
			coalesce(doc.sent,FALSE) AS doc_sent
			
		FROM applications AS app
		LEFT JOIN application_document_files AS app_f ON app_f.application_id=app.id AND app_f.file_id=%s
		LEFT JOIN doc_flow_attachments AS contr_docs ON contr_docs.file_id=app_f.file_id
		LEFT JOIN doc_flow_out_client_document_files AS doc_files ON doc_files.file_id=app_f.file_id
		LEFT JOIN doc_flow_out_client AS doc ON doc.id=doc_files.doc_flow_out_client_id
		WHERE app.id=%d",
		$file_id_for_db,
		$this->getExtDbVal($pm,'application_id')
		));
		
		if (!count($ar)
		|| ($_SESSION['role_id']!='admin' && $ar['user_id']!=$_SESSION['user_id'])
		|| $ar['this_app_file']!='t'
		|| $ar['doc_sent']=='t'
		){
			throw new Exception('Forbidden!');
		}

		if ($ar['contr_return']=='t' && $ar['signature']=='t'){
		
			//Возврат контракта
			$rel_dir = Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.$ar['file_path'];
			
			$max_index = NULL;
			$old_sig_file = Application_Controller::getMaxIndexSigFile($rel_dir,$ar['file_id'],$max_index);
			if (!$max_index){
				//что-то пошло не так - нет файла подписи sig.s(1)
				throw new Exception(self::ER_COULD_NOT_REMOVE_SIG);
			}

			if (
			!file_exists($file_doc=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$ar['file_id'])
			&&
			(
				!defined('FILE_STORAGE_DIR_MAIN')
				|| !file_exists($file_doc=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$ar['file_id'])
			)
			){				
				throw new Exception(self::ER_NO_DOC_FILE);
			}			
			
			try{
				$dbLinkMaster= $this->getDbLinkMaster();
		
				$dbLinkMaster->query("BEGIN");
			
				$dbLinkMaster->query(sprintf(
					"UPDATE application_document_files
					SET file_signed_by_client=FALSE
					WHERE file_id=%s",
				$file_id_for_db
				));				
			
				$dbLinkMaster->query(sprintf("DELETE FROM doc_flow_out_client_document_files WHERE file_id=%s", $file_id_for_db));
				
				$sig_file = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$ar['file_id'].'.sig';
				exec(sprintf('mv -f "%s" "%s"',$old_sig_file,$sig_file));
				if (defined('FILE_STORAGE_DIR_MAIN') && file_exists($fl=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$ar['file_id'].'.sig'))unlink($fl);
				
				$pki_man = pki_create_manager();
				pki_log_sig_check($sig_file, $file_doc, $file_id_for_db, $pki_man, $dbLinkMaster,TRUE);
				
				$dbLinkMaster->query("COMMIT");
			}
			catch(Exception $e){
				$dbLinkMaster->query("ROLLBACK");
				throw $e;
			}
			
		}
		else{
			//Прочие вложения, непосредственное удаление
			
			try{
				$dbLinkMaster= $this->getDbLinkMaster();
			
				$dbLinkMaster->query("BEGIN");
						
				Application_Controller::removeFile($dbLinkMaster, $file_id_for_db,TRUE);		
			
				$dbLinkMaster->query(sprintf("DELETE FROM doc_flow_out_client_document_files WHERE file_id=%s", $file_id_for_db));
			
				$dbLinkMaster->query("COMMIT");
			}
			catch(Exception $e){
				$dbLinkMaster->query("ROLLBACK");
				throw $e;
			}
		}
	}

	private function check_user_and_state($docIdDb){
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT
			d.user_id,
			d.sent,
			d.doc_flow_out_client_type,
			d.application_id
		FROM doc_flow_out_client AS d
		WHERE d.id=%d",
		$docIdDb
		));
		if (!count($ar)){
			throw new Exception(self::ER_NO_DOC);
		}
		else if ($_SESSION['role_id']!='admin' && $ar['user_id']!=$_SESSION['user_id']){
			throw new Exception(self::ER_NO_DOC);
		}
		else if ($ar['sent']=='t'){
			throw new Exception(self::ER_DOC_SENT);
		}
	
		return $ar;
	}

	public function delete($pm){
		$this->delete_all_attachments($pm);
		
		parent::delete($pm);
	}
		
	/**
	 * Удаляет все вложения, восстанавливает файлы документации
	 */
	public function delete_all_attachments($pm){
	
		$doc_attrs = $this->check_user_and_state($this->getExtDbVal($pm,'id'));
		
		try{
			$dbLinkMaster= $this->getDbLinkMaster();
			
			$dbLinkMaster->query("BEGIN");
			
			$q_id = $dbLinkMaster->query(sprintf(
				"SELECT
					doc_f.file_id,
					app_f.file_path,
					app_f.document_id,
					app_f.document_type,
					app_f.file_signed,
					app_f.deleted,
					doc_f.signature,
					coalesce(doc_f.is_new) AS is_new
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=%d",
			$this->getExtDbVal($pm,'id')
			));
			
			$pki_man = NULL;			
			if ($doc_attrs['doc_flow_out_client_type']=='contr_return'){
				$pki_man = pki_create_manager();
			}
			
			while($ar= $dbLinkMaster->fetch_array($q_id)){
				if ($doc_attrs['doc_flow_out_client_type']=='contr_return' && $ar['signature']=='t'){
					if ($ar['file_path']){
						$rel_dir = Application_Controller::APP_DIR_PREF.$doc_attrs['application_id'].DIRECTORY_SEPARATOR.$ar['file_path'];
						$data_rel_file = $rel_dir.DIRECTORY_SEPARATOR.$ar['file_id'];
						$sig_rel_file = $data_rel_file.'.sig';
					
						if (
						!file_exists($file_doc=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$data_rel_file)
						&&
							(!defined('FILE_STORAGE_DIR_MAIN')
							|| !file_exists($file_doc=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$data_rel_file)
							)
						){				
							throw new Exception(self::ER_NO_DOC_FILE);
						}			
					
						//find previous sig
						$max_ind = NULL;
						$prev_sig = Application_Controller::getMaxIndexSigFile($rel_dir,$ar['file_id'],$max_ind);
						if (!$max_ind){
							throw new Exception(self::ER_COULD_NOT_REMOVE_SIG);
						}

						//current .sig from all servers
						$this->remove_file_from_all_servers($doc_attrs['application_id'],$sig_rel_file);
					
						//sig.s(1) -> .sig
						$file_sig = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$sig_rel_file;
						exec(sprintf('mv -f "%s" "%s"',$prev_sig,$file_sig));					
						pki_log_sig_check($file_sig, $file_doc, "'".$ar['file_id']."'", $pki_man, $dbLinkMaster,TRUE);
					}
					
					$dbLinkMaster->query(sprintf(
						"UPDATE application_document_files
						SET file_signed_by_client=FALSE
						WHERE file_id='%s'",
					$ar['file_id']
					));
				}
				else{
					if ($ar['document_type']!='documents' && $ar['deleted']=='t'){
						$file_rel = DIRECTORY_SEPARATOR.Application_Controller::APP_DIR_PREF.$doc_attrs['application_id'].DIRECTORY_SEPARATOR.
							Application_Controller::APP_DIR_DELETED_FILES.DIRECTORY_SEPARATOR.$ar['file_id'];
						$restor_file_rel = DIRECTORY_SEPARATOR.Application_Controller::APP_DIR_PREF.$doc_attrs['application_id'].DIRECTORY_SEPARATOR.
							(($ar['document_type']!='documents')? (Application_Controller::dirNameOnDocType($ar['document_type']).DIRECTORY_SEPARATOR.$ar['document_id']) : $ar['file_path']).DIRECTORY_SEPARATOR.
							$ar['file_id'];
							
						$unlink_file = FALSE;
					}
					else{
						$file_rel = DIRECTORY_SEPARATOR.Application_Controller::APP_DIR_PREF.$doc_attrs['application_id'].DIRECTORY_SEPARATOR.
							(($ar['document_type']!='documents')? (Application_Controller::dirNameOnDocType($ar['document_type']).DIRECTORY_SEPARATOR.$ar['document_id']) : $ar['file_path']).DIRECTORY_SEPARATOR.
							$ar['file_id'];
						$unlink_file = TRUE;
					}
					
					if (
					file_exists($file=FILE_STORAGE_DIR.$file_rel)
					|| (defined('FILE_STORAGE_DIR_MAIN') && file_exists($file=FILE_STORAGE_DIR_MAIN.$file_rel))
					){							
						if ($unlink_file){
							unlink($file);
							$dbLinkMaster->query(sprintf(
								"DELETE FROM application_document_files WHERE file_id=%s",
							"'".$ar['file_id']."'"
							));
							
						}
						else{
							//move back to documentation
							$dbLinkMaster->query(sprintf(
								"UPDATE application_document_files
								SET
									deleted=FALSE,
									deleted_dt = NULL
								WHERE file_id=%s",
							"'".$ar['file_id']."'"
							));
							
							rename($file,FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$restor_file_rel);							
						}										
					}								

					if (
					$ar['file_signed']
					&&
					(file_exists($file=FILE_STORAGE_DIR.$file_rel.'.sig')
					|| (defined('FILE_STORAGE_DIR_MAIN') && file_exists($file=FILE_STORAGE_DIR_MAIN.$file_rel.'.sig'))
					)
					){							
						if ($unlink_file){
							unlink($file);
						}
						else{
							//move back to documentation
							rename($file,FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$restor_file_rel.'.sig');							
						}										
					}								
				}
			}
						
			$dbLinkMaster->query(sprintf(
				"DELETE FROM doc_flow_out_client_document_files
				WHERE doc_flow_out_client_id=%d",
			$this->getExtDbVal($pm,'id')
			));
						
			$dbLinkMaster->query(sprintf(
				"DELETE FROM doc_flow_out_client_original_files
				WHERE doc_flow_out_client_id=%d",
			$this->getExtDbVal($pm,'id')
			));
			
			Application_Controller::removeAllZipFile($doc_attrs['application_id']);
			Application_Controller::removePDFFile($doc_attrs['application_id']);
			
			$dbLinkMaster->query("COMMIT");
		}
		catch(Exception $e){
			$dbLinkMaster->query("ROLLBACK");
			throw $e;
		}
	}

	private function add_files_for_signing($applicationId){			
		$this->addNewModel(sprintf(
		"SELECT jsonb_agg(doc_flow_out_client_files_for_signing(%d)) AS attachment_files_only_sigs",
		$applicationId
		),"FileForSigningList_Model");
		
	}
	
	public function get_files_for_signing($pm){
		if ($_SESSION['role_id']=='client'){
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					user_id
				FROM applications
				WHERE id=%d",
			$this->getExtDbVal($pm,'application_id')
			));
			if (!count($ar) || $ar['user_id']!=$_SESSION['user_id']){
				throw new Exception(ER_NO_DOC);
			}
		}
	
		$this->add_files_for_signing($this->getExtDbVal($pm,'application_id'));
	}
	
	public function remove_document_file($pm){
		$file_id_for_db = $this->getExtDbVal($pm,'file_id');
		$doc_flow_out_client_id_for_db = $this->getExtDbVal($pm,'doc_flow_out_client_id');
		
		$this->check_user_and_state($doc_flow_out_client_id_for_db);
		
		//А можно ли удалять файлы?
		$ar = $this->getDbLink()->query_first(
			sprintf(
				"SELECT
					doc_flow_out_client_out_attrs(
						(SELECT t.application_id FROM doc_flow_out_client AS t WHERE t.id=%d)
					) AS attrs,
					(SELECT t.doc_flow_out_client_id=%d
					FROM doc_flow_out_client_document_files t					
					WHERE t.file_id=%s
					ORDER BY doc_flow_out_client_id DESC
					LIMIT 1
					) AS added_by_this_doc
				",
				$doc_flow_out_client_id_for_db,
				$doc_flow_out_client_id_for_db,
				$file_id_for_db
			)
		);
		if(is_array($ar) && count($ar)  && isset($ar['attrs'])){
			$attrs = json_decode($ar['attrs']);
			if (!$attrs->allow_new_file_add && $ar['added_by_this_doc']=='f'){
				throw new Exception(self::ER_DEL_NOT_ALLOWED);
			}
		}
		
		try{
			$dbLinkMaster= $this->getDbLinkMaster();
		
			$dbLinkMaster->query("BEGIN");

			//Добавлен ЭТИМ документом!!!
			$ar = $dbLinkMaster->query_first(sprintf(
				"SELECT
					(doc_flow_out_client_id=%d) AS unlink_file
				FROM doc_flow_out_client_document_files
				WHERE file_id=%s",			
			$doc_flow_out_client_id_for_db,
			$file_id_for_db
			));
			
			$unlink_file = (count($ar) && $ar['unlink_file']=='t');
					
			if ($unlink_file){				
				//Восстановим файлы, удаленные взамен этому (файл и возможно УЛ и подписи)
				$q_id = $dbLinkMaster->query(sprintf(
					"SELECT
						orig_f.original_file_id AS file_id,
						app_f.document_type,
						app_f.document_id,
						app_f.file_name,
						app_f.file_signed,
						app_f.deleted,
						app_f.application_id,
						app_f.file_signed
					FROM doc_flow_out_client_original_files AS orig_f
					LEFT JOIN application_document_files AS app_f ON orig_f.original_file_id=app_f.file_id
					WHERE orig_f.doc_flow_out_client_id=%d AND orig_f.new_file_id=%s",			
				$doc_flow_out_client_id_for_db,
				$file_id_for_db
				));
				$orig_file_str = "";
				while($ar= $dbLinkMaster->fetch_array($q_id)){
					$orig_file_str.= ($orig_file_str=="")? "":",";
					$orig_file_str.= "'".$ar['file_id']."'";
					
					//Фактическое восстановление файла: копирование из Удаленные в нужную папку документации
					$file_rel = DIRECTORY_SEPARATOR.Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_DELETED_FILES.DIRECTORY_SEPARATOR.$ar['file_id'];
					$restor_file_rel = DIRECTORY_SEPARATOR.Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
						(($ar['document_type']!='documents')? (Application_Controller::dirNameOnDocType($ar['document_type']).DIRECTORY_SEPARATOR.$ar['document_id']) : $ar['file_path']).DIRECTORY_SEPARATOR.
						$ar['file_id'];
					if (
					file_exists($file=FILE_STORAGE_DIR.$file_rel)
					|| (defined('FILE_STORAGE_DIR_MAIN') && file_exists($file=FILE_STORAGE_DIR_MAIN.$file_rel))
					){							
						//move back to documentation
						rename($file,FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$restor_file_rel);							
					}								
					if (
					$ar['file_signed']
					&&
					(file_exists($file=FILE_STORAGE_DIR.$file_rel.'.sig')
					|| (defined('FILE_STORAGE_DIR_MAIN') && file_exists($file=FILE_STORAGE_DIR_MAIN.$file_rel.'.sig'))
					)
					){							
						//move back to documentation
						rename($file,FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$restor_file_rel.'.sig');							
					}								
					
				}
				
				$dbLinkMaster->query(sprintf("DELETE FROM doc_flow_out_client_document_files WHERE file_id=%s", $file_id_for_db));
				
				if(strlen($orig_file_str)){
					$dbLinkMaster->query(sprintf(
						"UPDATE application_document_files
						SET
							deleted = FALSE,
							deleted_dt = NULL
						WHERE file_id IN (%s)",
					$orig_file_str
					));
				
					$dbLinkMaster->query(sprintf(
						"DELETE FROM doc_flow_out_client_original_files
						WHERE doc_flow_out_client_id=%d AND original_file_id IN (%s)",
					$doc_flow_out_client_id_for_db,
					$orig_file_str
					));
				
					$dbLinkMaster->query(sprintf(
						"DELETE FROM doc_flow_out_client_document_files
						WHERE file_id IN (%s)",
					$orig_file_str
					));
				}
			}
			else{
				//просто пометили на удаление - отметим принадлежность к этому письму
				$dbLinkMaster->query(sprintf(
					"INSERT INTO doc_flow_out_client_document_files
					(file_id,doc_flow_out_client_id,is_new)
					VALUES (%s,%d,FALSE)",
				$file_id_for_db,
				$doc_flow_out_client_id_for_db
				));
			}
			
			Application_Controller::removeFile($dbLinkMaster, $file_id_for_db,$unlink_file);		
					
			$dbLinkMaster->query("COMMIT");
		}
		catch(Exception $e){
			$dbLinkMaster->query("ROLLBACK");
			throw $e;
		}
	}
	
	private function check_unsent_doc($appId,$docFlowOutClientTypeForDb,$docFlowOutClientId=NULL){
		//Проверка на существование других неотправленных писем в таким же типом
		$doc_id_cond = ($docFlowOutClientId && $docFlowOutClientId!=''&&strlen($docFlowOutClientId))?
			 sprintf(' AND NOT id=%d',$docFlowOutClientId) : '';
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				id,
				to_char(date_time,'DD/MM/YY') date_time
			FROM doc_flow_out_client
			WHERE application_id=%d AND doc_flow_out_client_type=%s AND coalesce(sent,FALSE)=FALSE".$doc_id_cond,
		$appId,
		$docFlowOutClientTypeForDb
		));
		if (is_array($ar) && count($ar) && $ar['id']){
			throw new Exception(sprintf(self::ER_UNSENT_DOC_EXISTS,$ar['date_time']));
		}
	}

	private function check_resp_doc($appId,$clientType){
		//Проверка на возможность отправки писем с ответами за Х дней до окончания срока
		if($clientType=="contr_resp"){
			$ar = $this->getDbLink()->query_first(sprintf(
				"WITH
				contr AS (SELECT
						coalesce(allow_client_out_documents,FALSE) AS allow_client_out_documents,
						work_end_date,
						bank_day_next(
							work_end_date,-const_ban_client_responses_day_cnt_val()
						) AS ban_from
					FROM contracts
					WHERE application_id=%d
				)
				SELECT
				to_char((SELECT ban_from FROM contr),'dd/mm/yy') AS ban_from,					
				coalesce(
					(
						(SELECT allow_client_out_documents FROM contr)=FALSE
						AND now()::date>=(SELECT ban_from FROM contr)
					)
				,FALSE) AS banned",
			$appId
			));
			if (is_array($ar) && count($ar) && $ar['banned']!='f'){
				throw new Exception(sprintf(self::ER_CLIENT_OUT_DOC_BANNED,$ar['ban_from']));
			}
		}
	}
	
	public function check_type($pm){
		$app = $this->getExtDbVal($pm,'application_id');
		$this->check_unsent_doc($app, $this->getExtDbVal($pm,'doc_flow_out_client_type'),$this->getExtDbVal($pm,'doc_flow_out_client_id'));
		$this->check_resp_doc($app,$this->getExtVal($pm,'doc_flow_out_client_type'));
	}
	
	public function get_correction_list($pm){
		$this->addNewModel(sprintf(
			"SELECT
				jsonb_agg(paths.section_o) AS corrected_sections
			FROM
			(
				SELECT 
				app_f.file_path,
				jsonb_build_object(
					'name',app_f.file_path,
					'deleted',sum(CASE WHEN doc_f.is_new THEN 0 ELSE 1 END),
					'added',sum(CASE WHEN doc_f.is_new THEN 1 ELSE 0 END)
				) AS section_o
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=%d AND app_f.document_id<>0
				GROUP BY app_f.file_path
				ORDER BY app_f.file_path
			) AS paths",
		$this->getExtDbVal($pm,'id')
		),
		"DocFlowOutClientCorrectionList_Model");
	
	}
	
	/**
	 * Возвращает объект
	 *	- allow_new_file_add bool
	 *	- allow_edit_sections array on int
	 * Информация из НАШЕГО последнего письма
	 */
	public function get_doc_flow_out_attrs($pm){
		$this->addNewModel(sprintf(
			"SELECT doc_flow_out_client_out_attrs(%d) AS attrs",
			$this->getExtDbVal($pm,'application_id')
		),
		'DocFlowOutAttrList_Model'
		);
	}
	
	public static function removeOriginalFile($dbLink,$origFileIdForDb,$newFileId,$docFlowOutClientIdForDb){
		//if uploaded by this same document - actual unlinking!
		$ar = $dbLink->query_first(sprintf(		
		"SELECT TRUE AS present
		FROM doc_flow_out_client_document_files
		WHERE file_id=%s AND doc_flow_out_client_id=%d",
		$origFileIdForDb,$docFlowOutClientIdForDb
		));
		$unlink_file = (count($ar) && $ar['present']=='t');
		Application_Controller::removeFile($dbLink,$origFileIdForDb,$unlink_file);

		if (!$unlink_file){
			$dbLink->query(sprintf(		
				"INSERT INTO doc_flow_out_client_document_files
				(file_id,doc_flow_out_client_id,is_new)
				VALUES (%s,%d,FALSE)
				ON CONFLICT DO NOTHING",
			$origFileIdForDb,$docFlowOutClientIdForDb
			));
			
			$dbLink->query(sprintf(
				"INSERT INTO doc_flow_out_client_original_files
				(doc_flow_out_client_id,original_file_id,new_file_id)
				VALUES (%d,%s,%s) ON CONFLICT DO NOTHING",
			$docFlowOutClientIdForDb,$origFileIdForDb,$newFileId
			));
		}
	}
	
	public function admin_enable_edit($pm){
		if($_SESSION[role_id]!="admin"){
			throw new Exception(self::ER_DOC_SENT);
		}
		
		$this->getDbLinkMaster()->query(sprintf(
			"UPDATE doc_flow_out_client
			SET
				admin_correction = TRUE,
				sent = FALSE
			WHERE id=%d",
			$this->getExtDbVal($pm,'id')
		));
	}
	

}
?>