<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ConstantList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("constants_list_view");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field descr ***
		$f_opts = array();
		$f_opts['id']="descr";
						
		$f_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"descr",$f_opts);
		$this->addField($f_descr);
		//********************
		
		//*** Field val ***
		$f_opts = array();
		$f_opts['id']="val";
						
		$f_val=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"val",$f_opts);
		$this->addField($f_val);
		//********************
		
		//*** Field val_type ***
		$f_opts = array();
		$f_opts['id']="val_type";
						
		$f_val_type=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"val_type",$f_opts);
		$this->addField($f_val_type);
		//********************
		
		//*** Field ctrl_class ***
		$f_opts = array();
		$f_opts['id']="ctrl_class";
						
		$f_ctrl_class=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ctrl_class",$f_opts);
		$this->addField($f_ctrl_class);
		//********************
		
		//*** Field ctrl_options ***
		$f_opts = array();
		$f_opts['id']="ctrl_options";
						
		$f_ctrl_options=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ctrl_options",$f_opts);
		$this->addField($f_ctrl_options);
		//********************
		
		//*** Field view_class ***
		$f_opts = array();
		$f_opts['id']="view_class";
						
		$f_view_class=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"view_class",$f_opts);
		$this->addField($f_view_class);
		//********************
		
		//*** Field view_options ***
		$f_opts = array();
		$f_opts['id']="view_options";
						
		$f_view_options=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"view_options",$f_opts);
		$this->addField($f_view_options);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_name,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
