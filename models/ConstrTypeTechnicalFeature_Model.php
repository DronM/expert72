<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');

class ConstrTypeTechnicalFeature_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("constr_type_technical_features");
			
		//*** Field construction_type ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="construction_type";
		
		$f_construction_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"construction_type",$f_opts);
		$this->addField($f_construction_type);
		//********************
	
		//*** Field technical_features ***
		$f_opts = array();
		$f_opts['id']="technical_features";
		
		$f_technical_features=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"technical_features",$f_opts);
		$this->addField($f_technical_features);
		//********************

		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_construction_type,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
