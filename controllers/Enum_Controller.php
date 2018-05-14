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


require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQL.php');
class Enum_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			
		$pm = new PublicMethod('get_enum_list');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	public function get_enum_list(){
		$link = $this->getDbLink();
		$model = new ModelSQL($link,array('id'=>'EnumList_Model'));
		$model->addField(new FieldSQL($link,null,null,'id',DT_STRING));
		$model->addField(new FieldSQL($link,null,null,'descr',DT_STRING));	
		
		$pm = $this->getPublicMethod('get_enum_list');
		$id = $pm->getParamValue('id');
		if (!isset($id)){
			throw new Exception('No enum id!');
		}
		$model->setSelectQueryText(
		'SELECT * FROM enum_list_'.$id);
		$model->select(false,null,null,
			null,null,null,null,null,TRUE);
		//
		$this->addModel($model);			
	}

}
?>