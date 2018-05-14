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
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class DocFlowInClient_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtDateTimeTZ('date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('reg_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('subject'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('content'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('files'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('viewed'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DocFlowInClient_Model');

			
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
		$param = new FieldExtInt('application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
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
		$param = new FieldExtText('comment_text'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('files'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('viewed'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocFlowInClient_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DocFlowInClient_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DocFlowInClientDialog_Model');		

			
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
		
		$this->setListModelId('DocFlowInClientList_Model');
		
			
		$pm = new PublicMethod('get_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('set_viewed');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	public function get_file($pm){
		$user_constr = ($_SESSION['role_id']=='client')?
				(" AND user_id=".$_SESSION['user_id']) : '';
				
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				files
			FROM doc_flow_in_client
			WHERE id=%d".$user_constr,
			$this->getExtDbVal($pm,'doc_id')
		));
		if (!count($ar) || !count($files=json_decode($ar['files']))){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		$file_id = $this->getExtVal($pm,'file_id');
		$new_files = [];
		$found = FALSE;
		$file_name = NULL;
		foreach($files as $file){
			if ($file->file_id==$file_id){
				$file_name = $file->file_name;
				$found = TRUE;
			}
			else{
				array_push($new_files,$file);
			}
		}
		if (!$found ||
			(!file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$file_id)
			&& ( defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN') && !file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$file_id) )
			) 
		){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
	
		$mime = getMimeTypeOnExt($file_name);
		ob_clean();
		downloadFile($fl, $mime,'attachment;',$file_name);
		return TRUE;	
	}


	public function set_viewed($pm){
		if ($_SESSION['role_id']=='client'){
			//check
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					user_id=%d AS check_passed
				FROM doc_flow_in_client
				WHERE id=%d",
				$_SESSION['user_id'],
				$this->getExtDbVal($pm,'doc_id')				
			));
			if (!count($ar) || $ar['check_passed']!='t'){
				throw new Exception('Wrong user app!');
			}
			
			$this->getDbLinkMaster()->query(sprintf(
				"UPDATE doc_flow_in_client
				SET
					viewed=TRUE,
					viewed_dt=now()
				WHERE id=%d",
				$this->getExtDbVal($pm,'doc_id')
			));
			
		}
		
		$this->addModel(self::get_unviwed_count_model($this->getDbLink()));
	}
	public static function get_unviwed_count_model($dbLink){
		$ar = $dbLink->query_first(sprintf(
			"SELECT
				count(*) AS cnt
			FROM doc_flow_in_client
			WHERE NOT viewed AND user_id=%d",
			$_SESSION['user_id']
		));
		$cnt = 0;
		if (count($ar)){
			$cnt = intval($ar['cnt']);
		}
		$model = new ModelVars(
			array('name'=>'UnviewedCount_Model',
				'id'=>'UnviewedCount_Model',
				'sysModel'=>TRUE,
				'values'=>array(
					new Field('cnt',DT_STRING,
						array('value'=>$cnt))
				)
			)
		);
		return $model;		
	}
	

}
?>