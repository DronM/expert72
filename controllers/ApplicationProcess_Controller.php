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

class ApplicationProcess_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('application_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array('required'=>TRUE));
		$pm->addParam($param);
		
				$param = new FieldExtEnum('state',',','filling,correcting,sent,checking,returned,closed_no_expertise,waiting_for_contract,waiting_for_pay,expertise,closed,archive'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('end_date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_examination_id'
				,array());
		$pm->addParam($param);
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['application_id'
			,'date_time'
			]
		];
		$pm->addEvent('ApplicationProcess.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('ApplicationProcess_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_application_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtDateTimeTZ('old_date_time',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('state',',','filling,correcting,sent,checking,returned,closed_no_expertise,waiting_for_contract,waiting_for_pay,expertise,closed,archive'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('end_date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_examination_id'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('application_id',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtDateTimeTZ('date_time',array(
			));
			$pm->addParam($param);
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['application_id'
				,'date_time'
				]
			];
			$pm->addEvent('ApplicationProcess.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('ApplicationProcess_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('application_id'
		));		
		
		$pm->addParam(new FieldExtDateTimeTZ('date_time'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
				
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['application_id'
			,'date_time'
			]
		];
		$pm->addEvent('ApplicationProcess.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('ApplicationProcess_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('application_id'
		));
		
		$pm->addParam(new FieldExtDateTimeTZ('date_time'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ApplicationProcessList_Model');		

			
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
		
		$this->setListModelId('ApplicationProcessList_Model');
		
		
	}	
	

	public function insert($pm){
		$pm->setParamValue('user_id',$_SESSION['user_id']);
		parent::insert($pm);
	}

	public function delete($pm){
		if ($_SESSION['role_id']!='admin' && $_SESSION['role_id']!='lawyer'){
			throw new Exception('Статусы удалять может только администратор или отдел приемки документации!');
		}
		
		$q = sprintf("DELETE FROM application_processes%s
		WHERE application_id=%d AND date_trunc('second',date_time)=date_trunc('second',%s::timestampTZ)",
			Application_Controller::LKPostfix(),
			$this->getExtDbVal($pm,'application_id'),
			$this->getExtDbVal($pm,'date_time')
		);
		//throw new Exception($q);
		$this->getDbLinkMaster()->query($q);
		//parent::delete($pm);
	}


}
?>