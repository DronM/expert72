<?php
require_once(USER_CONTROLLERS_PATH.'Mail_Controller.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtXML.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */



class InMail_Controller extends Mail_Controller{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('InMail_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('InMail_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('InMail_Model');

			
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
		
		$this->setListModelId('InMailList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtInt('browse_mode'));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('InMaillDialog_Model');		

			
		$pm = new PublicMethod('complete_addr_name');
		
				
	$opts=array();
	
		$opts['length']=250;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('addr_name',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('remove_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_file');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	public function insert($pm){
		$pm->setParamValue('user_id',$_SESSION['user_id']);
		return parent::insert($pm);
	}

	public function delete($pm){
		if ($_SESSION['role_id'!='admin']){
			throw new Exception('Невозможно удалять письмо!');
		}
		
		$pm->setParamValue('mail_type','in');
		try{
			$this->getDbLinkMaster()->query("BEGIN");
		
			$this->delete_attachments();
			
			parent::delete($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}	
	}

	public function get_file($pm){
		$pm->setParamValue('mail_type','in');
		return parent::get_file($pm);
	}

	public function remove_file($pm){
		$pm->setParamValue('mail_type','in');
		return parent::remove_file($pm);
	}


}
?>