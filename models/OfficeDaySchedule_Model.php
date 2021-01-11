<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class OfficeDaySchedule_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("office_day_schedules");
			
		//*** Field office_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="office_id";
						
		$f_office_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"office_id",$f_opts);
		$this->addField($f_office_id);
		//********************
		
		//*** Field day ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="day";
						
		$f_day=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"day",$f_opts);
		$this->addField($f_day);
		//********************
		
		//*** Field work_hours ***
		$f_opts = array();
		$f_opts['id']="work_hours";
						
		$f_work_hours=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"work_hours",$f_opts);
		$this->addField($f_work_hours);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_office_id,$direct);
$direct = 'ASC';
		$order->addField($f_day,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
