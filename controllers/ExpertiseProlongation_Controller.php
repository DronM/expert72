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



require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class ExpertiseProlongation_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('contract_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTime('date_time'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('day_count'
				,array('required'=>TRUE));
		$pm->addParam($param);
		
				$param = new FieldExtEnum('date_type',',','calendar,bank'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDate('new_end_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
				'alias'=>'Комментарий'
			));
		$pm->addParam($param);
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('ExpertiseProlongation_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_contract_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtDateTime('old_date_time',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('contract_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTime('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('day_count'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('date_type',',','calendar,bank'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('new_end_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			
				'alias'=>'Комментарий'
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('contract_id',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtDateTime('date_time',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('ExpertiseProlongation_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('contract_id'
		));		
		
		$pm->addParam(new FieldExtDateTime('date_time'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('ExpertiseProlongation_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('contract_id'
		));
		
		$pm->addParam(new FieldExtDateTime('date_time'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ExpertiseProlongationList_Model');		

			
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
		
		$this->setListModelId('ExpertiseProlongationList_Model');
		
			
		$pm = new PublicMethod('calc_work_end_date');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('contract_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtEnum('date_type',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('day_count',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	private function calc_date($contractIdDb,$dateTypeDb,$dayCountDb){
		$ar = $this->getDbLink()->query_first(sprintf(
		"WITH
		contr AS (SELECT
				app.office_id AS office_id,
				ct.work_end_date
			FROM contracts ct
			LEFT JOIN applications app ON app.id=ct.application_id
			WHERE ct.id=%d
		)
		SELECT contracts_work_end_date(
			(SELECT office_id FROM contr),
			%s,
			(SELECT work_end_date FROM contr)+'1 day'::interval,
			%d
		) AS contact_work_end_date",
		$contractIdDb,
		$dateTypeDb,
		$dayCountDb
		));
	
		return $ar['contact_work_end_date'];
	}

	public function calc_work_end_date($pm){
		$d = $this->calc_date(
			$this->getExtDbVal($pm,'contract_id'),
			$this->getExtDbVal($pm,'date_type'),
			$this->getExtDbVal($pm,'day_count')
		);
	
		$this->addModel(new ModelVars(
			array('id'=>'Result_Model',
				'values'=>array(new Field('work_end_date',DT_DATE,array('value'=>$d)))
				)
			)
		);	
	}

	public function insert($pm){
		if($_SESSION['role_id']!='admin'){
			//auto calc
			$pm->setParamValue(
				'new_end_date',
				$this->calc_date(
					$this->getExtDbVal($pm,'contract_id'),
					$this->getExtDbVal($pm,'date_type'),
					$this->getExtDbVal($pm,'day_count')
				)
			);
			$pm->setParamValue('employee_id',json_decode($_SESSION['employees_ref'])->keys->id);
		}
		else{
			if (!$pm->getParamValue('employee_id')){
				$pm->setParamValue('employee_id',json_decode($_SESSION['employees_ref'])->keys->id);
			}
			if (!$pm->getParamValue('new_end_date')){
				$pm->setParamValue(
					'new_end_date',
					$this->calc_date(
						$this->getExtDbVal($pm,'contract_id'),
						$this->getExtDbVal($pm,'date_type'),
						$this->getExtDbVal($pm,'day_count')
					)
				);			
			}
		}
		parent::insert($pm);
	}
	

}
?>