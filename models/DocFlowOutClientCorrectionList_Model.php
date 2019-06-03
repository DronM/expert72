<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocFlowOutClientCorrectionList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field corrected_sections ***
		$f_opts = array();
		$f_opts['id']="corrected_sections";
						
		$f_corrected_sections=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"corrected_sections",$f_opts);
		$this->addField($f_corrected_sections);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
