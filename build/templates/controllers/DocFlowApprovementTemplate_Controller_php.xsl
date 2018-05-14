<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowApprovementTemplate'"/>
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
require_once(USER_CONTROLLERS_PATH.'DocFlowTask_Controller.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public function insert($pm){
		if ($_SESSION['role_id']!='admin' || ($_SESSION['role_id']=='admin' &amp;&amp; !$pm->getParamValue('employee_id')) ){
			$ref = json_decode($_SESSION['employees_ref']);
			if ($ref){
				$pm->setParamValue('employee_id',$ref->keys->id);
			}
		}
		parent::insert($pm);
	}
	
	public function update($pm){
		if ($_SESSION['role_id']!='admin' &amp;&amp; $pm->getParamValue('employee_id')){
			throw new Exception('Запрещено менять автора!');
		}
	
		parent::update($pm);
	}

	public function delete($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				employee_id
			FROM doc_flow_approvement_templates
			WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		
		if (!count($ar)){
			throw new Exception('Шаблон не найден!');
		}
		
		$ref = json_decode($_SESSION['employees_ref']);
		if ($_SESSION['role_id']!='admin' &amp;&amp; $ar['employee_id']!=$ref->keys->id ){
			throw new Exception('Запрещено удалять чужой шаблон!');
		}
		
		parent::delete($pm);
	}

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
			$where->addExpression('permission_ar',
				sprintf(
				"employee_id=%d OR 'employees%s' =ANY (permission_ar) OR 'departments%s' =ANY (permission_ar)
				",
				$_SESSION['employee_id'],
				$_SESSION['employee_id'],
				$_SESSION['department_id']
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
