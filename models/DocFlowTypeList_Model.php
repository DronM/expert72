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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInterval.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class DocFlowTypeList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_types_list");
			
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
		
		//*** Field def_interval ***
		$f_opts = array();
		$f_opts['id']="def_interval";
				
		$f_def_interval=new FieldSQLInterval($this->getDbLink(),$this->getDbName(),$this->getTableName(),"def_interval",$f_opts);
		$this->addField($f_def_interval);
		//********************
		
		//*** Field doc_flow_types_type_id ***
		$f_opts = array();
		$f_opts['id']="doc_flow_types_type_id";
				
		$f_doc_flow_types_type_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_types_type_id",$f_opts);
		$this->addField($f_doc_flow_types_type_id);
		//********************
		
		//*** Field num_prefix ***
		$f_opts = array();
		$f_opts['length']=10;
		$f_opts['id']="num_prefix";
				
		$f_num_prefix=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"num_prefix",$f_opts);
		$this->addField($f_num_prefix);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_name,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
