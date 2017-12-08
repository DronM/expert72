<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');

class ConstrTypeTechnicalFeatureList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("constr_type_technical_features_list");
			
		//*** Field construction_type ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="construction_type";
		
		$f_construction_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"construction_type",$f_opts);
		$this->addField($f_construction_type);
		//********************
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
