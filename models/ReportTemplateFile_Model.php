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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLArray.php');
 
class ReportTemplateFile_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("report_template_files");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field report_template_id ***
		$f_opts = array();
		$f_opts['id']="report_template_id";
				
		$f_report_template_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"report_template_id",$f_opts);
		$this->addField($f_report_template_id);
		//********************
		
		//*** Field file_inf ***
		$f_opts = array();
		$f_opts['id']="file_inf";
				
		$f_file_inf=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_inf",$f_opts);
		$this->addField($f_file_inf);
		//********************
		
		//*** Field file_data ***
		$f_opts = array();
		$f_opts['id']="file_data";
				
		$f_file_data=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_data",$f_opts);
		$this->addField($f_file_data);
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
		
		//*** Field permission_ar ***
		$f_opts = array();
		$f_opts['id']="permission_ar";
				
		$f_permission_ar=new FieldSQLArray($this->getDbLink(),$this->getDbName(),$this->getTableName(),"permission_ar",$f_opts);
		$this->addField($f_permission_ar);
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
		
		//*** Field view_ar ***
		$f_opts = array();
		$f_opts['id']="view_ar";
				
		$f_view_ar=new FieldSQLArray($this->getDbLink(),$this->getDbName(),$this->getTableName(),"view_ar",$f_opts);
		$this->addField($f_view_ar);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
				
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
