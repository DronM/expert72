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



require_once(FRAME_WORK_PATH.'basic_classes/ModelWhereSQL.php');

class DocFlowTask_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			
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
		
		$this->setListModelId('DocFlowTaskList_Model');
		
			
		$pm = new PublicMethod('get_short_list');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_unviewed_task_list');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('set_task_viewed');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('task_view_id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	public static function set_employee_id($dbLink){
		if (!isset($_SESSION['employee_id']) && isset($_SESSION['employees_ref'])){
			$empl = json_decode($_SESSION['employees_ref']);
			$_SESSION['employee_id'] = $empl->keys->id;
			$ar = $dbLink->query_first(sprintf("
				SELECT
					e.department_id,
					(SELECT d.boss_employee_id FROM departments d WHERE d.id=e.department_id) AS dep_boss_employee_id
				FROM employees AS e
				WHERE e.id=%d",
				$_SESSION['employee_id']));
			$_SESSION['department_id'] = $ar['department_id'];
			$_SESSION['is_dep_boss'] = ($ar['dep_boss_employee_id']==$_SESSION['employee_id']);
		}
	}

	private static function add_self_cond(&$where){
		$where->addExpression('recipient',
			sprintf(
			"(
				(recipient->>'dataType'='employees'
				AND (recipient->'keys'->>'id')::int=%d)
				OR
				(recipient->>'dataType'='departments'
				AND (recipient->'keys'->>'id')::int=%d)
			) AND NOT coalesce(closed,FALSE)",
			$_SESSION['employee_id'],
			$_SESSION['department_id']
			)
		);
	}

	public static function get_short_list_model($dbLink){
		//С УСЛОВИЯМИ: свои + свой отдел (если задача на отдел) + не закрытые
		self::set_employee_id($dbLink);
		
		$model = new DocFlowTaskShortList_Model($dbLink);
		$where = new ModelWhereSQL();
		self::add_self_cond($where);
		$model->select(FALSE,$where,NULL,
			NULL,NULL,NULL,NULL,
			NULL,TRUE
		);
		return $model;		
	}
	
	
	public function get_short_list($pm){
		$this->addModel(self::get_short_list_model($this->getDbLink()));
	}
	
	public function get_list($pm){
		if ($_SESSION['role_id']=='admin'){
			//в соответствии с фильтрами формы
			parent::get_list($pm);
		}
		else{
			self::set_employee_id($this->getDbLink());
			
			$model = new DocFlowTaskList_Model($this->getDbLink());
			$from = null; $count = null;
			$limit = $this->limitFromParams($pm,$from,$count);
			$calc_total = ($count>0);
			if ($from){
				$model->setListFrom($from);
			}
			if ($count){
				$model->setRowsPerPage($count);
			}		
			$order = $this->orderFromParams($pm,$model);
			$where = $this->conditionFromParams($pm,$model);
			$fields = $this->fieldsFromParams($pm);		
			
			if (!$_SESSION['is_dep_boss']){
				//свои + свой Отдел + не закрытые
				self::add_self_cond($where);
			}
			else{
				//свои + свой отдел + всех людей из отдела
				$where->addExpression('recipient',
					sprintf(
					"(recipient->>'dataType'='employees'
					AND (recipient->'keys'->>'id')::int=%d)
					OR
					(recipient->>'dataType'='departments'
					AND (recipient->'keys'->>'id')::int=%d)
					OR
					(
						recipient->>'dataType'='employees'
						AND (recipient->'keys'->>'id')::int IN (
								SELECT d_emp.id
								FROM employees AS d_emp
								WHERE d_emp.department_id=%d
							)
					)
					",
					$_SESSION['employee_id'],
					$_SESSION['department_id'],
					$_SESSION['department_id']
					)
				);
				
			}
			
			$model->select(FALSE,$where,$order,
				$limit,$fields,NULL,NULL,
				$calc_total,TRUE
			);
			$this->addModel($model);
		}
	}

}
?>