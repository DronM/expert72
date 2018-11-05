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

require_once(USER_CONTROLLERS_PATH.'DocFlowOutClient_Controller.php');

require_once('common/downloader.php');
require_once(ABSOLUTE_PATH.'functions/Morpher.php');

require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldXML.php');

require_once('common/file_func.php');
require_once('common/short_name.php');

require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	
	const MAX_FILE_LEN = 200;
	
	const ALL_DOC_ZIP_FILE = 'all.zip';
	const SIG_EXT = '.sig';
	
	const APP_DIR_PREF = 'Заявление№';
	const APP_DIR_DELETED_FILES = 'Удаленные';
	const APP_PRINT_PREF = 'Заявления';
	
	const FILE_SIG_CHECK = 'ПроверкаЭЦП';
	const FILE_APPLICATION = 'ЗаявлениеПД';
	const FILE_COST_EVAL_VALIDITY = 'ЗаявлениеДостоверность';
	const FILE_MODIFICATION = 'ЗаявлениеМодификация';
	const FILE_AUDIT = 'ЗаявлениеАудит';
	
	const ER_STORAGE_FILE_NOT_FOUND = 'Файл не найден!';
	const ER_APP_NOT_FOUND = 'Заявление не найдено!';
	const ER_NO_FILES_FOR_ZIP = 'Проект не содержит файлов!';	
	const ER_MAKE_ZIP = 'Ошибка при создании архива!';
	const ER_NO_BOSS = 'Не определен руководитель НАШЕГО офиса!';
	const ER_OTHER_USER_APP = 'Forbidden!';
	const ER_APP_SENT = 'Невозможно удалять отправленное заявление!';
	const ER_NO_SIG = 'Для файла нет ЭЦП!';
	const ER_DOC_SENT = 'Документ отправлен на проверку. Операция невозможна.';
	const ER_NO_ATT = 'Нет ни одного вложенного файла с документацией!';

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
		
		$file_id = md5(uniqid());
		
		/* sig-data indexes ".sig" - 4 chars
		 * IE does not have File constructro, so Blob is used instead
		 * it has always name=blob
		 */
		$sig_ind = (strtolower($files['name'][0])=='blob' || strtolower(substr($files['name'][0],strlen($files['name'][0])-4,4))=='.sig')? 0 : NULL;		
		if (is_null($sig_ind)){
			$sig_ind = (strtolower($files['name'][1])=='blob' || strtolower(substr($files['name'][1],strlen($files['name'][1])-4,4))=='.sig')? 1 : NULL;
			if (is_null($sig_ind)){
				throw new Exception(self::ER_PRINT_FILE_CNT.$ER_PRINT_FILE_CNT_END[$id].'.');
			}
		}
		$data_ind = ($sig_ind==1)? 0:1;
		
		//data
		if (!move_uploaded_file($files['tmp_name'][$data_ind],$dir.DIRECTORY_SEPARATOR.$file_id)){
			throw new Exception('Ошибка загрузки заявления по '.$ER_PRINT_FILE_CNT_END[$id].'.');
		}
		
		//sig
		if (!move_uploaded_file($files['tmp_name'][$sig_ind],$dir.DIRECTORY_SEPARATOR.$file_id.'.sig')){
			throw new Exception('Ошибка загрузки подписи заявления по '.$ER_PRINT_FILE_CNT_END[$id].'.');
		}
	
		//проверка ЭЦП
		$sig_ar = NULL;
		$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,'error');		
		$db_file_id = "'".$file_id."'";
		$db_link = $this->getDbLinkMaster();
		$verif_res = pki_log_sig_check(
			$dir.DIRECTORY_SEPARATOR.$file_id.'.sig',
			$dir.DIRECTORY_SEPARATOR.$file_id,				
			$db_file_id,
			$pki_man,
			$db_link
		);
		if (pki_fatal_error($verif_res)){
			throw new Exception('Ошибка проверки подписи заявления по '.$ER_PRINT_FILE_CNT_END[$id].': '.$verif_res->checkError);
		}
		
		$sig_ar = $this->getDbLinkMaster()->query_first(sprintf(
		"SELECT
			f_sig.file_id,
			jsonb_agg(
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				)
			) AS signatures
		FROM file_signatures AS f_sig
		LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
		LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id			
		WHERE ver.file_id=%s
		GROUP BY f_sig.file_id",
		$db_file_id
		));
		/*
			if (!count($sig_ar) || !isset($sig_ar['signatures'])){
				$sig_ar['signatures'] = sprintf('[{
					"sign_date_time":"%s",
					"cert_from",null,
					"cert_to",null,
					"owner":null,
					"check_result":"%s",
					"check_time":"%s",
					"error_str":"%s"
				}]',
				date('Y-m-d H:i:s'),
				$verif_res->check_result,
				$verif_res->check_time,
				$verif_res->error_str
				);
			}
		}
		catch(Exception $e){
			$sig_ar['signatures'] = sprintf('[{
				"sign_date_time":"%s",
				"owner":null,
				"cert_from",null,
				"cert_to",null,
				"check_result":false,
				"check_time":null,
				"error_str":"%s"
			}]',
			date('Y-m-d H:i:s'),
			$e->getMessage()
			);
			
		}
		*/
		$fileParams[$id] = sprintf(
			'[{
				"name":"%s",
				"id":"%s",
				"size":"%s",
				"file_signed":"true",
				"signatures":%s
			}]',
			$files['name'][$data_ind],
			$file_id,
			$files['size'][$data_ind],
			$sig_ar['signatures']
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
			self::removePDFFile($appId);
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
						$file_o->signatures	= $file['signatures'];
						
						if ($file['doc_flow_out_client_id']){
							$file_o->doc_flow_out	= new stdClass();
							$file_o->doc_flow_out->id = $file['doc_flow_out_client_id'];
							$file_o->doc_flow_out->date_time = $file['doc_flow_out_date_time'];
							$file_o->doc_flow_out->reg_number = $file['doc_flow_out_reg_number'];
						}
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
		if (count($f) &amp;&amp; $f[0]->id){
			$fileName = $f[0]->name. ($isSig? '.sig':'');
			$rel_fl = self::APP_DIR_PREF.$appId.DIRECTORY_SEPARATOR.
				self::dirNameOnDocType($docType).DIRECTORY_SEPARATOR.
				$f[0]->id. ($isSig? '.sig':'');
			return (
				file_exists($fullPath=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)
				|| ( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($fullPath=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl) )
			);
		}		
	}

	public function delete_print($appId,$docType,$fillPercent){
		$state = self::checkSentState($this->getDbLink(),$appId,TRUE);
		if ($_SESSION['role_id']!='admin' &amp;&amp; $state!='filling' &amp;&amp; $state!='correcting'){
			throw new Exception(ER_DOC_SENT);
		}
		$fullPath = '';
		$fileName = '';
		if ($fillPercent>=100){
			$fillPercent = 99;
		}
		if ($this->get_print_file($appId,$docType,FALSE,$fullPath,$fileName)){
			try{
				$this->getDbLinkMaster()->query("BEGIN");
				$this->getDbLinkMaster()->query(sprintf(
					"UPDATE applications
					SET
						%s=NULL,
						filled_percent=%d
					WHERE id=%d",
					$docType,$fillPercent,$appId));
				
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
		return $this->delete_print($this->getExtDbVal($pm,'id'),'app_print_expertise',$this->getExtDbVal($pm,'fill_percent'));
	}
	
	public function download_app_print_modification($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_modification',FALSE);
	}
	public function download_app_print_modification_sig($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_modification',TRUE);
	}
	public function delete_app_print_modification($pm){
		return $this->delete_print($this->getExtDbVal($pm,'id'),'app_print_modification',$this->getExtDbVal($pm,'fill_percent'));
	}
	
	public function download_app_print_audit($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_audit',FALSE);
	}
	public function download_app_print_audit_sig($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_audit',TRUE);
	}
	public function delete_app_print_audit($pm){
		return $this->delete_print($this->getExtDbVal($pm,'id'),'app_print_audit',$this->getExtDbVal($pm,'fill_percent'));
	}
	
	public function download_app_print_cost_eval($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_cost_eval',FALSE);
	}
	public function download_app_print_cost_eval_sig($pm){
		return $this->download_print($this->getExtDbVal($pm,'id'),'app_print_cost_eval',TRUE);
	}
	public function delete_app_print_cost_eval($pm){
		return $this->delete_print($this->getExtDbVal($pm,'id'),'app_print_cost_eval',$this->getExtDbVal($pm,'fill_percent'));
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

	public static function attachmentsQuery($dbLink,$appId,$deletedCond){
		return $dbLink->query(sprintf(
			"SELECT
				adf.*,
				mdf.doc_flow_out_client_id,
				m.date_time AS doc_flow_out_date_time,
				reg.reg_number AS doc_flow_out_reg_number,				
				CASE
					WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
						jsonb_build_array(
							jsonb_build_object(
								'owner',NULL,
								'sign_date_time',f_ver.date_time,
								'check_result',f_ver.check_result,
								'check_time',f_ver.check_time,
								'error_str',f_ver.error_str
							)
						)
					ELSE sign.signatures
				END AS signatures
								
			FROM application_document_files AS adf
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=adf.file_id
			--LEFT JOIN doc_flow_out_client_document_files AS mdf ON mdf.file_id=adf.file_id
			LEFT JOIN (SELECT DISTINCT ON (cf.file_id) cf.file_id,cf.doc_flow_out_client_id FROM doc_flow_out_client_document_files cf) AS mdf ON mdf.file_id=adf.file_id
			LEFT JOIN doc_flow_out_client AS m ON m.id=mdf.doc_flow_out_client_id
			LEFT JOIN doc_flow_out_client_reg_numbers AS reg ON reg.doc_flow_out_client_id=m.id
			LEFT JOIN (
				SELECT
					f_sig.file_id,
					jsonb_agg(
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						)
					) As signatures
				FROM file_signatures AS f_sig
				LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
				LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
				GROUP BY f_sig.file_id
				-- Здесь Всегда одна подпись, можно без сортировки!!!
			) AS sign ON sign.file_id=adf.file_id			
			WHERE adf.application_id=%d %s
			ORDER BY adf.document_type,adf.document_id,adf.file_name,adf.deleted_dt ASC NULLS LAST",
		$appId,
		$deletedCond
		));				
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
			
			$deleted_cond = ($_SESSION['role_id']=='client')? "AND coalesce(adf.deleted,FALSE)=FALSE":"";
			
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
				$files_q_id = self::attachmentsQuery(
					$this->getDbLink(),
					$this->getExtDbVal($pm,'id'),
					$deleted_cond
				);
			}
			else{
				//Copy mode!!!
				$ar_obj['document_exists'] = 'f';
				$ar_obj['documents'] = NULL;
				$ar_obj['base_applications_ref'] = NULL;
				$ar_obj['derived_applications_ref'] = NULL;
				$ar_obj['auth_letter'] = NULL;
				$ar_obj['auth_letter_file'] = NULL;
				$ar_obj['application_state'] = NULL;
				$ar_obj['contract_date'] = NULL;
				$ar_obj['contract_number'] = NULL;
				$ar_obj['expertise_result_number'] = NULL;
				$ar_obj['expertise_result_date'] = NULL;
				$ar_obj['application_state'] = 'filling';
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
				NULL AS constr_technical_features_in_compound_obj,
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
				NULL as pd_usage_info,
				NULL AS doc_folders,
				NULL AS work_start_date,
				NULL AS contract_number,
				NULL AS contract_date,
				NULL AS expertise_result_number,
				NULL AS expertise_result_date,
				0 AS filled_percent
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
			$ar_obj['documents'] = json_encode($documents_json);
		}
		$obj_vals = array();
		foreach($ar_obj as $obj_f_id=>$obj_f){
			array_push($obj_vals,new Field($obj_f_id,DT_STRING,array('value'=>$obj_f)));
		}
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ApplicationDialog_Model',
				'values'=>$obj_vals
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
		else if ($docType=='documents'){
			$res = '';
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
	
	public static function removeSigCheckReport($applicationId){
		self::delFileFromStorage(
			self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
			self::FILE_SIG_CHECK.'.pdf'
		);
	}
	
	public static function removePDFFile($applicationId){
		self::delFileFromStorage(
			self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
			self::FILE_APPLICATION.'.pdf'
		);

		self::delFileFromStorage(
			self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
			self::FILE_COST_EVAL_VALIDITY.'.pdf'
		);
		self::delFileFromStorage(
			self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
			self::FILE_MODIFICATION.'.pdf'
		);
		self::delFileFromStorage(
			self::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
			self::FILE_AUDIT.'.pdf'
		);
		self::removeSigCheckReport($applicationId);
	}

	public function insert($pm){		
		$set_sent_v = $pm->getParamValue('set_sent');
		$set_sent = (isset($set_sent_v) &amp;&amp; $set_sent_v=='1');
		if ($set_sent){
			throw new Exception(self::ER_NO_ATT);
		}		
	
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
			if ($set_sent){
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
				$this->move_files_to_new_app(FILE_STORAGE_DIR,$resAr);
				if (defined('FILE_STORAGE_DIR_MAIN')){
					$this->move_files_to_new_app(FILE_STORAGE_DIR_MAIN,$resAr);
				}
				
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
		
		if ($ar['state']=='sent' || $ar['state']=='checking'){
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
		$old_state = self::checkSentState($this->getDbLink(),$this->getExtDbVal($pm,'old_id'),TRUE);

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
			
			$set_sent_v = $pm->getParamValue('set_sent');
			$set_sent = (isset($set_sent_v) &amp;&amp; $set_sent_v=='1');
			
			$ar = NULL;
			$q = $model->getUpdateQuery();
			if (strlen($q) &amp;&amp; $set_sent){
				$q.=' RETURNING
					id,
					expertise_type,
					cost_eval_validity,
					modification,
					audit,
					app_print_expertise IS NOT NULL AS app_print_expertise_set,
					app_print_cost_eval IS NOT NULL AS app_print_cost_eval_set,
					app_print_modification IS NOT NULL AS app_print_modificationl_set,
					app_print_audit IS NOT NULL AS app_print_audit_set,
					(SELECT COUNT(*) FROM application_document_files af WHERE af.application_id=id) AS file_count';
				$ar = $this->getDbLinkMaster()->query_first($q);
			}
			else if ($set_sent){
				$q = sprintf(
				'SELECT
					id,
					expertise_type,
					cost_eval_validity,
					modification,
					audit,
					app_print_expertise IS NOT NULL AS app_print_expertise_set,
					app_print_cost_eval IS NOT NULL AS app_print_cost_eval_set,
					app_print_modification IS NOT NULL AS app_print_modificationl_set,
					app_print_audit IS NOT NULL AS app_print_audit_set,
					(SELECT COUNT(*) FROM application_document_files af WHERE af.application_id=id) AS file_count						
				FROM applications WHERE id=%d',
				$this->getExtDbVal($pm,'old_id')
				);				
			}			
			
			if (strlen($q)){
				$ar = $this->getDbLinkMaster()->query_first($q);
			}
			
			if ($set_sent){
				//Серверные проверки перед отправкой
				if (
				($ar['expertise_type'] &amp;&amp; $ar['app_print_expertise_set']!='t')
				||($ar['cost_eval_validity']=='t' &amp;&amp; $ar['app_print_cost_eval_set']!='t')
				||($ar['modification']=='t' &amp;&amp; $ar['app_print_modification_set']!='t')
				||($ar['audit']=='t' &amp;&amp; $ar['app_print_audit_set']!='t')
				){
					throw new Exception('Нет файла с заявлением по выбранной услуге!');
				}
				
				if ($ar['file_count']==0){
					throw new Exception(self::ER_NO_ATT);
				}				
				
				self::checkIULs($this->getDbLinkMaster(),$this->getExtDbVal($pm,'old_id'));
				
				$resAr = [];
				$this->set_state(
					$this->getExtDbVal($pm,'old_id'),
					($old_state=='correcting')? 'checking':'sent',
					$ar,
					$resAr
				);
				if (isset($resAr['new_app_id'])){
					$this->move_files_to_new_app(FILE_STORAGE_DIR,$resAr);
					if (defined('FILE_STORAGE_DIR_MAIN')){
						$this->move_files_to_new_app(FILE_STORAGE_DIR_MAIN,$resAr);
					}
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

	public static function removeFile($dbLinkMaster,$fileIdForDb,$unlinkFile=FALSE){
		$ar = $dbLinkMaster->query_first(sprintf(
			"SELECT
				f.application_id,
				app.user_id,
				f.document_id,
				(SELECT
					st.state
				FROM application_processes AS st
				WHERE st.application_id=f.application_id
				ORDER BY st.date_time DESC
				LIMIT 1
				) AS state
			FROM application_document_files AS f
			LEFT JOIN applications AS app ON app.id=f.application_id
			WHERE f.file_id=%s",
		$fileIdForDb
		));
		if (!count($ar) || !$ar['application_id']){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		
		if ($_SESSION['role_id']!='admin' &amp;&amp; $ar['user_id']!=$_SESSION['user_id']){
			throw new Exception(self::ER_OTHER_USER_APP.' app_user='.$ar['user_id']);
		}
		
		if ($ar['state']=='sent'){
			throw new Exception(self::ER_DOC_SENT);
		}
	
		try{
			$dbLinkMaster->query("BEGIN");
			
			//1) Mark in DB or delete
			//|| $ar['state']=='returned'
			//В этом случае - непосредственное удаление, без копирования в Удаленные
			$unlink_file = ($unlinkFile || $ar['document_id']==0 || $ar['state']=='filling' || $ar['state']=='correcting');
			if ($unlink_file){
				$q = sprintf(
					"DELETE FROM application_document_files
					WHERE file_id=%s
					RETURNING application_id,document_type,document_id,file_path,file_id,file_name,file_signed",
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
					RETURNING application_id,document_type,document_id,file_path,file_id,file_name,file_signed",
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
			
			$document_type_path = self::dirNameOnDocType($ar['document_type']);
			$document_type_path.= ($document_type_path=='')? '':DIRECTORY_SEPARATOR;
			$rel_fl = self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				$document_type_path.
				(($ar['document_id']==0)? $ar['file_path']:$ar['document_id']).DIRECTORY_SEPARATOR.
				$ar['file_id'];
				
			if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)){
				if ($unlink_file){
					unlink($fl);
				}
				else{
					if (!file_exists($dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dest)){
						mkdir($dest,0777,TRUE);
					}				
					rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id']);
				}
			}
			if (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl)){
				if ($unlink_file){
					unlink($fl);
				}
				else{
					if (!file_exists($dest = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dest)){
						mkdir($dest,0777,TRUE);
					}				
					rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id']);
				}
				
			}
			
			if ($ar['file_signed']=='t'){
				if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl.self::SIG_EXT)){
					if ($unlink_file){
						unlink($fl);
					}
					else{				
						if (!file_exists($dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dest)){
							mkdir($dest,0777,TRUE);
						}
					
						rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id'].self::SIG_EXT);
					}
				}
				if (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl.self::SIG_EXT)){
					if ($unlink_file){
						unlink($fl);
					}
					else{				
						if (!file_exists($dest = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dest)){
							mkdir($dest,0777,TRUE);
						}
					
						rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id'].self::SIG_EXT);
					}
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
					CASE WHEN af.document_type='documents' THEN af.file_path
						ELSE af.document_id::text
					END AS document_id,
					af.file_id,
					af.file_name,
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
					CASE WHEN af.document_type='documents' THEN af.file_path
						ELSE af.document_id::text
					END AS document_id,
					af.file_id,
					af.file_name,
					af.deleted,
					af.file_signed
				FROM application_document_files AS af
				WHERE af.file_id=%s",
			$this->getExtDbVal($pm,'id')
			));
		}
		try{
			if (!is_array($ar) || !count($ar)){
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);	
			}
		
			if ($sig &amp;&amp; $ar['file_signed']!='t'){
				$this->setHeaderStatus(400);
				throw new Exception(self::ER_NO_SIG);	
			}
		
			$fl_postf = (($sig)? self::SIG_EXT:'');
		
			if ($ar['deleted']=='t'){
				$rel_fl = self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
					self::APP_DIR_DELETED_FILES.DIRECTORY_SEPARATOR.
					$ar['file_id'].$fl_postf;
			}
			else{
				$document_type_path = self::dirNameOnDocType($ar['document_type']);
				$document_type_path.= ($document_type_path=='')? '':DIRECTORY_SEPARATOR;			
				$rel_fl = self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
					$document_type_path.
					$ar['document_id'].DIRECTORY_SEPARATOR.
					$ar['file_id'].$fl_postf;		
			}
		
			if (!file_exists($fl=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)
			&amp;&amp;( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; !file_exists($fl=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl))
			){
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			}
		
			$mime = getMimeTypeOnExt($ar['file_name'].$fl_postf);
			ob_clean();
			downloadFile($fl, $mime,'attachment;',$ar['file_name'].$fl_postf);
			return TRUE;
		}	
		catch(Exception $e){
			$this->setHeaderStatus(400);
			throw $e;
		}
	}
	
	public function get_file($pm){
		$this->download_file($pm,FALSE);
	}
	public function get_file_sig($pm){
		$this->download_file($pm,TRUE);
	}

	public function get_file_out_sig($pm){
		$q = sprintf(
			"SELECT
				a.id AS application_id,
				att.file_id,
				att.file_path AS file_path,
				att.file_id,
				att.file_name
			FROM doc_flow_attachments AS att
			LEFT JOIN doc_flow_out AS dout ON dout.id=att.doc_id AND att.doc_type='doc_flow_out'
			LEFT JOIN applications AS a ON a.id=dout.to_application_id
			WHERE att.file_id=%s",
		$this->getExtDbVal($pm,'id')		
		);			
		try{
			if ($_SESSION['role_id']=='client'){
				//открывает только свои заявления!!!
				$q.=sprintf(' AND a.user_id=%d',$_SESSION['user_id']);
			}
			$ar = $this->getDbLink()->query_first($q);
			if (!is_array($ar) || !count($ar)){
				throw new Exception(self::ER_OTHER_USER_APP);	
			}
			$fl_postf = '.sig';
			$rel_fl = self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				$ar['file_path'].DIRECTORY_SEPARATOR.
				$ar['file_id'].$fl_postf;		
		
			if (!file_exists($fl=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)
			&amp;&amp;( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; !file_exists($fl=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl))
			){
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			}
		
			$mime = getMimeTypeOnExt($ar['file_name'].$fl_postf);
			ob_clean();
			downloadFile($fl, $mime,'attachment;',$ar['file_name'].$fl_postf);
			return TRUE;
		}	
		catch(Exception $e){
			$this->setHeaderStatus(400);
			throw $e;
		}
	
	}
	
	private static function add_print_to_zip($docType,&amp;$fileInfo,&amp;$relDirZip,&amp;$zip,&amp;$cnt){
		$file_ar = json_decode($fileInfo);
		if (count($file_ar)){
			$rel_path = self::dirNameOnDocType($docType).DIRECTORY_SEPARATOR;
			if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR. $rel_path.$file_ar[0]->id)
			||( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR. $rel_path.$file_ar[0]->id) )
			){
				$zip->addFile($file_doc, $rel_path.$file_ar[0]->name);
				$cnt++;				
				if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR.$rel_path.$file_ar[0]->id.self::SIG_EXT)
				||( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR.$rel_path.$file_ar[0]->id.self::SIG_EXT))
				){
					$zip->addFile($file_doc,$rel_path.$file_ar[0]->name.self::SIG_EXT);
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
		){
			//Всегда на клиентском сервере
			mkdir(FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip,0775,TRUE);
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
					document_type,
					document_id
				FROM application_document_files
				WHERE application_id=%s",
				$this->getExtDbVal($pm,'application_id')
			));			
			while($file = $this->getDbLink()->fetch_array($qid)){
				$rel_path = self::dirNameOnDocType($file['document_type']).DIRECTORY_SEPARATOR.
						$file['document_id'].DIRECTORY_SEPARATOR;
						
				if (mb_strlen($file['file_path'])>self::MAX_FILE_LEN){
					$file_path_conc = mb_substr($file['file_path'],0,self::MAX_FILE_LEN).'...';
				}
				else{
					$file_path_conc = $file['file_path'];
				}

				if (mb_strlen($file['file_name'])>self::MAX_FILE_LEN){
					$file_name_conc = mb_substr($file['file_name'],0,self::MAX_FILE_LEN).'...';
				}
				else{
					$file_name_conc = $file['file_name'];
				}
				
				$rel_path_for_zip = self::dirNameOnDocType($file['document_type']).DIRECTORY_SEPARATOR.
						$file_path_conc.DIRECTORY_SEPARATOR;
						
				if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR. $rel_path. $file['file_id'])
				|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR. $rel_path. $file['file_id']) )
				){
					$zip->addFile($file_doc, $rel_path_for_zip. $file_name_conc);
					$cnt++;				
					
					if ($file['file_signed']=='t'){
						if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.$rel_path.$file['file_id'].self::SIG_EXT)
						|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.$rel_path.$file['file_id'].self::SIG_EXT) )
						){
							$zip->addFile($file_doc,$rel_path_for_zip.$file_name_conc.self::SIG_EXT);
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
	
	private function move_files_to_new_app($storage,&amp;$ar){
		//move files
		//Документация
		$doc_type_dir = self::dirNameOnDocType($ar['doc_type']);
		$doc_type_print_dir = self::dirNameOnDocType($ar['doc_type_print']);
		$dest = $storage.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['new_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_dir;
		$source = $storage.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['old_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_dir;
		mkdir($dest,0777,TRUE);
		rmove($source,$dest);
		
		//заявления
		$dest = $storage.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['new_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_print_dir;
		$source = $storage.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['old_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_print_dir;
		mkdir($dest,0777,TRUE);
		rmove($source,$dest);
		
		//Доверенность?
		$doc_type_auth_dir = self::dirNameOnDocType('auth_letter_file');
		if (file_exists($source = $storage.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['old_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_auth_dir)
		){
			$dest = $storage.DIRECTORY_SEPARATOR.
				self::APP_DIR_PREF.$ar['new_app_id'];
			mkdir($dest,0777,TRUE);									
			rcopy($source,$dest);
		}
	}
	
	/**
  	 * @param{int} id
  	 * @param{string} state application_states
	 * @param{array} ar array of fields with all services and id
	 * @param{array} resAr array of new_app_id,doc_type,doc_type_print
	 */
	private function set_state($id,$state,&amp;$ar,&amp;$resAr){
		if ($state=='sent'||$state=='checking'){
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
		$q = '';
		if ($state=='sent'||$state=='filling'){
			$q = sprintf(
				"INSERT INTO application_processes
				(application_id,state,user_id)
				VALUES (%d,'%s',%d)",
				$id,$state,$_SESSION['user_id']
			);
		}
		else if ($state=='checking'){
			$q = sprintf(
				"INSERT INTO application_processes
				(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
				(SELECT
					doc_flow_in.from_application_id,
					now(),
					'checking',
					(SELECT user_id FROM employees WHERE id=ex.employee_id),
					ex.end_date_time,
					ex.id
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=%d
				LIMIT 1
				)",
				$id
			);
		}
		if (strlen($q)){
			$this->getDbLinkMaster()->query($q);
		}
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

	public static function checkApp(&amp;$qAr){
		if (!is_array($qAr) || !count($qAr)){
			throw new Exception(self::ER_APP_NOT_FOUND);
		}	
	}

	public function get_print($pm){
		
		if (
		!file_exists(FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.self::APP_DIR_PREF.$this->getExtDbVal($pm,'id'))
		&amp;&amp; (
			defined('FILE_STORAGE_DIR_MAIN')
			&amp;&amp; !file_exists(FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.self::APP_DIR_PREF.$this->getExtDbVal($pm,'id'))
			)
		){
			//нет ни одного файла
			$this->setHeaderStatus(400);
			throw new Exception(self::ER_NO_ATT);
		}
		
		$templ_name = $pm->getParamValue('templ');
		$out_file_name = '';
		if ($templ_name=='Application'){
			$out_file_name = self::FILE_APPLICATION;
		}
		else if ($templ_name=='ApplicationAudit'){
			$out_file_name = self::FILE_AUDIT;
		}
		else if ($templ_name=='ApplicationCostEvalValidity'){
			$out_file_name = self::FILE_COST_EVAL_VALIDITY;
		}
		else if ($templ_name=='ApplicationModification'){
			$out_file_name = self::FILE_MODIFICATION;
		}
		else{
			throw new Exception('Unknown template!');
		}
		
		$rel_dir = self::APP_DIR_PREF.$this->getExtDbVal($pm,'id');
		if (!file_exists($dir = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir)){
			mkdir($dir,0775,TRUE);
			chmod($dir, 0775);
		}
		
		$rel_out_file = $rel_dir.DIRECTORY_SEPARATOR.$out_file_name.".pdf";		
		$out_file = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_out_file;
			
		if (
		file_exists($out_pdf=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_out_file)
		|| (defined('FILE_STORAGE_DIR_MAIN')
			&amp;&amp; file_exists($out_pdf=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_out_file)
			)
		){
			downloadFile(
				$out_pdf,
				'application/pdf',
				(isset($_REQUEST['inline']) &amp;&amp; $_REQUEST['inline']=='1')? 'inline;':'attachment;',
				$out_file_name.".pdf"
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
		
		/*
		 * Экранирование больше-меньше для вывода в XML кавычки как есть
		
		foreach($ar as $fid=>$fv){
			//ENT_NOQUOTES|
			$ar[$fid] = htmlspecialchars($fv,ENT_NOQUOTES|ENT_HTML401);
		}
		*/
		$boss_name = '';
		$boss_post = '';
		$resp_m = json_decode($ar['office_responsable_persons'],TRUE);		
		$this->get_person_data_on_type($resp_m,'boss',$boss_name,$boss_post);
		if (!strlen($boss_name)){
			$this->setHeaderStatus(400);
			throw new Exception(self::ER_NO_BOSS);
		}
		try{
			$boss_decl = Morpher::declension(array('s'=>$boss_name,'flags'=>'name'),$this->getDbLinkMaster(),$this->getDbLink());
			$ar['boss_name_dat'] = get_short_name($boss_decl['Д']);
		}
		catch(Exception $e){
			$ar['boss_name_dat']	= get_short_name($boss_name);
		}
		
		try{	
			$boss_post_decl = Morpher::declension(array('s'=>$boss_post,'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink());
			$ar['boss_post_dat'] = $boss_post_decl['Д'];
		}
		catch(Exception $e){
			$ar['boss_post_dat']	= $boss_post;
		}
		
		try{	
			$office_decl = Morpher::declension(array('s'=>$ar['office_client_name_full'],'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink());
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
				$ar['constr_technical_features'].=sprintf('&lt;feature&gt;&lt;name&gt;%s&lt;/name&gt;&lt;value&gt;%s&lt;/value&gt;&lt;/feature&gt;',
					$row['fields']['name'],
					htmlspecialchars($feature_val)
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
			$person_head = array('name'=>$applicant_m['name_full'],'post'=>'');
		}
		if (strlen($applicant_m['base_document_for_contract'])){
			try{
				$base_document_for_contract = Morpher::declension(array('s'=>$applicant_m['base_document_for_contract'],'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
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
				$person_head_name_rod = get_short_name(Morpher::declension(array('s'=>$person_head['name'],'flags'=>'name'),$this->getDbLinkMaster(),$this->getDbLink())['Р']);
			}
			catch(Exception $e){
				$person_head_name_rod = get_short_name($person_head['name']);
			}
		}
		else{
			$person_head_name_rod = '';
		}		
		if (strlen($person_head['post'])){
			try{
				$person_head_post_rod = Morpher::declension(array('s'=>$person_head['post'],'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
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
				$applicant_contacts.= ($applicant_contacts=='')? '':', ';
				$applicant_contacts.= strlen($appl_resp['fields']['post'])? $appl_resp['fields']['post'].' ' : '';
				$applicant_contacts.= $appl_resp['fields']['name'];
				$applicant_contacts.= strlen($appl_resp['fields']['tel'])? ' '.$appl_resp['fields']['tel'] : '';
				$applicant_contacts.= strlen($appl_resp['fields']['email'])? ' '.$appl_resp['fields']['email'] : '';
			}
		}
		try{	
			$applicant_org_name_rod = Morpher::declension(array('s'=>$applicant_m['name_full'],'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
		}
		catch(Exception $e){
			$applicant_org_name_rod	= $applicant_m['name_full'];
		}
		if ($applicant_m['client_type']=='pboul' || $applicant_m['client_type']=='person'){
			$applicant_org_name_rod = get_short_name($applicant_org_name_rod);
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
			sprintf('&lt;client_type&gt;%s&lt;/client_type&gt;',$applicant_m['client_type']).
			sprintf('&lt;org_name_rod&gt;%s&lt;/org_name_rod&gt;',$applicant_org_name_rod).
			sprintf('&lt;ogrn&gt;%s&lt;/ogrn&gt;',$applicant_m['ogrn']).
			sprintf('&lt;field id="Контакты"&gt;%s&lt;/field&gt;',$applicant_contacts).
			(($ar['auth_letter'])? sprintf('&lt;field id="Доверенность"&gt;%s&lt;/field&gt;',$ar['auth_letter']) : '')
		;
		/*
		if ($applicant_m['client_type']=='pboul'){
		}
		*/
		
		//customer
		$customer_m = json_decode($ar['customer'],TRUE);
		$inn = $customer_m['inn'].( (strlen($customer_m['kpp']))? ('/'.$customer_m['kpp']):'' );		
		if ($customer_m['client_type']=='enterprise'){
			$person_head = json_decode($customer_m['responsable_person_head'],TRUE);
		}
		else{
			//pboul and person = name
			$person_head = array('name'=>$customer_m['name_full'],'post'=>'');			
		}
		
		if (strlen($customer_m['base_document_for_contract'])){
			try{
				$base_document_for_contract = Morpher::declension(array('s'=>$customer_m['base_document_for_contract'],'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
			}
			catch(Exception $e){
				$base_document_for_contract = $customer_m['base_document_for_contract'];
			}				
		}
		else{
			$base_document_for_contract = '';
		}
		
		if (array_key_exists('name',$person_head) &amp;&amp; strlen($person_head['name'])){
			try{
				$person_head_name_rod = Morpher::declension(array('s'=>$person_head['name'],'flags'=>'name'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
			}
			catch(Exception $e){
				$person_head_name_rod = $person_head['name'];
			}				
		}
		else{
			$person_head_name_rod = '';
		}		
		if (array_key_exists('post',$person_head) &amp;&amp; strlen($person_head['post'])){
			try{
				$person_head_post_rod = Morpher::declension(array('s'=>$person_head['post'],'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
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
			$person_head = array('name'=>$developer_m['name_full'],'post'=>'');			
		}
		
		if (strlen($developer_m['base_document_for_contract'])){
			try{
				$base_document_for_contract = Morpher::declension(array('s'=>$developer_m['base_document_for_contract'],'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
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
				$person_head_name_rod = Morpher::declension(array('s'=>$person_head['name'],'flags'=>'name'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
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
				$person_head_post_rod = Morpher::declension(array('s'=>$person_head['post'],'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
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
				$person_head = array('name'=>$contractor_m['name_full'],'post'=>'');			
			}
			
			if (strlen($contractor_m['base_document_for_contract'])){
				try{
					$base_document_for_contract = Morpher::declension(array('s'=>$contractor_m['base_document_for_contract'],'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
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
					$person_head_name_rod = Morpher::declension(array('s'=>$person_head['name'],'flags'=>'name'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
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
					$person_head_post_rod = Morpher::declension(array('s'=>$person_head['post'],'flags'=>'common'),$this->getDbLinkMaster(),$this->getDbLink())['Р'];
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
			ORDER BY f.document_type,f.document_id,f.file_name",
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
				new FieldXML($f_id,DT_STRING,array('value'=>$f_val))
			);
		}
		
		$model = new ModelVars(
			array('name'=>'Vars',
				'id'=>'ApplicationPrint_Model',
				'values'=>$m_fields
		));
		
		if ($_REQUEST['v']=='ViewPDF'){
			$cont = $model->dataToXML(TRUE);
			return $this->print_pdf($templ_name,$out_file_name,$out_file,$cont);		
		}
		else{
			$this->addModel($model);
		}	
	}
	
	private function print_pdf($templName,$outFileName,$outFile,&amp;$content){
		$xml = '&lt;?xml version="1.0" encoding="UTF-8"?&gt;';
		$xml.= '&lt;document&gt;';
		$xml.= $content;
		$xml.= '&lt;/document&gt;';
		$xml_file = OUTPUT_PATH.uniqid().".xml";
		file_put_contents($xml_file,$xml);
		//FOP
		$xslt_file = USER_VIEWS_PATH.$templName.".pdf.xsl";
		$out_file_tmp = OUTPUT_PATH.uniqid().".pdf";
		$cmd = sprintf(PDF_CMD_TEMPLATE,$xml_file, $xslt_file, $out_file_tmp);
		exec($cmd);
			
		if (!file_exists($out_file_tmp)){
			$this->setHeaderStatus(400);
			$m = NULL;
			if (DEBUG){
				$m = 'Ошибка формирования файла! CMD='.$cmd;
			}
			else{
				$m = 'Ошибка формирования файла!';
				unlink($xml_file);
			}
			throw new Exception($m);
		}
		
		rename($out_file_tmp, $outFile);
		ob_clean();
		downloadFile(
			$outFile,
			'application/pdf',
			(isset($_REQUEST['inline']) &amp;&amp; $_REQUEST['inline']=='1')? 'inline;':'attachment;',
			$outFileName.".pdf"
		);
		unlink($xml_file);
		if (file_exists($out_file_tmp)){
			rename($out_file_tmp, $outFile);
		}
	
		return TRUE;
	
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
	
	
	public function all_sig_report($pm){
		$db_app_id = $this->getExtDbVal($pm,'id');
		
		$rel_dir = self::APP_DIR_PREF.$db_app_id;
		if (!file_exists($dir = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir)){
			mkdir($dir,0775,TRUE);
			chmod($dir, 0775);
		}
	
		$templ_name = self::FILE_SIG_CHECK;
		$rel_out_file = $rel_dir.DIRECTORY_SEPARATOR.$templ_name.".pdf";		
		$out_file = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_out_file;
			
		if (
		file_exists($out_pdf=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_out_file)
		|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($out_pdf=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_out_file))
		){
			downloadFile(
				$out_pdf,
				'application/pdf',
				(isset($_REQUEST['inline']) &amp;&amp; $_REQUEST['inline']=='1')? 'inline;':'attachment;',
				$templ_name.".pdf"
			);
			return TRUE;			
		}
		
		//Header
		$ar_app = $this->getDbLink()->query_first(sprintf(
			"SELECT	
				to_char(app.create_dt,'DD/MM/YY') AS date_time_descr,			
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
			$db_app_id
		));			
	
		if ($_SESSION['role_id']=='client' &amp;&amp; $_SESSION['user_id']!=$ar_app['user_id']){
			throw new Exception(self::ER_OTHER_USER_APP);
		}
		
		//Не проверенные документы
		$qid = $this->getDbLink()->query(sprintf(
			"(SELECT 
							app_f.file_id,
							CASE
								WHEN app_f.document_type='pd' THEN 'ПД/'||app_f.document_id
								WHEN app_f.document_type='eng_survey' THEN 'РИИ/'||app_f.document_id
								WHEN app_f.document_type='cost_eval_validity' THEN 'Достоверность/'||app_f.document_id
								WHEN app_f.document_type='modification' THEN 'Модификация/'||app_f.document_id
								WHEN app_f.document_type='audit' THEN 'Аудит/'||app_f.document_id
								ELSE 'Договорные документы'
							END||'/'||app_f.file_id
							AS file_path	
						FROM application_document_files AS app_f
						LEFT JOIN file_verifications AS v ON app_f.file_id=v.file_id
						WHERE app_f.application_id=%d AND app_f.deleted=FALSE AND app_f.file_signed AND v.file_id IS NULL
						ORDER BY v.date_time)
			UNION ALL
			(SELECT 
							app_f.fl->>'id',
							'Заявления/Экспертиза/'||(app_f.fl->>'id')::text
						FROM (
						SELECT jsonb_array_elements(app_print_expertise) AS fl FROM applications WHERE id=%d AND app_print_expertise IS NOT NULL
						) AS app_f
						LEFT JOIN file_verifications AS v ON app_f.fl->>'id'=v.file_id
						WHERE v.file_id IS NULL)
			UNION ALL
			(SELECT 
							app_f.fl->>'id',
							'Заявления/Достоверность/'||(app_f.fl->>'id')::text
						FROM (
						SELECT jsonb_array_elements(app_print_cost_eval) AS fl FROM applications WHERE id=%d AND app_print_cost_eval IS NOT NULL
						) AS app_f
						LEFT JOIN file_verifications AS v ON app_f.fl->>'id'=v.file_id
						WHERE v.file_id IS NULL)			
			UNION ALL
			(SELECT 
							app_f.fl->>'id',
							'Заявления/Модификация/'||(app_f.fl->>'id')::text
						FROM (
						SELECT jsonb_array_elements(app_print_modification) AS fl FROM applications WHERE id=%d AND app_print_modification IS NOT NULL
						) AS app_f
						LEFT JOIN file_verifications AS v ON app_f.fl->>'id'=v.file_id
						WHERE v.file_id IS NULL)						
			UNION ALL
			(SELECT 
							app_f.fl->>'id',
							'Заявления/Аудит/'||(app_f.fl->>'id')::text
						FROM (
						SELECT jsonb_array_elements(app_print_audit) AS fl FROM applications WHERE id=%d AND app_print_audit IS NOT NULL
						) AS app_f
						LEFT JOIN file_verifications AS v ON app_f.fl->>'id'=v.file_id
						WHERE v.file_id IS NULL)									
			UNION ALL
			(SELECT 
							app_f.fl->>'id',
							'Доверенность/'||(app_f.fl->>'id')::text
						FROM (
						SELECT jsonb_array_elements(auth_letter_file) AS fl FROM applications WHERE id=%d AND auth_letter_file IS NOT NULL
						) AS app_f
						LEFT JOIN file_verifications AS v ON app_f.fl->>'id'=v.file_id
						WHERE v.file_id IS NULL)															
			",
			$db_app_id,
			$db_app_id,
			$db_app_id,
			$db_app_id,
			$db_app_id,
			$db_app_id
		));
		
		$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,'error');		
		$rel_dir = self::APP_DIR_PREF.$this->getExtVal($pm,'id');
		
		while($file = $this->getDbLink()->fetch_array($qid)){
			if (
			(file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$file['file_path'])
			|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$file['file_path']) )
			)
			&amp;&amp;
			(file_exists($file_doc_sig = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$file['file_path'].self::SIG_EXT)
			|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc_sig = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$file['file_path'].self::SIG_EXT) )
			)			
			){
				$db_link = $this->getDbLinkMaster();
				pki_log_sig_check($file_doc_sig, $file_doc, "'".$file['file_id']."'", $pki_man,$db_link);
			}
		}		
	
		$m = new ModelSQL($this->getDbLinkMaster(),array('id'=>'SigCheck_Model'));
		$m->query(sprintf(
			"(SELECT 
				v.date_time,
				to_char(u_certs.date_time_from,'DD/MM/YY') AS date_from,
				to_char(u_certs.date_time_to,'DD/MM/YY') AS date_to,
				round(v.check_time,1) AS check_time,
				v.check_result,
				v.error_str,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.subject_cert)).* ) f
				) AS subject_cert,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.issuer_cert)).* ) f
				) AS issuer_cert,
				to_char(f_sig.sign_date_time,'DD/MM/YY') AS sign_date_time,
				CASE
					WHEN app_f.document_type='pd' THEN 'ПД'
					WHEN app_f.document_type='eng_survey' THEN 'РИИ'
					WHEN app_f.document_type='cost_eval_validity' THEN 'Достоверность'
					WHEN app_f.document_type='modification' THEN 'Модификация'
					WHEN app_f.document_type='audit' THEN 'Аудит'
					ELSE ''
				END||' / '||app_f.file_path||' / '||app_f.file_name
				AS file_name
		
			FROM application_document_files AS app_f
			LEFT JOIN file_verifications AS v ON app_f.file_id=v.file_id
			LEFT JOIN file_signatures AS f_sig ON f_sig.file_id=v.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			WHERE app_f.application_id=%d AND app_f.deleted=FALSE AND v.date_time IS NOT NULL
			ORDER BY v.date_time)

			UNION ALL

			(SELECT
				v.date_time,
				to_char(u_certs.date_time_from,'DD/MM/YY') AS date_from,
				to_char(u_certs.date_time_to,'DD/MM/YY') AS date_to,
				round(v.check_time,1) AS check_time,
				v.check_result,
				v.error_str,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.subject_cert)).* ) f
				) AS subject_cert,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.issuer_cert)).* ) f
				) AS issuer_cert,
				to_char(f_sig.sign_date_time,'DD/MM/YY') AS sign_date_time,
				'Заявление ПД / '||(app_f.fl->>'name')::text AS file_name

			FROM (
			SELECT jsonb_array_elements(app_print_expertise) AS fl FROM applications WHERE id=%d AND app_print_expertise IS NOT NULL
			) AS app_f
			LEFT JOIN file_verifications AS v ON app_f.fl->>'id'=v.file_id
			LEFT JOIN file_signatures AS f_sig ON f_sig.file_id=v.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id)			

			UNION ALL

			(SELECT
				v.date_time,
				to_char(u_certs.date_time_from,'DD/MM/YY') AS date_from,
				to_char(u_certs.date_time_to,'DD/MM/YY') AS date_to,
				round(v.check_time,1) AS check_time,
				v.check_result,
				v.error_str,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.subject_cert)).* ) f
				) AS subject_cert,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.issuer_cert)).* ) f
				) AS issuer_cert,
				to_char(f_sig.sign_date_time,'DD/MM/YY') AS sign_date_time,
				'Заявление Достоверность / '||(app_f.fl->>'name')::text AS file_name

			FROM (
			SELECT jsonb_array_elements(app_print_cost_eval) AS fl FROM applications WHERE id=%d AND app_print_cost_eval IS NOT NULL
			) AS app_f
			LEFT JOIN file_verifications AS v ON app_f.fl->>'id'=v.file_id
			LEFT JOIN file_signatures AS f_sig ON f_sig.file_id=v.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id)			

			UNION ALL

			(SELECT
				v.date_time,
				to_char(u_certs.date_time_from,'DD/MM/YY') AS date_from,
				to_char(u_certs.date_time_to,'DD/MM/YY') AS date_to,
				round(v.check_time,1) AS check_time,
				v.check_result,
				v.error_str,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.subject_cert)).* ) f
				) AS subject_cert,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.issuer_cert)).* ) f
				) AS issuer_cert,
				to_char(f_sig.sign_date_time,'DD/MM/YY') AS sign_date_time,
				'Заявление Модификация / '||(app_f.fl->>'name')::text AS file_name

			FROM (
			SELECT jsonb_array_elements(app_print_modification) AS fl FROM applications WHERE id=%d AND app_print_modification IS NOT NULL
			) AS app_f
			LEFT JOIN file_verifications AS v ON app_f.fl->>'id'=v.file_id
			LEFT JOIN file_signatures AS f_sig ON f_sig.file_id=v.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id)			

			UNION ALL

			(SELECT
				v.date_time,
				to_char(u_certs.date_time_from,'DD/MM/YY') AS date_from,
				to_char(u_certs.date_time_to,'DD/MM/YY') AS date_to,
				round(v.check_time,1) AS check_time,
				v.check_result,
				v.error_str,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.subject_cert)).* ) f
				) AS subject_cert,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.issuer_cert)).* ) f
				) AS issuer_cert,
				to_char(f_sig.sign_date_time,'DD/MM/YY') AS sign_date_time,
				'Заявление Аудит / '||(app_f.fl->>'name')::text AS file_name

			FROM (
			SELECT jsonb_array_elements(app_print_audit) AS fl FROM applications WHERE id=%d AND app_print_audit IS NOT NULL
			) AS app_f
			LEFT JOIN file_verifications AS v ON app_f.fl->>'id'=v.file_id
			LEFT JOIN file_signatures AS f_sig ON f_sig.file_id=v.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id)			

			UNION ALL

			(SELECT
				v.date_time,
				to_char(u_certs.date_time_from,'DD/MM/YY') AS date_from,
				to_char(u_certs.date_time_to,'DD/MM/YY') AS date_to,
				round(v.check_time,1) AS check_time,
				v.check_result,
				v.error_str,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.subject_cert)).* ) f
				) AS subject_cert,
				(SELECT string_agg('&lt;field alias=\"'||f.key||'\"&gt;'||f.value||'&lt;/field&gt;','')
				FROM 
				(select (jsonb_each_text(u_certs.issuer_cert)).* ) f
				) AS issuer_cert,
				to_char(f_sig.sign_date_time,'DD/MM/YY') AS sign_date_time,
				'Доверенность / '||(app_f.fl->>'name')::text AS file_name

			FROM (
			SELECT jsonb_array_elements(auth_letter_file) AS fl FROM applications WHERE id=%d AND auth_letter_file IS NOT NULL
			) AS app_f
			LEFT JOIN file_verifications AS v ON app_f.fl->>'id'=v.file_id
			LEFT JOIN file_signatures AS f_sig ON f_sig.file_id=v.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id)			
			",
			$db_app_id,
			$db_app_id,
			$db_app_id,
			$db_app_id,
			$db_app_id,
			$db_app_id
		));
		
		$h = new ModelVars(
			array('name'=>'Vars',
				'id'=>'Header_Model',
				'values'=>array(
						new Field('application_id',DT_STRING,array('value'=>$db_app_id))
						,new Field('application_date',DT_STRING,array('value'=>$ar_app['date_time_descr']))
					)
				)
		);
		if ($_REQUEST['v']=='ViewPDF'){
			$cont = $h->dataToXML(TRUE).html_entity_decode($m->dataToXML(TRUE));
			return $this->print_pdf('ApplicationSigCheck',$templ_name,$out_file,$cont);
		}
		else{
			$this->addModel($h);
			$this->addModel($m);
		}
		
		/*
		$xml_file = OUTPUT_PATH."rep.xml";
		$xml = '&lt;?xml version="1.0" encoding="UTF-8"?&gt;';
		$xml.= '&lt;document&gt;';
		$xml.= $h->dataToXML(TRUE);
		$xml.= $m->dataToXML(TRUE);
		$xml.= '&lt;/document&gt;';
		file_put_contents($xml_file,$xml);
		*/
	}
	
	
	public function get_constr_name($pm){
		$this->addNewModel(sprintf(
			"SELECT constr_name FROM applications WHERE id=%d",
			$this->getExtDbVal($pm,'id')
		),'ConstrName_Model');
	}
	
	public static function getSigDetailsQuery($fileIdDb){
		return sprintf(
		"SELECT
			f_sig.file_id,
			jsonb_agg(
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				)
			) AS signatures
		FROM file_signatures AS f_sig
		LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
		LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id			
		WHERE ver.file_id=%s
		GROUP BY f_sig.file_id",
		$fileIdDb
		);
	}
	
	public function get_sig_details($pm){
		
		$this->addNewModel(
			self::getSigDetailsQuery($this->getExtDbVal($pm,'id')),
			'FileSignatures_Model'
		);	
	}
	
	public function get_customer_list($pm){
		$this->setCompleteModelId('ApplicationCustomerList_Model');
		$this->complete($pm);
	}
	public function get_contractor_list($pm){
		$this->setCompleteModelId('ApplicationContractorList_Model');
		$this->complete($pm);
	}
	public function get_constr_name_list($pm){
		$this->setCompleteModelId('ApplicationConstrNameList_Model');
		$this->complete($pm);
	}
	
	public static function getMaxIndexInDir($dir,$fileId){
		$m_ind = 0;
		$cdir = scandir($dir);
		foreach ($cdir as $key => $value){
			if (preg_match('/^'.$fileId.'\.sig\.s\d+$/',$value)){
				$i = substr($value,strrpos($value,'.s')+2);
				if ($i>$m_ind){
					$m_ind = $i;
				}
			}
		}
		return $m_ind;	
	}
	
	/*
	 * if relDir is empty - its common doc flow
	 */
	public static function getMaxIndexSigFile($relDir,$fileId,&amp;$maxIndex){
	
		$maxIndex = 0;
		
		if ($relDir &amp;&amp; strlen($relDir)){
			if (file_exists(FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDir)){
				$maxIndex = self::getMaxIndexInDir(FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDir,$fileId);		
				$dir = FILE_STORAGE_DIR;
			}
		
			if (defined('FILE_STORAGE_DIR_MAIN' &amp;&amp; file_exists(FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relDir))){
				$ind2 = self::getMaxIndexInDir(FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relDir,$fileId);
				if($ind2>$maxIndex){
					$maxIndex = $ind2;
					$dir = FILE_STORAGE_DIR_MAIN;
				}
			}
		}
		else{
			if (file_exists(DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR)){
				$maxIndex = Application_Controller::getMaxIndexInDir(DOC_FLOW_FILE_STORAGE_DIR,$fileId);
				$dir = DOC_FLOW_FILE_STORAGE_DIR;
			}
			if (defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists(DOC_FLOW_FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR)){
				$ind2 = Application_Controller::getMaxIndexInDir(DOC_FLOW_FILE_STORAGE_DIR_MAIN,$fileId);
				if ($ind2 > $maxIndex){
					$maxIndex = $ind2;
					$dir = DOC_FLOW_FILE_STORAGE_DIR_MAIN;
				}
			}
		
		}
		return $dir.DIRECTORY_SEPARATOR.$relDir.DIRECTORY_SEPARATOR.$fileId.'.sig.s'.$maxIndex;
	}
	
	public static function checkIULs(&amp;$dbLink,$appId,$outClientId=NULL){
		$qid = $dbLink->query(sprintf(
			"SELECT
				app_f.file_id,
				app_f.file_path,
				app_f.document_type,
				app_f.file_name	
			FROM application_document_files AS app_f
			WHERE app_f.application_id=%d
				AND NOT coalesce(app_f.file_signed,FALSE)
				AND
				( SELECT t.file_name FROM application_document_files t
				WHERE
					t.file_id&lt;&gt;app_f.file_id AND t.application_id=app_f.application_id
					AND
					lower(t.file_name) ~ ('^'||(SELECT f_name FROM file_name_explode(lower(app_f.file_name)) AS (f_name text,f_ext text))||' *- *ул *\.'||(SELECT f_ext FROM file_name_explode(lower(app_f.file_name)) AS (f_name text,f_ext text))||'$')
				) IS NULL
				AND app_f.document_type&lt;&gt;'documents'
				%s
			ORDER BY app_f.document_type,app_f.file_path,app_f.file_name",
		$appId,
		(	is_null($outClientId)? '':sprintf('AND (app_f.file_id IN (
				SELECT
					cl_f.file_id
				FROM doc_flow_out_client_document_files AS cl_f
				WHERE cl_f.doc_flow_out_client_id=%d
				) )',$outClientId)
		)
		));
		
		$err_str = '';
		while($file = $dbLink->fetch_array($qid)){
			if (!strlen($err_str)){
				$err_str = 'У следующих файлов нет ни подписи ни информационно-удостоверяющего листа: ';
			}
			else{
				$err_str.= ', ';
			}
			$err_str.= self::dirNameOnDocType($file['document_type']).'/'.$file['file_path'].'/'.$file['file_name'];
		}
		
		if (strlen($err_str)){
			throw new Exception($err_str);
		}
	}
	
	public function remove_unregistered_data_file($pm){
		$app_id = $this->getExtDbVal($pm,'id');		
	
		$state = self::checkSentState($this->getDbLink(),$app_id,TRUE);
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				TRUE AS file_exists
			FROM application_document_files
			WHERE file_id=%s AND application_id=%d",		
		$this->getExtDbVal($pm,'file_id'),
		$app_id
		));
		
		if (is_array($ar) &amp;&amp; count($ar) &amp;&amp; $ar['file_exists']=='t'){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		
		$rel_fl = self::APP_DIR_PREF.$app_id.DIRECTORY_SEPARATOR.
			self::dirNameOnDocType($this->getExtVal($pm,'doc_type')).DIRECTORY_SEPARATOR.
			$this->getExtVal($pm,'doc_id').DIRECTORY_SEPARATOR.
			$this->getExtVal($pm,'file_id');

		$data_file_exists = (
			file_exists($data_file = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)
			|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($data_file = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl))
		);
		$sig_file_exists = (
			file_exists($sig_file = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl.self::SIG_EXT)
			|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($sig_file = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl.self::SIG_EXT))
		);
			
		if (
			($data_file_exists &amp;&amp; !$sig_file_exists)
			||(!$data_file_exists &amp;&amp; $sig_file_exists)
		){
			if($data_file_exists)unlink($data_file);
			if($sig_file_exists)unlink($sig_file);
		}
	}
	
</xsl:template>

</xsl:stylesheet>
