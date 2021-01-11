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


class Service_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtString('name'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('date_type',',','calendar,bank'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('work_day_count'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('expertise_day_count'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('contract_postf'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('service_type',',','expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance'
				,array('required'=>TRUE,
				'alias'=>'Вид услуги'
			));
		$pm->addParam($param);
		
				$param = new FieldExtEnum('expertise_type',',','pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey'
				,array(
				'alias'=>'Вид гос.экспертизы'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('ban_client_responses_day_cnt'
				,array(
				'alias'=>'За сколько дней блокировать отправку клиентских писем сответами'
			));
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('Service.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Service_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('name'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('date_type',',','calendar,bank'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('work_day_count'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('expertise_day_count'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('contract_postf'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('service_type',',','expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance'
				,array(
			
				'alias'=>'Вид услуги'
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('expertise_type',',','pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey'
				,array(
			
				'alias'=>'Вид гос.экспертизы'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('ban_client_responses_day_cnt'
				,array(
			
				'alias'=>'За сколько дней блокировать отправку клиентских писем сответами'
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
			$pm->addEvent('Service.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Service_Model');

			
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
		$pm->addEvent('Service.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Service_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('Service_Model');		

			
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
		
		$this->setListModelId('Service_Model');
		
		
	}	
	
}
?>