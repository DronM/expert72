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
 
class ViewLocal_Model extends {
	
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
		
		//*** Field view ***
		$f_opts = array();
		$f_opts['id']="view";
						
		$f_view=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"view",$f_opts);
		$this->addField($f_view);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
