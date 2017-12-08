<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');

class EmailTemplate_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("email_templates");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
		
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
	
		//*** Field email_type ***
		$f_opts = array();
		$f_opts['primaryKey'] = FALSE;
		$f_opts['autoInc']=FALSE;
		$f_opts['id']="email_type";
		
		$f_email_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"email_type",$f_opts);
		$this->addField($f_email_type);
		//********************
	
		//*** Field template ***
		$f_opts = array();
		$f_opts['id']="template";
		
		$f_template=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"template",$f_opts);
		$this->addField($f_template);
		//********************
	
		//*** Field comment_text ***
		$f_opts = array();
		$f_opts['id']="comment_text";
		
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
	
		//*** Field mes_subject ***
		$f_opts = array();
		$f_opts['id']="mes_subject";
		
		$f_mes_subject=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mes_subject",$f_opts);
		$this->addField($f_mes_subject);
		//********************
	
		//*** Field fields ***
		$f_opts = array();
		$f_opts['id']="fields";
		
		$f_fields=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fields",$f_opts);
		$this->addField($f_fields);
		//********************

		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_email_type,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
