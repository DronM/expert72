<?php

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');

class ApplicationClient_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
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
	
		//*** Field responsable_persons ***
		$f_opts = array();
		$f_opts['id']="responsable_persons";
		
		$f_responsable_persons=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"responsable_persons",$f_opts);
		$this->addField($f_responsable_persons);
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
	
		//*** Field ogrn ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="ogrn";
		
		$f_ogrn=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ogrn",$f_opts);
		$this->addField($f_ogrn);
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
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
