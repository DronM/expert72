<?php
require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInterval.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtArray.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtXML.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */



require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');



class Kladr_Controller extends ControllerSQL{
	const COMPLETE_RES_COUNT=5;
	
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		$kladr_link = new DB_Sql();
		$kladr_link->appname		= APP_NAME;
		$kladr_link->technicalemail = TECH_EMAIL;
		$kladr_link->reporterror	= DEBUG;
		$kladr_link->database		= 'kladr';
		$kladr_link->connect(KLADR_DB_SERVER,KLADR_DB_USER,KLADR_DB_PASSWORD);
		//$kladr_link->set_error_verbosity((DEBUG)? PGSQL_ERRORS_VERBOSE:PGSQL_ERRORS_TERSE);
		
		parent::__construct($dbLinkMaster,$kladr_link);
			
		$pm = new PublicMethod('get_region_list');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('pattern',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_raion_list');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('region_code',$opts));
	
				
	$opts=array();
	
		$opts['length']=40;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('pattern',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_naspunkt_list');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('region_code',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('raion_code',$opts));
	
				
	$opts=array();
	
		$opts['length']=40;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('pattern',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_gorod_list');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('region_code',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('raion_code',$opts));
	
				
	$opts=array();
	
		$opts['length']=40;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('pattern',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_ulitsa_list');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('region_code',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('raion_code',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('naspunkt_code',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('gorod_code',$opts));
	
				
	$opts=array();
	
		$opts['length']=40;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('pattern',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_from_naspunkt');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('region_code',$opts));
	
				
	$opts=array();
	
		$opts['length']=40;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('pattern',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('from',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('count',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	public function get_region_list($pm){
		$dbLink = $this->getDbLink();
		$pattern = $dbLink->escape_string($pm->getParamValue('pattern'));
		$q = sprintf("SELECT 
				code AS region_code,
				name,
				name||' '||socr AS full_name
			FROM kladr
			WHERE code LIKE '__000000000__'
				AND lower(name) LIKE lower('%s%%')
			ORDER BY name LIMIT %d",
			$pattern,
			Kladr_Controller::COMPLETE_RES_COUNT);
		$this->addNewModel($q);
	}	
	public function get_raion_list($pm){
		$dbLink = $this->getDbLink();
		$pattern = $dbLink->escape_string($pm->getParamValue('pattern'));
		$region_code = substr($dbLink->escape_string($pm->getParamValue('region_code')),0,2);
	
		$q = sprintf("SELECT 
				code AS raion_code,
				name,
				name||' '||socr AS full_name
			FROM kladr
			WHERE
				code LIKE '%s___00000000'
				AND code <> '%s00000000000'
				AND lower(name) LIKE lower('%s%%')
			ORDER BY name LIMIT %d",
			$region_code,
			$region_code,
			$pattern,
			Kladr_Controller::COMPLETE_RES_COUNT);
		$this->addNewModel($q);
	}		
	public function get_naspunkt_list($pm){
		$dbLink = $this->getDbLink();
		$pattern = $dbLink->escape_string($pm->getParamValue('pattern'));
		$region_code = substr($dbLink->escape_string($pm->getParamValue('region_code')),0,2);
		$raion_code_str = $dbLink->escape_string($pm->getParamValue('raion_code'));
		$raion_code = substr($raion_code_str,2,3);
		if (!strlen($raion_code) || $raion_code_str=='null'){
			$raion_code = '000';
		}
		
		$q = sprintf("SELECT 
				code AS naspunkt_code,
				name,
				name||' '||socr AS full_name
			FROM kladr
			WHERE code LIKE '%s%s________'
				AND code <> '%s%s00000000'
				AND lower(name) LIKE lower('%s%%')
			ORDER BY name LIMIT %d",
			$region_code,
			$raion_code,
			$region_code,
			$raion_code,
			$pattern,
			Kladr_Controller::COMPLETE_RES_COUNT);
		$this->addNewModel($q);
	}			
	public function get_gorod_list($pm){
		$dbLink = $this->getDbLink();
		$pattern = $dbLink->escape_string($pm->getParamValue('pattern'));
		$region_code = substr($dbLink->escape_string($pm->getParamValue('region_code')),0,2);
		$raion_code_str = $dbLink->escape_string($pm->getParamValue('raion_code'));
		$raion_code = substr($raion_code_str,2,3);
		
		if (!strlen($raion_code) || $raion_code_str=='null'){
			$raion_code = '000';
		}
		
		$q = sprintf("SELECT 
				code AS gorod_code,
				name,
				name||' '||socr AS full_name
			FROM kladr
			WHERE code LIKE '%s%s___00000'
				AND code <> '%s%s00000000'
				AND code <> '%s00000000000'
				AND lower(name) LIKE lower('%s%%')
			ORDER BY name LIMIT %d",
			$region_code,
			$raion_code,
			$region_code,
			$raion_code,
			$region_code,
			$pattern,
			Kladr_Controller::COMPLETE_RES_COUNT);
		$this->addNewModel($q);
	}				
	public function get_ulitsa_list($pm){
		$dbLink = $this->getDbLink();
		
		$params = new ParamsSQL($pm,$dbLink);
		$params->addAll();		
		
		$pattern = $params->getDbVal('pattern');
		
		if ($params->getVal('naspunkt_code') && $params->getVal('naspunkt_code')!='null'){
			$code = "'".substr($params->getVal('naspunkt_code'),0,11)."'";
		}
		else if ($params->getVal('gorod_code') && $params->getVal('gorod_code')!='null'){
			$code = "'".substr($params->getVal('gorod_code'),0,11)."'";
		}
		else if ($params->getVal('raion_code') && $params->getVal('raion_code')!='null'){
			$code = "'".substr($params->getVal('raion_code'),0,11)."'";
		}
		else{
			$code = "'".substr($params->getVal('region_code'),0,11)."'";
		}		
		
		$q = sprintf("SELECT 
				code AS ulitsa_code,
				name,
				name||' '||socr AS full_name
			FROM street
			WHERE
				code_part = %s
				AND lower(name) LIKE lower(%s)||'%%'
			ORDER BY name LIMIT %d",
			$code,
			$pattern,
			Kladr_Controller::COMPLETE_RES_COUNT);
		//throw new Exception($q);
		$this->addNewModel($q);
	}
	
	public function get_from_naspunkt($pm){
		$dbLink = $this->getDbLink();
		
		$params = new ParamsSQL($pm,$dbLink);
		$params->addAll();		
		
		$pattern = $params->getDbVal('pattern');
		$count = $params->getDbVal('count');
		if (!$count){
			$count = Kladr_Controller::COMPLETE_RES_COUNT;
		}
		$from = $params->getDbVal('from');
		if (!$from){
			$from = 0;
		}

		/*
		$pattern = $dbLink->escape_string($pm->getParamValue('pattern'));
		
		if ($_REQUEST['count']){
			$count = intval($_REQUEST['count']); 
		}
		else{
			$count = Kladr_Controller::COMPLETE_RES_COUNT;
		}
		
		if ($_REQUEST['from']){
			$from = intval($_REQUEST['from']); 
		}
		else{
			$from = 0;
		}
		*/
		
		$q = sprintf("SELECT * FROM kladr_naspunkt WHERE lower(name) LIKE lower(%s)||'%%' OFFSET %d LIMIT %d",
			$pattern,
			$from,$count);
		//throw new ($q);
		$this->addNewModel($q);
	}	
					
	public function query_first($q,&$res){
		$res = $this->getDbLink()->query_first($q);
	}
}
?>