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


class EmployeeExpertCertificate_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('employee_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtString('expert_type'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtString('cert_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDate('date_from'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDate('date_to'
				,array('required'=>TRUE));
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('EmployeeExpertCertificate.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('EmployeeExpertCertificate_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('expert_type'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('cert_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('date_from'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('date_to'
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
			$pm->addEvent('EmployeeExpertCertificate.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('EmployeeExpertCertificate_Model');

			
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
		$pm->addEvent('EmployeeExpertCertificate.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('EmployeeExpertCertificate_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('EmployeeExpertCertificateList_Model');		

			
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
		
		$this->setListModelId('EmployeeExpertCertificateList_Model');
		
			
		$pm = new PublicMethod('complete_on_cert_id');
		
				
	$opts=array();
			
		$pm->addParam(new FieldExtInt('employee_id',$opts));
	
				
	$opts=array();
			
		$pm->addParam(new FieldExtString('cert_id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
					
			
		$this->addPublicMethod($pm);

			
		
	}	
	

	public function complete_on_cert_id($pm){
	
		//one expert
		
		$cert_cond = '';
		//конкретные сертификаты одного эксперта
		if($pm->getParamValue('cert_id')){
			$cert_cond = " AND lower(certs.cert_id) LIKE '%%'||lower(".$this->getExtDbVal($pm,'cert_id').")||'%%'";
		}
		//if($pm->getParamValue('expert_type')){
		//	$cert_cond .= " AND lower(certs.expert_type) LIKE '%%'||lower(".$this->getExtDbVal($pm,'expert_type').")||'%%'";
		//}
		
		$q = sprintf(
			"SELECT
				certs.*				
			FROM employee_expert_certificates_list AS certs
			WHERE certs.employee_id = %d ".$cert_cond."
			ORDER BY certs.date_to DESC
			LIMIT 10"
			,$this->getExtDbVal($pm,'employee_id')
		);				
		$this->addNewModel($q,'EmployeeExpertCertificateList_Model');			
	}


}
?>