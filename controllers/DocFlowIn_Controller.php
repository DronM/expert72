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



require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');

require_once(FRAME_WORK_PATH.'basic_classes/ModelWhereSQL.php');

class DocFlowIn_Controller extends DocFlow_Controller{

	const ER_NO_ATTACH = 'У данного документ нет вложенных файлов!';

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
		$param = new FieldExtInt('from_client_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('from_client_signed_by'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('from_client_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDate('from_client_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('from_addr_name'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('from_user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('from_application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('from_doc_flow_out_client_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('end_date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('subject'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('content'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_type_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_out_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('recipient'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('from_client_app'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('corrected_sections'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('ext_contract'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('DocFlowIn.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DocFlowIn_Model');

			
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
		$param = new FieldExtInt('from_client_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('from_client_signed_by'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('from_client_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('from_client_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('from_addr_name'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('from_user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('from_application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('from_doc_flow_out_client_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('end_date_time'
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
		$param = new FieldExtInt('doc_flow_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_out_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('recipient'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('from_client_app'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('corrected_sections'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('ext_contract'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['id'
				]
			];
			$pm->addEvent('DocFlowIn.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocFlowIn_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
				
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('DocFlowIn.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DocFlowIn_Model');

			
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
		
		$this->setListModelId('DocFlowInList_Model');
		
			
		$pm = new PublicMethod('get_ext_list');
		
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

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DocFlowInDialog_Model');		

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('reg_number'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('DocFlowInList_Model');

			
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

			
		$pm = new PublicMethod('download_attachments');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_flow_in_id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	public function insert($pm){
		if ($_SESSION['role_id'!='client']){
			if ($_SESSION['employees_ref']){
				$ar = json_decode($_SESSION['employees_ref'],TRUE);
				$pm->setParamValue('employee_id',$ar['RefType']['id']);
			}
			else{
				throw new Exception(self:: ER_EMPLOYEE_NOT_DEFINED);
			}
		}
		
		return parent::insert($pm);
	}

	public function get_state($id,$type='in'){
		parent::get_state($id,$type);
	}

	public function delete($pm){
		$this->delete_attachments($pm,'in');
	}
	
	public function remove_file($pm){
		$this->remove_afile($pm,'in');
	}
	public function remove_sig($pm){
		$this->remove_asig($pm,'in');
	}
	
	public function get_next_num($pm){
		$this->get_next_num_on_type(
			'in',
			$this->getExtDbVal($pm,'doc_flow_type_id'),
			$this->getExtDbVal($pm,'ext_contract')
		);
	}

	public function get_object($pm){
		if($_SESSION['role_id']=='expert_ext'){
			//только ответы на замечания!!!
			$model_name = $this->getObjectModelId();
			$object_model = new $model_name($this->getDbLink());
			$where = new ModelWhereSQL();
			$where->addExpression('doc_flow_type_cond',"(doc_flow_types_ref->'keys'->>'id')::int=(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int");
			
			$this->methodParamsToWhere($where,$pm,$object_model);
			$limit = new ModelLimitSQL(1);
			$object_model->select(
					FALSE,
					$where,NULL,$limit,NULL,NULL,NULL,NULL,TRUE);
			//
		
			$this->addModel($object_model);			
		}
		else{
			parent::get_object($pm);
		}	
	}

	public function get_list($pm){
		if($_SESSION['role_id']=='expert_ext'){
			//только ответы на замечания!!!
			
			$model = new DocFlowInList_Model($this->getDbLink());
			
			$from = null; $count = null;
			$limit = $this->limitFromParams($pm,$from,$count);
			$calc_total = ($count>0);
			if ($from){
				$model->setListFrom($from);
			}
			if ($count){
				$model->setRowsPerPage($count);
			}			
			$order = $this->orderFromParams($pm,$model);
			$where = $this->conditionFromParams($pm,$model);
			
			//ADDED
			if(is_null($where)){
				$where = new ModelWhereSQL();				
			}
			$where->addExpression('doc_flow_type_cond',"(doc_flow_types_ref->'keys'->>'id')::int=(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int");
			
			$fields = $this->fieldsFromParams($pm);		
			
			$model->select(FALSE,$where,$order,
				$limit,$fields,NULL,NULL,
				$calc_total,TRUE);
			//
			$this->addModel($model);
			
		}
		else{
			parent::get_list($pm);
		}
	}

	public function download_attachments($pm){
		$er_h_stat = 500;//unknown
		try{
			$doc_id = $this->getExtDbVal($pm,'doc_flow_in_id');
		
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					files,reg_number,from_application_id
				FROM doc_flow_in_dialog AS t
				WHERE id=%d",
				$doc_id
			));			
	
			if (!count($ar)){
				$er_h_stat = 400;
				throw new Exception(Application_Controller::ER_APP_NOT_FOUND);
			}
		
			$fl_name = sprintf('attach_%d.zip',$doc_id);		
			$rel_dir = Application_Controller::APP_DIR_PREF.$ar['from_application_id'].DIRECTORY_SEPARATOR.'Исходящие заявителя';
			$file_zip = NULL;
			if (
			!file_exists($file_zip = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$fl_name)
				&&
			(!defined('FILE_STORAGE_DIR_MAIN') || !file_exists($file_zip = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$fl_name))
			){
				//generate
				$files = json_decode($ar['files']);
				if (!count($files) || !count($files[0]->files)){
					$er_h_stat = 400;
					throw new Exception(self::ER_NO_ATTACH);
				}
				
				//take all file ids for getting document_ids from dataBase
				$file_ids = '';
				foreach($files[0]->files as $file){
					$file_ids.= ($file_ids=='')? '':',';
					$file_ids.= "'".$file->file_id."'";
				}
				$q_paths = $this->getDbLink()->query(sprintf(
					"SELECT
						file_id,document_id,document_type	
					FROM application_document_files AS t
					WHERE file_id IN (%s)",
					$file_ids
				));			
				$ar_paths = [];
				while($path = $this->getDbLink()->fetch_array($q_paths)){
					$ar_paths[$path['file_id']] = array('document_id'=>$path['document_id'],'document_type'=>$path['document_type']);
				}
				
				$file_zip = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$fl_name;
				mkdir(FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir,0777,TRUE);
				$zip = new ZipArchive();
				if ($zip->open($file_zip, ZIPARCHIVE::CREATE)!==TRUE) {
					throw new Exception(Application_Controller::ER_MAKE_ZIP);
				}
				$cnt = 0;
				foreach($files[0]->files as $file){
					$rel_file = Application_Controller::APP_DIR_PREF.$ar['from_application_id'].DIRECTORY_SEPARATOR.
						(($ar_paths[$file->file_id]['document_id']==0)? '' : Application_Controller::dirNameOnDocType($ar_paths[$file->file_id]['document_type']).DIRECTORY_SEPARATOR).
						(($ar_paths[$file->file_id]['document_id']==0)? $file->file_path : $ar_paths[$file->file_id]['document_id']).DIRECTORY_SEPARATOR.
						$file->file_id
					;
					if (
						(file_exists($file_for_zip=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_file) && !is_dir($file_for_zip) )
						||(defined('FILE_STORAGE_DIR_MAIN') &&  (file_exists($file_for_zip=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_file)&&!is_dir($file_for_zip)) )
					){
						$rel_file_path = (($ar_paths[$file->file_id]['document_id']==0)? '' : Application_Controller::dirNameOnDocType($ar_paths[$file->file_id]['document_type']).DIRECTORY_SEPARATOR.$file->file_path ).DIRECTORY_SEPARATOR;
						$zip->addFile($file_for_zip, $rel_file_path.$file->file_name);
						
						if (
						$file->file_signed
						&&
						(file_exists($file_for_zip=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_file.Application_Controller::SIG_EXT)
						||(defined('FILE_STORAGE_DIR_MAIN') &&  file_exists($file_for_zip=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_file.Application_Controller::SIG_EXT) )
						)
						){
							$zip->addFile($file_for_zip, $rel_file_path.$file->file_name.Application_Controller::SIG_EXT);
						}
						
						$cnt++;
					}
				}

				if (!$cnt){
					$er_h_stat = 400;
					throw new Exception(self::ER_NO_ATTACH);
				}
				
				if($zip->close()===FALSE){
					$er_h_stat = 500;
					throw new Exception('Ошибка создания архива:'.$zip->getStatusString());
				}
			}

			ob_clean();
			$mime = getMimeTypeOnExt($fl_name);
			downloadFile($file_zip, $mime,'attachment;','Файлы по вход.документу №'.$ar['reg_number'].'.zip');
			return TRUE;
	
		}
		catch(Exception $e){
			$this->setHeaderStatus($er_h_stat);
			throw $e;
		}
	}
	
	public function get_ext_list($pm){
		$this->setListModelId('DocFlowInExtList_Model');
		parent::get_list($pm);
	
	}
	


}
?>