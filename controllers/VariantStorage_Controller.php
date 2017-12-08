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



require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/VariantStorage.php');

class VariantStorage_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('user_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtText('storage_name'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtText('variant_name'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtBool('default_variant'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('filter_data'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('col_visib_data'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('col_order_data'
				,array());
		$pm->addParam($param);
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('VariantStorage_Model');

			
		$pm = new PublicMethod('upsert_filter_data');
		
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('storage_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('variant_name',$opts));
	
				
	$opts=array();
			
		$pm->addParam(new FieldExtText('filter_data',$opts));
	
				
	$opts=array();
			
		$pm->addParam(new FieldExtBool('default_variant',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('upsert_col_visib_data');
		
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('storage_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('variant_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('col_visib',$opts));
	
				
	$opts=array();
			
		$pm->addParam(new FieldExtBool('default_variant',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('upsert_col_order_data');
		
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('storage_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('variant_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('col_order',$opts));
	
				
	$opts=array();
			
		$pm->addParam(new FieldExtBool('default_variant',$opts));
	
			
		$this->addPublicMethod($pm);

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_user_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtText('old_storage_name',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtText('old_variant_name',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('storage_name'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('variant_name'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('default_variant'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('filter_data'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('col_visib_data'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('col_order_data'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('user_id',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtText('storage_name',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtText('variant_name',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('VariantStorage_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('user_id'
		));		
		
		$pm->addParam(new FieldExtText('storage_name'
		));		
		
		$pm->addParam(new FieldExtText('variant_name'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('VariantStorage_Model');

			
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

			$f_params = array();
			
				$f_params['required']=TRUE;
			$param = new FieldExtString('storage_name'
			,$f_params);
		$pm->addParam($param);		
		
			$f_params = array();
			$param = new FieldExtString('variant_name'
			,$f_params);
		$pm->addParam($param);		
		
		$this->addPublicMethod($pm);
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtInt('browse_mode'));
		
		$pm->addParam(new FieldExtInt('user_id'
		));
		
		$pm->addParam(new FieldExtText('storage_name'
		));
		
		$pm->addParam(new FieldExtText('variant_name'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('VariantStorage_Model');		

			
		$pm = new PublicMethod('get_filter_data');
		
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('storage_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('variant_name',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_col_visib_data');
		
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('storage_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('variant_name',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_col_order_data');
		
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('storage_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('variant_name',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	public function insert($pm){
		$pm->setParamValue("user_id",$_SESSION['user_id']);
		parent::insert($pm);
	}

	public function delete($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();
	
		$pm->setParamValue("user_id",$_SESSION['user_id']);
		parent::delete($pm);
		
		VariantStorage::clear($params->getVal("storage_name"));
	}

	public function upsert($pm,$dataCol){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();
	
		$this->getDbLinkMaster()->query(sprintf(
		"SELECT variant_storages_upsert_%s(%d,%s,%s,%s,%s)",
		$dataCol,
		$_SESSION['user_id'],
		$params->getDbVal("storage_name"),
		$params->getDbVal("variant_name"),
		$params->getDbVal($dataCol),
		$params->getDbVal("default_variant")
		));
		
		VariantStorage::clear($params->getVal("storage_name"));
	}
	
	public function upsert_filter_data($pm){
		$this->upsert($pm,'filter_data');
	}

	public function upsert_col_visib_data($pm){
		$this->upsert($pm,'col_visib_data');
	}

	public function upsert_col_order_data($pm){
		$this->upsert($pm,'col_visib_order');
	}
	
	public function get_list($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();
		$this->AddNewModel(sprintf(
			"SELECT
				user_id,
				storage_name,
				variant_name,
				default_variant
			FROM variant_storages
			WHERE user_id=%d AND storage_name=%s",
			$_SESSION['user_id'],
			$params->getParamById('storage_name')
			),
		"VariantStorageList_Model"
		);
	}	
	
	public function get_obj_col($pm,$dataCol){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();
		$this->AddNewModel(sprintf(
			"SELECT
				user_id,
				storage_name,
				variant_name,
				%s,
				default_variant
			FROM variant_storages
			WHERE user_id=%d AND storage_name=%s AND variant_name=%s",
			$dataCol,
			$_SESSION['user_id'],
			$params->getParamById('storage_name'),
			$params->getParamById('variant_name')
			),
		"VariantStorage_Model"
		);
	}
	
	public function get_filter_data($pm){
		$this->get_obj_col($pm,'filter_data');
	}	
	public function get_col_visib_data($pm){
		$this->get_obj_col($pm,'col_visib_data');
	}	
	public function get_col_order_data($pm){
		$this->get_obj_col($pm,'col_order_data');
	}	
	

}
?>