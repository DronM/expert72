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



require_once(USER_CONTROLLERS_PATH.'DocFlowOutClient_Controller.php');

require_once('common/downloader.php');
require_once(ABSOLUTE_PATH.'functions/Morpher.php');

require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

require_once('common/file_func.php');
require_once('common/short_name.php');

class Application_Controller extends ControllerSQL{
	
	const MAX_FILE_LEN = 200;
	
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
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('create_dt'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('expertise_type',',','pd,eng_survey,pd_eng_survey'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('cost_eval_validity'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('cost_eval_validity_simult'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('modification'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('audit'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('fund_source_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('construction_type_id'
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
		$param = new FieldExtJSONB('developer'
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
		$param = new FieldExtJSONB('constr_technical_features_in_compound_obj'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('total_cost_eval'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('limit_cost_eval'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('filled_percent'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('office_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('primary_application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('primary_application_reg_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('modif_primary_application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('modif_primary_application_reg_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('build_type_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('app_print_expertise'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('app_print_cost_eval'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('app_print_modification'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('app_print_audit'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('base_application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('derived_application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('pd_usage_info'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('auth_letter'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('auth_letter_file'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
			$f_params = array();
			$param = new FieldExtBool('set_sent'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtText('app_print_expertise_files'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtText('app_print_cost_eval_files'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtText('app_print_modification_files'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtText('app_print_audit_files'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtText('auth_letter_files'
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
		
				$param = new FieldExtEnum('expertise_type',',','pd,eng_survey,pd_eng_survey'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('cost_eval_validity'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('cost_eval_validity_simult'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('modification'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('audit'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('fund_source_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('construction_type_id'
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
		$param = new FieldExtJSONB('developer'
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
		$param = new FieldExtJSONB('constr_technical_features_in_compound_obj'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('total_cost_eval'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('limit_cost_eval'
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
		$param = new FieldExtInt('primary_application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('primary_application_reg_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('modif_primary_application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('modif_primary_application_reg_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('build_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('app_print_expertise'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('app_print_cost_eval'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('app_print_modification'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('app_print_audit'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('base_application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('derived_application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('pd_usage_info'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('auth_letter'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('auth_letter_file'
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
		
			$f_params = array();
			$param = new FieldExtText('app_print_expertise_files'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtText('app_print_cost_eval_files'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtText('app_print_modification_files'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtText('app_print_audit_files'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtText('auth_letter_files'
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
		$pm->addParam(new FieldExtString('mode'));
		
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
		$pm->addParam(new FieldExtString('file_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_file_sig');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_file_out_sig');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('zip_all');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_document_templates');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('remove_document_types');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtJSON('document_types',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('download_app_print_expertise');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('download_app_print_expertise_sig');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_app_print_expertise');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('download_app_print_modification');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('download_app_print_modification_sig');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_app_print_modification');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('download_app_print_audit');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('download_app_print_audit_sig');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_app_print_audit');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('download_app_print_cost_eval');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('download_app_print_cost_eval_sig');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_app_print_cost_eval');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('set_user');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('user_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('download_auth_letter_file');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('download_auth_letter_file_sig');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_auth_letter_file');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	private function copy_print_file($appId,$id,&$fileParams,&$files){
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
		
		//sig-data indexes ".sig" - 4 chars
		$sig_ind = (strtolower(substr($files['name'][0],strlen($files['name'][0])-4,4))=='.sig')? 0 : NULL;		
		if (is_null($sig_ind)){
			$sig_ind = (strtolower(substr($files['name'][1],strlen($files['name'][1])-4,4))=='.sig')? 1 : NULL;
			if (is_null($sig_ind)){
				throw new Exception(self::ER_PRINT_FILE_CNT.$ER_PRINT_FILE_CNT_END[$id].'.');
			}
		}
		$data_ind = ($sig_ind==1)? 0:1;
		
		//data
		if (!move_uploaded_file($files['tmp_name'][$data_ind],$dir.DIRECTORY_SEPARATOR.$file_id)){
			throw new Exception('Ошибка загрузки заявления о '.$ER_PRINT_FILE_CNT_END[$id].'.');
		}
		
		//sig
		if (!move_uploaded_file($files['tmp_name'][$sig_ind],$dir.DIRECTORY_SEPARATOR.$file_id.'.sig')){
			throw new Exception('Ошибка загрузки подписи заявления о '.$ER_PRINT_FILE_CNT_END[$id].'.');
		}
	
		$fileParams[$id] = sprintf(
			'[{"name":"%s","id":"%s","size":"%s","file_signed":"true"}]',
			$files['name'][$data_ind],
			$file_id,
			$files['size'][$data_ind]
		);
	
	}

	private function upload_prints($appId,&$fileParams){
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

	public static function addDocumentFiles(&$obj,$dbLink,$documentType,$qId){
		foreach($obj as $row){
			$item = $row->fields;
			$item_id = (string) $item->id;
			$files = [];
			if (isset($qId)){
				$dbLink->data_seek(0,$qId);
				while($file = $dbLink->fetch_array($qId)){
					if ($file['document_type']==$documentType && $file['document_id']==$item_id){
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

	public function get_print_file($appId,$docType,$isSig,&$fullPath,&$fileName){
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
		if (count($f) && $f[0]->id){
			$fileName = $f[0]->name. ($isSig? '.sig':'');
			$rel_fl = self::APP_DIR_PREF.$appId.DIRECTORY_SEPARATOR.
				self::dirNameOnDocType($docType).DIRECTORY_SEPARATOR.
				$f[0]->id. ($isSig? '.sig':'');
			return (
				file_exists($fullPath=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)
				|| ( defined('FILE_STORAGE_DIR_MAIN') && file_exists($fullPath=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl) )
			);
		}		
	}

	public function delete_print($appId,$docType){
		$state = self::checkSentState($this->getDbLink(),$appId,TRUE);
		if ($_SESSION['role_id']!='admin' && $state!='filling' && $state!='correcting'){
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

	public static function attachmentsQuery($dbLink,$appId,$deletedCond){
		return $dbLink->query(sprintf(
			"SELECT
				adf.*,
				mdf.doc_flow_out_client_id,
				m.date_time AS doc_flow_out_date_time,
				reg.reg_number AS doc_flow_out_reg_number
			FROM application_document_files AS adf
			LEFT JOIN doc_flow_out_client_document_files AS mdf ON mdf.file_id=adf.file_id
			LEFT JOIN doc_flow_out_client AS m ON m.id=mdf.doc_flow_out_client_id
			LEFT JOIN doc_flow_out_client_reg_numbers AS reg ON reg.doc_flow_out_client_id=m.id
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
				NULL AS expertise_result_date
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
		
		if (isset($_REQUEST[PARAM_TEMPLATE]) && !is_null($pm->getParamValue("id"))){
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
		if ( defined('FILE_STORAGE_DIR_MAIN') &&  file_exists($fl =FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relFile)
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
			if (isset($set_sent) && $set_sent){
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
			if ( $state=='sent' && isset($resAr['new_app_id']) ){
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
		$do_check = ($_SESSION['role_id']=='client' && $checkUser);
		if ($do_check){
			$q.=sprintf(",(SELECT ap.user_id=%d FROM applications AS ap WHERE ap.id=%d) AS user_check_passed",
				$_SESSION['user_id'],$appId
			);
		}
//throw new Exception($q);
		$ar = $dbLink->query_first($q);
		self::checkApp($ar);
		
		if ($do_check && $ar['user_check_passed']!='t'){
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

		if ($pm->getParamValue('user_id') && $_SESSION['role_id']!='admin'){
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
			if (isset($set_sent) && $set_sent){
				if (is_null($ar)){
					//simple select
					$ar = $this->getDbLink()->query_first($q);
				}
				$resAr = [];
				$this->set_state(
					$this->getExtDbVal($pm,'old_id'),
					($old_state=='correcting')? 'checking':'sent',
					$ar,
					$resAr
				);
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
			if (defined('FILE_STORAGE_DIR_MAIN') && file_exists($dir =
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
		
		if ($_SESSION['role_id']!='admin' && $ar['user_id']!=$_SESSION['user_id']){
			throw new Exception(self::ER_OTHER_USER_APP);
		}
		
		if ($ar['state']=='sent'){
			throw new Exception(self::ER_DOC_SENT);
		}
	
		try{
			$dbLinkMaster->query("BEGIN");
			
			//1) Mark in DB or delete
			//|| $ar['state']=='returned'
			//В этом случае - непосредственное удаление, без копирования в Удаленные
			$unlink_file = ($ar['state']=='filling' || $ar['state']=='correcting');
			if ($unlink_file){
				$q = sprintf(
					"DELETE FROM application_document_files
					WHERE file_id=%s
					RETURNING application_id,document_type,document_id,file_id,file_name,file_signed",
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
					RETURNING application_id,document_type,document_id,file_id,file_name,file_signed",
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
				$ar['document_id'].DIRECTORY_SEPARATOR.
				$ar['file_id'];
				
			if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)){
				if (!file_exists($dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dest)){
					mkdir($dest,0777,TRUE);
				}
				if ($unlink_file){
					unlink($fl);
				}
				else{
					rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id']);
				}
			}
			if (defined('FILE_STORAGE_DIR_MAIN') && file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl)){
				if (!file_exists($dest = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dest)){
					mkdir($dest,0777,TRUE);
				}
				if ($unlink_file){
					unlink($fl);
				}
				else{
					rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id']);
				}
				
			}
			
			if ($ar['file_signed']=='t'){
				if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl.self::SIG_EXT)){
					if (!file_exists($dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dest)){
						mkdir($dest,0777,TRUE);
					}
					if ($unlink_file){
						unlink($fl);
					}
					else{				
						rename($fl, $dest.DIRECTORY_SEPARATOR.$ar['file_id'].self::SIG_EXT);
					}
				}
				if (defined('FILE_STORAGE_DIR_MAIN') && file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl.self::SIG_EXT)){
					if (!file_exists($dest = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dest)){
						mkdir($dest,0777,TRUE);
					}
					if ($unlink_file){
						unlink($fl);
					}
					else{				
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
				throw new Exception(self::ER_OTHER_USER_APP);	
			}
		
			if ($sig && $ar['file_signed']!='t'){
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
				$rel_fl = self::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
					self::dirNameOnDocType($ar['document_type']).DIRECTORY_SEPARATOR.
					$ar['document_id'].DIRECTORY_SEPARATOR.
					$ar['file_id'].$fl_postf;		
			}
		
			if (!file_exists($fl=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)
			&&( defined('FILE_STORAGE_DIR_MAIN') && !file_exists($fl=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl))
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
			&&( defined('FILE_STORAGE_DIR_MAIN') && !file_exists($fl=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl))
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
	
	private static function add_print_to_zip($docType,&$fileInfo,&$relDirZip,&$zip,&$cnt){
		$file_ar = json_decode($fileInfo);
		if (count($file_ar)){
			$rel_path = self::dirNameOnDocType($docType).DIRECTORY_SEPARATOR;
			if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR. $rel_path.$file_ar[0]->id)
			||( defined('FILE_STORAGE_DIR_MAIN') && file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR. $rel_path.$file_ar[0]->id) )
			){
				$zip->addFile($file_doc, $rel_path.$file_ar[0]->name);
				$cnt++;				
				if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR.$rel_path.$file_ar[0]->id.self::SIG_EXT)
				||( defined('FILE_STORAGE_DIR_MAIN') && file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR.$rel_path.$file_ar[0]->id.self::SIG_EXT))
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
	
		if ($_SESSION['role_id']=='client' && $_SESSION['user_id']!=$ar_app['user_id']){
			throw new Exception(self::ER_OTHER_USER_APP);
		}
	
		$rel_dir_zip =	self::APP_DIR_PREF.$this->getExtVal($pm,'application_id');
				
		if (!file_exists($file_zip = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.self::ALL_DOC_ZIP_FILE)
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
				|| (defined('FILE_STORAGE_DIR_MAIN') && file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR. $rel_path. $file['file_id']) )
				){
					$zip->addFile($file_doc, $rel_path_for_zip. $file_name_conc);
					$cnt++;				
					
					if ($file['file_signed']=='t'){
						if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.$rel_path.$file['file_id'].self::SIG_EXT)
						|| (defined('FILE_STORAGE_DIR_MAIN') && file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.$rel_path.$file['file_id'].self::SIG_EXT) )
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
	
	private function move_files_to_new_app(&$ar){
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
		
		//заявления
		$dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['new_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_print_dir;
		$source = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['old_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_print_dir;
		mkdir($dest,0777,TRUE);
		rmove($source,$dest);
		
		//Доверенность?
		$doc_type_auth_dir = self::dirNameOnDocType('auth_letter_file');
		if (file_exists($source = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			self::APP_DIR_PREF.$ar['old_app_id'].DIRECTORY_SEPARATOR.
			$doc_type_auth_dir)
		){
			$dest = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
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
	private function set_state($id,$state,&$ar,&$resAr){
		if ($state=='sent'||$state=='checking'){
			if (!is_null($ar['expertise_type']) && $ar['cost_eval_validity']=='t'){
				//убрать Достоверность в другую заявку
				$resAr['doc_type'] = 'cost_eval_validity';
				$resAr['doc_type_print'] = 'app_print_cost_eval';
			}
			else if($ar['cost_eval_validity']=='t' && $ar['modification']=='t'){
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
	
	private function get_person_data_on_type(&$jsonModel,$personType,&$personName,&$personPost){
		foreach($jsonModel['rows'] as $row){
			if ($row['fields']['person_type']==$personType){
				$personName = trim($row['fields']['name']);
				$personPost = trim($row['fields']['post']);
				break;
			}
		}
	}

	public static function checkApp(&$qAr){
		if (!is_array($qAr) || !count($qAr)){
			throw new Exception(self::ER_APP_NOT_FOUND);
		}	
	}

	public function get_print($pm){
		/*
		if (
		!file_exists(FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.self::APP_DIR_PREF.$this->getExtDbVal($pm,'id'))
		&& (defined('FILE_STORAGE_DIR_MAIN') && !file_exists(FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.self::APP_DIR_PREF.$this->getExtDbVal($pm,'id')))
		){
			//нет ни одного файла
			$this->setHeaderStatus(400);
			throw new Exception('Нет ни одного вложенного файла!');
		}
		*/
		$templ_name = $pm->getParamValue('templ');
		$rel_dir = self::APP_DIR_PREF.$this->getExtDbVal($pm,'id');
		if (!file_exists($dir = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir)){
			mkdir($dir,0775,TRUE);
			chmod($dir, 0775);
		}
		
		$rel_out_file = $rel_dir.DIRECTORY_SEPARATOR.$templ_name.".pdf";		
		$out_file = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_out_file;
			
		if (
		file_exists($out_pdf=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_out_file)
		|| (defined('FILE_STORAGE_DIR_MAIN') && file_exists($out_pdf=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_out_file))
		){
			downloadFile(
				$out_pdf,
				'application/pdf',
				(isset($_REQUEST['inline']) && $_REQUEST['inline']=='1')? 'inline;':'attachment;',
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
				$ar['constr_technical_features'].=sprintf('<feature name="%s" value="%s"/>',
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
				$applicant_contacts.= ($appl_contacts=='')? '':', ';
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
			sprintf('<field id="Наименование">%s</field>',$applicant_m['name_full']).
			sprintf('<field id="ИНН/КПП">%s</field>',$inn).
			sprintf('<field id="Юридический адрес">%s</field>',$ar['applicant_legal_address']).
			sprintf('<field id="Почтовый адрес">%s</field>',$ar['applicant_post_address']).
			sprintf('<field id="Банк">%s</field>',$ar['applicant_bank']).			
			sprintf('<field id="ФИО руководителя">%s</field>',$person_head['name']).
			sprintf('<field id="Должность руководителя">%s</field>',$person_head['post']).
			sprintf('<field id="Действует на основании">%s</field>',$base_document_for_contract).
			sprintf('<person_head_name_rod>%s</person_head_name_rod>',$person_head_name_rod).
			sprintf('<person_head_post_rod>%s</person_head_post_rod>',$person_head_post_rod).			
			sprintf('<client_type>%s</client_type>',$applicant_m['client_type']).
			sprintf('<org_name_rod>%s</org_name_rod>',$applicant_org_name_rod).
			sprintf('<ogrn>%s</ogrn>',$applicant_m['ogrn']).
			sprintf('<field id="Контакты">%s</field>',$applicant_contacts).
			(($ar['auth_letter'])? sprintf('<field id="Доверенность">%s</field>',$ar['auth_letter']) : '')
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
			$person_head = $customer_m['name'];
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
		$ar['customer'] =
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
			sprintf('<field id="Наименование">%s</field>',$developer_m['name_full']).
			sprintf('<field id="ИНН/КПП">%s</field>',$inn).
			sprintf('<field id="Юридический адрес">%s</field>',$ar['developer_legal_address']).
			sprintf('<field id="Почтовый адрес">%s</field>',$ar['developer_post_address']).
			sprintf('<field id="Банк">%s</field>',$ar['developer_bank']).		
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
			if ($contractor_m['client_type']=='enterprise'){
				$person_head = json_decode($contractor_m['responsable_person_head'],TRUE);
			}
			else{
				//pboul and person = name
				$person_head = $contractor_m['name'];
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
				$ar['documents_pd_eng_survey'] = '<files>';
			}
			/*
			$path_ar = explode('/',$file['file_path']);
			$sec1 = self::dirNameOnDocType($file['document_type']).'/'.( (count($path_ar)>=1)? $path_ar[0]:'' );
			$sec2 = (count($path_ar)>=2)? $path_ar[1]:'';
			*/
			$ar['documents_pd_eng_survey'].= sprintf('<file path="%s" name="%s"/>',
				self::dirNameOnDocType($file['document_type']).'/'.$file['file_path'],
				$file['file_name']
			);
		}
		if ($ar['documents_pd_eng_survey']!=''){		
			$ar['documents_pd_eng_survey'].= '</files>';
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
					$ar['documents_cost_eval_validity'] = '<files>';
				}
				/*			
				$path_ar = explode('/',$file['file_path']);
				$sec1 = (count($path_ar)>=1)? $path_ar[0]:'';
				$sec2 = (count($path_ar)>=2)? $path_ar[1]:'';
				$ar['documents_cost_eval_validity'].= sprintf('<file section1="%s" section2="%s" name="%s"/>',$sec1,$sec2,$file['file_name']);
				*/
				$ar['documents_cost_eval_validity'].= sprintf('<file path="%s" name="%s"/>',
					self::dirNameOnDocType($file['document_type']).'/'.$file['file_path'],
					$file['file_name']
				);
				
			}		
			if ($ar['documents_cost_eval_validity']!=''){		
				$ar['documents_cost_eval_validity'].= '</files>';
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
			$xml = '<?xml version="1.0" encoding="UTF-8"?>';
			$xml.= '<document>';
			$xml.= $model->dataToXML(TRUE);
			$xml.= '</document>';
			$xml_file = OUTPUT_PATH.uniqid().".xml";
			file_put_contents($xml_file,$xml);
			//FOP
			try{			
				$xslt_file = USER_VIEWS_PATH.$templ_name.".pdf.xsl";
				$out_file_tmp = OUTPUT_PATH.uniqid().".pdf";
				exec(sprintf(PDF_CMD_TEMPLATE,$xml_file, $xslt_file, $out_file_tmp));
					
				if (!file_exists($out_file_tmp)){
					$this->setHeaderStatus(400);
					throw new Exception('Ошибка формирования файла!');
				}
				
				rename($out_file_tmp, $out_file);
				ob_clean();
				downloadFile(
					$out_file,
					'application/pdf',
					(isset($_REQUEST['inline']) && $_REQUEST['inline']=='1')? 'inline;':'attachment;',
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
	

}
?>