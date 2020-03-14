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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class Service_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("services");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		$f_opts['length']=250;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field date_type ***
		$f_opts = array();
		$f_opts['id']="date_type";
						
		$f_date_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_type",$f_opts);
		$this->addField($f_date_type);
		//********************
		
		//*** Field work_day_count ***
		$f_opts = array();
		$f_opts['id']="work_day_count";
						
		$f_work_day_count=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"work_day_count",$f_opts);
		$this->addField($f_work_day_count);
		//********************
		
		//*** Field expertise_day_count ***
		$f_opts = array();
		$f_opts['id']="expertise_day_count";
						
		$f_expertise_day_count=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_day_count",$f_opts);
		$this->addField($f_expertise_day_count);
		//********************
		
		//*** Field contract_postf ***
		$f_opts = array();
		$f_opts['length']=5;
		$f_opts['id']="contract_postf";
						
		$f_contract_postf=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_postf",$f_opts);
		$this->addField($f_contract_postf);
		//********************
		
		//*** Field service_type ***
		$f_opts = array();
		
		$f_opts['alias']='Вид услуги';
		$f_opts['id']="service_type";
						
		$f_service_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"service_type",$f_opts);
		$this->addField($f_service_type);
		//********************
		
		//*** Field expertise_type ***
		$f_opts = array();
		
		$f_opts['alias']='Вид гос.экспертизы';
		$f_opts['id']="expertise_type";
						
		$f_expertise_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_type",$f_opts);
		$this->addField($f_expertise_type);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_service_type,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
