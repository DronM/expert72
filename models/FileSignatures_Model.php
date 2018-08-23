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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class FileSignatures_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("file_signatures");
			
		//*** Field file_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=36;
		$f_opts['id']="file_id";
				
		$f_file_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_id",$f_opts);
		$this->addField($f_file_id);
		//********************
		
		//*** Field signature_file_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=36;
		$f_opts['id']="signature_file_id";
				
		$f_signature_file_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"signature_file_id",$f_opts);
		$this->addField($f_signature_file_id);
		//********************
		
		//*** Field sign_date_time ***
		$f_opts = array();
		$f_opts['id']="sign_date_time";
				
		$f_sign_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sign_date_time",$f_opts);
		$this->addField($f_sign_date_time);
		//********************
		
		//*** Field user_certificate_id ***
		$f_opts = array();
		$f_opts['id']="user_certificate_id";
				
		$f_user_certificate_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_certificate_id",$f_opts);
		$this->addField($f_user_certificate_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
