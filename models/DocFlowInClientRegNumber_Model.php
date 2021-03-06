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
 
class DocFlowInClientRegNumber_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("doc_flow_in_client_reg_numbers");
			
		//*** Field doc_flow_in_client_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="doc_flow_in_client_id";
						
		$f_doc_flow_in_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_in_client_id",$f_opts);
		$this->addField($f_doc_flow_in_client_id);
		//********************
		
		//*** Field reg_number ***
		$f_opts = array();
		$f_opts['length']=30;
		$f_opts['id']="reg_number";
						
		$f_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number",$f_opts);
		$this->addField($f_reg_number);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
