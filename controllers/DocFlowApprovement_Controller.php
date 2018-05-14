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

class DocFlowApprovement_Controller extends ControllerSQL{

	const ER_NOT_FOUND = 'Документ не нйден!@1000';

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtDateTimeTZ('date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('close_date_time'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('close_result',',','approved,not_approved,approved_with_notes'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('closed'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('subject'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtJSONB('subject_doc'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtJSONB('recipient_list'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtText('description'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_importance_type_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('end_date_time'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('step_count'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('current_step'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('doc_flow_approvement_type',',','to_all,to_one,mixed'
				,array('required'=>TRUE));
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DocFlowApprovement_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('close_date_time'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('close_result',',','approved,not_approved,approved_with_notes'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('closed'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('subject'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('subject_doc'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('recipient_list'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('description'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('doc_flow_importance_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('end_date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('step_count'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('current_step'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('doc_flow_approvement_type',',','to_all,to_one,mixed'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocFlowApprovement_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DocFlowApprovement_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DocFlowApprovementDialog_Model');		

			
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
		
		$this->setListModelId('DocFlowApprovementList_Model');
		
			
		$pm = new PublicMethod('set_approved');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('employee_comment',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('set_approved_with_remarks');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('employee_comment',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('set_disapproved');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('employee_comment',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('set_closed');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	private function set_state($id,$employeeComment,$approvementResult){
		$employeeComment = (!$employeeComment || $employeeComment=='null')? '': substr($employeeComment,1,strlen($employeeComment)-2);
		
		$empl_id = json_decode($_SESSION['employees_ref'])->keys->id;
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				step_count,
				current_step,
				recipient_list
			FROM doc_flow_approvements
			WHERE id=%d",
			$id
		));
		if (!count($ar)){
			throw new Exception(self::ER_NOT_FOUND);
		}
		$step_closed = TRUE;
		$empl_step = intval($ar['current_step']);
		$bigger_step_exists = (intval($ar['step_count'])>$empl_step);
		$cur_empl_found = FALSE;
		$appr_results = ['not_approved'=>0,'approved_with_notes'=>1,'approved'=>2];
		$close_result = 'approved';
		$close_result_num = 2;
		
		$list = json_decode($ar['recipient_list']);
		foreach($list->rows as $row){
			if($row->fields->employee->keys->id==$empl_id){
				$row->fields->closed = TRUE;
				$row->fields->employee_comment = $employeeComment;
				$row->fields->approvement_result = $approvementResult;
				$row->fields->approvement_dt = date('Y-m-d H:i:s');
				$cur_empl_found = TRUE;
			}
			
			if (intval($row->fields->step)==$empl_step && !$row->fields->closed){
				$step_closed = FALSE;
			}
			
			if ($row->fields->closed && $appr_results[$row->fields->approvement_result] < $close_result_num){
				$close_result = $row->fields->approvement_result;
				$close_result_num = $appr_results[$row->fields->approvement_result];
			}
		}
		
		if ($cur_empl_found){
			
			$link = $this->getDbLinkMaster();
			
			$link->query('BEGIN');
			try{
				if (!$bigger_step_exists && $step_closed){
					$close_fields = sprintf(", close_date_time=now(),close_result='%s'",$close_result);
				}
				else if ($bigger_step_exists && $step_closed){
					$close_fields = sprintf(", current_step=%d",$empl_step+1);
				}
				$link->query(sprintf(
					"UPDATE doc_flow_approvements
					SET
						recipient_list = '%s'
						%s
					WHERE id=%d",
					json_encode($list),
					$close_fields,
					$id
				));
				
				//Закрыть задачу по тек.сотру
				$link->query(sprintf(
					"UPDATE doc_flow_tasks
					SET
						close_date_time = now(),
						close_doc = register_doc,
						closed = TRUE,
						close_employee_id = %d
					WHERE
						register_doc->>'dataType'='doc_flow_approvements'
						AND  (register_doc->'keys'->>'id')::int=%d
						AND recipient->>'dataType'='employees'
						AND (recipient->'keys'->>'id')::int=%d 
						",
					$empl_id,
					$id,
					$empl_id
				));
				
				//передать дальше по цепочке, если все с днным step закрыты и есть еще строки с большим step
				if ($bigger_step_exists && $step_closed){
					$link->query(sprintf(
						"SELECT doc_flow_approvements_add_task_for_step(
							(SELECT doc_flow_approvements FROM doc_flow_approvements WHERE id=%d),
							%d
						)",
						$id,
						$empl_step+1
					));
				}
				
				$link->query('COMMIT');
			}
			catch(Exception $e){
				$link->query('ROLLBACK');
				throw $e;
			}		
		}
	}

	public function set_approved($pm){
		$this->set_state(
			$this->getExtDbVal($pm,"id"),
			$this->getExtDbVal($pm,"employee_comment"),
			'approved'
		);
	}
	public function set_disapproved($pm){
		$this->set_state(
			$this->getExtDbVal($pm,"id"),
			$this->getExtDbVal($pm,"employee_comment"),
			'not_approved'
		);
	}
	public function set_approved_with_remarks($pm){
		$this->set_state(
			$this->getExtDbVal($pm,"id"),
			$this->getExtDbVal($pm,"employee_comment"),
			'approved_with_notes'
		);
	}

	public function set_closed($pm){
		$link = $this->getDbLinkMaster();
		
		$empl_id = json_decode($_SESSION['employees_ref'])->keys->id;
		
		$link->query('BEGIN');
		try{
			
			$link->query(sprintf(
				"UPDATE doc_flow_approvements
				SET
					closed = TRUE
				WHERE id=%d",
				$this->getExtDbVal($pm,"id")
			));

			//Закрыть задачу по тек.сотру
			$link->query(sprintf(
				"UPDATE doc_flow_tasks
				SET
					close_date_time = now(),
					close_doc = register_doc,
					closed = TRUE,
					close_employee_id = %d
				WHERE
					register_doc->>'dataType'='doc_flow_approvements'
					AND  (register_doc->'keys'->>'id')::int=%d
					AND recipient->>'dataType'='employees'
					AND (recipient->'keys'->>'id')::int=%d",
				$empl_id,
				$this->getExtDbVal($pm,"id"),
				$empl_id
			));
			
			$link->query('COMMIT');
		}
		catch(Exception $e){
			$link->query('ROLLBACK');
			throw $e;
		}
	}

	/*
	public function get_form_for_task($pm){
		
		$empl_id = json_decode($_SESSION['employees_ref'])->keys->id;
	
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				coalesce(appr.closed,false),
				appr.employee_id AS author_id,
				%d IN (
					SELECT 
						(jsonb_array_elements(t.recipient_list->'rows')->'fields'->'employee'->'keys'->>'id')::int AS e_id
					FROM doc_flow_approvements AS t
					WHERE t.id=appr.id
				) AS is_employee_in_list ,
				
				(
					SELECT 
						CASE WHEN COUNT(*)=0 THEN FALSE ELSE (SUM((coalesce(sub.closed,FALSE))::int)/COUNT(*))=1 END
					FROM
					(
					SELECT 
						(jsonb_array_elements(recipient_list->'rows')->'fields'->>'closed')::bool AS closed
					FROM doc_flow_approvements
					WHERE id=appr.id
					) AS sub				
				) AS all_employees_closed
			FROM doc_flow_approvements AS appr
			WHERE appr.id=%d",
			$empl_id,
			$this->getExtDbVal($pm,"approvement_id")
		));
		
		if (!count($ar)){
			throw new Exception("Not found!");
		}
		
		$form = '';
		//если не закрыто и все завершили и открывает автор задачи = ОЗНАКОМЛЕНИЕ
		if ($ar['closed']!='t' && $ar['all_employees_closed']=='t' && $ar['author_id']==$empl_id){
			$form = 'DocFlowApprovementAuthorNote_Form';
		}
		
		//если открывает сотр из списка = ФОРМА УТВЕРЖДЕНИЯ
		else if ($ar['is_employee_in_list']!='t'){
			$form = 'DocFlowApprovemenApprove_Form';
		}
		
		//в остальных случаях ОСНОВНАЯ ФОРМА
		else{
			$form = 'DocFlowApprovement_Form';
		}
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Form_Model',
				'values'=>array(
					new Field('form',DT_STRING,
						array('value'=>$form))
				)
			)
		));		
	}
	*/
	

}
?>