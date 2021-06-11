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


class ExpertConclusion_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('contract_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('expert_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('last_modified'
				,array());
		$pm->addParam($param);
		$param = new FieldExtXML('conclusion'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtString('conclusion_type'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('conclusion_type_descr'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('ExpertConclusion.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('ExpertConclusion_Model');

			
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
		$param = new FieldExtInt('expert_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('last_modified'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtXML('conclusion'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('conclusion_type'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('conclusion_type_descr'
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
			$pm->addEvent('ExpertConclusion.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('ExpertConclusion_Model');

			
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
		$pm->addEvent('ExpertConclusion.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('ExpertConclusion_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ExpertConclusionDialog_Model');		

			
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
		
		$this->setListModelId('ExpertConclusionList_Model');
		
		
	}	
	

	public function insert($pm){
		//doc owner
		if(!$pm->getParamValue('date_time')){
			$pm->setParamValue('date_time',date('Y-m-d H:i:s'));
		}
		
		if(!isset($_SESSION['global_employee_id'])){
			throw new Exception('Expert ID not defined!');
		}
		$pm->setParamValue('expert_id', $_SESSION['global_employee_id']);
		
		return parent::insert($pm);		
	}
	
	public function update($pm){
		if( ($_SESSION['role_id']=='expert' ||$_SESSION['role_id']=='expert_ext')
		&&$pm->getParamValue('expert_id')
		&&$pm->getParamValue('expert_id')!=$_SESSION['expert_id']
		){
			throw new Exception("Запрещено менять сотрудника!");
		}
	
		$pm->setParamValue('last_modified',date('Y-m-d H:i:s'));
		
		parent::update($pm);		
	}


}
?>