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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLXML.php');
 
class ExpertConclusion_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("expert_conclusions");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field contract_id ***
		$f_opts = array();
		$f_opts['id']="contract_id";
						
		$f_contract_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_id",$f_opts);
		$this->addField($f_contract_id);
		//********************
		
		//*** Field expert_id ***
		$f_opts = array();
		$f_opts['id']="expert_id";
						
		$f_expert_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expert_id",$f_opts);
		$this->addField($f_expert_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field last_modified ***
		$f_opts = array();
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="last_modified";
						
		$f_last_modified=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"last_modified",$f_opts);
		$this->addField($f_last_modified);
		//********************
		
		//*** Field conclusion ***
		$f_opts = array();
		$f_opts['id']="conclusion";
						
		$f_conclusion=new FieldSQLXML($this->getDbLink(),$this->getDbName(),$this->getTableName(),"conclusion",$f_opts);
		$this->addField($f_conclusion);
		//********************
		
		//*** Field conclusion_type ***
		$f_opts = array();
		$f_opts['length']=10;
		$f_opts['id']="conclusion_type";
						
		$f_conclusion_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"conclusion_type",$f_opts);
		$this->addField($f_conclusion_type);
		//********************
		
		//*** Field conclusion_type_descr ***
		$f_opts = array();
		$f_opts['id']="conclusion_type_descr";
						
		$f_conclusion_type_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"conclusion_type_descr",$f_opts);
		$this->addField($f_conclusion_type_descr);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
