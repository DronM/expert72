<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/Model.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class MainMenuContent_Model extends Model{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field descr ***
		$f_opts = array();
		$f_opts['id']="descr";
						
		$f_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"descr",$f_opts);
		$this->addField($f_descr);
		//********************
		
		//*** Field viewid ***
		$f_opts = array();
		$f_opts['id']="viewid";
						
		$f_viewid=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"viewid",$f_opts);
		$this->addField($f_viewid);
		//********************
		
		//*** Field viewdescr ***
		$f_opts = array();
		$f_opts['id']="viewdescr";
						
		$f_viewdescr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"viewdescr",$f_opts);
		$this->addField($f_viewdescr);
		//********************
		
		//*** Field default ***
		$f_opts = array();
		$f_opts['id']="default";
						
		$f_default=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"default",$f_opts);
		$this->addField($f_default);
		//********************
		
		//*** Field glyphclass ***
		$f_opts = array();
		$f_opts['id']="glyphclass";
						
		$f_glyphclass=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"glyphclass",$f_opts);
		$this->addField($f_glyphclass);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
