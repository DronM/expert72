<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLXML.php');
 
class Morpher_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("morpher");
			
		//*** Field src ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="src";
				
		$f_src=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"src",$f_opts);
		$this->addField($f_src);
		//********************
		
		//*** Field res ***
		$f_opts = array();
		$f_opts['id']="res";
				
		$f_res=new FieldSQLXML($this->getDbLink(),$this->getDbName(),$this->getTableName(),"res",$f_opts);
		$this->addField($f_res);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
