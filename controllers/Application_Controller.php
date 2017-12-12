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



require_once('common/downloader.php');
require_once(ABSOLUTE_PATH.'functions/morpher.php');

require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class Application_Controller extends ControllerSQL{

	const APP_NOT_FOUND = 'Заявление не найдено!';
	const STORAGE_FILE_NOT_FOUND = 'Файл не найден!';
	const ER_MAKE_ZIP = 'Ошибка при создании архива!';
	const ALL_DOC_ZIP_FILE = 'all.zip';
	const ER_NO_FILES_FOR_ZIP = 'Проект не содержит файлов!';
	const APP_DIR_PREF = 'Заявление№';
	const APP_DIR_DELETED_FILES = 'Удаленные';
	const ER_NO_BOSS = 'Не определен руководитель организации!';

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('create_dt'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('expertise_type',',','pd,eng_survey,pd_eng_survey,pd_eng_survey_estim_cost'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('estim_cost_type',',','construction,reconstruction,capital_repairs'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('fund_source',',','fed_budget,own'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('applicant'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('customer'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('contractors'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('constr_name'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('constr_address'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('constr_technical_features'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('constr_construction_type',',','buildings,extended_constructions'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('constr_total_est_cost'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('constr_land_area'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('constr_total_area'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('filled_percent'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('office_id'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
			$f_params = array();
			$param = new FieldExtBool('set_sent'
			,$f_params);
		$pm->addParam($param);		
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Application_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('create_dt'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('expertise_type',',','pd,eng_survey,pd_eng_survey,pd_eng_survey_estim_cost'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('estim_cost_type',',','construction,reconstruction,capital_repairs'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('fund_source',',','fed_budget,own'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('applicant'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('customer'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('contractors'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('constr_name'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('constr_address'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('constr_technical_features'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('constr_construction_type',',','buildings,extended_constructions'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('constr_total_est_cost'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('constr_land_area'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('constr_total_area'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('filled_percent'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('office_id'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
			$f_params = array();
			$param = new FieldExtBool('set_sent'
			,$f_params);
		$pm->addParam($param);		
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Application_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Application_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtInt('browse_mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ApplicationDialog_Model');		

			
		$pm = new PublicMethod('get_print');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('inline',$opts));
	
				
	$opts=array();
	
		$opts['length']=100;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('templ',$opts));
	
			
		$this->addPublicMethod($pm);

			
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
		
		$this->setListModelId('ApplicationList_Model');
		
			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('id'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('ApplicationList_Model');

			
		$pm = new PublicMethod('get_client_list');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('remove_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
				
	$opts=array();
	
		$opts['length']=5;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('doc_type',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
				
	$opts=array();
	
		$opts['length']=5;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('doc_type',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('zip_all');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	private function item_as_string($xml,$qId){
		$item_str = '';
		foreach($xml->item as $item){
			$item_id = (string) $item->id;
			$files = '';
			if (isset($qId)){
				$this->getDbLink()->data_seek(0,$qId);
				while($file = $this->getDbLink()->fetch_array($qId)){
					if ($file['document_id']==$item_id){
						$files.= ($files=='')? '':',';
						$files.= sprintf('{"date_time":"%s","file_name":"%s","file_id":"%s","file_size":"%s","file_uploaded":true,"deleted":"%s","deleted_dt":"%s","file_path":"%s"}',
						$file['date_time'],
						$file['file_name'],
						$file['file_id'],
						$file['file_size'],
						($file['deleted']=='t')? TRUE:FALSE,
						$file['deleted_dt'],
						$file['file_path']
						);
					}
				}
			}
			$items = '';
			if ($item->item->count()){
				$items = $this->item_as_string($item,$qId);
			}
			$item_str.= ($item_str=='')? '':',';
			$item_str.= sprintf('{"item_id":"%s","item_descr":"%s","files":[%s],"items":[%s],"no_items":%s}',
			$item_id,
			(string) $item->descr,
			$files,
			$items,
			($items=='')? 'true':'false'
			);
		}	
		return $item_str;
	}

	public function get_object($pm){
		$files_pd_q_id = NULL;
		$files_dost_q_id = NULL;
		if (!is_null($pm->getParamValue("id"))){		
			$ar_obj = $this->getDbLink()->query_first(sprintf(
			"SELECT * FROM applications_dialog WHERE id=%d",
			$this->getExtDbVal($pm,'id')
			));
		
			if (!is_array($ar_obj) || !count($ar_obj)){
				throw new Exception("No app found!");
			
			}
			
			$deleted_cond = ($_SESSION['role_id']=='client')? "AND deleted=FALSE":"";
			
			$files_pd_q_id = $this->getDbLink()->query(sprintf(
				"SELECT *
				FROM application_pd_document_files
				WHERE application_id=%d %s
				ORDER BY document_id,file_name,deleted DESC",
			$this->getExtDbVal($pm,'id'),
			$deleted_cond
			));

			$files_dost_q_id = $this->getDbLink()->query(sprintf(
				"SELECT *
				FROM application_dost_document_files
				WHERE application_id=%d %s
				ORDER BY document_id,file_name,deleted DESC",
			$this->getExtDbVal($pm,'id'),
			$deleted_cond
			));
			
		}
		else{
			//new aplication
			$ar_obj = $this->getDbLink()->query_first(
			"SELECT
				NULL AS id,
				now() AS create_dt,
				NULL AS expertise_type,
				NULL AS estim_cost_type,
				NULL AS fund_source,
				NULL AS applicant,
				NULL AS customer,
				NULL AS contractors,
				NULL AS constr_name,
				NULL AS constr_address,
				NULL AS constr_technical_features,
				NULL AS constr_construction_type,
				NULL AS constr_total_est_cost,
				NULL AS constr_land_area,
				NULL AS constr_total_area,						
				NULL AS office_id,
				'filling' AS application_state,
				NULL AS application_state_dt,
				NULL AS application_state_end_date,
				'filling' AS application_state,		
				(SELECT doc_tmpl.content
				FROM application_pd_templates AS doc_tmpl
				ORDER BY doc_tmpl.date_time DESC
				LIMIT 1 
				) AS documents_pd,
				(SELECT doc_tmpl.content
				FROM application_dost_templates AS doc_tmpl
				ORDER BY doc_tmpl.date_time DESC
				LIMIT 1 
				) AS documents_dost				
				"
			);
			
		}
				
		$xml_pd = simplexml_load_string($ar_obj['documents_pd']);
		$documents_pd = '{"items":['.$this->item_as_string($xml_pd,$files_pd_q_id).']}';

		$xml_dost = simplexml_load_string($ar_obj['documents_dost']);
		$documents_dost = '{"items":['.$this->item_as_string($xml_dost,$files_dost_q_id).']}';
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ApplicationDialog_Model',
				'values'=>array(
					new Field('id',DT_STRING,array('value'=>$ar_obj['id'])),
					new Field('create_dt',DT_STRING,array('value'=>$ar_obj['create_dt'])),					
					new Field('expertise_type',DT_STRING,array('value'=>$ar_obj['expertise_type'])),
					new Field('estim_cost_type',DT_STRING,array('value'=>$ar_obj['estim_cost_type'])),
					new Field('fund_source',DT_STRING,array('value'=>$ar_obj['fund_source'])),
					new Field('applicant',DT_STRING,array('value'=>$ar_obj['applicant'])),
					new Field('customer',DT_STRING,array('value'=>$ar_obj['customer'])),
					new Field('contractors',DT_STRING,array('value'=>$ar_obj['contractors'])),
					new Field('constr_name',DT_STRING,array('value'=>$ar_obj['constr_name'])),
					new Field('constr_address',DT_STRING,array('value'=>$ar_obj['constr_address'])),
					new Field('constr_technical_features',DT_STRING,array('value'=>$ar_obj['constr_technical_features'])),
					new Field('constr_construction_type',DT_STRING,array('value'=>$ar_obj['constr_construction_type'])),
					new Field('constr_total_est_cost',DT_STRING,array('value'=>$ar_obj['constr_total_est_cost'])),
					new Field('constr_land_area',DT_STRING,array('value'=>$ar_obj['constr_land_area'])),
					new Field('constr_total_area',DT_STRING,array('value'=>$ar_obj['constr_total_area'])),
					new Field('application_state',DT_STRING,array('value'=>$ar_obj['application_state'])),
					new Field('application_state_dt',DT_DATETIMETZ,array('value'=>$ar_obj['application_state_dt'])),
					new Field('application_state_end_date',DT_DATE,array('value'=>$ar_obj['application_state_end_date'])),
					new Field('documents_pd',DT_STRING,array('value'=>$documents_pd)),
					new Field('documents_dost',DT_STRING,array('value'=>$documents_dost)),
					new Field('office_id',DT_STRING,array('value'=>$ar_obj['office_id'])),
					)
				)
			)
		);		
		
	}
	
	public static function removeAllZipFile($applicationId){
		if (file_exists($fl =
				FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
				$_SESSION['user_name'].DIRECTORY_SEPARATOR.
				self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
				self::ALL_DOC_ZIP_FILE)
		){
			unlink($fl);
		}	
	}

	public function insert($pm){
		$pm->setParamValue("user_id",$_SESSION['user_id']);
		$this->getDbLinkMaster()->query("BEGIN");
		try{			
			$inserted_id_ar = parent::insert($pm);
			$this->set_sent($pm, $inserted_id_ar['id']);
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
		
		return $inserted_id_ar;
	}
	
	public static function checkSentState($dbLink,$appId){
		$ar = $dbLink->query_first(sprintf("SELECT application_state_history_last(%d) AS state",$appId));
		self::checkApp($ar);
		if ($ar['state']=='sent'){
			throw new Exception('Документ отправлен на проверку. Операция невозможна.');
		}
	}
	
	public function update($pm){
		self::checkSentState($this->getDbLink(),$this->getExtDbVal($pm,'old_id'));
		
		$this->getDbLinkMaster()->query("BEGIN");
		try{			
			parent::update($pm);
			$this->set_sent($pm, $this->getExtDbVal($pm,'old_id'));
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}
	public function delete($pm){
		$ar = $this->getDbLink()->query_first(sprintf("SELECT application_state_history_last(%d) AS state",$this->getExtDbVal($pm,'id')));
		self::checkApp($ar);
		
		if ($ar['state']!='filling'){
			throw new Exception('Невозможно удалять отправленное заявление!');
		}
		
		parent::delete($pm);
	}
	
	public function get_client_list($pm){
		if (!isset($_SESSION['user_id'])){
			throw new Exception("No user id!");
		}
		$this->addNewModel(sprintf(
			"SELECT	*
			FROM applications_client_list(%d)",
		$_SESSION['user_id']
		),
		'ApplicationClientList_Model');
	}

	public static function fileTableOnDocType($docType){
		if ($docType=='pd'){
			return 'application_pd_document_files';
		}
		else if ($docType=='dost'){
			return 'application_dost_document_files';
		}		
		else{
			throw new Exception('Unknown document type!');
		}
	}
	
	private function get_file_table_on_pm($pm){
		return self::fileTableOnDocType($this->getExtVal($pm,'doc_type'));
	}
	
	public function remove_file($pm){
		self::checkSentState($this->getDbLink(),$this->getExtDbVal($pm,'application_id'));
		
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			//1) Mark in DB
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
				"UPDATE %s
				SET					
					deleted = TRUE,
					deleted_dt=now()
				WHERE file_id=%s
				RETURNING application_id,file_path,file_id,file_name",
			$this->get_file_table_on_pm($pm),
			$this->getExtDbVal($pm,'id')		
			));
		
			//2) Delete All Zip file
			self::removeAllZipFile($ar['application_id']);

			//3) Move file to deleted folder
			$dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
				$_SESSION['user_name'].DIRECTORY_SEPARATOR.
				self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				self::APP_DIR_DELETED_FILES;
			if (!file_exists($dest)){
				mkdir($dest,0777,TRUE);
			}
			rename(
				FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
				$_SESSION['user_name'].DIRECTORY_SEPARATOR.
				self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				$ar['file_path'].DIRECTORY_SEPARATOR.
				$ar['file_name'],
				$dest.DIRECTORY_SEPARATOR.$ar['file_id']
			);
			
			$this->getDbLinkMaster()->query("COMMIT");
			
			
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}

	public function get_file($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				application_id,
				file_id,
				file_name,
				file_path,
				deleted
			FROM %s
			WHERE file_id=%s",
		$this->get_file_table_on_pm($pm),
		$this->getExtDbVal($pm,'id')
		));
		if ($ar['deleted']=='t'){
			$fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
				$_SESSION['user_name'].DIRECTORY_SEPARATOR.
				self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				self::APP_DIR_DELETED_FILES.DIRECTORY_SEPARATOR.
				$ar['file_id'];		
		}
		else{
			$fl = 	FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
				$_SESSION['user_name'].DIRECTORY_SEPARATOR.
				self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				$ar['file_path'].DIRECTORY_SEPARATOR.
				$ar['file_name'];		
		}
		if (!file_exists($fl)){
			throw new Exception(self::STORAGE_FILE_NOT_FOUND.' '.$fl);
		}
		
		$mime = getMimeTypeOnExt($ar['file_name']);
		ob_clean();
		downloadFile($fl, $mime,'attachment;',$ar['file_name']);
		return TRUE;
	}
	
	public function zip_all($pm){
		$dir_zip =	FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
				$_SESSION['user_name'].DIRECTORY_SEPARATOR.
				self::APP_DIR_PREF.$this->getExtVal($pm,'application_id');
		if (!file_exists($file_zip = $dir_zip.DIRECTORY_SEPARATOR.self::ALL_DOC_ZIP_FILE)){
			//make zip
			$zip = new ZipArchive();
			if ($zip->open($file_zip, ZIPARCHIVE::CREATE)!==TRUE) {
				throw new Exception(self::ER_MAKE_ZIP);
			}

			$cnt = 0;
			
			$qid = $this->getDbLink()->query(sprintf(
				"SELECT
					file_id,
					file_name,
					file_path
				FROM application_pd_document_files
				WHERE application_id=%s",
				$this->getExtDbVal($pm,'application_id')
			));			
			while($file = $this->getDbLink()->fetch_array($qid)){
				if (file_exists($file_doc = $dir_zip.DIRECTORY_SEPARATOR. $file['file_path'].DIRECTORY_SEPARATOR. $file['file_name'])){					
					$zip->addFile($file_doc, $file['file_path'].DIRECTORY_SEPARATOR.$file['file_name']);
					$cnt++;				
				}
			}
			
			$qid = $this->getDbLink()->query(sprintf(
				"SELECT
					file_id,
					file_name,
					file_path
				FROM application_dost_document_files
				WHERE application_id=%s",
				$this->getExtDbVal($pm,'application_id')
			));			
			while($file = $this->getDbLink()->fetch_array($qid)){
				if (file_exists($file_doc = $dir_zip.DIRECTORY_SEPARATOR. $file['file_path'].DIRECTORY_SEPARATOR. $file['file_name'])){					
					$zip->addFile($file_doc, $file['file_path'].DIRECTORY_SEPARATOR.$file['file_name']);
					$cnt++;				
				}
			}
			
			if (!$cnt){
				throw new Exception(self::ER_NO_FILES_FOR_ZIP);
			}
			$zip->close();
			
		}
		if (!file_exists($file_zip)){
			throw new Exception(self::ER_MAKE_ZIP);
		}
		
		ob_clean();
		downloadFile($file_zip, 'application/zip','attachment;',sprintf('ДокументацияПоЗаявлению№%d.zip',$this->getExtVal($pm,'application_id')));
		return TRUE;
		
	}

	private function set_state($id,$state){
		$this->getDbLinkMaster()->query(sprintf(
			"INSERT INTO application_state_history
			(application_id,state)
			VALUES (%d,'%s')",
			$id,$state
		));
		
	}
	
	private function set_sent($pm,$appId){
		$set_sent = $pm->getParamValue('set_sent');
		if (isset($set_sent) && $set_sent){
			$this->set_state($appId,'sent');
		}
	}

	private function get_person_data_on_type(&$jsonModel,$personType,&$personName,&$personPost){
		foreach($jsonModel['rows'] as $row){
			if ($row['fields']['person_type']==$personType){
				$personName = trim($row['fields']['name']);
				$personPost = trim($row['fields']['post']);
				break;
			}
		}
	}

	private static function checkApp(&$qAr){
		if (!is_array($qAr) || !count($qAr)){
			throw new Exception(self::APP_NOT_FOUND);
		}	
	}

	public function get_print($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT	*
			FROM applications_print
			WHERE id=%d %s",
		$this->getExtDbVal($pm,'id'),
		($_SESSION['role_id']=='client')? (' AND user_id='.$_SESSION['user_id']):''
		));
		self::checkApp($ar);
		
		$boss_name = '';
		$boss_post = '';
		$resp_m = json_decode($ar['office_responsable_persons'],TRUE);		
		$this->get_person_data_on_type($resp_m,'boss',$boss_name,$boss_post);
		if (!strlen($boss_name)){
			throw new Exception(self::ER_NO_BOSS);
		}
		$boss_decl = declension($this->getDbLink(),$boss_name);
		$ar['boss_name_dat'] = $boss_decl['Д'];		
		$sep = strpos($ar['boss_name_dat'],' ');
		if ($sep>=0){
			$ar['boss_name_dat'] = substr($ar['boss_name_dat'],0,$sep);
		}
		$n2 = (strlen($boss_decl['ФИО']->И))? (mb_substr($boss_decl['ФИО']->И,0,1,'UTF-8').'.'):'';
		$n3 = (strlen($boss_decl['ФИО']->О))? (mb_substr($boss_decl['ФИО']->О,0,1,'UTF-8').'.'):'';
		$n23 = (strlen($n2) || strlen($n3))? (' '.$n2.$n3):'';
		$ar['boss_name_dat'] = $ar['boss_name_dat'].$n23;

		$boss_post_decl = declension($this->getDbLink(),$boss_post);
		$ar['boss_post_dat'] = $boss_post_decl['Д'];
		
		$office_decl = declension($this->getDbLink(),$ar['office_client_name_full']);
		$ar['office_rod'] = $office_decl['Р'];
		
		//technical features
		$featrures_m = json_decode($ar['constr_technical_features'],TRUE);
		$ar['constr_technical_features'] = '';
		foreach($featrures_m['rows'] as $row){
			$ar['constr_technical_features'].=sprintf('<feature name="%s" value="%s"/>',
				$row['fields']['name'],
				$row['fields']['value']			
			);
		}

		//applicant
		$applicant_m = json_decode($ar['applicant'],TRUE);
		$inn = $applicant_m['inn'].( (strlen($applicant_m['kpp']))? ('/'.$applicant_m['kpp']):'' );
		$person_head = json_decode($applicant_m['responsable_person_head'],TRUE);
		if (strlen($applicant_m['base_document_for_contract'])){
			$base_document_for_contract = declension($this->getDbLink(),$applicant_m['base_document_for_contract'])['Р'];
		}
		else{
			$base_document_for_contract = '';
		}
		if (strlen($person_head['name'])){
			$person_head_name_rod = declension($this->getDbLink(),$person_head['name'])['Р'];
		}
		else{
			$person_head_name_rod = '';
		}		
		if (strlen($person_head['post'])){
			$person_head_post_rod = declension($this->getDbLink(),$person_head['post'])['Р'];
		}
		else{
			$person_head_post_rod = '';
		}				
		$ar['applicant'] =
			sprintf('<field name="%s" value="%s"/>',$applicant_m['name_full']).
			sprintf('<field id="Наименование">%s</field>',$applicant_m['name_full']).
			sprintf('<field id="ИНН/КПП">%s</field>',$inn).
			sprintf('<field id="Юридический адрес">%s</field>',$ar['applicant_legal_address']).
			sprintf('<field id="Почтовый адрес">%s</field>',$ar['applicant_post_address']).
			sprintf('<field id="Банк">%s</field>',$ar['applicant_bank']).			
			sprintf('<field id="ФИО руководителя">%s</field>',$person_head['name']).
			sprintf('<field id="Должность руководителя">%s</field>',$person_head['post']).
			sprintf('<field id="Действует на основании">%s</field>',$base_document_for_contract).
			sprintf('<person_head_name_rod>%s</person_head_name_rod>',$person_head_name_rod).
			sprintf('<person_head_post_rod>%s</person_head_post_rod>',$person_head_post_rod)
		;

		//customer
		$customer_m = json_decode($ar['customer'],TRUE);
		$inn = $customer_m['inn'].( (strlen($customer_m['kpp']))? ('/'.$customer_m['kpp']):'' );
		$person_head = json_decode($customer_m['responsable_person_head'],TRUE);
		if (strlen($customer_m['base_document_for_contract'])){
			$base_document_for_contract = declension($this->getDbLink(),$customer_m['base_document_for_contract'])['Р'];
		}
		else{
			$base_document_for_contract = '';
		}
		if (strlen($person_head['name'])){
			$person_head_name_rod = declension($this->getDbLink(),$person_head['name'])['Р'];
		}
		else{
			$person_head_name_rod = '';
		}		
		if (strlen($person_head['post'])){
			$person_head_post_rod = declension($this->getDbLink(),$person_head['post'])['Р'];
		}
		else{
			$person_head_post_rod = '';
		}								
		$ar['customer'] =
			sprintf('<field name="%s" value="%s"/>',$customer_m['name_full']).
			sprintf('<field id="Наименование">%s</field>',$customer_m['name_full']).
			sprintf('<field id="ИНН/КПП">%s</field>',$inn).
			sprintf('<field id="Юридический адрес">%s</field>',$ar['customer_legal_address']).
			sprintf('<field id="Почтовый адрес">%s</field>',$ar['customer_post_address']).
			sprintf('<field id="Банк">%s</field>',$ar['customer_bank']).		
			sprintf('<field id="ФИО руководителя">%s</field>',$person_head['name']).
			sprintf('<field id="Должность руководителя">%s</field>',$person_head['post']).
			sprintf('<field id="Действует на основании">%s</field>',$base_document_for_contract).
			sprintf('<person_head_name_rod>%s</person_head_name_rod>',$person_head_name_rod).
			sprintf('<person_head_post_rod>%s</person_head_post_rod>',$person_head_post_rod)			
		;
		
		//contractors
		$contractors = json_decode($ar['contractors'],TRUE);
		$ar['contractors'] = '';
		foreach($contractors as $contractor){
			$contractor_m = $contractor['contractor'];
			$inn = $contractor_m['inn'].( (strlen($contractor_m['kpp']))? ('/'.$contractor_m['kpp']):'' );
			$person_head = json_decode($contractor_m['responsable_person_head'],TRUE);
			if (strlen($contractor_m['base_document_for_contract'])){
				$base_document_for_contract = declension($this->getDbLink(),$contractor_m['base_document_for_contract'])['Р'];
			}
			else{
				$base_document_for_contract = '';
			}		
			if (strlen($person_head['name'])){
				$person_head_name_rod = declension($this->getDbLink(),$person_head['name'])['Р'];
			}
			else{
				$person_head_name_rod = '';
			}		
			if (strlen($person_head['post'])){
				$person_head_post_rod = declension($this->getDbLink(),$person_head['post'])['Р'];
			}
			else{
				$person_head_post_rod = '';
			}								
			
			$ar['contractors'].=
			'<contractor>'.
				sprintf('<field id="Наименование">%s</field>',$contractor_m['name_full']).
				sprintf('<field id="ИНН/КПП">%s</field>',$inn).
				sprintf('<field id="Юридический адрес">%s</field>',$contractor['legal_address']).
				sprintf('<field id="Почтовый адрес">%s</field>',$contractor['post_address']).
				sprintf('<field id="Банк">%s</field>',$contractor['bank']).				
				sprintf('<field id="ФИО руководителя">%s</field>',$person_head['name']).
				sprintf('<field id="Должность руководителя">%s</field>',$person_head['post']).				
				sprintf('<field id="Действует на основании">%s</field>',$base_document_for_contract).
				sprintf('<person_head_name_rod>%s</person_head_name_rod>',$person_head_name_rod).
				sprintf('<person_head_post_rod>%s</person_head_post_rod>',$person_head_post_rod).				
			'</contractor>'
			;		
		}		
		
		//files
		//PD
		$files_q_id = $this->getDbLink()->query(sprintf(
			"SELECT
				f.file_name,
				f.file_path
			FROM application_pd_document_files AS f
			WHERE f.application_id=%d AND f.deleted=FALSE %s
			ORDER BY f.file_path,f.file_name",
		$this->getExtDbVal($pm,'id'),
		($_SESSION['role_id']=='client')? (' AND (SELECT t.user_id FROM applications t WHERE t.id=f.application_id)='.$_SESSION['user_id']):''
		));
		$ar['documents_pd'] = '';
		while($file = $this->getDbLink()->fetch_array($files_q_id)){
			if ($ar['documents_pd']==''){
				$ar['documents_pd'] = '<files>';
			}
			$path_ar = explode('/',$file['file_path']);
			$sec1 = (count($path_ar)>=1)? $path_ar[0]:'';
			$sec2 = (count($path_ar)>=2)? $path_ar[1]:'';
			$ar['documents_pd'].= sprintf('<file section1="%s" section2="%s" name="%s"/>',$sec1,$sec2,$file['file_name']);
		}
		if ($ar['documents_pd']!=''){		
			$ar['documents_pd'].= '</files>';
		}
		
		//Dost
		if ($ar['d.expertise_type']!='pd'){
			$files_q_id = $this->getDbLink()->query(sprintf(
				"SELECT
					f.file_name,
					f.file_path
				FROM application_dost_document_files AS f
				WHERE f.application_id=%d AND f.deleted=FALSE %s
				ORDER BY f.file_path,f.file_name",
			$this->getExtDbVal($pm,'id'),
			($_SESSION['role_id']=='client')? (' AND (SELECT t.user_id FROM applications t WHERE t.id=f.application_id)='.$_SESSION['user_id']):''
			));
			$ar['documents_dost'] = '';
			while($file = $this->getDbLink()->fetch_array($files_q_id)){
				if ($ar['documents_dost']==''){
					$ar['documents_dost'] = '<files>';
				}			
				$path_ar = explode('/',$file['file_path']);
				$sec1 = (count($path_ar)>=1)? $path_ar[0]:'';
				$sec2 = (count($path_ar)>=2)? $path_ar[1]:'';
				$ar['documents_dost'].= sprintf('<file section1="%s" section2="%s" name="%s"/>',$sec1,$sec2,$file['file_name']);
			}		
			if ($ar['documents_dost']!=''){		
				$ar['documents_dost'].= '</files>';
			}			
		}
				
		//*************************************************
		$m_fields = array();
		foreach($ar as $f_id=>$f_val){
			array_push(
				$m_fields,
				new Field($f_id,DT_STRING,array('value'=>$f_val))
			);
		}
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ApplicationPrint_Model',
				'values'=>$m_fields
			)
		));
		
	}
	

}
?>