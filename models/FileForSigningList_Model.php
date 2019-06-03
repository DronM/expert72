<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class FileForSigningList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field attachment_files_only_sigs ***
		$f_opts = array();
		$f_opts['id']="attachment_files_only_sigs";
						
		$f_attachment_files_only_sigs=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"attachment_files_only_sigs",$f_opts);
		$this->addField($f_attachment_files_only_sigs);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
