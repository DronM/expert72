<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ApplicationReturnedFilesRemovedList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("applications_returned_files_removed_list");
			
		//*** Field application_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="application_id";
						
		$f_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_id",$f_opts);
		$this->addField($f_application_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field applications_ref ***
		$f_opts = array();
		$f_opts['id']="applications_ref";
						
		$f_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"applications_ref",$f_opts);
		$this->addField($f_applications_ref);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
