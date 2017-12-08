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


require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQL.php');

require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');

class Constant_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			
		$pm = new PublicMethod('set_value');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('val',$opts));
	
			
		$this->addPublicMethod($pm);

			
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
		
		$this->setListModelId('ConstantList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtInt('browse_mode'));
		
		$pm->addParam(new FieldExtString('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ConstantList_Model');		

			
		$pm = new PublicMethod('get_values');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('id_list',$opts));
	
				
	$opts=array();
	
		$opts['length']=1;				
		$pm->addParam(new FieldExtString('field_sep',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}
	
	/**
	 * @param {array} $idList
	 * @returns {ModelSQL}
	 */
	public function getConstantValueModel(&$idList){
		$link = $this->getDbLink();
		$model = new ModelSQL($link,array('id'=>'ConstantValueList_Model','sysModel'=>TRUE));
		$model->addField(new FieldSQL($link,null,null,'id',DT_STRING));
		$model->addField(new FieldSQL($link,null,null,'val',DT_STRING));		

		$q = '';
		foreach($idList as $id) {
			$q.= ($q!='')? ' UNION ALL ':'';
			$q.= sprintf("SELECT
				'%s' AS id,
				const_%s_val()::text AS val,
				(SELECT c.val_type FROM const_%s c) AS val_type", $id,$id,$id);
		}
		
		$model->setSelectQueryText($q);
		$model->select(false,null,null,
			null,null,null,null,null,TRUE);
			
		return $model;
		//
	}
	
	public function get_values($pm){
		$p = new ParamsSQL($pm,$this->getDbLink());
		$p->addAll();
	
		$id_list = $p->getVal('id_list');
		$field_sep = $p->getVal('field_sep');
		$field_sep = (isset($field_sep))? $field_sep:',';
		if (isset($id_list)){
			$model = $this->getConstantValueModel(explode($field_sep,$id_list));
			$this->addModel($model);
		}
	}
	
	public function set_value($pm){
		$p = new ParamsSQL($pm,$this->getDbLink());
		$p->addAll();
	
		$link = $this->getDbLinkMaster();
		$link->query(sprintf(
		"SELECT const_%s_set_val(%s)",
		$p->getVal('id'),$p->getDbVal('val')));
	}
}
?>