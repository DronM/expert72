<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class VariantStorage_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("variant_storages");
			
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="user_id";
						
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field storage_name ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="storage_name";
						
		$f_storage_name=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"storage_name",$f_opts);
		$this->addField($f_storage_name);
		//********************
		
		//*** Field variant_name ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="variant_name";
						
		$f_variant_name=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"variant_name",$f_opts);
		$this->addField($f_variant_name);
		//********************
		
		//*** Field default_variant ***
		$f_opts = array();
		$f_opts['id']="default_variant";
						
		$f_default_variant=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"default_variant",$f_opts);
		$this->addField($f_default_variant);
		//********************
		
		//*** Field filter_data ***
		$f_opts = array();
		$f_opts['id']="filter_data";
						
		$f_filter_data=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"filter_data",$f_opts);
		$this->addField($f_filter_data);
		//********************
		
		//*** Field col_visib_data ***
		$f_opts = array();
		$f_opts['id']="col_visib_data";
						
		$f_col_visib_data=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"col_visib_data",$f_opts);
		$this->addField($f_col_visib_data);
		//********************
		
		//*** Field col_order_data ***
		$f_opts = array();
		$f_opts['id']="col_order_data";
						
		$f_col_order_data=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"col_order_data",$f_opts);
		$this->addField($f_col_order_data);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
