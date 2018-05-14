<?php
require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQL.php');
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


class DocCostEvalValidityTemplate_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('construction_type_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDate('create_date'
				,array('required'=>TRUE,
				'alias'=>'Дата создания'
			));
		$pm->addParam($param);
		$param = new FieldExtXML('content'
				,array('required'=>TRUE,
				'alias'=>'Содержимое шаблона'
			));
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
				'alias'=>'Комментарий'
			));
		$pm->addParam($param);
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DocCostEvalValidityTemplate_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_construction_type_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtDate('old_create_date',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('construction_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('create_date'
				,array(
			
				'alias'=>'Дата создания'
			));
			$pm->addParam($param);
		$param = new FieldExtXML('content'
				,array(
			
				'alias'=>'Содержимое шаблона'
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			
				'alias'=>'Комментарий'
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('construction_type_id',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtDate('create_date',array(
			
				'alias'=>'Дата создания'
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocCostEvalValidityTemplate_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('construction_type_id'
		));		
		
		$pm->addParam(new FieldExtDate('create_date'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DocCostEvalValidityTemplate_Model');

			
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
		
		$this->setListModelId('DocCostEvalValidityTemplateList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtInt('browse_mode'));
		
		$pm->addParam(new FieldExtInt('construction_type_id'
		));
		
		$pm->addParam(new FieldExtDate('create_date'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DocCostEvalValidityTemplate_Model');		

		
	}	
	
}
?>