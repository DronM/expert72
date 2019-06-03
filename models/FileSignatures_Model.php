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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class FileSignatures_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("file_signatures");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field file_id ***
		$f_opts = array();
		$f_opts['length']=36;
		$f_opts['id']="file_id";
						
		$f_file_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_id",$f_opts);
		$this->addField($f_file_id);
		//********************
		
		//*** Field user_certificate_id ***
		$f_opts = array();
		$f_opts['id']="user_certificate_id";
						
		$f_user_certificate_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_certificate_id",$f_opts);
		$this->addField($f_user_certificate_id);
		//********************
		
		//*** Field sign_date_time ***
		$f_opts = array();
		$f_opts['id']="sign_date_time";
						
		$f_sign_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sign_date_time",$f_opts);
		$this->addField($f_sign_date_time);
		//********************
		
		//*** Field algorithm ***
		$f_opts = array();
		$f_opts['id']="algorithm";
						
		$f_algorithm=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"algorithm",$f_opts);
		$this->addField($f_algorithm);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
