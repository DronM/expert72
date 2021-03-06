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


class ConclusionDictionaryDetail_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtString('old_conclusion_dictionary_name',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtString('old_code',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtString('conclusion_dictionary_name'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('code'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('descr'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('is_group'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('ord'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtString('conclusion_dictionary_name',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtString('code',array(
			));
			$pm->addParam($param);
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['conclusion_dictionary_name'
				,'code'
				]
			];
			$pm->addEvent('ConclusionDictionaryDetail.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('ConclusionDictionaryDetail_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtString('conclusion_dictionary_name'
		));
		
		$pm->addParam(new FieldExtString('code'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ConclusionDictionaryDetail_Model');		

			
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
		
		$this->setListModelId('ConclusionDictionaryDetail_Model');
		
			
		$pm = new PublicMethod('complete_search');
		
				
	$opts=array();
	
		$opts['length']=50;
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtString('conclusion_dictionary_name',$opts));
	
				
	$opts=array();
	
		$opts['length']=500;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('search',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
					
			
		$this->addPublicMethod($pm);

			
		
	}	
	

	public function complete_search($pm){
		$this->addNewModel(sprintf(
			"SELECT *
			FROM conclusion_dictionary_detail
			WHERE	conclusion_dictionary_name = %s
				AND (lower(descr) LIKE '%%'||lower(%s)||'%%' OR code LIKE %s||'%%')
			ORDER BY ord	
			LIMIT 10"			
			,$this->getExtDbVal($pm,'conclusion_dictionary_name')
			,$this->getExtDbVal($pm,'search')
			,$this->getExtDbVal($pm,'search')
			),
			'ConclusionDictionaryDetail_Model'
		);	
	}


}
?>