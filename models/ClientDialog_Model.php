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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class ClientDialog_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("clients_dialog");
			
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
		
		//*** Field name_full ***
		$f_opts = array();
		$f_opts['id']="name_full";
				
		$f_name_full=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name_full",$f_opts);
		$this->addField($f_name_full);
		//********************
		
		//*** Field inn ***
		$f_opts = array();
		$f_opts['length']=12;
		$f_opts['id']="inn";
				
		$f_inn=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"inn",$f_opts);
		$this->addField($f_inn);
		//********************
		
		//*** Field kpp ***
		$f_opts = array();
		$f_opts['length']=10;
		$f_opts['id']="kpp";
				
		$f_kpp=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"kpp",$f_opts);
		$this->addField($f_kpp);
		//********************
		
		//*** Field ogrn ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="ogrn";
				
		$f_ogrn=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ogrn",$f_opts);
		$this->addField($f_ogrn);
		//********************
		
		//*** Field okpo ***
		$f_opts = array();
		$f_opts['length']=20;
		$f_opts['id']="okpo";
				
		$f_okpo=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"okpo",$f_opts);
		$this->addField($f_okpo);
		//********************
		
		//*** Field okved ***
		$f_opts = array();
		$f_opts['id']="okved";
				
		$f_okved=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"okved",$f_opts);
		$this->addField($f_okved);
		//********************
		
		//*** Field ext_id ***
		$f_opts = array();
		$f_opts['length']=36;
		$f_opts['id']="ext_id";
				
		$f_ext_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ext_id",$f_opts);
		$this->addField($f_ext_id);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
				
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field post_address ***
		$f_opts = array();
		$f_opts['id']="post_address";
				
		$f_post_address=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"post_address",$f_opts);
		$this->addField($f_post_address);
		//********************
		
		//*** Field legal_address ***
		$f_opts = array();
		$f_opts['id']="legal_address";
				
		$f_legal_address=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"legal_address",$f_opts);
		$this->addField($f_legal_address);
		//********************
		
		//*** Field bank_accounts ***
		$f_opts = array();
		$f_opts['id']="bank_accounts";
				
		$f_bank_accounts=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"bank_accounts",$f_opts);
		$this->addField($f_bank_accounts);
		//********************
		
		//*** Field client_type ***
		$f_opts = array();
		$f_opts['defaultValue']='enterprise';
		$f_opts['id']="client_type";
				
		$f_client_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_type",$f_opts);
		$this->addField($f_client_type);
		//********************
		
		//*** Field base_document_for_contract ***
		$f_opts = array();
		$f_opts['id']="base_document_for_contract";
				
		$f_base_document_for_contract=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"base_document_for_contract",$f_opts);
		$this->addField($f_base_document_for_contract);
		//********************
		
		//*** Field person_id_paper ***
		$f_opts = array();
		$f_opts['id']="person_id_paper";
				
		$f_person_id_paper=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"person_id_paper",$f_opts);
		$this->addField($f_person_id_paper);
		//********************
		
		//*** Field person_registr_paper ***
		$f_opts = array();
		$f_opts['id']="person_registr_paper";
				
		$f_person_registr_paper=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"person_registr_paper",$f_opts);
		$this->addField($f_person_registr_paper);
		//********************
		
		//*** Field responsable_persons ***
		$f_opts = array();
		$f_opts['id']="responsable_persons";
				
		$f_responsable_persons=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"responsable_persons",$f_opts);
		$this->addField($f_responsable_persons);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
