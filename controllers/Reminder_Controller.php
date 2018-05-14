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



require_once(USER_CONTROLLERS_PATH.'DocFlowTask_Controller.php');

class Reminder_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('recipient_employee_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtBool('viewed'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('viewed_dt'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('content'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('register_docs_ref'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('docs_ref'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Reminder_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('recipient_employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('viewed'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('viewed_dt'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('content'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('register_docs_ref'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('docs_ref'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Reminder_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Reminder_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('Reminder_Model');		

			
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
		
		$this->setListModelId('Reminder_Model');
		
			
		$pm = new PublicMethod('get_unviewed_list');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('set_viewed');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	public function get_unviewed_list($pm){
		$m = $this->addNewModel(sprintf(
			"SELECT
				id,
				date_time,
				content,docs_ref
			FROM reminders
			WHERE
				recipient_employee_id=%d
				AND NOT viewed
				AND date_time <= now()
				AND date_time::date > (now()::date - ((const_reminder_show_days_val()||' days')::interval)*2)
			ORDER BY date_time ASC",
			json_decode($_SESSION['employees_ref'])->keys->id
			),
		"ReminderUnviewedList_Model",
		FALSE //NOT XML!
		);
		if ($m->getRowCount()){
			$this->addModel(DocFlowTask_Controller::get_short_list_model($this->getDbLink()));
		}
	}
	
	public function set_viewed($pm){
		$this->getDbLinkMaster()->query(sprintf(
			"UPDATE reminders SET viewed=TRUE,viewed_dt=now() WHERE id=%d",
			$this->getExtDbVal($pm,'id')
		));
	}
	


}
?>