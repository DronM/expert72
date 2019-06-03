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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ReportTemplate_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("report_templates");
			
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
		$f_opts['length']=100;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field db_entity ***
		$f_opts = array();
		$f_opts['length']=100;
		$f_opts['id']="db_entity";
						
		$f_db_entity=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"db_entity",$f_opts);
		$this->addField($f_db_entity);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field fields ***
		$f_opts = array();
		
		$f_opts['alias']='Поля шаблона';
		$f_opts['id']="fields";
						
		$f_fields=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fields",$f_opts);
		$this->addField($f_fields);
		//********************
		
		//*** Field in_params ***
		$f_opts = array();
		
		$f_opts['alias']='Параметры выборки данных';
		$f_opts['id']="in_params";
						
		$f_in_params=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"in_params",$f_opts);
		$this->addField($f_in_params);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
