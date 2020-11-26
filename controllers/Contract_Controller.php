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

require_once(FRAME_WORK_PATH.'basic_classes/ConditionParamsSQL.php');

require_once('functions/ExtProg.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class Contract_Controller extends ControllerSQL{

	const ER_NO_DOC = 'Документ не найден!';

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
		
				$param = new FieldExtEnum('expertise_type',',','pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey'
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
		$param = new FieldExtBool('for_all_employees'
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
		$param = new FieldExtJSONB('constr_technical_features_in_compound_obj'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('in_estim_cost'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('in_estim_cost_recommend'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('cur_estim_cost'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('cur_estim_cost_recommend'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('result_sign_expert_list'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('primary_contract_reg_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('experts_for_notification'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('contract_return_date_on_sig'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('fund_source_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('allow_new_file_add'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('allow_client_out_documents'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('service_type',',','expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance'
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
		
				$param = new FieldExtEnum('expertise_type',',','pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey'
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
		$param = new FieldExtBool('for_all_employees'
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
		$param = new FieldExtJSONB('constr_technical_features_in_compound_obj'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('in_estim_cost'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('in_estim_cost_recommend'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('cur_estim_cost'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('cur_estim_cost_recommend'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('result_sign_expert_list'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('primary_contract_reg_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('experts_for_notification'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('contract_return_date_on_sig'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('fund_source_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('allow_new_file_add'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('allow_client_out_documents'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('service_type',',','expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance'
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
		
			$f_params = array();
			$param = new FieldExtString('fields'
			,$f_params);		
		$pm->addParam($param);		
		
		
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

			
		$pm = new PublicMethod('get_expert_maintenance_list');
		
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

			
		$pm = new PublicMethod('get_modified_documents_list');
		
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

			
		$pm = new PublicMethod('get_expertise_list');
		
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

			
		$pm = new PublicMethod('get_pd_cost_valid_eval_list');
		
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
	
				
	$opts=array();
	
		$opts['length']=20;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('acc_number',$opts));
	
			
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

			
		$pm = new PublicMethod('get_object_inf');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('templ',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('inline',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_reestr_expertise');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

				
	$opts=array();
					
		$pm->addParam(new FieldExtString('templ',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('inline',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_reestr_cost_eval');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

				
	$opts=array();
					
		$pm->addParam(new FieldExtString('templ',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('inline',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_constr_name');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_reestr_pay');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

				
	$opts=array();
					
		$pm->addParam(new FieldExtString('templ',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('inline',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_reestr_contract');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

				
	$opts=array();
					
		$pm->addParam(new FieldExtString('templ',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('inline',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_quarter_rep');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

				
	$opts=array();
					
		$pm->addParam(new FieldExtString('templ',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('inline',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('ext_contract_to_contract');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('contract_id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	public function get_object($pm){		
		$columns = '*';
		$tb = 'contracts_dialog';
		$fields = $this->getExtVal($pm,'fields');
		if ($fields && strlen($fields) && strtolower($fields)!='null'){
			$aval_fields = ['experts_for_notification'];
			$fields_ar = explode(',',$fields);
			foreach($fields_ar as $field){
				if (array_search($field,$aval_fields)!==FALSE){
					if ($columns=='*'){
						$columns = '';
					}
					else{
						$columns.= ',';
					}
					$columns.= $field;
				}
			}
			if($columns!='*'){
				$tb = 'contracts';
			}
		}
	
		//Дополнительные проверки на визимость контракта
		$where = new ModelWhereSQL();
		$where->addExpression('id',sprintf('id=%d',$this->getExtDbVal($pm,'id')));
		$this->addPermissionCond($where,$tb);
	
		$ar_obj = $this->getDbLink()->query_first(sprintf(
		"SELECT %s FROM %s %s",
		$columns,
		$tb,
		$where->getSQL()
		));
	
		if (!is_array($ar_obj) || !count($ar_obj)){
			throw new Exception(self::ER_NO_DOC);
		
		}
		
		$files_q_id = Application_Controller::attachmentsQuery(
			$this->getDbLink(),
			$ar_obj['application_id'],
			''
		);
		
		/*
		$files_q_id = $this->getDbLink()->query(sprintf(
			"SELECT
				adf.file_id,
				adf.document_id,
				adf.document_type,
				adf.date_time,
				adf.file_name,
				adf.file_path,
				adf.file_signed,
				adf.file_size,
				adf.deleted,
				adf.deleted_dt,
				adf.information_list,
				mdf.doc_flow_out_client_id,
				m.date_time AS doc_flow_out_date_time,
				reg.reg_number AS doc_flow_out_reg_number,
				(clorg_f.new_file_id IS NOT NULL) AS is_switched,
				
				(WITH sign AS (
					SELECT
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					WHERE f_sig.file_id = adf.file_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
				)
				SELECT
					CASE
						WHEN (SELECT sign.signatures FROM sign) IS NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'id',adf.file_id,
									'owner',NULL,
									'sign_date_time',NULL,
									'check_result',NULL,
									'check_time',NULL,
									'error_str',NULL
								)
							)
						ELSE (SELECT sign.signatures FROM sign)
					END
				) AS signatures
				
			FROM application_document_files AS adf
			LEFT JOIN doc_flow_out_client_document_files AS mdf ON mdf.file_id=adf.file_id
			LEFT JOIN doc_flow_out_client AS m ON m.id=mdf.doc_flow_out_client_id
			LEFT JOIN doc_flow_out_client_reg_numbers AS reg ON reg.doc_flow_out_client_id=m.id
			LEFT JOIN doc_flow_out_client_original_files AS clorg_f ON clorg_f.doc_flow_out_client_id=m.id AND clorg_f.new_file_id=adf.file_id
			
			WHERE adf.application_id=%d AND adf.document_id>0
			ORDER BY
				adf.document_type,
				adf.document_id,
				adf.file_name,
				adf.deleted_dt ASC NULLS LAST",
		$ar_obj['application_id']
		));
		*/
		
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
		
		//extra value, document visibility for expert
		$contract_document_visib = ($_SESSION['role_id']!='expert_ext');
		if ($_SESSION['role_id']=='expert'){			
			if (!isset($_SESSION['contract_document_visib'])){
				$contract_document_visib = FALSE;
				$emp_id = intval(json_decode($_SESSION['employees_ref'])->keys->id);
				$ar = $this->getDbLink()->query_first(sprintf("SELECT const_contract_document_visib_expert_list_val() AS v"));
				if(count($ar)){
					$l = json_decode($ar['v']);
					foreach ($l->rows as $r){
						if (intval($r->fields->employees_ref->keys->id)==$emp_id){
							$contract_document_visib = TRUE;
							break;
						}
					}
					$_SESSION['contract_document_visib'] = $contract_document_visib;
				}
			}
			else{
				$contract_document_visib = $_SESSION['contract_document_visib'];
			}			
		}	
		array_push($values,new Field('contract_document_visib',DT_BOOL,array('value'=>$contract_document_visib)));
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ContractDialog_Model',
				'values'=>$values
				)
			)
		);		
		
	}
	
	private function addPermissionCond(&$where,$tb){
		if ($_SESSION['role_id']!='admin' && $_SESSION['role_id']!='lawyer' && $_SESSION['role_id']!='boss'&& $_SESSION['role_id']!='accountant'){
			DocFlowTask_Controller::set_employee_id($this->getDbLink());
			
			$perm_col = ($tb=='contracts')? 'permission_ar':'condition_ar';
			
			$where->addExpression('permission_ar',
				sprintf(
				"(%s
					(main_expert_id=%d OR 'employees%s' =ANY (".$perm_col.") OR 'departments%s' =ANY (".$perm_col.")
						OR ( %s AND main_department_id=%d )
					)
				)",
				($_SESSION['role_id']=='expert')? 'for_all_employees OR ':'',
				$_SESSION['employee_id'],
				$_SESSION['employee_id'],
				$_SESSION['department_id'],
				($_SESSION['department_boss']==TRUE)? 'TRUE':'FALSE',
				$_SESSION['department_id']
				)
			);	
		}
	}
	
	public function get_list($pm){
		if ($_SESSION['role_id']=='admin' || $_SESSION['role_id']=='lawyer' || $_SESSION['role_id']=='boss' || $_SESSION['role_id']=='accountant'){
			parent::get_list($pm);
		}
		else{
			//permissions
			$list_model = $this->getListModelId();
			$model = new $list_model($this->getDbLink());
			
			$where = $this->conditionFromParams($pm,$model);
			if (!$where){
				$where = new ModelWhereSQL();
			}
			$this->addPermissionCond($where,'contracts_list');
			
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
			$fields = $this->fieldsFromParams($pm);		
			$model->select(FALSE,$where,$order,
				$limit,$fields,NULL,NULL,
				$calc_total,TRUE
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

	private function get_list_on_service_type($pm,$serviceType){
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
		
		$pm->setParamValue('cond_fields',$cond_fields.'service_type');
		$pm->setParamValue('cond_sgns',$cond_sgns.'e');
		$pm->setParamValue('cond_vals',$cond_vals.$serviceType);
		$pm->setParamValue('cond_ic',$cond_ic.'0');
		
		$this->get_list($pm);
	}
	
	public function get_pd_list($pm){
		$this->get_list_on_type($pm,'pd');
	}

	public function get_expert_maintenance_list($pm){
		$this->get_list_on_service_type($pm,'expert_maintenance');
	}
	public function get_modified_documents_list($pm){
		$this->get_list_on_service_type($pm,'modified_documents');
	}

	/**
	 * Все по гос.экспертизе:
	 *  ПД,РИИ,Достоверность,ПД+РИИ,ПД+РИИ+Достоверность,ПД+Достоверность
	 */	
	public function get_expertise_list($pm){
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
		
		$pm->setParamValue('cond_fields',$cond_fields.'expertise_type');//is not null
		$pm->setParamValue('cond_sgns',$cond_sgns.'in');
		$pm->setParamValue('cond_vals',$cond_vals.'');
		$pm->setParamValue('cond_ic',$cond_ic.'0');
		
		$this->get_list($pm);
	}

	public function get_pd_cost_valid_eval_list($pm){
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
		
		$pm->setParamValue('cond_fields',$cond_fields.'document_type'.$field_sep.'exp_cost_eval_validity');
		$pm->setParamValue('cond_sgns',$cond_sgns.'e'.$field_sep.'e');
		$pm->setParamValue('cond_vals',$cond_vals.'pd'.$field_sep.'1');
		$pm->setParamValue('cond_ic',$cond_ic.'0'.$field_sep.'0');
		
		$this->get_list($pm);
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
			' от '||to_char(contr.contract_date,'DD.MM.YYYY')
			--kladr_parse_addr(d.constr_address)
			AS item_1c_doc_descr,
			
			coalesce(contr.expertise_cost_budget,0)+coalesce(contr.expertise_cost_self_fund,0) AS total,
			contr.reg_number,
			
			(SELECT
				jsonb_agg(json_build_object('pay_docum_date',pm.pay_docum_date,'pay_docum_number',pm.pay_docum_number))
			FROM client_payments AS pm
			WHERE pm.contract_id=contr.id
			) AS payment,
			
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
		$params['acc_number'] = $this->getExtDbVal($pm,'acc_number');
		if (strtolower($params['acc_number'])=='null'){
			//не понимает с клиента???
			throw new Exception('Не выбран лицевой счет!');
		}
		
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
			"WITH contr AS (SELECT app.office_id AS office_id
				FROM contracts AS contr
				LEFT JOIN applications AS app ON app.id=contr.application_id
				WHERE contr.id=%d
			)
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
	
	public function update($pm){
		$for_all_employees = $pm->getParamValue('for_all_employees');
		$permissions = $pm->getParamValue('permissions');
		if(
		($_SESSION['role_id']!='admin' && $_SESSION['role_id']!='boss')
		&&
		( isset($for_all_employees) || isset($permissions) )
		){
			throw new Exception('Изменение набора прав контракта доступно только администратору и руководителю!');
		}
		
		parent::update($pm);
	}
	
	public function get_object_inf($pm){
		$this->addNewModel(
			sprintf(
			"SELECT
				t.id,
				t.constr_name,
				kladr_parse_addr(t.constr_address) AS constr_address,
				t.grad_plan_number,
				t.kadastr_number,
				t.area_document,
				app.customer->>'name' AS customer_name,
				(SELECT
					string_agg(a2.contractor_name,', ')
				FROM (SELECT (jsonb_array_elements(app.contractors)->>'name')::text AS contractor_name) AS a2
				) AS contrcator_names,
				t.expertise_result,
				t.reg_number,
				t.expertise_result_date,
				format_date_rus(t.expertise_result_date,FALSE) AS expertise_result_date_descr,
				
				t.document_type
				
			FROM contracts AS t
			LEFT JOIN applications AS app ON app.id=t.application_id
			WHERE t.id=%d",
			$this->getExtDbVal($pm,'id')
			),
		'ObjectData_Model'
		);		
		
		$this->addNewModel(
			sprintf(
			"SELECT rep.* FROM
			(SELECT
				jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'name' AS n,
				jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'value' AS v
			FROM contracts AS t
			LEFT JOIN applications AS app ON app.id=t.application_id
			WHERE t.id=%d) AS rep
			ORDER BY rep.n
			",
			$this->getExtDbVal($pm,'id')
			),
		'FeatureList_Model'
		);		
		
	}
	
	public function get_reestr_expertise($pm){
		$cond = new ConditionParamsSQL($pm,$this->getDbLink());
		$dt_from = $cond->getDbVal('date_time','ge',DT_DATETIME);
		if (!isset($dt_from)){
			throw new Exception('Не задана дата начала!');
		}		
		$dt_to = $cond->getDbVal('date_time','le',DT_DATETIME);
		if (!isset($dt_to)){
			throw new Exception('Не задана дата окончания!');
		}		
		
		$exp_res_cond = '';
		$expertise_result = $cond->getVal('expertise_result','e',DT_STRING);
		if ($expertise_result=='positive'){
			$exp_res_cond.= " AND t.expertise_result='positive'";
		}
		else if ($expertise_result=='negative'){
			$exp_res_cond.= " AND t.expertise_result='negative'";
		}
		else{
			$expertise_result = '';
		}
		
		$model = new RepReestrExpertise_Model($this->getDbLink());
		$model->query(
			sprintf(
			"SELECT
				row_number() OVER (ORDER BY t.expertise_result_date) AS ord,
				
				(SELECT
					string_agg(a2.contractor_name,', ')
				FROM (SELECT (jsonb_array_elements(app.contractors)->>'name')::text AS contractor_name) AS a2
				) AS contrcator_names,
			
				(SELECT
					string_agg(e.n,', ')
	
					FROM (SELECT
						jsonb_array_elements(t.result_sign_expert_list->'rows')->'fields'->'employees_ref'->>'descr' AS n
					) AS e
	
				) AS experts,
				
				t.contract_number||' от '||to_char(t.contract_date,'DD/MM/YY') AS contract,
				
				t.constr_name,
				kladr_parse_addr(t.constr_address) AS constr_address,
				
				(SELECT
					string_agg(rep.n||':'||rep.v,', ')
					FROM (SELECT
						jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'name' AS n,
						jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'value' AS v
					) AS rep
				) AS constr_features,
				
				t.kadastr_number,
				t.grad_plan_number,				
				
				coalesce(app.developer->>'name','')||
				CASE WHEN app.developer->>'name' IS NOT NULL THEN ', ' ELSE '' END||
				coalesce(app.customer->>'name','')
				AS developer_customer,
								
				t.area_document,
				
				CASE
					WHEN t.expertise_result='negative' THEN 'Отрицательое заключение: '||rej.name
					ELSE 'Положительное заключение'
				END AS exeprtise_res_descr,
				
				CASE
					WHEN t.expertise_type='pd' THEN 'ПД'
					WHEN t.expertise_type='eng_survey' THEN 'РИИ'
					WHEN t.expertise_type='pd_eng_survey' THEN 'ПД и РИИ'
					WHEN t.expertise_type='cost_eval_validity' THEN 'Достоверность'
					WHEN t.expertise_type='cost_eval_validity_pd' THEN 'ПД и Достоверность'
					WHEN t.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ и Достоверность'
					WHEN t.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД,РИИ,Достоверность'
					ELSE '-'
				END AS exeprtise_type,
				
				t.reg_number,
				
				t.expertise_result_date::date AS expertise_result_date,
				
				t.date_time::date AS date_time,
				
				(SELECT max(p.pay_date::date) FROM client_payments AS p
				WHERE p.contract_id=t.id
				) AS pay_date,
				
				t.expertise_result_date AS expertise_result_ret_date,
				t.id AS contract_id
				
			FROM contracts AS t
			LEFT JOIN applications AS app ON app.id=t.application_id
			LEFT JOIN expertise_reject_types AS rej ON rej.id=t.expertise_reject_type_id
			WHERE t.expertise_result_date BETWEEN %s AND (%s::timestamp+'1 day'::interval-'1 second'::interval)
				AND document_type='pd' AND t.expertise_result IS NOT NULL %s
			ORDER BY t.expertise_result_date",
			$dt_from,
			$dt_to,
			$exp_res_cond
			)
		);
		$this->addModel($model);
		
		$this->addNewModel(
			sprintf(
			"SELECT
				format_period_rus(%s::date,%s::date,NULL) AS period_descr,
				'%s' AS expertise_result
			",
			$dt_from,
			$dt_to,
			$expertise_result
			),
		'Head_Model'
		);		
	
	}
	
	public function get_reestr_cost_eval($pm){
		$cond = new ConditionParamsSQL($pm,$this->getDbLink());
		$dt_from = $cond->getDbVal('date_time','ge',DT_DATETIME);
		if (!isset($dt_from)){
			throw new Exception('Не задана дата начала!');
		}		
		$dt_to = $cond->getDbVal('date_time','le',DT_DATETIME);
		if (!isset($dt_to)){
			throw new Exception('Не задана дата окончания!');
		}		
		
		$exp_res_cond = '';
		$expertise_result = $cond->getVal('expertise_result','e',DT_STRING);
		if ($expertise_result=='positive'){
			$exp_res_cond.= " AND t.expertise_result='positive'";
		}
		else if ($expertise_result=='negative'){
			$exp_res_cond.= " AND t.expertise_result='negative'";
		}
		else{
			$expertise_result = '';
		}
		
		$model = new RepReestrCostEval_Model($this->getDbLink());
		$model->query(
			sprintf(
			"SELECT
				row_number() OVER (ORDER BY t.expertise_result_date) AS ord,
				t.constr_name,
				
				CASE WHEN t.constr_address IS NOT NULL THEN kladr_parse_addr(t.constr_address)||', ' ELSE '' END||
				(SELECT
					string_agg(rep.n||':'||rep.v,', ')
					FROM (SELECT
						jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'name' AS n,
						jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'value' AS v
					) AS rep
				)				
				AS constr_address_features,
				
				coalesce(app.customer->>'name','')||
				CASE WHEN app.customer->>'name' IS NOT NULL THEN ', ' ELSE '' END||
				coalesce(app.developer->>'name','')
				AS customer_developer,
				
				(SELECT
					string_agg(a2.contractor_name,', ')
				FROM (SELECT (jsonb_array_elements(a1.contractors)->>'name')::text AS contractor_name FROM applications AS a1 WHERE a1.id=t.application_id) AS a2
				) AS contrcator_names,
			
				CASE
					WHEN t.expertise_result='negative' THEN 'Отрицательое заключение: '||rej.name
					ELSE 'Положительное заключение'
				END AS exeprtise_res_descr,
			
				t.reg_number||' от '||to_char(t.expertise_result_date,'DD/MM/YY') AS exeprtise_res_number_date,			
			
				t.order_document,
				t.argument_document,
				t.id AS contract_id
				
			FROM contracts AS t
			LEFT JOIN applications AS app ON app.id=t.application_id
			LEFT JOIN expertise_reject_types AS rej ON rej.id=t.expertise_reject_type_id
			WHERE t.expertise_result_date BETWEEN %s AND (%s::timestamp+'1 day'::interval-'1 second'::interval)
				AND document_type='cost_eval_validity' AND t.expertise_result IS NOT NULL %s
			ORDER BY t.expertise_result_date",
			$dt_from,
			$dt_to,
			$exp_res_cond
			)
		);
		$this->addModel($model);
		
		$this->addNewModel(
			sprintf(
			"SELECT
				format_period_rus(%s::date,%s::date,NULL) AS period_descr,
				'%s' AS expertise_result
			",
			$dt_from,
			$dt_to,
			$expertise_result
			),
		'Head_Model'
		);		
	
	}

	/**
	 * Вызывается из формы исходящего документа для формирования темы письма
	 * с 19/08/20 + признак внеконтракта
	 */
	public function get_constr_name($pm){
		$this->addNewModel(sprintf(
			"SELECT
				contr.constr_name,
				app.ext_contract AS ext_contract
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			WHERE contr.id=%d",
			$this->getExtDbVal($pm,'id')
		),'ConstrName_Model');
	}
	
	public function get_reestr_pay($pm){
		$cond = new ConditionParamsSQL($pm,$this->getDbLink());
		$dt_from = $cond->getDbVal('date_time','ge',DT_DATE);
		if (!isset($dt_from)){
			throw new Exception('Не задана дата начала!');
		}		
		$dt_to = $cond->getDbVal('date_time','le',DT_DATE);
		if (!isset($dt_to)){
			throw new Exception('Не задана дата окончания!');
		}		
	
		$extra_cond = '';
		$client_id = $cond->getDbVal('client_id','e',DT_INT);
		if ($client_id && strtolower($client_id)!='null'){
			$extra_cond.= sprintf(' AND contracts.client_id=%d',$client_id);
		}
		$customer_name = $cond->getDbVal('customer_name','e',DT_STRING);
		if ($customer_name && strtolower($customer_name)!='null'){
			$extra_cond.= sprintf(" AND app.customer->>'name'=%s",$customer_name);
		}
		
		$model = new RepReestrPay_Model($this->getDbLink());
		$model->query(
			sprintf(
			"SELECT
				row_number() OVER (ORDER BY p.pay_date) AS ord,
				contracts.expertise_result_number,
				app.applicant->>'name' AS applicant,
				app.customer->>'name' AS customer,
				contracts.contract_number,
				contracts.constr_name,	
				contracts.work_start_date::date AS work_start_date,
				contracts.expertise_cost_budget,
				contracts.expertise_cost_self_fund,
				p.total,
				p.pay_docum_number,
				p.pay_docum_date::date AS pay_docum_date,
				contracts.id AS contract_id
				
			FROM client_payments AS p
			LEFT JOIN contracts ON contracts.id=p.contract_id
			LEFT JOIN applications AS app ON app.id=contracts.application_id
			WHERE p.pay_date BETWEEN %s AND %s %s
			ORDER BY p.pay_date",
			$dt_from,
			$dt_to,
			$extra_cond
			)
		);
		$this->addModel($model);
	
		$this->addNewModel(
			sprintf(
			"SELECT
				format_period_rus(%s::date,%s::date,NULL) AS period_descr,
				%s AS customer_name,
				CASE WHEN %s IS NOT NULL THEN (SELECT name FROM clients WHERE id=%d) ELSE '' END AS client_name
			",
			$dt_from,
			$dt_to,
			$customer_name,
			$client_id,
			$client_id
			),
		'Head_Model'
		);		
	
	}

	public function get_reestr_contract($pm){
		$cond = new ConditionParamsSQL($pm,$this->getDbLink());
		$dt_from = $cond->getDbVal('date_time','ge',DT_DATE);
		if (!isset($dt_from)){
			throw new Exception('Не задана дата начала!');
		}		
		$dt_to = $cond->getDbVal('date_time','le',DT_DATE);
		if (!isset($dt_to)){
			throw new Exception('Не задана дата окончания!');
		}		
		$extra_cond = '';
		
		$date_type_par = strtolower($cond->getVal('date_type','e',DT_STRING));		
		if ($date_type_par && $date_type_par=='date_akt'){
			$date_type = 'contracts.akt_date';
			$date_type_descr = 'По дате акта выполненных работ';
		}
		else if ($date_type_par && $date_type_par=='work_start_date'){
			$date_type = 'contracts.work_start_date';
			$date_type_descr = 'По дате начала работ';
		}
		
		else{
			$date_type = 'contracts.date_time';
			$date_type_descr = 'По дате поступления контракта';
		}
	
		$client_id = $cond->getDbVal('client_id','e',DT_INT);
		if ($client_id && strtolower($client_id)!='null'){
			$extra_cond.= sprintf(' AND contracts.client_id=%d',$client_id);
		}
		
		$main_expert_id = $cond->getDbVal('main_expert_id','e',DT_INT);
		if ($main_expert_id && strtolower($main_expert_id)!='null'){
			$extra_cond.= sprintf(' AND contracts.main_expert_id=%d',$main_expert_id);
		}

		$fund_source_id = $cond->getDbVal('fund_source_id','e',DT_INT);
		if ($fund_source_id && strtolower($fund_source_id)!='null'){
			$extra_cond.= sprintf(' AND app.fund_source_id=%d',$fund_source_id);
		}
		
		$customer_name = $cond->getDbVal('customer_name','e',DT_STRING);
		if ($customer_name && strtolower($customer_name)!='null'){
			$extra_cond.= sprintf(" AND app.customer->>'name'=%s",$customer_name);
		}

		$contractor_name = $cond->getDbVal('contractor_name','e',DT_STRING);
		if ($contractor_name && strtolower($contractor_name)!='null'){
			$extra_cond.= sprintf(
				"AND (%s =ANY( ARRAY((SELECT s.contractor->>'name'
				FROM (SELECT jsonb_array_elements(app_t.contractors) AS contractor
					FROM applications AS app_t
					WHERE app_t.id=app.id
				) AS s)) ) )",
				$contractor_name);
		}

		$service = strtolower($cond->getVal('service','e',DT_STRING));
		$service_descr = 'Все услуги';
		if ($service && $service=='pd'){
			$extra_cond.= " AND contracts.expertise_type='pd'";
			$service_descr = 'Проектная документация';
		}
		else if ($service && $service=='eng_survey'){
			$extra_cond.= " AND contracts.expertise_type='eng_survey'";
			$service_descr = 'Результаты инженерных изысканий';
		}
		else if ($service && $service=='pd_eng_survey'){
			$extra_cond.= " AND contracts.expertise_type='pd_eng_survey'";
			$service_descr = 'Проектная документация и результаты инженерных изысканий';
		}
		else if ($service && $service=='cost_eval_validity'){
			$extra_cond.= " AND (contracts.expertise_type='cost_eval_validity' OR app.cost_eval_validity)";
			$service_descr = 'Достоверность';
		}
		else if ($service && $service=='cost_eval_validity_pd'){
			$extra_cond.= " AND contracts.expertise_type='cost_eval_validity_pd'";
			$service_descr = 'Проектная документация и Достоверность';
		}
		else if ($service && $service=='cost_eval_validity_eng_survey'){
			$extra_cond.= " AND contracts.expertise_type='cost_eval_validity_eng_survey'";
			$service_descr = 'Достоверность и Результаты инженерных изысканий';
		}
		else if ($service && $service=='cost_eval_validity_pd_eng_survey'){
			$extra_cond.= " AND contracts.expertise_type='cost_eval_validity_pd_eng_survey'";
			$service_descr = 'Проектная документация, Достоверность, Результаты инженерных изысканий';
		}


		$service_type = strtolower($cond->getVal('service_type','e',DT_STRING));
		$service_type_descr = 'Все виды экспертиз';
		if ($service_type && $service_type=='expertise'){
			$extra_cond.= " AND contracts.service_type='expertise'";
			$service_type_descr = 'Государственная экспертиза';
		}
		else if ($service_type && $service_type=='modified_documents'){
			$extra_cond.= " AND contracts.service_type='modified_documents'";
			$service_type_descr = 'Измененная документация';
		}
		else if ($service_type && $service_type=='expert_maintenance'){
			$extra_cond.= " AND contracts.service_type='expert_maintenance'";
			$service_type_descr = 'Экспертное сопровождение';
		}
		
		$contract_type = strtolower($cond->getVal('contract_type','e',DT_STRING));
		$contract_type_descr = 'Все виды контрактов';
		if ($contract_type && $contract_type=='not_ext_contract'){
			$extra_cond.= " AND coalesce(app.ext_contract,FALSE)=FALSE";
			$contract_type_descr = 'Только контракты';
		}
		else if ($contract_type && $contract_type=='ext_contract'){
			$extra_cond.= " AND coalesce(app.ext_contract,FALSE)=TRUE";
			$contract_type_descr = 'Только внеконтракты';
		}
		
		$model = new RepReestrContract_Model($this->getDbLink());
		$model->query(
		//throw new Exception(
			sprintf(
			"SELECT
				row_number() OVER (ORDER BY %s) AS ord,
				contracts.expertise_result_number,
				contracts.date_time::date AS date,
				(CASE WHEN coalesce(primary_ct.expertise_result_number,contracts.primary_contract_reg_number) IS NOT NULL THEN 'Повтор' ELSE '' END) AS primary_exists,				
				app.applicant->>'name' AS applicant,
				app.customer->>'name' AS customer,
				contracts.constr_name,	
				contracts.expertise_cost_budget,
				contracts.expertise_cost_self_fund,				
				
				coalesce(contracts.contract_number,'')||
					CASE WHEN contracts.contract_date IS NOT NULL THEN ' от '||to_char(contracts.contract_date,'DD/MM/YY')
					ELSE ''
					END
				AS contract_number_date,
				
				coalesce(payments.total,0) AS pay_total,
				
				contracts.work_start_date::date AS work_start_date,
				
				person_init(employees.name,FALSE) AS main_expert,
				
				CASE
					WHEN contracts.expertise_result='positive' THEN contracts.expertise_result_date
					ELSE NULL
				END AS expertise_result_date_positive,
				
				coalesce(primary_ct.expertise_result_number,contracts.primary_contract_reg_number) AS back_to_work_date,
				
				coalesce(contracts.akt_number,'..')||' от '||coalesce(to_char(contracts.akt_date,'DD/MM/YY'),'..') AS akt_number_date,
				
				contracts.comment_text AS comment_text,
				
				contracts.id AS contract_id
				
			FROM contracts
			LEFT JOIN (
				SELECT
					p.contract_id,
					sum(total) AS total
				FROM client_payments p
				GROUP BY p.contract_id
			) AS payments ON contracts.id=payments.contract_id
			LEFT JOIN applications AS app ON app.id=contracts.application_id
			LEFT JOIN employees ON employees.id=contracts.main_expert_id
			LEFT JOIN contracts AS primary_ct ON primary_ct.id=contracts.primary_contract_id
			WHERE %s BETWEEN %s AND %s %s
			ORDER BY %s",
			$date_type,
			$date_type,
			$dt_from,
			$dt_to,
			$extra_cond,
			$date_type
			)
		);
		$this->addModel($model);
	
		$this->addNewModel(
			sprintf(
			"SELECT
				format_period_rus(%s::date,%s::date,NULL) AS period_descr,
				%s AS customer_name,
				%s AS contractor_name,
				CASE WHEN %s IS NOT NULL THEN (SELECT name FROM clients WHERE id=%d) ELSE '' END AS client_name,
				'%s' AS service_descr,
				'%s' AS service_type_descr,
				'%s' AS contract_type_descr,
				'%s' date_type_descr,
				CASE WHEN %s IS NOT NULL THEN (SELECT name FROM employees WHERE id=%d) ELSE '' END AS main_expert_name,
				CASE WHEN %s IS NOT NULL THEN (SELECT name FROM fund_sources WHERE id=%d) ELSE '' END AS fund_source_name
			",
			$dt_from,
			$dt_to,
			$customer_name,
			$contractor_name,
			$client_id,
			$client_id,
			$service_descr,
			$service_type_descr,
			$contract_type_descr,
			$date_type_descr,
			$main_expert_id,
			$main_expert_id,
			$fund_source_id,
			$fund_source_id						
			),
		'Head_Model'
		);		
	
	}
	
	public function get_quarter_rep($pm){
		$cond = new ConditionParamsSQL($pm,$this->getDbLink());
		$dt_from = $cond->getDbVal('date_time','ge',DT_DATE);
		if (!isset($dt_from)){
			throw new Exception('Не задана дата начала!');
		}		
		$dt_to = $cond->getDbVal('date_time','le',DT_DATE);
		if (!isset($dt_to)){
			throw new Exception('Не задана дата окончания!');
		}		
		$extra_cond = '';
		
		$client_id = $cond->getDbVal('client_id','e',DT_INT);
		if ($client_id && strtolower($client_id)!='null'){
			$extra_cond.= sprintf(' AND contracts.client_id=%d',$client_id);
		}

		$build_type_id = $cond->getDbVal('build_type_id','e',DT_INT);
		if ($build_type_id && strtolower($build_type_id)!='null'){
			$extra_cond.= sprintf(' AND app.build_type_id=%d',$build_type_id);
		}
		
		$constr_name = $cond->getDbVal('constr_name','e',DT_STRING);
		if ($constr_name && strtolower($constr_name)!='null'){
			$extra_cond.= sprintf(" AND coalesce(contracts.constr_name,app.constr_name) = %s",$constr_name);
		}
		
		$main_expert_id = $cond->getDbVal('main_expert_id','e',DT_INT);
		if ($main_expert_id && strtolower($main_expert_id)!='null'){
			$extra_cond.= sprintf(' AND contracts.main_expert_id=%d',$main_expert_id);
		}
		
		$result_type_par = strtolower($cond->getVal('result_type','e',DT_STRING));		
		$result_type_descr = '';
		if ($result_type_par && $result_type_par=='positive'){
			$extra_cond.= " AND expertise_result='positive'";
			$result_type_descr = 'Только с положительным заключением';
		}
		else if ($result_type_par && $result_type_par=='negative'){
			$extra_cond.= " AND expertise_result='negative'";
			$result_type_descr = 'Только с отрицательным заключением';
		}
		else if ($result_type_par && $result_type_par=='primary_exists'){
			$extra_cond.= "";
			$result_type_descr = 'Только повторные';
		}
		
		$customer_name = $cond->getDbVal('customer_name','e',DT_STRING);
		if ($customer_name && strtolower($customer_name)!='null'){
			$extra_cond.= sprintf(" AND app.customer->>'name'=%s",$customer_name);
		}

		$contractor_name = $cond->getDbVal('contractor_name','e',DT_STRING);
		if ($contractor_name && strtolower($contractor_name)!='null'){
			$extra_cond.= sprintf(
				"AND (%s =ANY( ARRAY((SELECT s.contractor->>'name'
				FROM (SELECT jsonb_array_elements(app_t.contractors) AS contractor
					FROM applications AS app_t
					WHERE app_t.id=app.id
				) AS s)) ) )",
				$contractor_name);
		}
		
		$service_type = strtolower($cond->getVal('service_type','e',DT_STRING));
		$service_type_descr = 'Все виды экспертиз';
		if ($service_type && $service_type=='expertise'){
			$extra_cond.= " AND contracts.service_type='expertise'";
			$service_type_descr = 'Государственная экспертиза';
		}
		else if ($service_type && $service_type=='modified_documents'){
			$extra_cond.= " AND contracts.service_type='modified_documents'";
			$service_type_descr = 'Измененная документация';
		}
		else if ($service_type && $service_type=='expert_maintenance'){
			$extra_cond.= " AND contracts.service_type='expert_maintenance'";
			$service_type_descr = 'Экспертное сопровождение';
		}
		
		$expertise_type_par = strtolower($cond->getVal('expertise_type','e',DT_STRING));		
		$expertise_type_descr = '';
		if ($expertise_type_par && $expertise_type_par=='pd'){
			$extra_cond.= " AND contracts.expertise_type='pd'";
			$expertise_type_descr = 'Проектная документация';
		}
		else if ($expertise_type_par && $expertise_type_par=='eng_survey'){
			$extra_cond.= " AND contracts.expertise_type='eng_survey'";
			$expertise_type_descr = 'Результаты инженерных изысканий';
		}
		else if ($expertise_type_par && $expertise_type_par=='pd_eng_survey'){
			$extra_cond.= " AND contracts.expertise_type='pd_eng_survey'";
			$expertise_type_descr = 'Проектная документация и результаты инженерных изысканий';
		}
		else if ($expertise_type_par && $expertise_type_par=='cost_eval_validity'){
			$extra_cond.= " AND (contracts.expertise_type='cost_eval_validity' OR app.cost_eval_validity)";
			$expertise_type_descr = 'Достоверность';
		}
		else if ($expertise_type_par && $expertise_type_par=='cost_eval_validity_pd'){
			$extra_cond.= " AND contracts.expertise_type='cost_eval_validity_pd'";
			$expertise_type_descr = 'Проектная документация и Достоверность';
		}
		else if ($expertise_type_par && $expertise_type_par=='cost_eval_validity_eng_survey'){
			$extra_cond.= " AND contracts.expertise_type='cost_eval_validity_eng_survey'";
			$expertise_type_descr = 'Достоверность и Результаты инженерных изысканий';
		}
		else if ($expertise_type_par && $expertise_type_par=='cost_eval_validity_pd_eng_survey'){
			$extra_cond.= " AND contracts.expertise_type='cost_eval_validity_pd_eng_survey'";
			$expertise_type_descr = 'Проектная документация, Достоверность, Результаты инженерных изысканий';
		}
		
		$expertise_result = $cond->getVal('expertise_result','e',DT_STRING);		
		$expertise_result_descr = '';
		if ($expertise_result=='positive'){
			$extra_cond.= " AND contracts.expertise_result='positive'";
			$expertise_result_descr = 'Положительные заключения';
		}
		else if ($expertise_result=='negative'){
			$extra_cond.= " AND contracts.expertise_result='negative'";
			$expertise_result_descr = 'Отрицательные заключения';
		}
		
		$this->addNewModel(
			sprintf(
			"SELECT
				row_number() OVER (ORDER BY contracts.expertise_result_date) AS ord,
				contracts.expertise_result_number,
				contracts.date_time::date AS date,
				app.customer->>'name' AS customer,
				contracts.constr_name,	
				contracts.work_start_date::date AS work_start_date,
				coalesce(primary_ct.expertise_result_number,contracts.primary_contract_reg_number) AS primary_expertise_result_number,
				contracts.expertise_result,
				contracts.expertise_result_date::date AS expertise_result_date,
				app.build_type_id,
				build_types.name AS build_type_name,
				
				contracts.expertise_type AS expertise_type,
				app.cost_eval_validity,
				
				contracts.in_estim_cost,
				contracts.in_estim_cost_recommend,
				contracts.cur_estim_cost,
				contracts.cur_estim_cost_recommend,
				contracts.id AS contract_id,
				contracts.expertise_cost_budget,
				contracts.expertise_cost_self_fund
				
			FROM contracts	
			LEFT JOIN applications AS app ON app.id=contracts.application_id
			LEFT JOIN build_types ON build_types.id=app.build_type_id
			LEFT JOIN contracts AS primary_ct ON primary_ct.id=contracts.primary_contract_id
			WHERE contracts.expertise_result_date BETWEEN %s AND (%s::timestamp+'1 day'::interval-'1 second'::interval)
			AND coalesce(app.ext_contract,FALSE)=FALSE
			%s
			ORDER BY contracts.expertise_result_date",
			$dt_from,
			$dt_to,
			$extra_cond
			),
		'RepQuarter_Model'
		);		
		
		$this->addNewModel(
			sprintf(
			"SELECT
				format_period_rus(%s::date,%s::date,NULL) AS period_descr,
				CASE WHEN %s IS NOT NULL THEN (SELECT name FROM clients WHERE id=%d) ELSE '' END AS client_name,
				'%s' result_type_descr,
				%s AS customer_name,
				%s AS contractor_name,
				%s AS constr_name,
				CASE WHEN %s IS NOT NULL THEN (SELECT name FROM build_types WHERE id=%d) ELSE '' END AS build_type_name,
				CASE WHEN %s IS NOT NULL THEN (SELECT name FROM employees WHERE id=%d) ELSE '' END AS main_expert_name,
				'%s' AS service_type_descr,
				'%s' AS expertise_type_descr,
				'%s' AS expertise_result_descr
			",
			$dt_from,
			$dt_to,
			$client_id,
			$client_id,
			$result_type_descr,
			$customer_name,
			$contractor_name			,
			$constr_name,
			$build_type_id,
			$build_type_id,
			$main_expert_id,
			$main_expert_id,
			$service_type_descr,
			$expertise_type_descr,
			$expertise_result_descr
			),
		'Head_Model'
		);		

		$this->addNewModel(
			"SELECT * FROM build_types ORDER BY name",
		'BuildType_Model'
		);		
		
	}	
	
	public function get_ext_list($pm){
		$this->setListModelId('ContractExtList_Model');
		parent::get_list($pm);
	
	}
	
	public function ext_contract_to_contract($pm){
		//Проверки boss + admin + main_expert
		$app_ar = $this->getDbLink()->query_first(sprintf(
			"WITH contr AS (
				SELECT
					t.application_id
					,t.main_expert_id
				FROM contracts AS t
				WHERE t.id=%d
			)
			SELECT
				ext_contract,
				(SELECT main_expert_id FROM contr) AS main_expert_id
			FROM applications
			WHERE id = (SELECT application_id FROM contr)"
			,$this->getExtDbVal($pm,'contract_id')
		));
		if(!is_array($app_ar) || !count($app_ar)){
			throw new Exception(self::ER_NO_DOC);
		}
		
		if($app_ar['ext_contract']!='t'){
			throw new Exception('Не внеконтракт!');
		}
		
		if(   !(
			$_SESSION['role_id']=='admin'
			|| $_SESSION['role_id']=='boss'
			|| ($_SESSION['global_employee_id'] == $app_ar['main_expert_id'])
			)
		){
			throw new Exception('Действие запрещено!');
		}
		
		//Вся логика в plpg
		$this->getDbLinkMaster()->query(sprintf(
			"SELECT contracts_ext_to_contract(%d)"
			,$this->getExtDbVal($pm,'contract_id')
		));
		
	}
	

}
?>