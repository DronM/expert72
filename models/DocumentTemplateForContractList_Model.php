<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocumentTemplateForContractList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field document_type ***
		$f_opts = array();
		$f_opts['id']="document_type";
						
		$f_document_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"document_type",$f_opts);
		$this->addField($f_document_type);
		//********************
		
		//*** Field sections ***
		$f_opts = array();
		$f_opts['id']="sections";
						
		$f_sections=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sections",$f_opts);
		$this->addField($f_sections);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
