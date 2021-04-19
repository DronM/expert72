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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInterval.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class DocFlowType_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("doc_flow_types");
			
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
		
		//*** Field num_prefix ***
		$f_opts = array();
		$f_opts['length']=10;
		$f_opts['id']="num_prefix";
						
		$f_num_prefix=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"num_prefix",$f_opts);
		$this->addField($f_num_prefix);
		//********************
		
		//*** Field def_interval ***
		$f_opts = array();
		$f_opts['id']="def_interval";
						
		$f_def_interval=new FieldSQLInterval($this->getDbLink(),$this->getDbName(),$this->getTableName(),"def_interval",$f_opts);
		$this->addField($f_def_interval);
		//********************
		
		//*** Field def_intervals ***
		$f_opts = array();
		$f_opts['id']="def_intervals";
						
		$f_def_intervals=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"def_intervals",$f_opts);
		$this->addField($f_def_intervals);
		//********************
		
		//*** Field doc_flow_types_type_id ***
		$f_opts = array();
		$f_opts['id']="doc_flow_types_type_id";
						
		$f_doc_flow_types_type_id=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_types_type_id",$f_opts);
		$this->addField($f_doc_flow_types_type_id);
		//********************
		
		//*** Field document_type ***
		$f_opts = array();
		$f_opts['length']=30;
		$f_opts['id']="document_type";
						
		$f_document_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"document_type",$f_opts);
		$this->addField($f_document_type);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_doc_flow_types_type_id,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
