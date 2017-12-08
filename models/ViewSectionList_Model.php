<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');

class ViewSectionList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("views_section_list");
			
		//*** Field section ***
		$f_opts = array();
		$f_opts['id']="section";
		
		$f_section=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"section",$f_opts);
		$this->addField($f_section);
		//********************
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
