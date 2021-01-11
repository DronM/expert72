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

class ExpertWork_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('contract_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('section_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('expert_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
				'alias'=>'Комментарий'
			));
		$pm->addParam($param);
		$param = new FieldExtDateTime('date_time'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtJSONB('files'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
			$f_params = array();
			$param = new FieldExtText('file_data'
			,$f_params);
		$pm->addParam($param);		
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('ExpertWork.insert',$ev_opts);
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('file_data',$opts));
	
			
		$this->addPublicMethod($pm);
		$this->setInsertModelId('ExpertWork_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('contract_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('section_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('expert_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			
				'alias'=>'Комментарий'
			));
			$pm->addParam($param);
		$param = new FieldExtDateTime('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('files'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
			$f_params = array();
			$param = new FieldExtText('file_data'
			,$f_params);
		$pm->addParam($param);		
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['id'
				]
			];
			$pm->addEvent('ExpertWork.update',$ev_opts);
			
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('file_data',$opts));
	
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('ExpertWork_Model');

			
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
		$pm->addEvent('ExpertWork.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('ExpertWork_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ExpertWorkList_Model');		

			
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
		
		$this->setListModelId('ExpertWorkList_Model');
		
			
		$pm = new PublicMethod('download_file');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('contract_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('section_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('expert_id',$opts));
	
				
	$opts=array();
	
		$opts['length']=32;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_file');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('contract_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('section_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('expert_id',$opts));
	
				
	$opts=array();
	
		$opts['length']=32;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	private function delete_files_on_id($id){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				files
			FROM expert_works
			WHERE id=%d",
		$id
		));
		$files = json_decode($ar['files']);
		foreach($files as $file){
			if (
				file_exists($fl=DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$file->id)
				||(defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')&& file_exists($fl=DOC_FLOW_FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$file->id))
			){
				unlink($fl);
			}
		}				
	}

	private function upload_file($pm){
		if (isset($_FILES['file_data'])){
		//throw new Exception("file_data set!!!");
			if ($this->getExtVal($pm,'old_id')){
				$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT
						files
					FROM expert_works
					WHERE id=%d",
				$this->getExtVal($pm,'old_id')
				));
				$files = json_decode($ar['files']);
				if(!isset($files)){
					$files = [];
				}
			}
			else{
				$files = [];
			}
			
			$i = 0;
			foreach($_FILES['file_data']['tmp_name'] as $file_name){
				$file_id = md5(uniqid().$file_name);
				$fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR. $file_id;
				move_uploaded_file($file_name, $fl);
				array_push($files,
					json_decode(sprintf(
					'{"name":"%s","id":"%s","size":"%s","date":"%s"}',
						$_FILES['file_data']['name'][$i],
						$file_id,
						filesize($fl),
						date('Y-m-d H:i:s')
					))
				);
				$i++;
			}
						
			$pm->setParamValue('files',json_encode($files));
		}
	}

	private function set_def_params(&$pm){
		//admin can do everything
		if ($_SESSION['role_id']!='admin'){			
			$emp_id = json_decode($_SESSION['employees_ref'])->keys->id;
			$is_main_expert = FALSE;
			if ($_SESSION['role_id']=='expert'){
				//can be main expert
				//contract_id||old_id must be present!
				if ($pm->getParamValue('contract_id')){
					$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT main_expert_id
					FROM contracts
					WHERE id=%d",
					$this->getExtDbVal($pm,'contract_id')
					));
				
				}
				else{
					$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT main_expert_id
					FROM contracts
					WHERE id=(SELECT ew.contract_id FROM expert_works ew WHERE ew.id=%d)",
					$this->getExtDbVal($pm,'old_id')
					));
				}
				$is_main_expert = ($ar['main_expert_id']==$emp_id);
			}
			if (!$is_main_expert){
				//date_time and expert_id = only default values
				if ($pm->getParamValue('date_time')){
					$pm->setParamValue('date_time',date('Y-m-d H:i:s'));
				}
				if ($pm->getParamValue('expert_id')){
					$pm->setParamValue('expert_id',$emp_id);
				}
				
			}
		}
	}

	public function insert($pm){
		$this->upload_file($pm);
		$this->set_def_params($pm);
		parent::insert($pm);
	}
	
	public function update($pm){
		$this->upload_file($pm);
		$this->set_def_params($pm);
		parent::update($pm);
	}

	public function delete($pm){
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			$this->delete_files_on_id($this->getExtDbVal($pm,'id'));
			
			parent::delete($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
		
	}
	
	public function download_file($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT 
				r.files->>'id' AS file_id,
				r.files->>'name' AS file_name
	
			FROM (
			SELECT
				jsonb_array_elements(files) AS files
			FROM expert_works
			WHERE
				contract_id=%d AND section_id=%d AND expert_id=%d
				AND files IS NOT NULL
				AND %s = ANY (ARRAY(SELECT f->>'id' FROM jsonb_array_elements(files) AS f))
			) AS r
			WHERE r.files->>'id'=%s",
		$this->getExtDbVal($pm,'contract_id'),
		$this->getExtDbVal($pm,'section_id'),
		$this->getExtDbVal($pm,'expert_id'),
		$this->getExtDbVal($pm,'file_id'),
		$this->getExtDbVal($pm,'file_id')
		));
		if (
			count($ar) &&
				(file_exists($fl=DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$ar['file_id'])
				||(defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')&& file_exists($fl=DOC_FLOW_FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$ar['file_id']) )
				)
		){
			$mime = getMimeTypeOnExt($ar['file_name']);
			ob_clean();
			downloadFile($fl, $mime,'attachment;',$ar['file_name']);
			return TRUE;
		}
	}

	public function delete_file($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				files
			FROM expert_works
			WHERE
				contract_id=%d AND section_id=%d AND expert_id=%d AND files IS NOT NULL
				AND %s =ANY (ARRAY(SELECT f->>'id' FROM jsonb_array_elements(files) AS f))",
		$this->getExtDbVal($pm,'contract_id'),
		$this->getExtDbVal($pm,'section_id'),
		$this->getExtDbVal($pm,'expert_id'),
		$this->getExtDbVal($pm,'file_id')
		));
		if (count($ar)){		
			$files = json_decode($ar['files']);
			$new_files = [];
			$file_id = $this->getExtVal($pm,'file_id');
			foreach($files as $file){
				if ($file->id!=$file_id){
					array_push($new_files,$file);
				}
			}
			if (
				file_exists($fl=DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$file_id)
				||(defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')&&file_exists($fl=DOC_FLOW_FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$file_id))
			){
				$new_db_files = (count($new_files))? ("'".json_encode($new_files)."'") : 'NULL';
				unlink($fl);
				$this->getDbLinkMaster()->query(sprintf(
					"UPDATE expert_works
					SET files=%s
					WHERE contract_id=%d AND section_id=%d AND expert_id=%d",
				$new_db_files,
				$this->getExtDbVal($pm,'contract_id'),
				$this->getExtDbVal($pm,'section_id'),
				$this->getExtDbVal($pm,'expert_id')				
				));
			}
		}
	}


}
?>