<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocumentTemplateAllList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("document_templates_all_list");
			
		//*** Field documents ***
		$f_opts = array();
		$f_opts['id']="documents";
				
		$f_documents=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"documents",$f_opts);
		$this->addField($f_documents);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
