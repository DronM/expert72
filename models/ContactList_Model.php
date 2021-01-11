<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class ContactList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("contacts_list");
			
		//*** Field name ***
		$f_opts = array();
		$f_opts['length']=200;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field email ***
		$f_opts = array();
		$f_opts['id']="email";
						
		$f_email=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"email",$f_opts);
		$this->addField($f_email);
		//********************
		
		//*** Field tel ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="tel";
						
		$f_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tel",$f_opts);
		$this->addField($f_tel);
		//********************
		
		//*** Field post ***
		$f_opts = array();
		$f_opts['id']="post";
						
		$f_post=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"post",$f_opts);
		$this->addField($f_post);
		//********************
		
		//*** Field firm_name ***
		$f_opts = array();
		$f_opts['length']=250;
		$f_opts['id']="firm_name";
						
		$f_firm_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"firm_name",$f_opts);
		$this->addField($f_firm_name);
		//********************
		
		//*** Field dep ***
		$f_opts = array();
		$f_opts['length']=250;
		$f_opts['id']="dep";
						
		$f_dep=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dep",$f_opts);
		$this->addField($f_dep);
		//********************
		
		//*** Field contact ***
		$f_opts = array();
		$f_opts['id']="contact";
						
		$f_contact=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contact",$f_opts);
		$this->addField($f_contact);
		//********************
		
		//*** Field contact_descr ***
		$f_opts = array();
		$f_opts['id']="contact_descr";
						
		$f_contact_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contact_descr",$f_opts);
		$this->addField($f_contact_descr);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_contact,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
