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


class OfficeDaySchedule_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('office_id'
				,array('required'=>FALSE));
		$pm->addParam($param);
		$param = new FieldExtDate('day'
				,array('required'=>FALSE));
		$pm->addParam($param);
		$param = new FieldExtJSONB('work_hours'
				,array());
		$pm->addParam($param);
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('OfficeDaySchedule_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_office_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtDate('old_day',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('office_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('day'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('work_hours'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('office_id',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtDate('day',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('OfficeDaySchedule_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('office_id'
		));		
		
		$pm->addParam(new FieldExtDate('day'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('OfficeDaySchedule_Model');

			
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
		
		$this->setListModelId('OfficeDaySchedule_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('office_id'
		));
		
		$pm->addParam(new FieldExtDate('day'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('OfficeDaySchedule_Model');		

		
	}	
	
}
?>