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
 
class VariantStorageList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("variant_storages_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
						
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field storage_name ***
		$f_opts = array();
		$f_opts['id']="storage_name";
						
		$f_storage_name=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"storage_name",$f_opts);
		$this->addField($f_storage_name);
		//********************
		
		//*** Field default_variant ***
		$f_opts = array();
		$f_opts['id']="default_variant";
						
		$f_default_variant=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"default_variant",$f_opts);
		$this->addField($f_default_variant);
		//********************
		
		//*** Field variant_name ***
		$f_opts = array();
		$f_opts['id']="variant_name";
						
		$f_variant_name=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"variant_name",$f_opts);
		$this->addField($f_variant_name);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
