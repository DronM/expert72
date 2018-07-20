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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class BankList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("banks_list");
			
		//*** Field bik ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		
		$f_opts['alias']='БИК';
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
		
		//*** Field gr_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Регион';
		$f_opts['length']=50;
		$f_opts['id']="gr_descr";
				
		$f_gr_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"gr_descr",$f_opts);
		$this->addField($f_gr_descr);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		
		$f_opts['alias']='Наименование';
		$f_opts['length']=50;
		$f_opts['id']="name";
				
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field korshet ***
		$f_opts = array();
		
		$f_opts['alias']='Кoр.счет';
		$f_opts['length']=20;
		$f_opts['id']="korshet";
				
		$f_korshet=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"korshet",$f_opts);
		$this->addField($f_korshet);
		//********************
		
		//*** Field adres ***
		$f_opts = array();
		
		$f_opts['alias']='Адрес';
		$f_opts['length']=70;
		$f_opts['id']="adres";
				
		$f_adres=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"adres",$f_opts);
		$this->addField($f_adres);
		//********************
		
		//*** Field gor ***
		$f_opts = array();
		
		$f_opts['alias']='Город';
		$f_opts['length']=31;
		$f_opts['id']="gor";
				
		$f_gor=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"gor",$f_opts);
		$this->addField($f_gor);
		//********************
		
		//*** Field tgoup ***
		$f_opts = array();
		$f_opts['length']=31;
		$f_opts['id']="tgoup";
				
		$f_tgoup=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tgoup",$f_opts);
		$this->addField($f_tgoup);
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
