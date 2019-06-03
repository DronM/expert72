<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
 
class RecipientPicture_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field picture ***
		$f_opts = array();
		$f_opts['id']="picture";
						
		$f_picture=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"picture",$f_opts);
		$this->addField($f_picture);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
