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
 
class DocFlowOutClientOriginalFile_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("doc_flow_out_client_original_files");
			
		//*** Field doc_flow_out_client_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="doc_flow_out_client_id";
						
		$f_doc_flow_out_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_out_client_id",$f_opts);
		$this->addField($f_doc_flow_out_client_id);
		//********************
		
		//*** Field original_file_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=36;
		$f_opts['id']="original_file_id";
						
		$f_original_file_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"original_file_id",$f_opts);
		$this->addField($f_original_file_id);
		//********************
		
		//*** Field new_file_id ***
		$f_opts = array();
		$f_opts['length']=36;
		$f_opts['id']="new_file_id";
						
		$f_new_file_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"new_file_id",$f_opts);
		$this->addField($f_new_file_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
