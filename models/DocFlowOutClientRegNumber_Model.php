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
 
class DocFlowOutClientRegNumber_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_out_client_reg_numbers");
			
		//*** Field doc_flow_out_client_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="doc_flow_out_client_id";
						
		$f_doc_flow_out_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_out_client_id",$f_opts);
		$this->addField($f_doc_flow_out_client_id);
		//********************
		
		//*** Field application_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="application_id";
						
		$f_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_id",$f_opts);
		$this->addField($f_application_id);
		//********************
		
		//*** Field reg_number ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="reg_number";
						
		$f_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number",$f_opts);
		$this->addField($f_reg_number);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
