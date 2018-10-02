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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class Employee_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("employees");
			
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
		$f_opts['length']=200;
		$f_opts['id']="name";
				
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
				
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field department_id ***
		$f_opts = array();
		$f_opts['id']="department_id";
				
		$f_department_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"department_id",$f_opts);
		$this->addField($f_department_id);
		//********************
		
		//*** Field post_id ***
		$f_opts = array();
		$f_opts['id']="post_id";
				
		$f_post_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"post_id",$f_opts);
		$this->addField($f_post_id);
		//********************
		
		//*** Field picture ***
		$f_opts = array();
		$f_opts['id']="picture";
				
		$f_picture=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"picture",$f_opts);
		$this->addField($f_picture);
		//********************
		
		//*** Field picture_info ***
		$f_opts = array();
		$f_opts['id']="picture_info";
				
		$f_picture_info=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"picture_info",$f_opts);
		$this->addField($f_picture_info);
		//********************
		
		//*** Field snils ***
		$f_opts = array();
		$f_opts['length']=11;
		$f_opts['id']="snils";
				
		$f_snils=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"snils",$f_opts);
		$this->addField($f_snils);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_name,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
