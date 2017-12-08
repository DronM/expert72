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


class Client_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtString('name'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtText('name_full'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtString('inn'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtString('kpp'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('ogrn'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('okpo'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('okved'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('ext_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('post_address'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('legal_address'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('responsable_persons'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('bank_accounts'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('client_type',',','enterprise,person'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtText('base_document_for_contract'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('person_id_paper'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSONB('person_registr_paper'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Client_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('name'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('name_full'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('inn'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('kpp'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('ogrn'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('okpo'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('okved'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('ext_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('post_address'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('legal_address'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('responsable_persons'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('bank_accounts'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('client_type',',','enterprise,person'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('base_document_for_contract'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('person_id_paper'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('person_registr_paper'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Client_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Client_Model');

			
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
		
		$this->setListModelId('ClientList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtInt('browse_mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('Client_Model');		

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('name'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('ClientList_Model');

		
	}	
	
	public function insert($pm){
		$pm->setParamValue('user_id',$_SESSION['user_id']);
		parent::insert($pm);
	}

}
?>