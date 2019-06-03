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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class View_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("views");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field c ***
		$f_opts = array();
		$f_opts['id']="c";
						
		$f_c=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"c",$f_opts);
		$this->addField($f_c);
		//********************
		
		//*** Field f ***
		$f_opts = array();
		$f_opts['id']="f";
						
		$f_f=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"f",$f_opts);
		$this->addField($f_f);
		//********************
		
		//*** Field t ***
		$f_opts = array();
		$f_opts['id']="t";
						
		$f_t=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"t",$f_opts);
		$this->addField($f_t);
		//********************
		
		//*** Field section ***
		$f_opts = array();
		$f_opts['id']="section";
						
		$f_section=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"section",$f_opts);
		$this->addField($f_section);
		//********************
		
		//*** Field descr ***
		$f_opts = array();
		$f_opts['id']="descr";
						
		$f_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"descr",$f_opts);
		$this->addField($f_descr);
		//********************
		
		//*** Field limited ***
		$f_opts = array();
		$f_opts['id']="limited";
						
		$f_limited=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"limited",$f_opts);
		$this->addField($f_limited);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_section,$direct);
$direct = 'ASC';
		$order->addField($f_descr,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
