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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocumentTemplate_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("document_templates");
			
		//*** Field document_type ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="document_type";
						
		$f_document_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"document_type",$f_opts);
		$this->addField($f_document_type);
		//********************
		
		//*** Field service_type ***
		$f_opts = array();
		$f_opts['id']="service_type";
						
		$f_service_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"service_type",$f_opts);
		$this->addField($f_service_type);
		//********************
		
		//*** Field construction_type_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="construction_type_id";
						
		$f_construction_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"construction_type_id",$f_opts);
		$this->addField($f_construction_type_id);
		//********************
		
		//*** Field create_date ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Дата создания';
		$f_opts['defaultValue']='now()::date';
		$f_opts['id']="create_date";
						
		$f_create_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"create_date",$f_opts);
		$this->addField($f_create_date);
		//********************
		
		//*** Field content ***
		$f_opts = array();
		
		$f_opts['alias']='Содержимое шаблона';
		$f_opts['id']="content";
						
		$f_content=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"content",$f_opts);
		$this->addField($f_content);
		//********************
		
		//*** Field content_for_experts ***
		$f_opts = array();
		
		$f_opts['alias']='Содержимое шаблона';
		$f_opts['id']="content_for_experts";
						
		$f_content_for_experts=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"content_for_experts",$f_opts);
		$this->addField($f_content_for_experts);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
