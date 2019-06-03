<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
 
class ClientPersonIdPaper_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field paper ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="paper";
						
		$f_paper=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"paper",$f_opts);
		$this->addField($f_paper);
		//********************
		
		//*** Field series ***
		$f_opts = array();
		$f_opts['id']="series";
						
		$f_series=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"series",$f_opts);
		$this->addField($f_series);
		//********************
		
		//*** Field number ***
		$f_opts = array();
		$f_opts['id']="number";
						
		$f_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"number",$f_opts);
		$this->addField($f_number);
		//********************
		
		//*** Field issue_body ***
		$f_opts = array();
		$f_opts['id']="issue_body";
						
		$f_issue_body=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"issue_body",$f_opts);
		$this->addField($f_issue_body);
		//********************
		
		//*** Field issue_date ***
		$f_opts = array();
		$f_opts['id']="issue_date";
						
		$f_issue_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"issue_date",$f_opts);
		$this->addField($f_issue_date);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
