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


class DocFlowOut_Controller extends DocFlow_Controller{
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
		$param = new FieldExtInt('doc_flow_type_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('signed_by_employee_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('to_addr_names'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('to_user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('to_application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('to_contract_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('to_client_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('subject'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('content'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_in_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('new_contract_number'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
			$f_params = array();
			
			$param = new FieldExtEnum('expertise_result',',','positive,negative'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtInt('expertise_reject_type_id'
			,$f_params);
		$pm->addParam($param);		
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DocFlowOut_Model');

			
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
		$param = new FieldExtInt('doc_flow_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('signed_by_employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('to_addr_names'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('to_user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('to_application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('to_contract_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('to_client_id'
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
		$param = new FieldExtInt('doc_flow_in_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('new_contract_number'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
			$f_params = array();
			
			$param = new FieldExtEnum('expertise_result',',','positive,negative'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtInt('expertise_reject_type_id'
			,$f_params);
		$pm->addParam($param);		
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocFlowOut_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DocFlowOut_Model');

			
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
		
		$this->setListModelId('DocFlowOutList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DocFlowOutDialog_Model');		

			
		$pm = new PublicMethod('remove_file');
		
				
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

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('reg_number'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('DocFlowOutList_Model');

			
		$pm = new PublicMethod('get_app_state');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_next_contract_number');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	public function remove_file($pm){
		$this->remove_afile($pm,'out');
	}

	public function delete($pm){
		$this->delete_attachments($pm,'out');
	}
	
	public function get_next_num($pm){
		$this->get_next_num_on_type('out', $this->getExtDbVal($pm,'doc_flow_type_id'));
	}

	public function get_next_contract_number($pm){
		$model = new ModelSQL($this->getDbLinkMaster(),array('id'=>'NewNum_Model'));
		$model->query(
			sprintf(
			"SELECT
				contracts_next_number(
					CASE
					WHEN applications.expertise_type IS NOT NULL THEN 'pd'::document_types
					WHEN applications.cost_eval_validity THEN 'cost_eval_validity'::document_types
					WHEN applications.modification THEN 'modification'::document_types
					WHEN applications.audit THEN 'audit'::document_types						
					END,
					now()::date
				) AS num
			FROM applications
			WHERE id=%d",
			$this->getExtDbVal($pm,'application_id')
			)		
		,TRUE);
		$this->addModel($model);	
	}
	
	public function get_app_state($pm){
		$this->addNewModel(
			sprintf(
				"SELECT
					doc_flow_out.to_application_id,
					st.state
				FROM doc_flow_out
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=doc_flow_out.to_application_id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time				
				WHERE doc_flow_out.id=%d",
				$this->getExtDbVal($pm,'id')
			),
			'AppState_Model'
		);
	}
	
	private function update_contract_data($pm){
		$fld = NULL;
		$app_id = 0;
		if ($pm->getParamValue('expertise_result')){
			$fld = sprintf('expertise_result=%s',$this->getExtDbVal($pm,'expertise_result'));
		}
		if ($pm->getParamValue('expertise_reject_type_id') && $this->getExtDbVal($pm,'expertise_reject_type_id')>0){
			$fld = (is_null($fld))? '':($fld.',');
			$fld.= sprintf('expertise_reject_type_id=%d',$this->getExtDbVal($pm,'expertise_reject_type_id'));
		}
		
		if (!is_null($fld)){
			if ($pm->getParamValue('to_application_id')){
				$app_id = $this->getExtDbVal($pm,'to_application_id');
			}
			else if ($pm->getParamValue('old_id')){
				$app_id = $this->getDbLink()->query_first_col(sprintf("SELECT to_application_id FROM doc_flow_out WHERE id=%d",
				$this->getExtDbVal($pm,'old_id')
				));
			
			}
			if ($app_id){
				$this->getDbLinkMaster()->query(sprintf("UPDATE contracts SET %s WHERE application_id=%d",
				$fld,$app_id
				));
			}
		}
	}


	public function insert($pm){
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			$this->update_contract_data($pm);
			
			parent::insert($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}
	
	public function update($pm){
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			$this->update_contract_data($pm);
			
			parent::update($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}


}
?>