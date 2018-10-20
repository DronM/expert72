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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class DocFlowOutClientDocumentFile_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_out_client_document_files");
			
		//*** Field file_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=36;
		$f_opts['id']="file_id";
				
		$f_file_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_id",$f_opts);
		$this->addField($f_file_id);
		//********************
		
		//*** Field doc_flow_out_client_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="doc_flow_out_client_id";
				
		$f_doc_flow_out_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_out_client_id",$f_opts);
		$this->addField($f_doc_flow_out_client_id);
		//********************
		
		//*** Field is_new ***
		$f_opts = array();
		$f_opts['defaultValue']='TRUE';
		$f_opts['id']="is_new";
				
		$f_is_new=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"is_new",$f_opts);
		$this->addField($f_is_new);
		//********************
		
		//*** Field signature ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="signature";
				
		$f_signature=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"signature",$f_opts);
		$this->addField($f_signature);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
