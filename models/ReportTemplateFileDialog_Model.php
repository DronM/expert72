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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class ReportTemplateFileDialog_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("report_template_files_dialog");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field report_templates_ref ***
		$f_opts = array();
		$f_opts['id']="report_templates_ref";
						
		$f_report_templates_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"report_templates_ref",$f_opts);
		$this->addField($f_report_templates_ref);
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
		
		//*** Field file_inf ***
		$f_opts = array();
		$f_opts['id']="file_inf";
						
		$f_file_inf=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_inf",$f_opts);
		$this->addField($f_file_inf);
		//********************
		
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
						
		$f_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field permissions ***
		$f_opts = array();
		$f_opts['id']="permissions";
						
		$f_permissions=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"permissions",$f_opts);
		$this->addField($f_permissions);
		//********************
		
		//*** Field for_all_views ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="for_all_views";
						
		$f_for_all_views=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"for_all_views",$f_opts);
		$this->addField($f_for_all_views);
		//********************
		
		//*** Field views ***
		$f_opts = array();
		$f_opts['id']="views";
						
		$f_views=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"views",$f_opts);
		$this->addField($f_views);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
