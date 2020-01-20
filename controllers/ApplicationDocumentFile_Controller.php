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


class ApplicationDocumentFile_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtString('old_file_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtString('file_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSON('applications_ref'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('document_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('document_type'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('file_name'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('file_path'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('file_signed'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('file_size'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('deleted'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('deleted_dt'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('file_signed_by_client'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('information_list'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtString('file_id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('ApplicationDocumentFileList_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtString('file_id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('ApplicationDocumentFile_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtString('file_id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ApplicationDocumentFileList_Model');		

			
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
		
		$this->setListModelId('ApplicationDocumentFileList_Model');
		
		
	}	
	
}
?>