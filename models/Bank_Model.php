<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class Bank_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("banks");
			
		//*** Field bik ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		$f_opts['length']=9;
		$f_opts['id']="bik";
						
		$f_bik=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"bik",$f_opts);
		$this->addField($f_bik);
		//********************
		
		//*** Field codegr ***
		$f_opts = array();
		$f_opts['length']=9;
		$f_opts['id']="codegr";
						
		$f_codegr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"codegr",$f_opts);
		$this->addField($f_codegr);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		$f_opts['length']=50;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field korshet ***
		$f_opts = array();
		$f_opts['length']=20;
		$f_opts['id']="korshet";
						
		$f_korshet=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"korshet",$f_opts);
		$this->addField($f_korshet);
		//********************
		
		//*** Field adres ***
		$f_opts = array();
		$f_opts['length']=70;
		$f_opts['id']="adres";
						
		$f_adres=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"adres",$f_opts);
		$this->addField($f_adres);
		//********************
		
		//*** Field gor ***
		$f_opts = array();
		$f_opts['length']=31;
		$f_opts['id']="gor";
						
		$f_gor=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"gor",$f_opts);
		$this->addField($f_gor);
		//********************
		
		//*** Field tgroup ***
		$f_opts = array();
		$f_opts['id']="tgroup";
						
		$f_tgroup=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tgroup",$f_opts);
		$this->addField($f_tgroup);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_codegr,$direct);
$direct = 'ASC';
		$order->addField($f_bik,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
