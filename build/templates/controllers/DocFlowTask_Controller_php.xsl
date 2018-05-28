<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowTask'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(FRAME_WORK_PATH.'basic_classes/ModelWhereSQL.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public static function set_employee_id($dbLink){
		if (!isset($_SESSION['employee_id']) &amp;&amp; isset($_SESSION['employees_ref'])){
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

	private static function add_self_cond(&amp;$where){
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
</xsl:template>

</xsl:stylesheet>
