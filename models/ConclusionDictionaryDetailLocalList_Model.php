<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ConclusionDictionaryDetailLocalList_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field conclusion_dictionary_details_ref ***
		$f_opts = array();
		$f_opts['id']="conclusion_dictionary_details_ref";
						
		$f_conclusion_dictionary_details_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"conclusion_dictionary_details_ref",$f_opts);
		$this->addField($f_conclusion_dictionary_details_ref);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
