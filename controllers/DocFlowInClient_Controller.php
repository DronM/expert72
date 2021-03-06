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

require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');
require_once(USER_CONTROLLERS_PATH.'DocFlow_Controller.php');

class DocFlowInClient_Controller extends ControllerSQL{

	const ER_STORAGE_FILE_NOT_FOUND = 'Файл не найден!@1001';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			
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
		$param = new FieldExtInt('doc_flow_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_out_id'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
			$f_params = array();
			$param = new FieldExtText('reg_number_out'
			,$f_params);
		$pm->addParam($param);		
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['id'
				]
			];
			$pm->addEvent('DocFlowInClient.update',$ev_opts);
			
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('reg_number_out',$opts));
	
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocFlowInClient_Model');

			
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

			
		$pm = new PublicMethod('get_file_sig');
		
				
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
	
	private function get_file_on_type($pm,$isSig){
		$user_constr = ($_SESSION['role_id']=='client')?
				(" AND user_id=".$_SESSION['user_id']) : '';
				
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				att_f.file_id,
				att_f.file_name,
				att_f.file_path,
				doc_flow_in_client.application_id
			FROM doc_flow_in_client
			LEFT JOIN doc_flow_attachments AS att_f ON att_f.doc_type='doc_flow_out' AND att_f.doc_id=doc_flow_in_client.doc_flow_out_id
			WHERE doc_flow_in_client.id=%d AND att_f.file_id=%s".$user_constr,
			$this->getExtDbVal($pm,'doc_id'),
			$this->getExtDbVal($pm,'file_id')
		));
		if (!count($ar) || !$ar['application_id']){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		
		//
		$rel_file = Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				($ar['file_path']? $ar['file_path'] : DocFlow_Controller::getDefAppDir('out') ) .DIRECTORY_SEPARATOR.
				$ar['file_id'].($isSig? '.sig':'');
		if (
			!file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_file)
			&& ( defined('FILE_STORAGE_DIR_MAIN') && !file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_file) )
		){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
	
		$mime = getMimeTypeOnExt($ar['file_name']);
		ob_clean();
		downloadFile($fl, $mime,'attachment;',$ar['file_name'].($isSig? '.sig':''));
		return TRUE;	
	}

	public function get_file($pm){
		return $this->get_file_on_type($pm,FALSE);
	}
	public function get_file_sig($pm){
		return $this->get_file_on_type($pm,TRUE);
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
		
		$this->addModel(self::get_unviwed_count_model($this->getDbLinkMaster()));
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
	
	public function update($pm){
		$reg_number_out = $this->getExtDbVal($pm,'reg_number_out');
		if ($pm->getParamValue('reg_number_out')){
			$this->getDbLinkMaster()->query(sprintf(
			"SELECT doc_flow_in_client_reg_numbers_insert(%d,%s)",
			$this->getExtDbVal($pm,'old_id'),
			$reg_number_out
			));
		}
	}
	
	public function get_object($pm){
		parent::get_object($pm);
		
		//extra model
		$m = new ApplicationDocFolder_Model($this->getDbLink());
		$m->select();
		$this->addModel($m);
	}
	

}
?>