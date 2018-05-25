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

class DocFlowExamination_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtDateTimeTZ('date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('subject'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtJSONB('subject_doc'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtJSONB('recipient'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtText('description'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_importance_type_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('end_date_time'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtText('resolution'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('close_date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('closed'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('close_employee_id'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('application_resolution_state',',','filling,sent,checking,returned,closed_no_expertise,waiting_for_contract,waiting_for_pay,expertise,closed'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DocFlowExamination_Model');

			
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
		$param = new FieldExtString('subject'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('subject_doc'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('recipient'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('description'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_importance_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('end_date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('resolution'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('close_date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('closed'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('close_employee_id'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('application_resolution_state',',','filling,sent,checking,returned,closed_no_expertise,waiting_for_contract,waiting_for_pay,expertise,closed'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocFlowExamination_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DocFlowExamination_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DocFlowExaminationDialog_Model');		

			
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
		
		$this->setListModelId('DocFlowExaminationList_Model');
		
			
		$pm = new PublicMethod('resolve');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('resolution',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtDateTimeTZ('close_date_time',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('close_employee_id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtEnum('application_resolution_state',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('unresolve');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	public function setResolved($emplForDb,$resolutionForDb,$closeDateTimeForDb,$applicationResolutionStateForDb,$examinationIdForDb){
		try{
			
			$this->getDbLinkMaster()->query('BEGIN');
			
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
			"UPDATE doc_flow_examinations
			SET
				resolution=%s,
				close_date_time=%s,
				application_resolution_state=%s,
				close_employee_id=%d,
				closed=TRUE
			WHERE id=%d
			RETURNING subject_doc",
			$resolutionForDb,
			$closeDateTimeForDb,
			$applicationResolutionStateForDb,
			$emplForDb,
			$examinationIdForDb
			));
			
			if($applicationResolutionStateForDb=="'returned'"){
				
				$subject_doc = json_decode($ar['subject_doc']);
				if ($subject_doc && $subject_doc->dataType=='doc_flow_in'){
					$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT
						from_application_id AS application_id
					FROM doc_flow_in
					WHERE id=%d",
					intval($subject_doc->keys->id)
					));
					
					if (count($ar)){
					
						//Delete PDF Zip
						Application_Controller::removeAllZipFile($ar['application_id']);
						Application_Controller::removePDFFile($ar['application_id']);
					
						//Удалить заявление
						if (file_exists($dir =
								FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
								Application_Controller::APP_PRINT_PREF)
						){
							rrmdir($dir);
						}	
						if (defined('FILE_STORAGE_DIR_MAIN') &&
						file_exists($dir =
								FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
								Application_Controller::APP_PRINT_PREF)
						){
							rrmdir($dir);
						}	
						
					}
				}
			}
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}
	}

	public function resolve($pm){
		$in_empl = $pm->getParamValue('close_employee_id');
		$this->setResolved(
			(isset($in_empl) && intval($in_empl)>0)? $this->getExtDbVal($pm,'close_employee_id') : json_decode($_SESSION['employees_ref'])->keys->id,
			$this->getExtDbVal($pm,'resolution'),
			($pm->getParamValue('close_date_time'))? $this->getExtDbVal($pm,'close_date_time') : 'now()',
			($pm->getParamValue('application_resolution_state'))? $this->getExtDbVal($pm,'application_resolution_state') : 'NULL',
			$this->getExtDbVal($pm,'id')
		);
		/*
		try{
			$in_empl = $pm->getParamValue('close_employee_id');
			
			$this->getDbLinkMaster()->query('BEGIN');
			
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
			"UPDATE doc_flow_examinations
			SET
				resolution=%s,
				close_date_time=%s,
				application_resolution_state=%s,
				close_employee_id=%d,
				closed=TRUE
			WHERE id=%d
			RETURNING subject_doc",
			$this->getExtDbVal($pm,'resolution'),
			($pm->getParamValue('close_date_time'))? $this->getExtDbVal($pm,'close_date_time') : 'now()',
			($pm->getParamValue('application_resolution_state'))? $this->getExtDbVal($pm,'application_resolution_state') : 'NULL',
			(isset($in_empl) && intval($in_empl)>0)? $this->getExtDbVal($pm,'close_employee_id') : json_decode($_SESSION['employees_ref'])->keys->id,
			$this->getExtDbVal($pm,'id')
			));
			
			if($pm->getParamValue('application_resolution_state')=='returned'){
				
				$subject_doc = json_decode($ar['subject_doc']);
				if ($subject_doc && $subject_doc->dataType=='doc_flow_in'){
					$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT
						from_application_id AS application_id
					FROM doc_flow_in
					WHERE id=%d",
					intval($subject_doc->keys->id)
					));
					
					if (count($ar)){
					
						//Delete PDF Zip
						Application_Controller::removeAllZipFile($ar['application_id']);
						Application_Controller::removePDFFile($ar['application_id']);
					
						//Удалить заявление
						if (file_exists($dir =
								FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
								Application_Controller::APP_PRINT_PREF)
						){
							rrmdir($dir);
						}	
						if (defined('FILE_STORAGE_DIR_MAIN') &&
						file_exists($dir =
								FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
								Application_Controller::APP_PRINT_PREF)
						){
							rrmdir($dir);
						}	
						
					}
				}
			}
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}
		*/
	}

	public function unresolve($pm){
		$this->getDbLinkMaster()->query(sprintf(
		"UPDATE doc_flow_examinations
		SET
			close_date_time=NULL,
			application_resolution_state = NULL,
			close_employee_id=NULL,
			closed=FALSE
		WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		$pm_obj = $this->getPublicMethod("get_object");
		$pm_obj->setParamValue('id',$pm->getParamValue('id'));
		$this->get_object($pm_obj);
	}
	

}
?>