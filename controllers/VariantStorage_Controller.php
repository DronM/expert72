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



require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/VariantStorage.php');

require_once(FRAME_WORK_PATH.'basic_classes/SessionVarManager.php');

class VariantStorage_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('id'
				,array());
		$pm->addParam($param);
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
		$param = new FieldExtJSON('filter_data'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSON('col_visib_data'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSON('col_order_data'
				,array());
		$pm->addParam($param);
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('VariantStorage.insert',$ev_opts);
		
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
			
		$pm->addParam(new FieldExtJSON('filter_data',$opts));
	
				
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
		$pm->addParam(new FieldExtJSON('col_visib',$opts));
	
				
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
		$pm->addParam(new FieldExtJSON('col_order',$opts));
	
				
	$opts=array();
			
		$pm->addParam(new FieldExtBool('default_variant',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('upsert_all_data');
		
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('storage_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('variant_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtJSON('all_data',$opts));
	
				
	$opts=array();
			
		$pm->addParam(new FieldExtBool('default_variant',$opts));
	
			
		$this->addPublicMethod($pm);

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
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
		$param = new FieldExtJSON('filter_data'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSON('col_visib_data'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSON('col_order_data'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['id'
				]
			];
			$pm->addEvent('VariantStorage.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('VariantStorage_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
				
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('VariantStorage.delete',$ev_opts);
		
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
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
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

			
		$pm = new PublicMethod('get_all_data');
		
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('storage_name',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtText('variant_name',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	private static function get_user_id(){
		return isset($_SESSION['user_id'])? $_SESSION['user_id'] : SessionVarManager::getValue('user_id');
	}
	
	public function insert($pm){		
		$pm->setParamValue("user_id",self:: get_user_id());
		parent::insert($pm);
	}

	public function delete($pm){
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
			"SELECT storage_name
			FROM variant_storages
			WHERE id=%d AND user_id=%d"
			,$this->getExtDbVal($pm,'id')
			,self:: get_user_id()
		));
	
		$this->getDbLinkMaster()->query(sprintf(
			"DELETE FROM variant_storages
			WHERE id=%d AND user_id=%d"
			,$this->getExtDbVal($pm,'id')
			,self:: get_user_id()
		));
		
		if(count($ar) && !is_null($ar['storage_name'])){
			VariantStorage::clear($ar['storage_name']);
		}
	}

	public function upsert($pm,$dataCol,$dataColVal){
	
		$this->getDbLinkMaster()->query(sprintf(
		"SELECT variant_storages_upsert_%s(%d,%s,%s,%s,%s)",
		$dataCol,
		self:: get_user_id(),
		$this->getExtDbVal($pm,'storage_name'),
		$this->getExtDbVal($pm,'variant_name'),
		$dataColVal,
		$this->getExtDbVal($pm,'default_variant')
		));
		
		VariantStorage::clear($this->getExtVal($pm,'storage_name'));
	}
	
	public function upsert_filter_data($pm){
		$this->upsert($pm, 'filter_data', $this->getExtDbVal($pm,'filter_data'));
	}

	public function upsert_col_visib_data($pm){
		$this->upsert($pm, 'col_visib_data', $this->getExtDbVal($pm,'col_visib_data'));
	}

	public function upsert_col_order_data($pm){
		$this->upsert($pm, 'col_visib_order', $this->getExtDbVal($pm,'col_visib_order'));
	}
	public function upsert_all_data($pm){
		$all_data = json_decode($this->getExtDbVal($pm,'all_data'));
		if ($all_data->filter_data){
			$this->upsert($pm, 'filter_data', json_encode($all_data->filter_data));
		}
		if ($all_data->col_visib_data){
			$this->upsert($pm, 'col_visib_data', json_encode($all_data->col_visib_data));
		}
		if ($all_data->col_order_data){
			$this->upsert($pm, 'col_order_data', json_encode($all_data->col_order_data));
		}
		
	}
	
	public function get_list($pm){
	
		$this->AddNewModel(sprintf(
			"SELECT *
			FROM variant_storages_list
			WHERE user_id=%d AND storage_name=%s",
			self:: get_user_id(),
			$this->getExtDbVal($pm,'storage_name')
			),
		"VariantStorageList_Model"
		);
	}	
	
	public function get_obj_col($pm,$dataCol){
	
		$this->AddNewModel(sprintf(
			"SELECT
				id,
				user_id,
				storage_name,
				variant_name,
				%s,
				default_variant
			FROM variant_storages
			WHERE user_id=%d AND storage_name=%s AND variant_name=%s",
			$dataCol,
			self::get_user_id(),
			$this->getExtDbVal($pm,'storage_name'),
			$this->getExtDbVal($pm,'variant_name')
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
	public function get_all_data($pm){
		$this->get_obj_col($pm,'filter_data,col_visib_data,col_order_data');
	}	
	
	

}
?>