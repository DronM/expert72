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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class ConclusionDictionaryDetail_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("conclusion_dictionary_detail");
			
		//*** Field conclusion_dictionary_name ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		$f_opts['length']=50;
		$f_opts['id']="conclusion_dictionary_name";
						
		$f_conclusion_dictionary_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"conclusion_dictionary_name",$f_opts);
		$this->addField($f_conclusion_dictionary_name);
		//********************
		
		//*** Field code ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=10;
		$f_opts['id']="code";
						
		$f_code=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"code",$f_opts);
		$this->addField($f_code);
		//********************
		
		//*** Field descr ***
		$f_opts = array();
		$f_opts['id']="descr";
						
		$f_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"descr",$f_opts);
		$this->addField($f_descr);
		//********************
		
		//*** Field is_group ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="is_group";
						
		$f_is_group=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"is_group",$f_opts);
		$this->addField($f_is_group);
		//********************
		
		//*** Field ord ***
		$f_opts = array();
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="ord";
						
		$f_ord=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ord",$f_opts);
		$this->addField($f_ord);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_conclusion_dictionary_name,$direct);
$direct = 'ASC';
		$order->addField($f_ord,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
