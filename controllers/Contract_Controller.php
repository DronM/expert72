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



require_once(FRAME_WORK_PATH.'basic_classes/ModelWhereSQL.php');
require_once(USER_CONTROLLERS_PATH.'DocFlowTask_Controller.php');
require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');
require_once('functions/ExtProg.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class Contract_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtDateTimeTZ('date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('client_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('reg_number'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('expertise_type',',','pd,eng_survey,pd_eng_survey'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('document_type',',','pd,eng_survey,cost_eval_validity,modification,audit,documents'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('contract_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDate('contract_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDate('contract_return_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('expertise_result_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('expertise_cost_budget'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('expertise_cost_self_fund'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('cost_eval_validity_pd_order',',','no_pd,simult_with_pd,after_pd'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDate('work_start_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDate('work_end_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDate('expert_work_end_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('expert_work_day_count'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('expertise_day_count'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('akt_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDate('akt_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('akt_total'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('akt_ext_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('kadastr_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('grad_plan_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('area_document'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('expertise_result',',','positive,negative'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDate('expertise_result_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('expertise_reject_type_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('main_department_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('main_expert_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('permissions'
				,array());
		$pm->addParam($param);
		$param = new FieldExtArray('permission_ar'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('primary_contract_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('modif_primary_contract_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('contract_ext_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('payment'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('invoice_ext_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('invoice_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDate('invoice_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSON('linked_contracts'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('date_type',',','calendar,bank'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('argument_document'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('order_document'
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
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Contract_Model');

			
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
		$param = new FieldExtInt('application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('client_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('reg_number'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('expertise_type',',','pd,eng_survey,pd_eng_survey'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('document_type',',','pd,eng_survey,cost_eval_validity,modification,audit,documents'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('contract_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('contract_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('contract_return_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('expertise_result_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('expertise_cost_budget'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('expertise_cost_self_fund'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('cost_eval_validity_pd_order',',','no_pd,simult_with_pd,after_pd'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('work_start_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('work_end_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('expert_work_end_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('expert_work_day_count'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('expertise_day_count'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('akt_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('akt_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('akt_total'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('akt_ext_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('kadastr_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('grad_plan_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('area_document'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('expertise_result',',','positive,negative'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('expertise_result_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('expertise_reject_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('main_department_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('main_expert_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('permissions'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtArray('permission_ar'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('primary_contract_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('modif_primary_contract_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('contract_ext_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('payment'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('invoice_ext_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('invoice_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('invoice_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSON('linked_contracts'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('date_type',',','calendar,bank'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('argument_document'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('order_document'
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
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Contract_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Contract_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ContractDialog_Model');		

			
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
		
		$this->setListModelId('ContractList_Model');
		
			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('expertise_result_number'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('ContractList_Model');

			
		$pm = new PublicMethod('get_pd_list');
		
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

			
		$pm = new PublicMethod('get_eng_survey_list');
		
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

			
		$pm = new PublicMethod('get_cost_eval_validity_list');
		
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

			
		$pm = new PublicMethod('get_modification_list');
		
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

			
		$pm = new PublicMethod('get_audit_list');
		
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

			
		$pm = new PublicMethod('print_order');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('order_ext_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('order_number',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_order_list');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('make_order');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
				
	$opts=array();
	
		$opts['length']=15;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtFloat('total',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('print_akt');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('print_invoice');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('make_akt');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_ext_data');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_work_end_date');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('contract_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtEnum('date_type',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('expertise_day_count',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('expert_work_day_count',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtDate('work_start_date',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	public function get_object($pm){
	
		$ar_obj = $this->getDbLink()->query_first(sprintf(
		"SELECT * FROM contracts_dialog WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
	
		if (!is_array($ar_obj) || !count($ar_obj)){
			throw new Exception("No contract found!");
		
		}
		
		//$deleted_cond = ($_SESSION['role_id']=='client')? "AND deleted=FALSE":"";
		
		$files_q_id = $this->getDbLink()->query(sprintf(
			"SELECT
				adf.*,
				mdf.doc_flow_out_client_id,
				m.date_time AS doc_flow_out_date_time,
				reg.reg_number AS doc_flow_out_reg_number
			FROM application_document_files AS adf
			LEFT JOIN doc_flow_out_client_document_files AS mdf ON mdf.file_id=adf.file_id
			LEFT JOIN doc_flow_out_client AS m ON m.id=mdf.doc_flow_out_client_id
			LEFT JOIN doc_flow_out_client_reg_numbers AS reg ON reg.doc_flow_out_client_id=m.id
			WHERE adf.application_id=%d
			ORDER BY adf.document_type,adf.document_id,adf.file_name,adf.deleted_dt ASC NULLS LAST",
		$ar_obj['application_id']
		));			
			
		$documents = NULL;
		if ($ar_obj['documents']){
			$documents_json = json_decode($ar_obj['documents']);
			foreach($documents_json as $doc){
				Application_Controller::addDocumentFiles($doc->document,$this->getDbLink(),$doc->document_type,$files_q_id);
			}
			$ar_obj['documents'] = json_encode($documents_json);
		}
		$values = [];
		foreach($ar_obj as $k=>$v){
			array_push($values,new Field($k,DT_STRING,array('value'=>$v)));
		}
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ContractDialog_Model',
				'values'=>$values
				)
			)
		);		
			
	}
	
	public function get_list($pm){
		if ($_SESSION['role_id']=='admin' || $_SESSION['role_id']=='lawyer'){
			parent::get_list($pm);
		}
		else{
			//permissions
			$list_model = $this->getListModelId();
			$model = new $list_model($this->getDbLink());
			
			$where = new ModelWhereSQL();
			DocFlowTask_Controller::set_employee_id($this->getDbLink());
			$where->addExpression('permission_ar',
				sprintf(
				"main_expert_id=%d OR 'employees%s' =ANY (permission_ar) OR 'departments%s' =ANY (permission_ar)
				OR ( %s AND main_department_id=%d )
				",
				$_SESSION['employee_id'],
				$_SESSION['employee_id'],
				$_SESSION['department_id'],
				($_SESSION['department_boss']==TRUE)? 'TRUE':'FALSE',
				$_SESSION['department_id']
				)
			);
			$model->select(FALSE,$where,NULL,
				NULL,NULL,NULL,NULL,
				NULL,TRUE
			);
			$this->addModel($model);
		}
	}

	private function get_list_on_type($pm,$documentType){
		$cond_fields = $pm->getParamValue('cond_fields');
		$cond_sgns = $pm->getParamValue('cond_sgns');
		$cond_vals = $pm->getParamValue('cond_vals');
		$cond_ic = $pm->getParamValue('cond_ic');
		$field_sep = $pm->getParamValue('field_sep');
		$field_sep = !is_null($field_sep)? $field_sep:',';
		
		$cond_fields = $cond_fields? $cond_fields.$field_sep : '';
		$cond_sgns = $cond_sgns? $cond_sgns.$field_sep : '';
		$cond_vals = $cond_vals? $cond_vals.$field_sep : '';
		$cond_ic = $cond_ic? $cond_ic.$field_sep : '';
		
		$pm->setParamValue('cond_fields',$cond_fields.'document_type');
		$pm->setParamValue('cond_sgns',$cond_sgns.'e');
		$pm->setParamValue('cond_vals',$cond_vals.$documentType);
		$pm->setParamValue('cond_ic',$cond_ic.'0');
		
		$this->get_list($pm);
	}
	
	public function get_pd_list($pm){
		$this->get_list_on_type($pm,'pd');
	}

	public function get_eng_survey_list($pm){
		$this->get_list_on_type($pm,'eng_survey');
	}
	public function get_cost_eval_validity_list($pm){
		$this->get_list_on_type($pm,'cost_eval_validity');
	}
	public function get_modification_list($pm){
		$this->get_list_on_type($pm,'modification');
	}
	public function get_audit_list($pm){
		$this->get_list_on_type($pm,'audit');
	}

	private function get_data_for_1c($contractId){
		return $this->getDbLink()->query_first(sprintf(
		"SELECT
			'Договор от '||to_char(contr.date_time,'DD.MM.YYYY')||' № '||contr.contract_number AS contract_name,
			'Договор' AS contract_type,
			contr.contract_ext_id,
			contr.contract_number,
			contr.contract_date,
			'Работы по контракту' AS item_1c_descr,
			'Работы по контракту' AS item_1c_descr_full,
			CASE
				WHEN contr.document_type='pd' THEN 'Проведение госудаственной экспертизы проектной документации'
				WHEN contr.document_type='eng_survey' THEN 'Проведение госудаственной экспертизы результатов инженерных изысканий'
				WHEN contr.document_type='cost_eval_validity' THEN 'Проведение проверки достоверности определения сметной стоимости'
				WHEN contr.document_type='modification' THEN 'Проведение модификации'
				WHEN contr.document_type='audit' THEN 'Проведение аудита'
				ELSE ''
			END||' объекта капитального строительства '||app.constr_name||' согласно договора № '||contr.contract_number||
			' от '||to_char(contr.date_time,'DD.MM.YYYY')
			--kladr_parse_addr(d.constr_address)
			AS item_1c_doc_descr,
			
			coalesce(contr.expertise_cost_budget,0)+coalesce(contr.expertise_cost_self_fund,0) AS total,
			contr.reg_number,
			
			cl.ext_id AS client_ext_id,
			cl.name AS client_name,
			cl.name_full AS client_name_full,
			cl.inn AS client_inn,
			cl.kpp AS client_kpp,
			cl.ogrn AS client_ogrn,
			cl.okpo AS client_okpo,
			cl.client_type AS client_type,
			kladr_parse_addr(cl.legal_address) AS client_legal_address,
			kladr_parse_addr(cl.post_address) AS client_post_address,
			bank_accounts->'rows' AS client_bank_accounts,
			CASE WHEN contr.expertise_type IS NOT NULL THEN contr.expertise_type::text ELSE contr.document_type::text END AS service_descr
		FROM contracts AS contr
		LEFT JOIN applications AS app ON app.id=contr.application_id		
		LEFT JOIN clients AS cl ON cl.id=contr.client_id
		WHERE contr.id=%d",
		$contractId
		));
	}

	private function set_contract_ext_id($contractId,$contractExtId){
		$this->getDbLinkMaster()->query_first(sprintf(
		"UPDATE contracts
		SET
			contract_ext_id='%s'
		WHERE id=%d",
		$contractExtId,
		$contractId
		));
	}
	private function set_client_ext_id($contractId,$clientExtId){
		$this->getDbLinkMaster()->query_first(sprintf(
		"UPDATE clients
		SET
			ext_id='%s'
		WHERE id=(SELECT t.client_id FROM contracts t WHERE t.id=%d)",
		$clientExtId,
		$contractId
		));
	}

	public function make_order($pm){
		$params = $this->get_data_for_1c($this->getExtDbVal($pm,'id'));
		$params['total'] = $this->getExtDbVal($pm,'total');
		
		if (!$params['client_inn'] || !$params['client_kpp']){
			throw new Exception('Не задан ИНН или КПП для контрагента');
		}
		if (!$params['contract_number'] || !$params['contract_date']){
			throw new Exception('Не задан номер или дата контракта!');
		}
		
		$res = [];
		ExtProg::make_order($params,$res);
		
		if (!$params['contract_ext_id'] && $res['contract_ext_id']){
			$this->set_contract_ext_id($this->getExtDbVal($pm,'id'), $res['contract_ext_id']);
		}

		if (!$params['client_ext_id'] && $res['client_ext_id']){
			$this->set_client_ext_id($this->getExtDbVal($pm,'id'), $res['client_ext_id']);
		}
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ExtDoc_Model',
				'values'=>array(
					new Field('doc_ext_id',DT_STRING,array('value'=>$res['doc_ext_id'])),
					new Field('doc_number',DT_STRING,array('value'=>$res['doc_number'])),
					new Field('doc_date',DT_DATETIME,array('value'=>$res['doc_date'])),
					new Field('doc_total',DT_FLOAT,array('value'=>$this->getExtVal($pm,'total')))
				)
			)
		));
		//ExtProg::print_order($res['doc_ext_id'],FALSE,array('name'=>'Счет№'.$res['doc_number'].'.pdf','disposition'=>'inline'));
	}
	public function make_akt($pm){
		$params = $this->get_data_for_1c($this->getExtDbVal($pm,'id'));
		if (!$params['client_inn'] || !$params['client_kpp']){
			throw new Exception('Не задан ИНН или КПП для контрагента');
		}
		if (!$params['contract_number'] || !$params['contract_date']){
			throw new Exception('Не задан номер или дата контракта!');
		}
		
		$res = [];
		ExtProg::make_akt($params,$res);
		
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
		"UPDATE contracts
		SET
			contract_ext_id='%s',
			akt_ext_id='%s',
			akt_date='%s',
			akt_number='%s',
			akt_total=%f,
			invoice_ext_id='%s',
			invoice_number='%s',
			invoice_date='%s'
		WHERE id=%d
		RETURNING client_id",
		$res['contract_ext_id'],
		$res['doc_ext_id'],
		$res['doc_date'],
		$res['doc_number'],
		$res['doc_total'],
		$res['invoice_ext_id'],
		$res['invoice_number'],
		$res['invoice_date'],
		$this->getExtDbVal($pm,'id')
		));

		if (!$params['client_ext_id'] && $res['client_ext_id']){
			$this->getDbLinkMaster()->query(sprintf(
			"UPDATE clients
			SET
				ext_id='%s'
			WHERE id=%d",
			$res['client_ext_id'],
			$ar['client_id']
			));
		}
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ExtDoc_Model',
				'values'=>array(
					new Field('akt_ext_id',DT_STRING,array('value'=>$res['doc_ext_id'])),
					new Field('akt_number',DT_STRING,array('value'=>$res['doc_number'])),
					new Field('akt_date',DT_DATETIME,array('value'=>$res['doc_date'])),
					new Field('akt_total',DT_FLOAT,array('value'=>$res['doc_total'])),
					new Field('invoice_ext_id',DT_STRING,array('value'=>$res['invoice_ext_id'])),
					new Field('invoice_number',DT_STRING,array('value'=>$res['invoice_number'])),
					new Field('invoice_date',DT_DATETIME,array('value'=>$res['invoice_date']))
				)
			)
		));
		//ExtProg::print_akt($res['doc_ext_id'],FALSE,array('name'=>'Акт№'.$res['doc_number'].'.pdf','disposition'=>'inline'));
	}
	
	public function print_akt($pm){
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
		"SELECT
			akt_number,
			akt_ext_id
		FROM contracts
		WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		if (!count($ar)){
			header(HEADER_404);
			
		}
		ExtProg::print_akt($ar['akt_ext_id'],FALSE,array('name'=>'Акт№'.$ar['akt_number'].'.pdf','disposition'=>'inline'));
		return TRUE;
	}
	public function print_invoice($pm){
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
		"SELECT
			invoice_number,
			invoice_ext_id
		FROM contracts
		WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		if (!count($ar)){
			header(HEADER_404);
			
		}
		ExtProg::print_invoice($ar['invoice_ext_id'],FALSE,array('name'=>'СчетФактура№'.$ar['invoice_number'].'.pdf','disposition'=>'inline'));
		return TRUE;
		
	}
	
	public function print_order($pm){
		ExtProg::print_order($this->getExtVal($pm,'order_ext_id'),FALSE,array('name'=>'Счет№'.$this->getExtVal($pm,'order_number').'.pdf','disposition'=>'inline'));
		return TRUE;
	}
	
	public function get_order_list($pm){
		$params = $this->get_data_for_1c($this->getExtDbVal($pm,'id'));
		if (!$params['contract_number'] || !$params['contract_date'] || !$params['client_inn'] || !$params['client_kpp']){
			$field_val = NULL;
		}
		else{
			$res = [];
			ExtProg::get_order_list($params,$res);
		
			if (!$params['contract_ext_id'] && $res['contract_ext_id']){
				$this->set_contract_ext_id($this->getExtDbVal($pm,'id'), $res['contract_ext_id']);
			}

			if (!$params['client_ext_id'] && $res['client_ext_id']){
				$this->set_client_ext_id($this->getExtDbVal($pm,'id'), $res['client_ext_id']);
			}
			$field_val = json_encode($res['orders']);
		}		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'OrderList_Model',
				'values'=>array(
					new Field('list',DT_STRING,array('value'=>$field_val))
				)
			)
		));		
	}
	
	public function get_ext_data($pm){
		$res = $this->getDbLink()->query_first(sprintf(
		"SELECT
			akt_ext_id,
			akt_number,
			akt_date,
			akt_total,
			invoice_ext_id,
			invoice_number,
			invoice_date			
		FROM contracts
		WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		
		if (!count($res)){
			throw new Exception('Contract not found!');
		}
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ExtDoc_Model',
				'values'=>array(
					new Field('akt_ext_id',DT_STRING,array('value'=>$res['akt_ext_id'])),
					new Field('akt_number',DT_STRING,array('value'=>$res['akt_number'])),
					new Field('akt_date',DT_DATETIME,array('value'=>$res['akt_date'])),
					new Field('akt_total',DT_FLOAT,array('value'=>$res['akt_total'])),
					new Field('invoice_ext_id',DT_STRING,array('value'=>$res['invoice_ext_id'])),
					new Field('invoice_number',DT_STRING,array('value'=>$res['invoice_number'])),
					new Field('invoice_date',DT_DATETIME,array('value'=>$res['invoice_date']))
				)
			)
		));
		
	}
	
	public function get_work_end_date($pm){
		$this->addNewModel(
			sprintf(
			"WITH (SELECT app.office_id AS office_id
				FROM contracts AS contr
				LEFT JOIN applications AS app ON app.id=contr.application_id
				WHERE contr.id=%d
			) AS contr
			SELECT
				contracts_work_end_date(
					(SELECT office_id FROM contr),
					%s,
					%s,
					%d
				) AS end_dt,
				contracts_work_end_date(
					(SELECT office_id FROM contr),
					%s,
					%s,
					%d
				) AS work_end_dt				
			",
			$this->getExtDbVal($pm,'contract_id'),
			$this->getExtDbVal($pm,'date_type'),
			$this->getExtDbVal($pm,'work_start_date'),
			$this->getExtDbVal($pm,'expertise_day_count'),
			$this->getExtDbVal($pm,'date_type'),
			$this->getExtDbVal($pm,'work_start_date'),
			$this->getExtDbVal($pm,'expert_work_day_count')
			),
		'Date_Model'
		);		
	}
	

}
?>