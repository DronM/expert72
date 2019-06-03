<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class DocFlowApprovementRecipientList_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field employee ***
		$f_opts = array();
		$f_opts['id']="employee";
						
		$f_employee=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee",$f_opts);
		$this->addField($f_employee);
		//********************
		
		//*** Field step ***
		$f_opts = array();
		$f_opts['id']="step";
						
		$f_step=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"step",$f_opts);
		$this->addField($f_step);
		//********************
		
		//*** Field employee_comment ***
		$f_opts = array();
		$f_opts['id']="employee_comment";
						
		$f_employee_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_comment",$f_opts);
		$this->addField($f_employee_comment);
		//********************
		
		//*** Field approvement_result ***
		$f_opts = array();
		$f_opts['id']="approvement_result";
						
		$f_approvement_result=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"approvement_result",$f_opts);
		$this->addField($f_approvement_result);
		//********************
		
		//*** Field approvement_dt ***
		$f_opts = array();
		$f_opts['id']="approvement_dt";
						
		$f_approvement_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"approvement_dt",$f_opts);
		$this->addField($f_approvement_dt);
		//********************
		
		//*** Field approvement_order ***
		$f_opts = array();
		$f_opts['id']="approvement_order";
						
		$f_approvement_order=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"approvement_order",$f_opts);
		$this->addField($f_approvement_order);
		//********************
		
		//*** Field closed ***
		$f_opts = array();
		$f_opts['id']="closed";
						
		$f_closed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"closed",$f_opts);
		$this->addField($f_closed);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
