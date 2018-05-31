<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Application'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once('common/downloader.php');
require_once(ABSOLUTE_PATH.'functions/Morpher.php');

require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

require_once('common/file_func.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	
	const ALL_DOC_ZIP_FILE = 'all.zip';
	const SIG_EXT = '.sig';
	
	const APP_DIR_PREF = 'Заявление№';
	const APP_DIR_DELETED_FILES = 'Удаленные';
	const APP_PRINT_PREF = 'Заявления';
	
	const ER_STORAGE_FILE_NOT_FOUND = 'Файл не найден!';
	const ER_APP_NOT_FOUND = 'Заявление не найдено!';
	const ER_NO_FILES_FOR_ZIP = 'Проект не содержит файлов!';	
	const ER_MAKE_ZIP = 'Ошибка при создании архива!';
	const ER_NO_BOSS = 'Не определен руководитель НАШЕГО офиса!';
	const ER_OTHER_USER_APP = 'Wrong application!';
	const ER_APP_SENT = 'Невозможно удалять отправленное заявление!';
	const ER_NO_SIG = 'Для файла нет ЭЦП!';
	const ER_DOC_SENT = 'Документ отправлен на проверку. Операция невозможна.';

	const ER_PRINT_FILE_CNT = 'Нет файла ЭЦП с заявлением по ';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	private function copy_print_file($appId,$id,&amp;$fileParams,&amp;$files){
		$ER_PRINT_FILE_CNT_END = [
			'app_print_expertise'=>' экспертизе',
			'app_print_cost_eval'=>' достоверности',
			'app_print_modification'=>' модификации',
			'app_print_modification'=>' аудиту',
			'auth_letter_file'=>' доверенности'
			];
	
	
		if (count($files['name'])!=2){
			throw new Exception(self::ER_PRINT_FILE_CNT.$ER_PRINT_FILE_CNT_END[$id].'.');
		}
		$dir = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$appId.DIRECTORY_SEPARATOR.
			self::dirNameOnDocType($id);
		mkdir($dir,0777,TRUE);
		
		//data
		if (!move_uploaded_file($files['tmp_name'][0],$dir.DIRECTORY_SEPARATOR.$files['name'][0])){
			throw new Exception('Ошибка загрузки заявления о '.$ER_PRINT_FILE_CNT_END[$id].'.');
		}
		
		//sig
		if (!move_uploaded_file($files['tmp_name'][1],$dir.DIRECTORY_SEPARATOR.$files['name'][1])){
			throw new Exception('Ошибка загрузки подписи заявления о '.$ER_PRINT_FILE_CNT_END[$id].'.');
		}
	
		$fileParams[$id] = sprintf(
			'[{"name":"%s","id":"%s","size":"%s","file_signed":"true"}]',
			$files['name'][0],
			md5(uniqid()),
			$files['size'][0]
		);
	
	}

	private function upload_prints($appId,&amp;$fileParams){
		$res = FALSE;
		//throw new Exception(var_dump($_FILES['app_print_expertise'],TRUE));
		
		if (isset($_FILES['app_print_expertise_files'])){
			$this->copy_print_file($appId,'app_print_expertise',$fileParams,$_FILES['app_print_expertise_files']);
			$res = TRUE;
		}
		if (isset($_FILES['app_print_cost_eval_files'])){
			$this->copy_print_file($appId,'app_print_cost_eval',$fileParams,$_FILES['app_print_cost_eval_files']);
			$res = TRUE;
		}
		if (isset($_FILES['app_print_modification_files'])){
			$this->copy_print_file($appId,'app_print_modification',$fileParams,$_FILES['app_print_modification_files']);
			$res = TRUE;
		}
		if (isset($_FILES['app_print_audit_files'])){
			$this->copy_print_file($appId,'app_print_audit',$fileParams,$_FILES['app_print_audit_files']);
			$res = TRUE;
		}
		if (isset($_FILES['auth_letter_files'])){
			$this->copy_print_file($appId,'auth_letter_file',$fileParams,$_FILES['auth_letter_files']);
			$res = TRUE;
		}
		
		if ($res){
			self::removeAllZipFile($appId);
		}
		
		return $res;
	}

	public static function addDocumentFiles(&amp;$obj,$dbLink,$documentType,$qId){
		foreach($obj as $row){
			$item = $row->fields;
			$item_id = (string) $item->id;
			$files = [];
			if (isset($qId)){
				$dbLink->data_seek(0,$qId);
				while($file = $dbLink->fetch_array($qId)){
					if ($file['document_type']==$documentType &amp;&amp; $file['document_id']==$item_id){
						$file_o = new stdClass();
						$file_o->date_time	= $file['date_time'];
						$file_o->file_name	= $file['file_name'];
						$file_o->file_id	= $file['file_id'];
						$file_o->file_size	= $file['file_size'];
						$file_o->deleted	= ($file['deleted']=='t')? TRUE:FALSE;
						$file_o->deleted_dt	= $file['deleted_dt'];
						$file_o->file_path	= $file['file_path'];
						$file_o->file_signed	= ($file['file_signed']=='t')? TRUE:FALSE;
						$file_o->file_uploaded	= TRUE;
						array_push($files,$file_o);
					}
				}
			}			
			$row->files = $files;
			if (!isset($row->items) || !is_array($row->items) || !count($row->items)){
				$row->items = NULL;
				$row->no_items = TRUE;
			}
			else{
				$row->no_items = FALSE;
				self::addDocumentFiles($row->items,$dbLink,$documentType,$qId);				
			}
		}	
	}

	public function get_print_file($appId,$docType,$isSig,&amp;$fullPath,&amp;$fileName){
		//Клиент видит только СВОЕ!!!
		$client_q_t = '';
		if ($_SESSION['role_id']=='client'){
			$client_q_t = ' AND user_id='.$_SESSION['user_id'];
		}
	
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT %s AS file_info FROM applications WHERE id=%d".$client_q_t,
			$docType,
			$appId
		));
		if (!is_array($ar) || !count($ar)){
			throw new Exception(self::ER_APP_NOT_FOUND);
		}
		//throw new Exception($ar['file_info']);
		$f = json_decode($ar['file_info']);
		if (count($f) &amp;&amp; $f[0]->name){
			$fileName = $f[0]->name. ($isSig? '.sig':'');
			$rel_fl = self::APP_DIR_PREF.$appId.DIRECTORY_SEPARATOR.
				self::dirNameOnDocType($docType).DIRECTORY_SEPARATOR.
				$fileName;
			return (
				file_exists($fullPath=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)
				|| ( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($fullPath=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl) )
			);
		}		
	}

	public function delete_print($appId,$docType){
		$state = self::checkSentState($this->getDbLink(),$appId,TRUE);
		if ($_SESSION['role_id']!='admin' &amp;&amp; $state!='filling'){
			throw new Exception(ER_DOC_SENT);
		}
		$fullPath = '';
		$fileName = '';
		if ($this->get_print_file($appId,$docType,FALSE,$fullPath,$fileName)){
			try{
				$this->getDbLinkMaster()->query("BEGIN");
				$this->getDbLinkMaster()->query(sprintf("UPDATE applications SET %s=NULL WHERE id=%d",$docType,$appId));
				
				unlink($fullPath);
				if(file_exists($fullPath.'.sig')){
					unlink($fullPath.'.sig');
				}
				
				/*	
				if ($this->get_print_file($appId,$docType,TRUE,$fullPath,$fileName)){
					unlink($fullPath);	
				}
				*/
				self::removeAllZipFile($appId);
				
				$this->getDbLinkMaster()->query("COMMIT");
			}
			catch(Exception $e){
				$this->getDbLinkMaster()->query("ROLLBACK");
				throw $e;
			}
		}
	}
	public function download_print($appId,$docType,$isSig){
		$fullPath = '';
		$fileName = '';
		if ($this->get_print_file($appId,$docType,$isSig,$fullPath,$fileName)){
			$mime = getMimeTypeOnExt($fl);
			ob_clean();
			downloadFile($fullPath, $mime,'attachment;',$fileName);
			return TRUE;
		}
	}

	public function download_app_print_expertise($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_expertise',FALSE);
	}
	public function download_app_print_expertise_sig($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_expertise',TRUE);
	}	
	public function delete_app_print_expertise($pm){
		return $this->delete_print($this->getExtDbVal($pm,'id'),'app_print_expertise');
	}
	
	public function download_app_print_modification($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_modification',FALSE);
	}
	public function download_app_print_modification_sig($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_modification',TRUE);
	}
	public function delete_app_print_modification($pm){
		return $this->delete_print($this->getExtDbVal($pm,'id'),'app_print_modification');
	}
	
	public function download_app_print_audit($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_audit',FALSE);
	}
	public function download_app_print_audit_sig($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_audit',TRUE);
	}
	public function delete_app_print_audit($pm){
		return $this->delete_print($this->getExtDbVal($pm,'id'),'app_print_audit');
	}
	
	public function download_app_print_cost_eval($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_cost_eval',FALSE);
	}
	public function download_app_print_cost_eval_sig($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_cost_eval',TRUE);
	}
	public function delete_app_print_cost_eval($pm){
		return $this->delete_print($this->getExtDbVal($pm,'id'),'app_print_cost_eval');
	}
	public function download_auth_letter_file($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'auth_letter_file',FALSE);
	}
	public function download_auth_letter_file_sig($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'auth_letter_file',TRUE);
	}
	public function delete_auth_letter_file($pm){
		return $this->delete_print($this->getExtDbVal($pm,'id'),'auth_letter_file');
	}

	public function get_object($pm){
		if (!is_null($pm->getParamValue("id"))){		
		
			//Клиент видит только СВОЕ!!!
			$client_q_t = '';
			if ($_SESSION['role_id']=='client'){
				$client_q_t = ' AND user_id='.$_SESSION['user_id'];
			}
			
			$ar_obj = $this->getDbLink()->query_first(sprintf(
			"SELECT * FROM applications_dialog WHERE id=%d".$client_q_t,
			$this->getExtDbVal($pm,'id')
			));
		
			if (!is_array($ar_obj) || !count($ar_obj)){
				throw new Exception("No app found!");
			
			}
			
			$deleted_cond = ($_SESSION['role_id']=='client')? "AND deleted=FALSE":"";
			
			//Если вернули - никаких заявлений
			/*
			if ($ar_obj['application_state']=='returned'){
				$ar_obj['app_print_expertise'] = NULL;
				$ar_obj['app_print_cost_eval'] = NULL;
				$ar_obj['app_print_modification'] = NULL;
				$ar_obj['app_print_audit'] = NULL;
			}
			*/
			
			//On copy - no files, no links!
			if ($pm->getParamValue('mode')!='copy'){
				$files_q_id = $this->getDbLink()->query(sprintf(
					"SELECT *
					FROM application_document_files
					WHERE application_id=%d %s
					ORDER BY document_type,document_id,file_name,deleted_dt ASC NULLS LAST",
				$this->getExtDbVal($pm,'id'),
				$deleted_cond
				));			
			}
			else{
				//Copy mode!!!
				$ar_obj['document_exists'] = 'f';
				$ar_obj['documents'] = null;
				$ar_obj['base_applications_ref'] = null;
				$ar_obj['derived_applications_ref'] = null;
			}
		}
		else{
			//new aplication
			$ar_obj = $this->getDbLink()->query_first(
			"SELECT
				NULL AS id,
				now() AS create_dt,
				NULL AS expertise_type,
				FALSE AS cost_eval_validity,
				FALSE AS cost_eval_validity_simult,				
				NULL AS fund_sources_ref,
				NULL AS construction_types_ref,
				NULL AS applicant,
				NULL AS customer,
				NULL AS contractors,
				NULL AS developer,
				NULL AS constr_name,
				NULL AS constr_address,
				NULL AS constr_technical_features,
				NULL AS constr_construction_type,
				NULL AS total_cost_eval,
				NULL AS limit_cost_eval,
				NULL AS offices_ref,
				NULL AS build_types_ref,
				FALSE AS modification,
				FALSE AS audit,
				NULL AS modif_primary_application,
				'filling' AS application_state,
				NULL AS application_state_dt,
				NULL AS application_state_end_date,
				'filling' AS application_state,		
				NULL AS documents,
				NULL AS primary_application,
				NULL AS select_descr,
				NULL AS app_print_expertise,
				NULL AS app_print_cost_eval,
				NULL AS app_print_modification,
				NULL AS app_print_audit,
				NULL AS base_applications_ref,
				NULL AS derived_applications_ref,
				NULL as users_ref,
				NULL as auth_letter,
				NULL as auth_letter_file,
				NULL as pd_usage_info
				"
			);
		}
		
		if ( is_null($pm->getParamValue("id")) || $ar_obj['document_exists']!='t' ){
			$this->addNewModel("SELECT * FROM document_templates_all_json_list",'DocumentTemplateAllList_Model');			
		}
		
		$documents = NULL;
		if ($ar_obj['documents']){
			$documents_json = json_decode($ar_obj['documents']);
			foreach($documents_json as $doc){
				self::addDocumentFiles($doc->document,$this->getDbLink(),$doc->document_type,$files_q_id);
			}
			$documents = json_encode($documents_json);
		}
				
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ApplicationDialog_Model',
				'values'=>array(
					new Field('id',DT_STRING,array('value'=>$ar_obj['id'])),
					new Field('create_dt',DT_STRING,array('value'=>$ar_obj['create_dt'])),					
					new Field('expertise_type',DT_STRING,array('value'=>$ar_obj['expertise_type'])),
					new Field('cost_eval_validity',DT_STRING,array('value'=>$ar_obj['cost_eval_validity'])),
					new Field('cost_eval_validity_simult',DT_STRING,array('value'=>$ar_obj['cost_eval_validity_simult'])),
					new Field('fund_sources_ref',DT_STRING,array('value'=>$ar_obj['fund_sources_ref'])),
					new Field('construction_types_ref',DT_STRING,array('value'=>$ar_obj['construction_types_ref'])),
					new Field('applicant',DT_STRING,array('value'=>$ar_obj['applicant'])),
					new Field('customer',DT_STRING,array('value'=>$ar_obj['customer'])),
					new Field('contractors',DT_STRING,array('value'=>$ar_obj['contractors'])),
					new Field('constr_name',DT_STRING,array('value'=>$ar_obj['constr_name'])),
					new Field('constr_address',DT_STRING,array('value'=>$ar_obj['constr_address'])),
					new Field('constr_technical_features',DT_STRING,array('value'=>$ar_obj['constr_technical_features'])),
					new Field('total_cost_eval',DT_STRING,array('value'=>$ar_obj['total_cost_eval'])),
					new Field('limit_cost_eval',DT_STRING,array('value'=>$ar_obj['limit_cost_eval'])),
					new Field('application_state',DT_STRING,array('value'=>$ar_obj['application_state'])),
					new Field('application_state_dt',DT_DATETIMETZ,array('value'=>$ar_obj['application_state_dt'])),
					new Field('application_state_end_date',DT_DATE,array('value'=>$ar_obj['application_state_end_date'])),
					new Field('documents',DT_STRING,array('value'=>$documents)),
					new Field('offices_ref',DT_STRING,array('value'=>$ar_obj['offices_ref'])),
					new Field('primary_application',DT_STRING,array('value'=>$ar_obj['primary_application'])),
					new Field('build_types_ref',DT_STRING,array('value'=>$ar_obj['build_types_ref'])),
					new Field('developer',DT_STRING,array('value'=>$ar_obj['developer'])),
					new Field('modification',DT_STRING,array('value'=>$ar_obj['modification'])),
					new Field('audit',DT_STRING,array('value'=>$ar_obj['audit'])),
					new Field('modif_primary_application',DT_STRING,array('value'=>$ar_obj['modif_primary_application'])),
					new Field('select_descr',DT_STRING,array('value'=>$ar_obj['select_descr'])),
					new Field('app_print_expertise',DT_STRING,array('value'=>$ar_obj['app_print_expertise'])),
					new Field('app_print_modification',DT_STRING,array('value'=>$ar_obj['app_print_modification'])),
					new Field('app_print_audit',DT_STRING,array('value'=>$ar_obj['app_print_audit'])),
					new Field('app_print_cost_eval',DT_STRING,array('value'=>$ar_obj['app_print_cost_eval'])),
					new Field('base_applications_ref',DT_STRING,array('value'=>$ar_obj['base_applications_ref'])),
					new Field('derived_applications_ref',DT_STRING,array('value'=>$ar_obj['derived_applications_ref'])),
					new Field('users_ref',DT_STRING,array('value'=>$ar_obj['users_ref'])),
					new Field('auth_letter',DT_STRING,array('value'=>$ar_obj['auth_letter'])),
					new Field('auth_letter_file',DT_STRING,array('value'=>$ar_obj['auth_letter_file'])),
					new Field('pd_usage_info',DT_STRING,array('value'=>$ar_obj['pd_usage_info']))
					)
				)
			)
		);		
		
		if (isset($_REQUEST[PARAM_TEMPLATE]) &amp;&amp; !is_null($pm->getParamValue("id"))){
			//extra models
			$this->addNewModel(
				sprintf("SELECT * FROM doc_flow_out_client_list WHERE application_id=%d".$client_q_t,
					$this->getExtDbVal($pm,'id')
				),
				'DocFlowOutClientList_Model'
			);
			$this->addNewModel(
				sprintf("SELECT * FROM doc_flow_in_client_list WHERE application_id=%d".$client_q_t,
					$this->getExtDbVal($pm,'id')
				),
				'DocFlowInClientList_Model'
			);			
		}
	}
	
	public static function dirNameOnDocType($docType){
		if ($docType=='pd'){
			$res = 'ПД';
		}
		else if ($docType=='eng_survey'){
			$res = 'РИИ';
		}
		else if ($docType=='cost_eval_validity'){
			$res = 'Достоверность';
		}
		else if ($docType=='modification'){
			$res = 'Модификация';
		}		
		else if ($docType=='audit'){
			$res = 'Аудит';
		}				
		else if ($docType=='app_print_expertise'){
			$res = self::APP_PRINT_PREF.DIRECTORY_SEPARATOR. 'Экспертиза';
		}				
		else if ($docType=='app_print_cost_eval'){
			$res = self::APP_PRINT_PREF.DIRECTORY_SEPARATOR. 'Достоверность';
		}				
		else if ($docType=='app_print_modification'){
			$res = self::APP_PRINT_PREF.DIRECTORY_SEPARATOR.'Модификация';
		}				
		else if ($docType=='app_print_audit'){
			$res = self::APP_PRINT_PREF.DIRECTORY_SEPARATOR.'Аудит';
		}
		else if ($docType=='auth_letter_file'){
			$res = 'Доверенность';
		}				
		else{
			$res = 'НеизвестныйТип';
		}
		return $res;
	}
	
	public static function delFileFromStorage($relFile){
		if (file_exists($fl =FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relFile)
		){
			unlink($fl);
		}	
		if ( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp;  file_exists($fl =FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relFile)
		){
			unlink($fl);
		}	
		
	}
	
	public static function removeAllZipFile($applicationId){
		self::delFileFromStorage(
			self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
			self::ALL_DOC_ZIP_FILE
		);
	}
	public static function removePDFFile($applicationId){
		self::delFileFromStorage(
			self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
			'Application.pdf'
		);

		self::delFileFromStorage(
			self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
			'ApplicationCostEvalValidity.pdf'
		);
		self::delFileFromStorage(
			self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
			'ApplicationModification.pdf'
		);
		self::delFileFromStorage(
			self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
			'ApplicationAudit.pdf'
		);
		
	}

	public function insert($pm){		
		$pm->setParamValue("user_id",$_SESSION['user_id']);
		$this->getDbLinkMaster()->query("BEGIN");
		try{			
			//$inserted_id_ar = parent::insert($pm);
			$model_name = $this->getInsertModelId();
			$model = new $model_name($this->getDbLinkMaster());
			$this->methodParamsToModel($pm,$model);
			$q = $model->getInsertQuery(TRUE).',expertise_type,cost_eval_validity,modification,audit';
			$inserted_id_ar = $this->getDbLinkMaster()->query_first($q);
			
			$state = NULL;
			$set_sent = $pm->getParamValue('set_sent');
			if (isset($set_sent) &amp;&amp; $set_sent){
				$state = 'sent';
			}
			else{
				$state = 'filling';
			}			
			
			$file_params = [];
			if ($this->upload_prints($inserted_id_ar['id'],$file_params)){
				//need updating
				$cols = '';
				foreach($file_params as $k=>$v){
					$cols.= ($cols=='')? '':', ';
					$cols.= $k.'='."'".$v."'";
				}			
				
				$this->getDbLinkMaster()->query(sprintf(
					"UPDATE applications
					SET %s
					WHERE id=%d",
				$cols,
				$inserted_id_ar['id']
				));
			}
			$resAr = [];
			$this->set_state($inserted_id_ar['id'],$state,$inserted_id_ar,$resAr);
			if ( $state=='sent' &amp;&amp; isset($resAr['new_app_id']) ){
				$this->move_files_to_new_app($resAr);
			}
			
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
		$fields = [new Field('id',DT_STRING,array('value'=>$inserted_id_ar['id']))];
		$this->addModel(new ModelVars(
			array('id'=>'InsertedId_Model',
				'values'=>$fields)
			)
		);
		
		return $inserted_id_ar;
	}
	
	public static function checkSentState($dbLink,$appId,$checkUser){
		$q = sprintf("SELECT application_processes_last(%d) AS state",$appId);
		$do_check = ($_SESSION['role_id']=='client' &amp;&amp; $checkUser);
		if ($do_check){
			$q.=sprintf(",(SELECT ap.user_id=%d FROM applications AS ap WHERE ap.id=%d) AS user_check_passed",
				$_SESSION['user_id'],$appId
			);
		}
//throw new Exception($q);
		$ar = $dbLink->query_first($q);
		self::checkApp($ar);
		
		if ($do_check &amp;&amp; $ar['user_check_passed']!='t'){
			throw new Exception(self::ER_OTHER_USER_APP);
		}
		
		if ($ar['state']=='sent'){
			throw new Exception(self::ER_DOC_SENT);
		}
		return $ar['state'];
	}
	
	public function set_user($pm){
		if ($_SESSION['role_id']!='admin' || !defined('TEMP_DOC_STORAGE') || !TEMP_DOC_STORAGE){
			throw new Exception('Действие разрешено администратору только на сервере с ЛК!');
		}
		$this->getDbLinkMaster()->query(sprintf(
		"UPDATE applications SET user_id=%d WHERE id=%d",
		$this->getExtDbVal($pm,'user_id'),
		$this->getExtDbVal($pm,'id')
		));
	}
	
	public function update($pm){
		self::checkSentState($this->getDbLink(),$this->getExtDbVal($pm,'old_id'),TRUE);

		if ($pm->getParamValue('user_id') &amp;&amp; $_SESSION['role_id']!='admin'){
			$pm->setParamValue('user_id', $_SESSION['user_id']);
		}

		$file_params = [];
		if ($this->upload_prints($this->getExtDbVal($pm,'old_id'),$file_params)){
			foreach($file_params as $k=>$v){
				$pm->setParamValue($k,$v);
			}			
		}

		$this->getDbLinkMaster()->query("BEGIN");
		try{			
			//parent::update($pm);
			$model_name = $this->getUpdateModelId();
			$model = new $model_name($this->getDbLinkMaster());
			$this->methodParamsToModel($pm,$model);
			
			$ar = NULL;
			$q = $model->getUpdateQuery();
			if (strlen($q)){
				$q.=' RETURNING id,expertise_type,cost_eval_validity,modification,audit';
				$ar = $this->getDbLinkMaster()->query_first($q);
			}
			else{
				$q = sprintf('SELECT id,expertise_type,cost_eval_validity,modification,audit FROM applications WHERE id=%d',
				$this->getExtDbVal($pm,'old_id')
				);
			}			
			
			$set_sent = $pm->getParamValue('set_sent');
			if (isset($set_sent) &amp;&amp; $set_sent){
				if (is_null($ar)){
					//simple select
					$ar = $this->getDbLink()->query_first($q);
				}
				$resAr = [];
				$this->set_state($this->getExtDbVal($pm,'old_id'),'sent',$ar,$resAr);
				if (isset($resAr['new_app_id'])){
					$this->move_files_to_new_app($resAr);
				}
			}
			
			self::removePDFFile($this->getExtVal($pm,'old_id'));
			self::removeAllZipFile($this->getExtVal($pm,'old_id'));
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}
	
	public function delete($pm){
		try{
			$this->getDbLinkMaster()->query("BEGIN");
		
			$this->checkSentState($this->getDbLinkMaster(),$this->getExtDbVal($pm,'id'),TRUE);
		
			//delete files, they belong to the user who created the application
			if (file_exists($dir =
					FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
					self::APP_DIR_PREF.$this->getExtVal($pm,'id'))
			){
				rrmdir($dir);
			}			
			if (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($dir =
					FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
					self::APP_DIR_PREF.$this->getExtVal($pm,'id'))
			){
				rrmdir($dir);
			}			
			
			parent::delete($pm);
			$this->getDbLinkMaster()->query("COMMIT");
			
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}			
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

	public static function removeFile($dbLinkMaster,$fileIdForDb){
		$ar = $dbLinkMaster->query_first(sprintf(
			"SELECT
				f.application_id,
				app.user_id,
				(SELECT st.state FROM application_processes AS st WHERE st.application_id=f.application_id ORDER BY st.date_time DESC LIMIT 1) AS state
			FROM application_document_files AS f
			LEFT JOIN applications AS app ON app.id=f.application_id
			WHERE f.file_id=%s",
		$fileIdForDb
		));
		if (!count($ar)){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		
		if ($_SESSION['role_id']!='admin' &amp;&amp; $ar['user_id']!=$_SESSION['user_id']){
			throw new Exception(self::ER_OTHER_USER_APP);
		}
		
		if ($ar['state']=='sent'){
			throw new Exception(self::ER_DOC_SENT);
		}
	
		try{
			$dbLinkMaster->query("BEGIN");
			
			//1) Mark in DB or delete
			//|| $ar['state']=='returned'
			if ($ar['state']=='filling'){
				$q = sprintf(
					"DELETE FROM application_document_files
					WHERE file_id=%s
					RETURNING application_id,document_type,file_path,file_id,file_name,file_signed",
				$fileIdForDb
				);
			}
			else{
				$q = sprintf(
					"UPDATE application_document_files
					SET					
						deleted = TRUE,
						deleted_dt=now()
					WHERE file_id=%s
					RETURNING application_id,document_type,file_path,file_id,file_name,file_signed",
				$fileIdForDb
				);
			}
			$ar = $dbLinkMaster->query_first($q);
			
			//2) Delete All Zip file
			self::removeAllZipFile($ar['application_id']);
			self::removePDFFile($ar['application_id']);

			//3) Move file to deleted folder
			$rel_dest = self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				self::APP_DIR_DELETED_FILES;
			
			$rel_fl = self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				self::dirNameOnDocType($ar['document_type']).DIRECTORY_SEPARATOR.				
				$ar['file_path'].DIRECTORY_SEPARATOR.
				$ar['file_name'];
				
			if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)){
				if (!file_exists($dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dest)){
					mkdir($dest,0777,TRUE);
				}
			
				rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id']);
			}
			if (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl)){
				if (!file_exists($dest = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dest)){
					mkdir($dest,0777,TRUE);
				}			
				rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id']);
			}
			
			if ($ar['file_signed']=='t'){
				if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl.self::SIG_EXT)){
					if (!file_exists($dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dest)){
						mkdir($dest,0777,TRUE);
					}				
					rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id'].self::SIG_EXT);
				}
				if (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl.self::SIG_EXT)){
					if (!file_exists($dest = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dest)){
						mkdir($dest,0777,TRUE);
					}				
					rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id'].self::SIG_EXT);
				}
				
			}
			
			$dbLinkMaster->query("COMMIT");
			
			
		}
		catch(Exception $e){
			$dbLinkMaster->query("ROLLBACK");
			throw $e;
		}
	}

	public function remove_file($pm){
		self::removeFile($this->getDbLinkMaster(), $this->getExtDbVal($pm,'file_id'));		
	}

	private function download_file($pm,$sig){
		if ($_SESSION['role_id']=='client'){
			//открывает только свои заявления!!!
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					af.application_id,
					af.document_type,
					af.file_id,
					af.file_name,
					af.file_path,
					af.deleted,
					af.file_signed
				FROM application_document_files AS af
				LEFT JOIN applications AS a ON a.id=af.application_id
				WHERE af.file_id=%s AND a.user_id=%d",
			$this->getExtDbVal($pm,'id'),
			$_SESSION['user_id']
			));			
		}
		else{
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					af.application_id,
					af.document_type,
					af.file_id,
					af.file_name,
					af.file_path,
					af.deleted,
					af.file_signed
				FROM application_document_files AS af
				WHERE af.file_id=%s",
			$this->getExtDbVal($pm,'id')
			));
		}
		if ($sig &amp;&amp; $ar['file_signed']!='t'){
			throw new Exception(self::ER_NO_SIG);	
		}
		
		$fl_postf = (($sig)? self::SIG_EXT:'');
		
		if ($ar['deleted']=='t'){
			$rel_fl = self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				self::APP_DIR_DELETED_FILES.DIRECTORY_SEPARATOR.
				$ar['file_id'].$fl_postf;
		}
		else{
			$rel_fl = self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				self::dirNameOnDocType($ar['document_type']).DIRECTORY_SEPARATOR.
				$ar['file_path'].DIRECTORY_SEPARATOR.
				$ar['file_name'].$fl_postf;		
		}
		
		if (!file_exists($fl=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)
		&amp;&amp;( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; !file_exists($fl=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl))
		){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND.' '.$fl);
		}
		
		$mime = getMimeTypeOnExt($ar['file_name'].$fl_postf);
		ob_clean();
		downloadFile($fl, $mime,'attachment;',$ar['file_name'].$fl_postf);
		return TRUE;
	}
	
	public function get_file($pm){
		$this->download_file($pm,FALSE);
	}
	public function get_file_sig($pm){
		$this->download_file($pm,TRUE);
	}
	
	private static function add_print_to_zip($docType,&amp;$fileInfo,&amp;$relDirZip,&amp;$zip,&amp;$cnt){
		$file_ar = json_decode($fileInfo);
		if (count($file_ar)){
			$rel_path = self::dirNameOnDocType($docType).DIRECTORY_SEPARATOR.$file_ar[0]->name;
			if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR. $rel_path)
			||( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR. $rel_path) )
			){
				$zip->addFile($file_doc, $rel_path);
				$cnt++;				
				if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR.$rel_path.self::SIG_EXT)
				||( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR.$rel_path.self::SIG_EXT))
				){
					$zip->addFile($file_doc,$rel_path.self::SIG_EXT);
					$cnt++;									
				}
			}				
		}
	}
	
	public function zip_all($pm){
		$ar_app = $this->getDbLink()->query_first(sprintf(
			"SELECT				
				app.user_id,
				app.app_print_expertise,
				app.expertise_type,
				app.app_print_cost_eval,
				app.cost_eval_validity,
				app.app_print_modification,
				app.modification,
				app.app_print_audit,
				app.audit,
				app.auth_letter_file
			FROM applications app			
			WHERE app.id=%s",
			$this->getExtDbVal($pm,'application_id')
		));			
	
		if ($_SESSION['role_id']=='client' &amp;&amp; $_SESSION['user_id']!=$ar_app['user_id']){
			throw new Exception(self::ER_OTHER_USER_APP);
		}
	
		$rel_dir_zip =	self::APP_DIR_PREF.$this->getExtVal($pm,'application_id');
				
		if (!file_exists($file_zip = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.self::ALL_DOC_ZIP_FILE)
		&amp;&amp;( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; !file_exists($file_zip = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.self::ALL_DOC_ZIP_FILE) )
		){
			//Всегда на клиентском сервере
			$file_zip = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.self::ALL_DOC_ZIP_FILE;
			
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
					file_path,
					file_signed,
					document_type
				FROM application_document_files
				WHERE application_id=%s",
				$this->getExtDbVal($pm,'application_id')
			));			
			while($file = $this->getDbLink()->fetch_array($qid)){
				$rel_path = self::dirNameOnDocType($file['document_type']).DIRECTORY_SEPARATOR.
						$file['file_path'].DIRECTORY_SEPARATOR.
						$file['file_name'];
				if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR. $rel_path)
				|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR. $rel_path) )
				){
					$zip->addFile($file_doc, $rel_path);
					$cnt++;				
					
					if ($file['file_signed']=='t'){
						if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.$rel_path.self::SIG_EXT)
						|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.$rel_path.self::SIG_EXT) )
						){
							$zip->addFile($file_doc,$rel_path.self::SIG_EXT);
							$cnt++;									
						}
					}					
				}
			}
			
			//Заявления
			if ($ar_app['expertise_type']){
				self::add_print_to_zip('app_print_expertise',$ar_app['app_print_expertise'],$rel_dir_zip,$zip,$cnt);
			}
			if ($ar_app['cost_eval_validity']=='t'){
				self::add_print_to_zip('app_print_cost_eval_validity',$ar_app['app_print_cost_eval'],$rel_dir_zip,$zip,$cnt);
			}
			if ($ar_app['modification']=='t'){
				self::add_print_to_zip('app_print_modification',$ar_app['app_print_modification'],$rel_dir_zip,$zip,$cnt);
			}
			if ($ar_app['audit']=='t'){
				self::add_print_to_zip('app_print_audit',$ar_app['app_print_audit'],$rel_dir_zip,$zip,$cnt);
			}
			//Доверенность
			if ($ar_app['auth_letter_file']){
				self::add_print_to_zip('auth_letter_file',$ar_app['auth_letter_file'],$rel_dir_zip,$zip,$cnt);
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
	
	private function move_files_to_new_app(&amp;$ar){
		//move files
		//Документация
		$doc_type_dir = self::dirNameOnDocType($ar['doc_type']);
		$doc_type_print_dir = self::dirNameOnDocType($ar['doc_type_print']);
		$dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['new_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_dir;
		$source = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['old_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_dir;
		mkdir($dest,0777,TRUE);
		rmove($source,$dest);
		rrmdir($source);
		
		//заявления
		$dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['new_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_print_dir;
		$source = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['old_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_print_dir;
		mkdir($dest,0777,TRUE);
		rmove($source,$dest);
		rrmdir($source);
	}
	
	/**
  	 * @param{int} id
  	 * @param{string} state application_states
	 * @param{array} ar array of fields with all services and id
	 * @param{array} resAr array of new_app_id,doc_type,doc_type_print
	 */
	private function set_state($id,$state,&amp;$ar,&amp;$resAr){
		if ($state=='sent'){
			if (!is_null($ar['expertise_type']) &amp;&amp; $ar['cost_eval_validity']=='t'){
				//убрать Достоверность в другую заявку
				$resAr['doc_type'] = 'cost_eval_validity';
				$resAr['doc_type_print'] = 'app_print_cost_eval';
			}
			else if($ar['cost_eval_validity']=='t' &amp;&amp; $ar['modification']=='t'){
				//убрать Модификацию в другую заявку
				$resAr['doc_type'] = 'modification';
				$resAr['doc_type_print'] = 'app_print_modification';
			}
			if (isset($resAr['doc_type'])){
				$new_id_ar = $this->getDbLinkMaster()->query_first(sprintf(
					"SELECT applications_split(%d,'%s'::document_types) AS new_app_id",
					$id,$resAr['doc_type']
				));
				$resAr['new_app_id'] = $new_id_ar['new_app_id'];
				$resAr['old_app_id'] = $id;
			}
		}
		$this->getDbLinkMaster()->query(sprintf(
			"INSERT INTO application_processes
			(application_id,state,user_id)
			VALUES (%d,'%s',%d)",
			$id,$state,$_SESSION['user_id']
		));
		
	}
	
	private function get_person_data_on_type(&amp;$jsonModel,$personType,&amp;$personName,&amp;$personPost){
		foreach($jsonModel['rows'] as $row){
			if ($row['fields']['person_type']==$personType){
				$personName = trim($row['fields']['name']);
				$personPost = trim($row['fields']['post']);
				break;
			}
		}
	}

	private static function checkApp(&amp;$qAr){
		if (!is_array($qAr) || !count($qAr)){
			throw new Exception(self::ER_APP_NOT_FOUND);
		}	
	}

	public function get_print($pm){
		$templ_name = $pm->getParamValue('templ');
		$out_file = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$this->getExtDbVal($pm,'id').DIRECTORY_SEPARATOR.
			$templ_name.".pdf";
			
		if (file_exists($out_file)){
			downloadFile(
				$out_file,
				'application/pdf',
				(isset($_REQUEST['inline']) &amp;&amp; $_REQUEST['inline']=='1')? 'inline;':'attachment;',
				$templ_name.".pdf"
			);
			return TRUE;			
		}
		
		//********************************
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
		try{
			$boss_decl = Morpher::declension($this->getDbLink(),array('s'=>$boss_name,'flags'=>'name'));
			$ar['boss_name_dat'] = $boss_decl['Д'];		
			$sep = strpos($ar['boss_name_dat'],' ');
			if ($sep !== FALSE){
				$ar['boss_name_dat'] = substr($ar['boss_name_dat'],0,$sep);
			}
			$n2 = (isset($boss_decl['ФИО']->И) &amp;&amp; strlen($boss_decl['ФИО']->И))? (mb_substr($boss_decl['ФИО']->И,0,1,'UTF-8').'.'):'';
			$n3 = (isset($boss_decl['ФИО']->О) &amp;&amp; strlen($boss_decl['ФИО']->О))? (mb_substr($boss_decl['ФИО']->О,0,1,'UTF-8').'.'):'';
			$n23 = (strlen($n2) || strlen($n3))? (' '.$n2.$n3):'';
			$ar['boss_name_dat'] = $ar['boss_name_dat'].$n23;
		}
		catch(Exception $e){
			$ar['boss_name_dat']	= $boss_name;
		}
		
		try{	
			$boss_post_decl = Morpher::declension($this->getDbLink(),array('s'=>$boss_post,'flags'=>'common'));
			$ar['boss_post_dat'] = $boss_post_decl['Д'];
		}
		catch(Exception $e){
			$ar['boss_post_dat']	= $boss_post;
		}
		
		try{	
			$office_decl = Morpher::declension($this->getDbLink(),array('s'=>$ar['office_client_name_full'],'flags'=>'common'));
			$ar['office_rod'] = $office_decl['Р'];
		}
		catch(Exception $e){
			$ar['office_rod']	= $ar['office_client_name_full'];
		}
				
		//technical features
		$featrures_m = json_decode($ar['constr_technical_features'],TRUE);
		$ar['constr_technical_features'] = '';
		foreach($featrures_m['rows'] as $row){
			$feature_val = (array_key_exists('value',$row['fields']))? $row['fields']['value'] : '';
			if (strlen($feature_val)){
				$ar['constr_technical_features'].=sprintf('&lt;feature name="%s" value="%s"/&gt;',
					$row['fields']['name'],
					$feature_val
				);
			}
		}

		//applicant
		$applicant_m = json_decode($ar['applicant'],TRUE);
		$inn = $applicant_m['inn'].( (strlen($applicant_m['kpp']))? ('/'.$applicant_m['kpp']):'' );
		if ($applicant_m['client_type']=='enterprise'){
			$person_head = json_decode($applicant_m['responsable_person_head'],TRUE);
		}
		else{
			//pboul and person = name
			$person_head = $applicant_m['name'];
		}
		if (strlen($applicant_m['base_document_for_contract'])){
			try{
				$base_document_for_contract = Morpher::declension($this->getDbLink(),array('s'=>$applicant_m['base_document_for_contract'],'flags'=>'common'))['Р'];
			}
			catch(Exception $e){
				$base_document_for_contract = $applicant_m['base_document_for_contract'];
			}
		}
		else{
			$base_document_for_contract = '';
		}
		if (strlen($person_head['name'])){
			try{
				$person_head_name_rod = Morpher::declension($this->getDbLink(),array('s'=>$person_head['name'],'flags'=>'name'))['Р'];
			}
			catch(Exception $e){
				$person_head_name_rod = $person_head['name'];
			}
		}
		else{
			$person_head_name_rod = '';
		}		
		if (strlen($person_head['post'])){
			try{
				$person_head_post_rod = Morpher::declension($this->getDbLink(),array('s'=>$person_head['post'],'flags'=>'common'))['Р'];
			}
			catch(Exception $e){
				$person_head_post_rod = $person_head['post'];
			}				
		}
		else{
			$person_head_post_rod = '';
		}				
		$applicant_contacts = '';
		if ($applicant_m['responsable_persons']){			
			$responsable_persons = json_decode($applicant_m['responsable_persons'],TRUE);
			foreach($responsable_persons['rows'] as $appl_resp){
				$applicant_contacts.= ($appl_contacts=='')? '':', ';
				$applicant_contacts.= strlen($appl_resp['fields']['post'])? $appl_resp['fields']['post'].' ' : '';
				$applicant_contacts.= $appl_resp['fields']['name'];
				$applicant_contacts.= strlen($appl_resp['fields']['tel'])? ' '.$appl_resp['fields']['tel'] : '';
				$applicant_contacts.= strlen($appl_resp['fields']['email'])? ' '.$appl_resp['fields']['email'] : '';
			}
		}
		$ar['applicant'] =
			sprintf('&lt;field id="Наименование"&gt;%s&lt;/field&gt;',$applicant_m['name_full']).
			sprintf('&lt;field id="ИНН/КПП"&gt;%s&lt;/field&gt;',$inn).
			sprintf('&lt;field id="Юридический адрес"&gt;%s&lt;/field&gt;',$ar['applicant_legal_address']).
			sprintf('&lt;field id="Почтовый адрес"&gt;%s&lt;/field&gt;',$ar['applicant_post_address']).
			sprintf('&lt;field id="Банк"&gt;%s&lt;/field&gt;',$ar['applicant_bank']).			
			sprintf('&lt;field id="ФИО руководителя"&gt;%s&lt;/field&gt;',$person_head['name']).
			sprintf('&lt;field id="Должность руководителя"&gt;%s&lt;/field&gt;',$person_head['post']).
			sprintf('&lt;field id="Действует на основании"&gt;%s&lt;/field&gt;',$base_document_for_contract).
			sprintf('&lt;person_head_name_rod&gt;%s&lt;/person_head_name_rod&gt;',$person_head_name_rod).
			sprintf('&lt;person_head_post_rod&gt;%s&lt;/person_head_post_rod&gt;',$person_head_post_rod).
			sprintf('&lt;field id="Контакты"&gt;%s&lt;/field&gt;',$applicant_contacts).
			(($ar['auth_letter'])? sprintf('&lt;field id="Доверенность"&gt;%s&lt;/field&gt;',$ar['auth_letter']) : '')
		;

		//customer
		$customer_m = json_decode($ar['customer'],TRUE);
		$inn = $customer_m['inn'].( (strlen($customer_m['kpp']))? ('/'.$customer_m['kpp']):'' );		
		if ($customer_m['client_type']=='enterprise'){
			$person_head = json_decode($customer_m['responsable_person_head'],TRUE);
		}
		else{
			//pboul and person = name
			$person_head = $customer_m['name'];
		}
		
		if (strlen($customer_m['base_document_for_contract'])){
			try{
				$base_document_for_contract = Morpher::declension($this->getDbLink(),array('s'=>$customer_m['base_document_for_contract'],'flags'=>'common'))['Р'];
			}
			catch(Exception $e){
				$base_document_for_contract = $customer_m['base_document_for_contract'];
			}				
		}
		else{
			$base_document_for_contract = '';
		}
		
		if (strlen($person_head['name'])){
			try{
				$person_head_name_rod = Morpher::declension($this->getDbLink(),array('s'=>$person_head['name'],'flags'=>'name'))['Р'];
			}
			catch(Exception $e){
				$person_head_name_rod = $person_head['name'];
			}				
		}
		else{
			$person_head_name_rod = '';
		}		
		if (strlen($person_head['post'])){
			try{
				$person_head_post_rod = Morpher::declension($this->getDbLink(),array('s'=>$person_head['post'],'flags'=>'common'))['Р'];
			}
			catch(Exception $e){
				$person_head_post_rod = $person_head['post'];
			}				
		}
		else{
			$person_head_post_rod = '';
		}								
		$ar['customer'] =
			sprintf('&lt;field id="Наименование"&gt;%s&lt;/field&gt;',$customer_m['name_full']).
			sprintf('&lt;field id="ИНН/КПП"&gt;%s&lt;/field&gt;',$inn).
			sprintf('&lt;field id="Юридический адрес"&gt;%s&lt;/field&gt;',$ar['customer_legal_address']).
			sprintf('&lt;field id="Почтовый адрес"&gt;%s&lt;/field&gt;',$ar['customer_post_address']).
			sprintf('&lt;field id="Банк"&gt;%s&lt;/field&gt;',$ar['customer_bank']).		
			sprintf('&lt;field id="ФИО руководителя"&gt;%s&lt;/field&gt;',$person_head['name']).
			sprintf('&lt;field id="Должность руководителя"&gt;%s&lt;/field&gt;',$person_head['post']).
			sprintf('&lt;field id="Действует на основании"&gt;%s&lt;/field&gt;',$base_document_for_contract).
			sprintf('&lt;person_head_name_rod&gt;%s&lt;/person_head_name_rod&gt;',$person_head_name_rod).
			sprintf('&lt;person_head_post_rod&gt;%s&lt;/person_head_post_rod&gt;',$person_head_post_rod)			
		;
		
		//developer
		$developer_m = json_decode($ar['developer'],TRUE);
		$inn = $developer_m['inn'].( (strlen($developer_m['kpp']))? ('/'.$developer_m['kpp']):'' );		
		if ($developer_m['client_type']=='enterprise'){
			$person_head = json_decode($developer_m['responsable_person_head'],TRUE);
		}
		else{
			//pboul and person = name
			$person_head = $developer_m['name'];
		}
		
		if (strlen($developer_m['base_document_for_contract'])){
			try{
				$base_document_for_contract = Morpher::declension($this->getDbLink(),array('s'=>$developer_m['base_document_for_contract'],'flags'=>'common'))['Р'];
			}
			catch(Exception $e){
				$base_document_for_contract = $developer_m['base_document_for_contract'];
			}				
		}
		else{
			$base_document_for_contract = '';
		}
		
		if (strlen($person_head['name'])){
			try{
				$person_head_name_rod = Morpher::declension($this->getDbLink(),array('s'=>$person_head['name'],'flags'=>'name'))['Р'];
			}
			catch(Exception $e){
				$person_head_name_rod = $person_head['name'];
			}				
		}
		else{
			$person_head_name_rod = '';
		}		
		if (strlen($person_head['post'])){
			try{
				$person_head_post_rod = Morpher::declension($this->getDbLink(),array('s'=>$person_head['post'],'flags'=>'common'))['Р'];
			}
			catch(Exception $e){
				$person_head_post_rod = $person_head['post'];
			}				
		}
		else{
			$person_head_post_rod = '';
		}								
		$ar['developer'] =
			sprintf('&lt;field id="Наименование"&gt;%s&lt;/field&gt;',$developer_m['name_full']).
			sprintf('&lt;field id="ИНН/КПП"&gt;%s&lt;/field&gt;',$inn).
			sprintf('&lt;field id="Юридический адрес"&gt;%s&lt;/field&gt;',$ar['developer_legal_address']).
			sprintf('&lt;field id="Почтовый адрес"&gt;%s&lt;/field&gt;',$ar['developer_post_address']).
			sprintf('&lt;field id="Банк"&gt;%s&lt;/field&gt;',$ar['developer_bank']).		
			sprintf('&lt;field id="ФИО руководителя"&gt;%s&lt;/field&gt;',$person_head['name']).
			sprintf('&lt;field id="Должность руководителя"&gt;%s&lt;/field&gt;',$person_head['post']).
			sprintf('&lt;field id="Действует на основании"&gt;%s&lt;/field&gt;',$base_document_for_contract).
			sprintf('&lt;person_head_name_rod&gt;%s&lt;/person_head_name_rod&gt;',$person_head_name_rod).
			sprintf('&lt;person_head_post_rod&gt;%s&lt;/person_head_post_rod&gt;',$person_head_post_rod)			
		;
		
		//contractors
		$contractors = json_decode($ar['contractors'],TRUE);
		$ar['contractors'] = '';
		foreach($contractors as $contractor){
			$contractor_m = $contractor['contractor'];
			$inn = $contractor_m['inn'].( (strlen($contractor_m['kpp']))? ('/'.$contractor_m['kpp']):'' );			
			if ($contractor_m['client_type']=='enterprise'){
				$person_head = json_decode($contractor_m['responsable_person_head'],TRUE);
			}
			else{
				//pboul and person = name
				$person_head = $contractor_m['name'];
			}
			
			if (strlen($contractor_m['base_document_for_contract'])){
				try{
					$base_document_for_contract = Morpher::declension($this->getDbLink(),array('s'=>$contractor_m['base_document_for_contract'],'flags'=>'common'))['Р'];
				}
				catch(Exception $e){
					$base_document_for_contract = $contractor_m['base_document_for_contract'];
				}									
			}
			else{
				$base_document_for_contract = '';
			}		
			if (strlen($person_head['name'])){
				try{
					$person_head_name_rod = Morpher::declension($this->getDbLink(),array('s'=>$person_head['name'],'flags'=>'name'))['Р'];
				}
				catch(Exception $e){
					$person_head_name_rod = $person_head['name'];
				}									
			}
			else{
				$person_head_name_rod = '';
			}		
			if (strlen($person_head['post'])){
				try{
					$person_head_post_rod = Morpher::declension($this->getDbLink(),array('s'=>$person_head['post'],'flags'=>'common'))['Р'];
				}
				catch(Exception $e){
					$person_head_post_rod = $person_head['post'];
				}									
			}
			else{
				$person_head_post_rod = '';
			}								
			
			$ar['contractors'].=
			'&lt;contractor&gt;'.
				sprintf('&lt;field id="Наименование"&gt;%s&lt;/field&gt;',$contractor_m['name_full']).
				sprintf('&lt;field id="ИНН/КПП"&gt;%s&lt;/field&gt;',$inn).
				sprintf('&lt;field id="Юридический адрес"&gt;%s&lt;/field&gt;',$contractor['legal_address']).
				sprintf('&lt;field id="Почтовый адрес"&gt;%s&lt;/field&gt;',$contractor['post_address']).
				sprintf('&lt;field id="Банк"&gt;%s&lt;/field&gt;',$contractor['bank']).				
				sprintf('&lt;field id="ФИО руководителя"&gt;%s&lt;/field&gt;',$person_head['name']).
				sprintf('&lt;field id="Должность руководителя"&gt;%s&lt;/field&gt;',$person_head['post']).				
				sprintf('&lt;field id="Действует на основании"&gt;%s&lt;/field&gt;',$base_document_for_contract).
				sprintf('&lt;person_head_name_rod&gt;%s&lt;/person_head_name_rod&gt;',$person_head_name_rod).
				sprintf('&lt;person_head_post_rod&gt;%s&lt;/person_head_post_rod&gt;',$person_head_post_rod).				
			'&lt;/contractor&gt;'
			;		
		}		
		
		//files
		//PD AND ENG_SURVEY
		$files_q_id = $this->getDbLink()->query(sprintf(
			"SELECT
				f.file_name,
				f.file_path,
				f.document_type
			FROM application_document_files AS f
			WHERE f.application_id=%d AND coalesce(f.deleted,FALSE)=FALSE AND (f.document_type='pd' OR f.document_type='eng_survey') %s
			ORDER BY f.document_type,f.file_path,f.file_name",
		$this->getExtDbVal($pm,'id'),
		($_SESSION['role_id']=='client')? (' AND (SELECT t.user_id FROM applications t WHERE t.id=f.application_id)='.$_SESSION['user_id']):''
		));
		$ar['documents_pd_eng_survey'] = '';
		while($file = $this->getDbLink()->fetch_array($files_q_id)){
			if ($ar['documents_pd_eng_survey']==''){
				$ar['documents_pd_eng_survey'] = '&lt;files&gt;';
			}
			/*
			$path_ar = explode('/',$file['file_path']);
			$sec1 = self::dirNameOnDocType($file['document_type']).'/'.( (count($path_ar)>=1)? $path_ar[0]:'' );
			$sec2 = (count($path_ar)>=2)? $path_ar[1]:'';
			*/
			$ar['documents_pd_eng_survey'].= sprintf('&lt;file path="%s" name="%s"/&gt;',
				self::dirNameOnDocType($file['document_type']).'/'.$file['file_path'],
				$file['file_name']
			);
		}
		if ($ar['documents_pd_eng_survey']!=''){		
			$ar['documents_pd_eng_survey'].= '&lt;/files&gt;';
		}
		
		//CostEvalValidity
		if ($ar['cost_eval_validity']=='t'){
			$files_q_id = $this->getDbLink()->query(sprintf(
				"SELECT
					f.file_name,
					f.file_path,
					f.document_type
				FROM application_document_files AS f
				WHERE f.application_id=%d AND coalesce(f.deleted,FALSE)=FALSE AND f.document_type='cost_eval_validity' %s
				ORDER BY f.file_path,f.file_name",
			$this->getExtDbVal($pm,'id'),
			($_SESSION['role_id']=='client')? (' AND (SELECT t.user_id FROM applications t WHERE t.id=f.application_id)='.$_SESSION['user_id']):''
			));
			$ar['documents_cost_eval_validity'] = '';
			while($file = $this->getDbLink()->fetch_array($files_q_id)){
				if ($ar['documents_cost_eval_validity']==''){
					$ar['documents_cost_eval_validity'] = '&lt;files&gt;';
				}
				/*			
				$path_ar = explode('/',$file['file_path']);
				$sec1 = (count($path_ar)>=1)? $path_ar[0]:'';
				$sec2 = (count($path_ar)>=2)? $path_ar[1]:'';
				$ar['documents_cost_eval_validity'].= sprintf('&lt;file section1="%s" section2="%s" name="%s"/&gt;',$sec1,$sec2,$file['file_name']);
				*/
				$ar['documents_cost_eval_validity'].= sprintf('&lt;file path="%s" name="%s"/&gt;',
					self::dirNameOnDocType($file['document_type']).'/'.$file['file_path'],
					$file['file_name']
				);
				
			}		
			if ($ar['documents_cost_eval_validity']!=''){		
				$ar['documents_cost_eval_validity'].= '&lt;/files&gt;';
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
		
		$model = new ModelVars(
			array('name'=>'Vars',
				'id'=>'ApplicationPrint_Model',
				'values'=>$m_fields
		));
		
		if ($_REQUEST['v']=='ViewPDF'){
			$xml = '&lt;?xml version="1.0" encoding="UTF-8"?&gt;';
			$xml.= '&lt;document&gt;';
			$xml.= $model->dataToXML(TRUE);
			$xml.= '&lt;/document&gt;';
			$xml_file = OUTPUT_PATH.uniqid().".xml";
			file_put_contents($xml_file,$xml);
			//FOP
			try{			
				$xslt_file = USER_VIEWS_PATH.$templ_name.".pdf.xsl";
				$out_file_tmp = OUTPUT_PATH.uniqid().".pdf";
				exec(sprintf(PDF_CMD_TEMPLATE,$xml_file, $xslt_file, $out_file_tmp));
					
				if (!file_exists($out_file_tmp)){
					throw new Exception('Файл не найден!');
				}
			
				rename($out_file_tmp, $out_file);
				ob_clean();
				downloadFile(
					$out_file,
					'application/pdf',
					(isset($_REQUEST['inline']) &amp;&amp; $_REQUEST['inline']=='1')? 'inline;':'attachment;',
					$templ_name.".pdf"
				);
			
			}
			finally{
				unlink($xml_file);
				if (file_exists($out_file_tmp)){
					rename($out_file_tmp, $out_file);
				}
			}		
		
			return TRUE;
		}
		else{
			$this->addModel($model);
		}	
	}
	
	public function get_document_templates($pm){
		$this->addNewModel("SELECT * FROM document_templates_all_json_list",'DocumentTemplateAllList_Model');
	}

	public function remove_document_types($pm){
	
		self::checkSentState($this->getDbLink(),$this->getExtDbVal($pm,'application_id'),TRUE);
		
		$app_id = $this->getExtVal($pm,'application_id');
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			$document_types = json_decode($this->getExtVal($pm,'document_types'));
			foreach($document_types as $document_type){
				$type_dir = self::dirNameOnDocType($document_type);
				//Если это нормальное значение перечисления, ЧТОБЫ не строить валидацию!
				if (!is_null($type_dir)){
					//1) Mark in DB
					$ar = $this->getDbLinkMaster()->query_first(sprintf(
						"DELETE FROM application_document_files
						WHERE application_id=%d AND document_type='%s'",
					$this->getExtDbVal($pm,'application_id'),
					$document_type
					));
		
					//2) Remove directory
					if (file_exists($dir = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
							self::APP_DIR_PREF.$app_id. DIRECTORY_SEPARATOR.
							$type_dir
						)
					){
						rrmdir($dir);
					}
				}
			}
			//Delete All Zip AND PDF file
			self::removeAllZipFile($app_id);
			self::removePDFFile($app_id);

			//Delete app prints
			$print_type = '';
			switch ($document_type) {
			    case 'pd':
			    case 'eng_survey':
			    	$print_type = 'app_print_expertise';
				break;
			    case 'cost_eval_validity':
			    	$print_type = 'app_print_cost_eval';
			    	break;
			     case 'modification':
			     	$print_type = 'app_print_modification';
			     	break;
			     case 'audit':
			     	$print_type = 'app_print_audit';
			     	break;
			}
			if ($print_type!=''){
				if (file_exists($dir = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						self::APP_DIR_PREF.$app_id. DIRECTORY_SEPARATOR.
						self::dirNameOnDocType($print_type)
					)
				){
					rrmdir($dir);
				}
			
				$this->getDbLinkMaster()->query_first(sprintf(
					"UPDATE applications
					SET
						%s = NULL,
						auth_letter_file = NULL
					WHERE id=%d",				
				$print_type,
				$this->getExtDbVal($pm,'application_id')
				));
			}
			else{
				//might be an auth letter
				$this->getDbLinkMaster()->query_first(sprintf(
					"UPDATE applications
					SET
						auth_letter_file = NULL
					WHERE id=%d",				
				$this->getExtDbVal($pm,'application_id')
				));
			}
			//Доверенность
			if (file_exists($dir = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
					self::APP_DIR_PREF.$app_id. DIRECTORY_SEPARATOR.
					self::dirNameOnDocType('auth_letter_file')
				)
			){
				rrmdir($dir);
			}
			
									
			$this->getDbLinkMaster()->query("COMMIT");
		}		
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}
	
</xsl:template>

</xsl:stylesheet>
