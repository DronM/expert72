<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowApprovement'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>

<xsl:call-template name="add_requirements"/>

require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');
require_once(USER_CONTROLLERS_PATH.'DocFlowTask_Controller.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{

	const ER_NOT_FOUND = 'Документ не нйден!@1000';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

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
			
			if (intval($row->fields->step)==$empl_step &amp;&amp; !$row->fields->closed){
				$step_closed = FALSE;
			}
			
			if ($row->fields->closed &amp;&amp; $appr_results[$row->fields->approvement_result] &lt; $close_result_num){
				$close_result = $row->fields->approvement_result;
				$close_result_num = $appr_results[$row->fields->approvement_result];
			}
		}
		
		if ($cur_empl_found){
			
			$link = $this->getDbLinkMaster();
			
			$link->query('BEGIN');
			try{
				if (!$bigger_step_exists &amp;&amp; $step_closed){
					$close_fields = sprintf(", close_date_time=now(),close_result='%s'",$close_result);
				}
				else if ($bigger_step_exists &amp;&amp; $step_closed){
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
				if ($bigger_step_exists &amp;&amp; $step_closed){
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
		if ($ar['closed']!='t' &amp;&amp; $ar['all_employees_closed']=='t' &amp;&amp; $ar['author_id']==$empl_id){
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
	
	public function get_list($pm){
		if ($_SESSION['role_id']=='admin'){
			parent::get_list($pm);
		}
		else{
			//permissions
			$list_model = $this->getListModelId();
			$model = new $list_model($this->getDbLink());
			
			$where = new ModelWhereSQL();
			DocFlowTask_Controller::set_employee_id($this->getDbLink());
			
			$where->addExpression('permission',
				sprintf(
				"employee_id=%d OR %d=ANY(recipient_employee_id_list)",
				$_SESSION['employee_id'],				
				$_SESSION['employee_id']
				)
			);
			$model->select(FALSE,$where,NULL,
				NULL,NULL,NULL,NULL,
				NULL,TRUE
			);
			$this->addModel($model);
		}
	}
	
	
</xsl:template>

</xsl:stylesheet>
