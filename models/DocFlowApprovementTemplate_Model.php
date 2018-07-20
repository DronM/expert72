<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLArray.php');
 
class DocFlowApprovementTemplate_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_approvement_templates");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		
		$f_opts['alias']='Наименование';
		$f_opts['length']=100;
		$f_opts['id']="name";
				
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="comment_text";
				
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
				
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
		
		//*** Field recipient_list ***
		$f_opts = array();
		$f_opts['id']="recipient_list";
				
		$f_recipient_list=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_list",$f_opts);
		$this->addField($f_recipient_list);
		//********************
		
		//*** Field permissions ***
		$f_opts = array();
		$f_opts['id']="permissions";
				
		$f_permissions=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"permissions",$f_opts);
		$this->addField($f_permissions);
		//********************
		
		//*** Field permission_ar ***
		$f_opts = array();
		$f_opts['id']="permission_ar";
				
		$f_permission_ar=new FieldSQLArray($this->getDbLink(),$this->getDbName(),$this->getTableName(),"permission_ar",$f_opts);
		$this->addField($f_permission_ar);
		//********************
		
		//*** Field for_all_employees ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="for_all_employees";
				
		$f_for_all_employees=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"for_all_employees",$f_opts);
		$this->addField($f_for_all_employees);
		//********************
		
		//*** Field doc_flow_approvement_type ***
		$f_opts = array();
		$f_opts['id']="doc_flow_approvement_type";
				
		$f_doc_flow_approvement_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_approvement_type",$f_opts);
		$this->addField($f_doc_flow_approvement_type);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
