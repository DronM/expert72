<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Conclusion'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>

<xsl:call-template name="add_requirements"/>

require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');

require_once('common/XSD11Validator/XSD11Validator.php');

require_once('mustache.php/src/Mustache/Loader.php');
require_once('mustache.php/src/Mustache/Cache.php');
require_once('mustache.php/src/Mustache/Logger.php');
require_once('mustache.php/src/Mustache/Parser.php');
require_once('mustache.php/src/Mustache/Tokenizer.php');
require_once('mustache.php/src/Mustache/Compiler.php');
require_once('mustache.php/src/Mustache/Template.php');
require_once('mustache.php/src/Mustache/Context.php');
require_once('mustache.php/src/Mustache/Exception.php');
require_once('mustache.php/src/Mustache/HelperCollection.php');
require_once('mustache.php/src/Mustache/LambdaHelper.php');
require_once('mustache.php/src/Mustache/Loader/StringLoader.php');
require_once('mustache.php/src/Mustache/Cache/AbstractCache.php');
require_once('mustache.php/src/Mustache/Cache/NoopCache.php');
require_once('mustache.php/src/Mustache/Logger/AbstractLogger.php');
require_once('mustache.php/src/Mustache/Logger/StreamLogger.php');
require_once('mustache.php/src/Mustache/Engine.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	const CORRECTION_TMPL = 'conclusionCorrect.xsl';
	const MINSTROY_TMPL = 'conclusion.xsl';
	const MINSTROY_SCHEMA = 'conclusion_corrected.xsd';
	const CHECK_RES_TMPL = 'ConclusionValidation.html.mst';

	private function set_def_params(&amp;$pm){
		//admin can do everything
		if ($_SESSION['role_id']!='admin' || !$pm->getParamValue('employee_id')){			
			$emp_id = json_decode($_SESSION['employees_ref'])->keys->id;			
			$pm->setParamValue('employee_id',$emp_id);
		}	

	}

	private static function cash_id($docId){
		return 'Conclusion_'.$docId;
	}

	private static function cash_file($docId){
		return OUTPUT_PATH.self::cash_id($docId);
	}

	private function checkSchemaFile(){
		if(!file_exists($xsd_file = USER_VIEWS_PATH.self::MINSTROY_SCHEMA)){
			throw new Exception('Файл схемы для преобразования заключения не найден!');
		}
		return $xsd_file;	
	}

	public function clear_cash($docId){
		$fl = self::cash_file($docId);
		// 1) raw data file
		if(file_exists($fl.'.xml')){
			unlink($fl.'.xml');
		}
		// 2)html print form
		if(file_exists($fl.'.html')){
			unlink($fl.'.html');
		}
		
		// 3) html check form
		if(file_exists($fl.'_vld.html')){
			unlink($fl.'_vld.html');
		}
		
	}

	public function insert($pm){
		$this->set_def_params($pm);
		
		$pm->setParamValue('content_hash', md5($pm->getParamValue('content')));
		
		parent::insert($pm);
	}
	
	public function update($pm){
		$doc_id = $this->getExtDbVal($pm,'old_id');
		
		$cont = $pm->getParamValue('content');
		if($cont){
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT content_hash FROM conclusions WHERE id=%d"
				,$doc_id
			));
			$cont_h = md5($cont);
			if(!is_array($ar) || !isset($ar['content_hash']) || $ar['content_hash']!=$cont_h){
				self::clear_cash($doc_id);
				
				$pm->setParamValue('content_hash', $cont_h);
				
			}else if(
				!$pm->getParamValue('contract_id')
				&amp;&amp; !$pm->getParamValue('create_dt')
				&amp;&amp; !$pm->getParamValue('employee_id')
				&amp;&amp; !$pm->getParamValue('comment_text')
			){
				return;
			}
		}
		
		$this->set_def_params($pm);
		parent::update($pm);
		
	}

	/**
	 * Если есть кэш отдает его сразу
	 * Сохраняет значение поля content в файл и накладывает корректировачный шблон
	 * Возвращает Номер экспертного заключения, исправленный для использования в имени файла!
	 */
	private function conclusionToXML($dbLink,$docId,$outFile){
	
		$get_content = !file_exists($outFile);
		
		$ar = $dbLink->query_first(sprintf(
			"SELECT				
				REPLACE(contr.expertise_result_number,'/','-') AS conclusion_num
				". ($get_content? ",concl.content":"") ."
			FROM conclusions AS concl
			LEFT JOIN contracts AS contr ON contr.id=concl.contract_id
			WHERE concl.id=%d"
			,$docId
		));
		if(!is_array($ar) || !count($ar)){
			throw new Exception('Документ не найден!');
		}
		if($get_content &amp;&amp; !isset($ar['content'])){
			throw new Exception('Заключение не сформировано!');
		}
		
		//Трансформация xml + correction xslt = Заключение.xml
		if($get_content){
		
			if(!file_exists($xslt_file = USER_VIEWS_PATH.self::CORRECTION_TMPL)){
				throw new Exception('Шаблон для преобразования заключения не найден!');
			}
			
			//$xsd_file = $this->checkSchemaFile();
			
			$doc = new DOMDocument();     
			$xsl = new XSLTProcessor();
			$doc->load($xslt_file);
			$xsl->importStyleSheet($doc);
			
			$xmlDoc = new DOMDocument();
			$xmlDoc->loadXML($ar['content']);
			
			/*if(!$xmlDoc->schemaValidate($xsd_file)){
				throw new Exception('Заключение не соответствует схеме!');
			}
			*/
			
			//$xmlDoc->formatOutput=TRUE;
			//$xmlDoc->save('page.xml');
			file_put_contents($outFile, $xsl->transformToXML($xmlDoc));
		
		}
		return $ar['conclusion_num'];
	}

	private static function echo_html($fl){
		ob_clean();
		header('Content-Type: text/html; charset="utf-8"');
		header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
		header("Last-Modified: " . gmdate( "D, d M Y H:i:s") . " GMT");		
		echo file_get_contents($fl);
	}
	
	//returns HTML text
	public function get_check($pm){
		try{
			$xsd_file = $this->checkSchemaFile();
			
			$doc_id = $this->getExtDbVal($pm,'doc_id');
			$cash_id = self::cash_file($doc_id);
			if(!file_exists($fl_check = $cash_id.'_vld.html')){
				
				if(!file_exists($mst_tmpl = USER_VIEWS_PATH.self::CHECK_RES_TMPL)){
					throw new Exception('Шаблон результата проверки не найден!');
				}
						
				$fl_xml = $cash_id.'.xml';
				$conclusion_num = $this->conclusionToXML($this->getDbLink(),$doc_id, $fl_xml);
				
				// Enable user error handling
				libxml_use_internal_errors(true);		
				
				//$xmlDoc = new DOMDocument();
				//$xmlDoc->load(file_get_contents($fl_xml));
				
				$tmpl_data = array(
					'scriptId' => (defined('DEBUG')&amp;&amp;DEBUG&amp;&amp;isset($_SESSION['scriptId']))? $_SESSION['scriptId']:VERSION
					,'conclusionNum' => $conclusion_num
				);
				
				XSD11Validator::validate($tmpl_data, $xsd_file, $fl_xml, 'rus');
				
				/*
				if(!$xmlDoc->schemaValidate($xsd_file)){
					$tmpl_data['isValid'] = FALSE;
					
					$tmpl_data['errors'] = array();
					$errors = libxml_get_errors();
					foreach ($errors as $error) {
						$err = array();
						switch ($error->level) {
							case LIBXML_ERR_WARNING:
								$err['isWarning'] = TRUE;
								$err['code'] = $error->code;
								break;
							case LIBXML_ERR_ERROR:
								$err['isError'] = TRUE;
								$err['code'] = $error->code;
								break;
							case LIBXML_ERR_FATAL:
								$err['isFatal'] = TRUE;
								$err['code'] = $error->code;							
								break;
						}
						$err['message'] = trim($error->message);
						$err['line'] = $error->line;
						
						array_push($tmpl_data['errors'],$err);
					}
					
					libxml_clear_errors();				
				}else{
					$tmpl_data['isValid'] = TRUE;
				}
				*/
				
                                if(!class_exists('Mustache_Engine')){
                                        throw new Exception('Mustache engine not found!');
                                }
				
				$mustache = new Mustache_Engine();				
				file_put_contents(
					$fl_check,
					$mustache->render(
						file_get_contents($mst_tmpl)
						,$tmpl_data
					)
				);
				
				/*$out_f = file_get_contents($mst_tmpl);
				foreach($tmpl_data as $tmpl_k=>$tmpl_v){
					$out_f = str_replace('{{'.$tmpl_k.'}}',$tmpl_v,$out_f);
				}
				file_put_contents($fl_check,$out_f);
				*/
			}
			
			self::echo_html($fl_check);
		}catch(Exception $e){
			echo sprintf("<html>
				<body>
					<h4>%s
					</h4>
				</body>
				</html>
			",$e->getMessage());
		}
		
		return TRUE;				
	}

	//returns HTML text
	public function get_print($pm){
		$doc_id = $this->getExtDbVal($pm,'doc_id');
		
		$fl_print = self::cash_file($doc_id).'.html';
		if(!file_exists($fl_print)){
			
			$fl_xml = self::cash_file($doc_id).'.xml';
			$this->conclusionToXML($this->getDbLink(),$doc_id, $fl_xml);
				
			//XML + шаблон минстроя = HTML
			if(!file_exists($xslt_file = USER_VIEWS_PATH.self::MINSTROY_TMPL)){
				throw new Exception('Шаблон для преобразования заключения не найден!');
			}
		
			$doc = new DOMDocument();     
			$xsl = new XSLTProcessor();
			$doc->load($xslt_file);
			$xsl->importStyleSheet($doc);
			
			$xmlDoc = new DOMDocument();
			$xmlDoc->load($fl_xml);//from file!
			file_put_contents($fl_print, $xsl->transformToXML($xmlDoc));			
		}
		
		self::echo_html($fl_print);
		return TRUE;
	}

	//returns XML file
	public function get_file($pm){
		try{
			$doc_id = $this->getExtDbVal($pm,'doc_id');
			$fl = self::cash_file($doc_id).'.xml';
			$conclusion_num = $this->conclusionToXML($this->getDbLink(),$doc_id, $fl);
			
			$file_name = 'Заключение№'.$conclusion_num.'.xml';
			$mime = getMimeTypeOnExt($file_name);
			ob_clean();
			downloadFile($fl, $mime,'attachment;',$file_name);
			return TRUE;
		}	
		catch(Exception $e){
			$this->setHeaderStatus(400);
			throw $e;
		}
		
	}
	
	private function split_person_name($name,&amp;$familyName,&amp;$firstName,&amp;$secondName){
		$n_ar = explode(' ',$name);
		if(count($n_ar)>=1){
			$familyName = $n_ar[0];
		}
		if(count($n_ar)>=2){
			$firstName = $n_ar[1];
		}
		if(count($n_ar)>=3){
			$secondName = $n_ar[2];
		}
		
	}

	private function get_addr_from_struc($jsonVal,$post){
		$addr = '';
		if(isset($jsonVal)){
			if(isset($jsonVal->region) &amp;&amp; isset($jsonVal->region->keys) &amp;&amp; isset($jsonVal->region->keys->region_code)){
				$reg_code = substr($jsonVal->region->keys->region_code,0,2);
				$reg_descr = $jsonVal->region->descr;
				
				$addr .= self::concl_xml_sys_node_dict('Region', 'tRegionsRF', $reg_code, $reg_descr);
			}
			if($post){
				//НЕТ ИНДЕКСА!!!
				$addr .= '&lt;PostIndex&gt;'.'000000'.'&lt;/PostIndex&gt;';
			}
			if(isset($jsonVal->raion) &amp;&amp; isset($jsonVal->raion->descr)){
				$addr .= '&lt;District&gt;'.$jsonVal->raion->descr.'&lt;/District&gt;';
			}
			if(isset($jsonVal->gorod) &amp;&amp; isset($jsonVal->gorod->descr)){
				$addr .= '&lt;City&gt;'.$jsonVal->gorod->descr.'&lt;/City&gt;';
			}
			if(isset($jsonVal->naspunkt) &amp;&amp; isset($jsonVal->naspunkt->descr)){
				$addr .= '&lt;Settlement&gt;'.$jsonVal->naspunkt->descr.'&lt;/Settlement&gt;';
			}
			if(isset($jsonVal->ulitsa) &amp;&amp; isset($jsonVal->ulitsa->descr)){
				$addr .= '&lt;Street&gt;'.$jsonVal->ulitsa->descr.'&lt;/Street&gt;';
			}
			if(isset($jsonVal->dom)){
				$addr .= '&lt;Building&gt;'.$jsonVal->dom.($jsonVal->korpus? ' '.$jsonVal->korpus:'').'&lt;/Building&gt;';
			}
			if(isset($jsonVal->kvartira)){
				$addr .= '&lt;Room&gt;'.$jsonVal->kvartira.'&lt;/Room&gt;';
			}
			
		}
		return $addr;
	}
	
	private function concl_xml_add_work_person($tagName,$name,$post,&amp;$xml){
		$familyName = '';
		$firstName = '';
		$secondName = '';
		$this->split_person_name($name,$familyName,$firstName,$secondName);
		
		$inner_val = '&lt;FamilyName&gt;'.$familyName.'&lt;/FamilyName&gt;'.
				'&lt;FirstName&gt;'.$firstName.'&lt;/FirstName&gt;'.
				(strlen($secondName)?
					'&lt;SecondName&gt;'.$secondName.'&lt;/SecondName&gt;' : ''
				).
				'&lt;Position&gt;'.$post.'&lt;/Position&gt;';
	
		$xml.= '&lt;'.$tagName.'&gt;'. $inner_val. '&lt;/'.$tagName.'&gt;';	
	}

	private function concl_xml_add_org($tagName,$val,&amp;$xml){
		$xml.= '&lt;'.$tagName.'&gt;'.
			'&lt;OrgFullName&gt;'.$val->name_full.'&lt;/OrgFullName&gt;'.
			'&lt;OrgOGRN&gt;'.$val->ogrn.'&lt;/OrgOGRN&gt;'.
			'&lt;OrgINN&gt;'.$val->inn.'&lt;/OrgINN&gt;'.
			'&lt;OrgKPP&gt;'.$val->kpp.'&lt;/OrgKPP&gt;'.			
			'&lt;Address&gt;'.$this->get_addr_from_struc($val->legal_address,FALSE).'&lt;/Address&gt;'.
		'&lt;/'.$tagName.'&gt;';
		
		/* No Email!
		if($val->corp_email &amp;&amp;strlen($val->corp_email)){
			$inner_val.= '&lt;Email&gt;'.$val->corp_email.'&lt;/Email&gt;';
		}
		*/			
		
	}	
	
	private function concl_get_contragent($tagName, $val, $multyType=FALSE){
		$inner_val = '';
		if($val->client_type == 'enterprise'){
			$tag_name = 'Organization';
			$inner_val.= '&lt;OrgFullName&gt;'.$val->name_full.'&lt;/OrgFullName&gt;';
			$inner_val.= '&lt;OrgOGRN&gt;'.$val->ogrn.'&lt;/OrgOGRN&gt;';
			$inner_val.= '&lt;OrgINN&gt;'.$val->inn.'&lt;/OrgINN&gt;';
			$inner_val.= '&lt;OrgKPP&gt;'.$val->kpp.'&lt;/OrgKPP&gt;';			
			
			$addr = isset($val->legal_address)? $val->legal_address : (isset($val->post_address)? $val->post_address:NULL);
			if($addr){
				$inner_val.= '&lt;Address&gt;'.$this->get_addr_from_struc($addr,FALSE).'&lt;/Address&gt;';
			}	
			/* No Email!
			if($val->corp_email &amp;&amp;strlen($val->corp_email)){
				$inner_val.= '&lt;Email&gt;'.$val->corp_email.'&lt;/Email&gt;';
			}
			*/			
		}
		else if($val->client_type == 'person'){
			$tag_name = 'Person';			
			$familyName = '';
			$firstName = '';
			$secondName = '';
			$this->split_person_name($val->name_full,$familyName,$firstName,$secondName);
			
			$inner_val.= '&lt;FamilyName&gt;'.$familyName.'&lt;/FamilyName&gt;';
			$inner_val.= '&lt;FirstName&gt;'.$firstName.'&lt;/FirstName&gt;';
			$inner_val.= '&lt;SecondName&gt;'.$secondName.'&lt;/SecondName&gt;';
			$inner_val.= '&lt;SNILS&gt;'.$val->snils.'&lt;/SNILS&gt;';
			$inner_val.= '&lt;PostAddress&gt;'.$this->get_addr_from_struc($val->post_address,TRUE).'&lt;/PostAddress&gt;';
			if($val->corp_email &amp;&amp;strlen($val->corp_email)){
				$inner_val.= '&lt;Email&gt;'.$val->corp_email.'&lt;/Email&gt;';
			}
		}
		else if($val->client_type == 'pboul'){
			$tag_name = 'IP';			
			$familyName = '';
			$firstName = '';
			$secondName = '';
			$this->split_person_name($val->name_full,$familyName,$firstName,$secondName);
			
			$inner_val.= '&lt;FamilyName&gt;'.$familyName.'&lt;/FamilyName&gt;'.
					'&lt;FirstName&gt;'.$firstName.'&lt;/FirstName&gt;'.
					(strlen($secondName)? '&lt;SecondName&gt;'.$secondName.'&lt;/SecondName&gt;' : '').
					'&lt;OGRNIP&gt;'.$val->ogrn.'&lt;/OGRNIP&gt;'.
					'&lt;PostAddress&gt;'.$this->get_addr_from_struc($val->post_address,TRUE).'&lt;/PostAddress&gt;'.
					(
						($val->corp_email &amp;&amp;strlen($val->corp_email))?
						$inner_val.= '&lt;Email&gt;'.$val->corp_email.'&lt;/Email&gt;' : ''
					);
		}
		else{
			throw new Exception('Незадан тип клиента:'.$val->name_full);
		}
		
		if(!$multyType){
			return '&lt;'.$tagName.'&gt;'.
					'&lt;conclusionValue conclusionTagName="'. $tag_name .'"&gt;'.
						$inner_val.	
					'&lt;/conclusionValue&gt;'.
					 '&lt;sysValue skeepNode="TRUE"&gt;'. $tag_name .'&lt;/sysValue&gt;'.
				'&lt;/'.$tagName.'&gt;';
								
		}else{
			return '&lt;'.$tagName.'&gt;'.
				 '&lt;orgType sysNode="TRUE"&gt;'.
					'&lt;conclusionValue conclusionTagName="'. $tag_name .'"&gt;'.
						$inner_val.	
					'&lt;/conclusionValue&gt;'.
					'&lt;sysValue skeepNode="TRUE"&gt;'. $tag_name .'&lt;/sysValue&gt;'.
				'&lt;/orgType&gt;'.
				'&lt;/'.$tagName.'&gt;';
		}
	}
	
	private function concl_xml_add_contragent($tagName,$val,&amp;$xml){
		$xml.= $this->concl_get_contragent($tagName,$val);
	}
	
	private static function concl_xml_sys_node($nodeName,$conclVal,$sysVal){
		return
			'&lt;'.$nodeName.'&gt;'.
				'&lt;conclusionValue sysNode="TRUE"&gt;'. $conclVal .'&lt;/conclusionValue&gt;'.
				'&lt;sysValue skeepNode="TRUE"&gt;'. $sysVal .'&lt;/sysValue&gt;'.
			'&lt;/'.$nodeName.'&gt;';
	}
	
	private static function concl_xml_sys_node_dict($nodeName,$dictName,$dictCode,$dictDescr){
		$dictDescr = str_replace('"','\"',$dictDescr);
		$sys_val = '{"keys":{"conclusion_dictionary_name":"'. $dictName .'","code":"'. $dictCode .'"},"descr":"'. $dictDescr .'"}';
		return self::concl_xml_sys_node($nodeName, $dictCode, $sys_val);
	}
	
	private function concl_xml_add_ExaminationObject(&amp;$ar,&amp;$xml){
		
		if($ar['expertise_result']=='positive'){
			$examine_res = '1';
			$examine_res_descr = '1 Положительный';
		
		}else if($ar['expertise_result']=='negative'){
			$examine_res = '2';
			$examine_res_descr = '2 Отрицательный';
		}else{
			$examine_res = '';
			$examine_res_descr = '';
		}
		
		
		//Тип 1 - РИИ, 2 - ПД, 3 - РИИ+ПД
		if($ar['expertise_type']=='pd' || $ar['expertise_type']=='cost_eval_validity_pd' || $ar['expertise_type']=='cost_eval_validity'){
			$examine_obj_type = '2';
			$examine_obj_type_descr = '2 Проектная документация';
		}else if($ar['expertise_type']=='eng_survey' || $ar['expertise_type']=='cost_eval_validity_eng_survey'){
			$examine_obj_type = '1';
			$examine_obj_type_descr = '1 Результаты инженерных изысканий';
			
		}else if($ar['expertise_type']=='pd_eng_survey' || $ar['expertise_type']=='cost_eval_validity_pd_eng_survey'){
			$examine_obj_type = '3';
			$examine_obj_type_descr = '3 Проектная документация и результаты инженерных изысканий';
		}else{
			$examine_obj_type = '';
			$examine_obj_type_descr = '';
		}

		//предмет экспертизы много
		$examination_types = '';
		if($ar['expertise_type']=='pd' || $ar['expertise_type']=='cost_eval_validity_pd'){
			$examination_types.= self::concl_xml_sys_node_dict('ExaminationType', 'tExaminationType', '2', '2 Оценка соответствия проектной документации установленным требованиям (подпункт 1 пункт 5 статьи 49 Градостроительного кодекса Российской Федерации)');
			
		}
		if($ar['expertise_type']=='pd_eng_survey' || $ar['expertise_type']=='eng_survey' || $ar['expertise_type']=='cost_eval_validity_eng_survey'){
			$examination_types.= self::concl_xml_sys_node_dict('ExaminationType', 'tExaminationType', '1', '1 Оценка соответствия результатов инженерных изысканий требованиям технических регламентов (абзац 1 пункта 5 статьи 49 Градостроительного кодекса Российской Федерации)');	
		}
		if($ar['expertise_type']=='cost_eval_validity' || $ar['expertise_type']=='cost_eval_validity_pd' || $ar['expertise_type']=='cost_eval_validity_pd_eng_survey'){
			$examination_types.= self::concl_xml_sys_node_dict('ExaminationType', 'tExaminationType', '3', '3 Проверка достоверности определения сметной стоимости (подпункт 2 пункт 5 статьи 49 Градостроительного кодекса Российской Федерации)');	
		}
		
		//ExaminationStage 1-Первичная, 2-вторичная, 3-сопровождение
		if($ar['service_type']=='expert_maintenance'){
			$examine_stage = '3';
			$examine_stage_descr = '3 По результатам экспертного сопровождения';
		
		}else if($ar['primary']=='t'){
			$examine_stage = '1';
			$examine_stage_descr = '1 Первичная';
		
		}else if($ar['primary']=='f'){
			$examine_stage = '2';
			$examine_stage_descr = '2 Повторная';
		}
		
		//Всегда государтвенная 1
		$examine_form = '1';
		$examine_form_descr = '1 Государственная';
				
		$xml.= '&lt;ExaminationObject&gt;'.
				self::concl_xml_sys_node_dict('ExaminationForm', 'tExaminationForm', $examine_form, $examine_form_descr).
				self::concl_xml_sys_node_dict('ExaminationResult', 'tExaminationResult', $examine_res, $examine_res_descr).
				self::concl_xml_sys_node_dict('ExaminationObjectType', 'tExaminationObjectType', $examine_obj_type, $examine_obj_type_descr).
				$examination_types.
				self::concl_xml_sys_node_dict('ConstructionType', 'tConstractionType', $ar['constr_type'], $ar['constr_type_descr']).
				self::concl_xml_sys_node_dict('ExaminationStage', 'tExaminationStage', $examine_stage, $examine_stage_descr).
				'&lt;sysName conclusionTagName="Name"&gt;'. $ar['constr_name'] .'&lt;/sysName&gt;'.
			'&lt;/ExaminationObject&gt;';
	}
	
	private static function get_file_parts($fileFullName, &amp;$fileName, &amp;$fileExt){
		$file_n_parts = explode('.', $fileFullName);
		if($file_n_parts>=2){
			$fileExt = $file_n_parts[count($file_n_parts)-1];
			unset($file_n_parts[(count($file_n_parts)-1)]);
			$fileName =  implode('.',$file_n_parts);
		}else{
			$fileExt = '';
			$fileName =  $fileFullName;
		}
	
	}
	
	private static function concl_xml_add_File($fileName, $docTypeCode, $docTypeDescr, $docDate, $docIssuerTag, $fileDoc, $sigExists, $fileSig, &amp;$docNum, &amp;$xml){
		
		$doc_name = '';
		$doc_ext = '';
		self::get_file_parts($fileName, $doc_name, $doc_ext);		
		$doc_h = hash_file('crc32', $fileDoc);		
		
		if($sigExists){
			$sig_name = $fileName;
			$sig_ext = substr(Application_Controller::SIG_EXT,1);
			$sig_h = hash_file('crc32', $fileSig);		
		}
		
		$docNum++;
		//str_replace($doc_ext,'',$doc_name) = Наименование раздела!!!
		//$docIssuerTag = Проектная организация
		//брал совсем так как не обязателен $docIssuerTag.
		//Если раздел 6 - нужна проектная организация!!!
		$xml.=	'&lt;Document&gt;'.
				self::concl_xml_sys_node_dict('DocType', 'tDocumentType', $docTypeCode, $docTypeDescr).
				'&lt;DocName&gt;'. $docTypeDescr .'&lt;/DocName&gt;'.
				'&lt;DocNumber&gt;'. $docNum .'&lt;/DocNumber&gt;'.
				'&lt;DocDate&gt;'. $docDate .'&lt;/DocDate&gt;'.				
				'&lt;File&gt;'.
					'&lt;FileName&gt;'. $doc_name .'&lt;/FileName&gt;'.
					'&lt;FileFormat&gt;'.$doc_ext .'&lt;/FileFormat&gt;'.
					'&lt;FileChecksum&gt;'. $doc_h .'&lt;/FileChecksum&gt;'.
					($sigExists? 
						('&lt;SignFile&gt;'.
							'&lt;FileName&gt;'. $sig_name .'&lt;/FileName&gt;'.
							'&lt;FileFormat&gt;'. $sig_ext .'&lt;/FileFormat&gt;'.
							'&lt;FileChecksum&gt;'. $sig_h .'&lt;/FileChecksum&gt;'.
						'&lt;/SignFile&gt;'
						) : ''
					).
				'&lt;/File&gt;'.
			'&lt;/Document&gt;'
			;
	}
	
	private static function concl_xml_add_app_File($docType, &amp;$fileInfo, $fileDate, $docTypeCode, $docTypeDescr, $docIssuerTag, &amp;$relDirZip, &amp;$docNum ){
		$file_ar = json_decode($fileInfo);
		if (count($file_ar)){
			$rel_path = Application_Controller::dirNameOnDocType($docType).DIRECTORY_SEPARATOR;
			if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR. $rel_path.$file_ar[0]->id)
			||( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR. $rel_path.$file_ar[0]->id) )
			){
				$sig_exists = FALSE;				
				if (file_exists($sig_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR.$rel_path.$file_ar[0]->id.Application_Controller::SIG_EXT)
				||( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($sig_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$relDirZip.DIRECTORY_SEPARATOR.$rel_path.$file_ar[0]->id.Application_Controller::SIG_EXT))
				){
					$sig_exists = TRUE;
				}
				
				self::concl_xml_add_File($file_ar[0]->name, $docTypeCode, $docTypeDescr, $fileDate, $docIssuerTag,  $file_doc, $sig_exists, $sig_doc, $docNum, $xml);
			}							
		}
	}
	
	private function concl_xml_add_object(&amp;$arApp, &amp;$xml){
		if(!isset($arApp['constr_address']) || !strlen($arApp['constr_address'])){
			return;
		}
	
		$xml.=	'&lt;Object&gt;'.
				'&lt;Name&gt;'. $arApp['constr_name'] .'&lt;/Name&gt;'.
				'&lt;addressContainer sysNode="TRUE"&gt;'.
					'&lt;conclusionValue conclusionTagName="Address"&gt;'.
						$this->get_addr_from_struc( json_decode($arApp['constr_address']),FALSE).
			       		'&lt;/conclusionValue&gt;'.
			      		'&lt;sysValue skeepNode="TRUE"&gt;Address&lt;/sysValue&gt;'.
			   	'&lt;/addressContainer&gt;'.
				self::concl_xml_sys_node_dict('Type', 'tObjectType', $arApp['object_type'], $arApp['object_type_descr']).
			'&lt;/Object&gt;'
			;	
	}

	private function concl_xml_add_finance(&amp;$arApp, &amp;$xml){
		$xml.=	'&lt;Finance&gt;'.
				self::concl_xml_sys_node_dict('FinanceType', 'tFinanceType', $arApp['finance_type'], $arApp['finance_type_descr']).
				self::concl_xml_sys_node_dict('BudgetType', 'tBudgetType', $arApp['budget_type'], $arApp['budget_type_descr']).
				'&lt;FinanceSize&gt;'. $arApp['fund_percent'] .'&lt;/FinanceSize&gt;'.
			'&lt;/Finance&gt;'
			;	
	}
		
	private function concl_xml_add_documents(&amp;$arApp, &amp;$xml){
		/**
		 * document_templates.tmpl fields:
		 * 	service_type (expertise)
		 * 	document_type (cost_eval_validity)
		 * 	expertise_type (cost_eval_validity)
		 * 	construction_type_id (3)
		 *	document array {fields: {id,descr,required,dt_descr,dt_code}}
    		 */
		$files_q_id = $this->getDbLink()->query(sprintf(
			"WITH document_templates AS (
				SELECT jsonb_array_elements(
					applications_get_documents((SELECT applications FROM applications WHERE applications.id=%d))
					) AS tmpl
			)
			SELECT
				adf.*
				,adf.date_time::date AS file_d
				
				,(SELECT					
					json_build_object(
						'code',doc_elems.elem->'fields'->>'dt_code',
						'descr', doc_elems.elem->'fields'->>'dt_descr'
					)				  
				FROM (
				SELECT					
						jsonb_array_elements(d_tmpl.tmpl->'document') AS elem
					FROM document_templates AS d_tmpl
					WHERE (d_tmpl.tmpl->>'document_type')::document_types = adf.document_type
				) doc_elems
				WHERE (doc_elems.elem->'fields'->>'id')::int = adf.document_id
				LIMIT 1
				) AS conclusion_dictionary_details_ref
				
				,(WITH sign AS (
					SELECT
						jsonb_agg(
							jsonb_build_object(
								'owner',u_certs.subject_cert
							)
						) As signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					WHERE f_sig.file_id=adf.file_id
					-- Здесь Всегда одна подпись, можно без сортировки!!!
				)
				SELECT				
					CASE
						WHEN (SELECT sign.signatures FROM sign) IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'owner',NULL,
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'check_time',f_ver.check_time,
									'error_str',f_ver.error_str
								)
							)
						ELSE (SELECT sign.signatures FROM sign)
					END
				) AS signatures
				
			FROM application_document_files AS adf
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=adf.file_id
			WHERE adf.application_id=%d
				AND coalesce(adf.deleted,FALSE)=FALSE
			ORDER BY adf.document_type,adf.document_id,adf.date_time"
			,$arApp['application_id']
			,$arApp['application_id']
		));
		
		//issuer Заказчик->>Застройщик
		// было так:
		//'&lt;DocIssueAuthor&gt;'. $arApp['doc_issuer_name'] .'&lt;/DocIssueAuthor&gt;'
		if(isset($arApp['customer'])){
			$doc_issuer_tag =
				'&lt;FullDocIssueAuthor&gt;'. 
					$this->concl_get_contragent('ProjectDocumentsTechnicalCustomer', json_decode($arApp['customer']));
				'&lt;/FullDocIssueAuthor&gt;';
			
		}else if(isset($arApp['developer'])){
			$doc_issuer_tag =
				'&lt;FullDocIssueAuthor&gt;'. 
					$this->concl_get_contragent('ProjectDocumentsTechnicalCustomer', json_decode($arApp['developer']));
				'&lt;/FullDocIssueAuthor&gt;';
		}
		
		//head tag
		$xml .= '&lt;Documents&gt;';
		
		$rel_dir_zip =	Application_Controller::APP_DIR_PREF.$arApp['application_id'];
		
		while($file = $this->getDbLink()->fetch_array($files_q_id)){
			$rel_path = Application_Controller::dirNameOnDocType($file['document_type']).DIRECTORY_SEPARATOR.
					$file['document_id'].DIRECTORY_SEPARATOR;
				
			if (file_exists($file_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR. $rel_path. $file['file_id'])
			|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR. $rel_path. $file['file_id']) )
			){
				$sig_exists = FALSE;
				if ($file['file_signed']=='t'){
					if (file_exists($sig_doc = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.$rel_path.$file['file_id'].Application_Controller::SIG_EXT)
					|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($sig_doc = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir_zip.DIRECTORY_SEPARATOR.$rel_path.$file['file_id'].Application_Controller::SIG_EXT) )
					){
						$sig_exists = TRUE;
					}
				}
				
				//по $file['doc_id'] определить из XML дерева dt_code, dt_descr
				$dict_ref_code = '';
				$dict_ref_descr = '';
				if(isset($file['conclusion_dictionary_details_ref'])){				
					//!!!Берем ТОЛЬКО документы с заполненными соответствиями!!!
					$dict_ref = json_decode($file['conclusion_dictionary_details_ref']);
					$dict_ref_code = (isset($dict_ref)&amp;&amp;isset($dict_ref->code))? $dict_ref->code:'';
					$dict_ref_descr = (isset($dict_ref)&amp;&amp;isset($dict_ref->descr))? $dict_ref->descr:'';
					if($dict_ref_code!=''){
						self::concl_xml_add_File($file['file_name'], $dict_ref_code, $dict_ref_descr, $file['file_d'], $doc_issuer_tag,  $file_doc, $sig_exists, $sig_doc, $docNum, $xml);
					}
				}				
			}
		
		}
		
		//Дополнительные файлы:
		$application_document_types_match = json_decode($arApp['application_document_types_match']);
		//Заявления
		if (isset($arApp['expertise_type'])){
			self::concl_xml_add_app_File('app_print_expertise',$arApp['app_print'], $arApp['app_date'], $application_document_types_match->app_print->code, $application_document_types_match->app_print->descr, $doc_issuer_tag, $rel_dir_zip, $docNum);
		}
		if (isset($arApp['cost_eval_validity']) &amp;&amp; $arApp['cost_eval_validity']=='t'){
			self::concl_xml_add_app_File('app_print_cost_eval_validity', $arApp['app_print'], $arApp['app_date'], $application_document_types_match->app_print->code, $application_document_types_match->app_print->descr, $doc_issuer_tag, $rel_dir_zip, $docNum);
		}
		if (isset($arApp['modification']) &amp;&amp; $arApp['modification']=='t'){
			self::concl_xml_add_app_File('app_print_modification', $arApp['app_print'], $arApp['app_date'], $application_document_types_match->app_print->code, $application_document_types_match->app_print->descr, $doc_issuer_tag, $rel_dir_zip, $docNum);
		}
		if (isset($arApp['audit']) &amp;&amp; $arApp['audit']=='t'){
			self::concl_xml_add_app_File('app_print_audit', $arApp['app_print'], $arApp['app_date'], $application_document_types_match->app_print->code, $application_document_types_match->app_print->descr, $doc_issuer_tag, $rel_dir_zip, $docNum);
		}
		//Доверенность
		if (isset($arApp['auth_letter_file']) &amp;&amp; $arApp['auth_letter_file']=='t'){
			self::concl_xml_add_app_File('auth_letter_file', $arApp['auth_letter_file'], $arApp['app_date'], $application_document_types_match->auth_letter->code, $application_document_types_match->auth_letter->descr, $doc_issuer_tag, $rel_dir_zip, $docNum);
		}
		//Доверенность техн.заказчика
		if (isset($arApp['customer_auth_letter_file']) &amp;&amp; $arApp['customer_auth_letter_file']=='t'){
			self::concl_xml_add_app_File('customer_auth_letter_file', $arApp['customer_auth_letter_file'], $application_document_types_match->auth_letter->code, $application_document_types_match->auth_letter->descr, $doc_issuer_tag, $arApp['app_date'], $rel_dir_zip, $docNum);
		}
		
		//foot
		$xml .= '&lt;/Documents&gt;';
	}
	
	private function concl_xml_add_experts($contractId, &amp;$arApp, &amp;$xml){
		$experts_q_id = $this->getDbLink()->query(sprintf(
			"SELECT 
				contr.empl->'fields'->'employees_ref'->'keys'->>'id' AS id,
				contr.empl->'fields'->'employees_ref'->>'descr' AS name,
				(SELECT
					json_agg(
					 	json_build_object(
								'expert_types_ref',conclusion_dictionary_detail_ref(expert_tp)
								,'cert_id', certs.cert_id
								,'date_from', certs.date_from
								,'date_to', certs.date_to
						)
					)
				FROM employee_expert_certificates AS certs
				LEFT JOIN conclusion_dictionary_detail AS expert_tp ON expert_tp.conclusion_dictionary_name='tExpertType' AND expert_tp.code=certs.expert_type
				WHERE certs.employee_id=(contr.empl->'fields'->'employees_ref'->'keys'->>'id')::int
				) AS certs
			FROM (
				SELECT jsonb_array_elements(result_sign_expert_list->'rows') AS empl
				FROM contracts
				WHERE id=%d
			) AS contr	
			WHERE contr.empl->'fields'->'employees_ref'->'keys'->>'id' IS NOT NULL
				AND (contr.empl->'fields'->'employees_ref'->'keys'->>'id')::int>0"
			,$contractId
		));
		
		$experts = '';
		while($expert = $this->getDbLink()->fetch_array($experts_q_id)){
			$familyName = '';
			$firstName = '';
			$secondName = '';
			$this->split_person_name($expert['name'],$familyName,$firstName,$secondName);
			
			if(isset($expert['certs'])){
				$certs = json_decode($expert['certs']);
				foreach($certs as $cert){
					$cert_id = $cert->cert_id;
					$date_from = $cert->date_from;
					$date_to = $cert->date_to;
					$expert_type_code = $cert->expert_types_ref->keys->code;
					$expert_type_descr = $cert->expert_types_ref->descr;
					
					$experts.= '&lt;Expert&gt;'.
							'&lt;FamilyName&gt;'. $familyName. '&lt;/FamilyName&gt;'.
							'&lt;FirstName&gt;'. $firstName. '&lt;/FirstName&gt;'.
							( strlen($secondName)? '&lt;SecondName&gt;'. $secondName. '&lt;/SecondName&gt;' : '' ).
							
							self::concl_xml_sys_node_dict('ExpertType', 'tExpertType', $expert_type_code, $expert_type_descr).
							
							'&lt;ExpertCertificate&gt;'. $cert_id. '&lt;/ExpertCertificate&gt;'.
							'&lt;ExpertCertificateBeginDate&gt;'. $date_from. '&lt;/ExpertCertificateBeginDate&gt;'.
							'&lt;ExpertCertificateEndDate&gt;'. $date_to. '&lt;/ExpertCertificateEndDate&gt;'.
							
						'&lt;/Expert&gt;';
					
				}
				
			}else{
				//no certs - once person without sert
				$cert_id = '';
				$date_from = '';
				$date_to = '';
				$expert_type_code = '';
				$expert_type_descr = '';
				
				$experts.= '&lt;Expert&gt;'.
						'&lt;FamilyName&gt;'. $familyName. '&lt;/FamilyName&gt;'.
						'&lt;FirstName&gt;'. $firstName. '&lt;/FirstName&gt;'.
						( strlen($secondName)? '&lt;SecondName&gt;'. $secondName. '&lt;/SecondName&gt;' : '' ).
						
						self::concl_xml_sys_node_dict('ExpertType', 'tExpertType', $expert_type_code, $expert_type_descr).
						
						'&lt;ExpertCertificate&gt;'. $cert_id. '&lt;/ExpertCertificate&gt;'.
						'&lt;ExpertCertificateBeginDate&gt;'. $date_from. '&lt;/ExpertCertificateBeginDate&gt;'.
						'&lt;ExpertCertificateEndDate&gt;'. $date_to. '&lt;/ExpertCertificateEndDate&gt;'.
						
					'&lt;/Expert&gt;';
				
			}			
		}
		
		if(strlen($experts)){
			$xml.= '&lt;Experts&gt;'. $experts . '&lt;/Experts&gt;';		
		}
	}
	
	/**
	 * returns pure XML
	 */
	public function fill_on_contract($pm){
	
		$contract_id = $this->getExtDbVal($pm,'doc_id');
		
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				json_build_object(
					'client_type',cl_expert.client_type
					,'inn',cl_expert.inn
					,'kpp',cl_expert.kpp
					,'name_full',cl_expert.name_full
					,'name',cl_expert.name
					,'ogrn',cl_expert.ogrn
					,'legal_address',cl_expert.legal_address
					,'post_address',cl_expert.post_address					
				) AS expert_org
				,contacts_get_persons(cl_expert.id,'clients') AS expert_org_resp
				,app.applicant
				,app.developer
				,app.customer
				,app.contractors
				
				,app.service_type
				,app.expertise_type
				
				,ct.kadastr_number
				
				,app.constr_address
				
				,fnd.finance_type_code AS finance_type
				,fn_tp.descr AS finance_type_descr
				,fnd.budget_type_code AS budget_type
				,bd_tp.descr AS budget_type_descr
				,app.fund_percent
				
				,constr_tp.dt_code AS constr_type
				,constr_tp_dict.descr AS constr_type_descr
				,obj_tp.object_type_code AS object_type
				,obj_tp_dict.descr AS object_type_descr
				
				,(app.primary_application_id IS NULL AND app.primary_application_reg_number IS NULL) AS primary
				
				,coalesce(ct.constr_name,app.constr_name) AS constr_name
				
				,ct.reg_number
				,ct.expertise_result
				,ct.expertise_result_date
				,ct.result_sign_expert_list
				
				,app.app_print
				,app.auth_letter_file
				,app.customer_auth_letter_file
				
				,ct.result_sign_expert_list
				
				,ct.application_id
				
				,app.create_dt::date AS app_date
				
				,const_applucation_document_types_match_val() AS application_document_types_match
				
				,u.name_full AS doc_issuer_name
				
			FROM contracts AS ct
			LEFT JOIN applications AS app ON app.id = ct.application_id
			LEFT JOIN users AS u ON u.id = app.user_id
			LEFT JOIN offices AS of ON of.id = app.office_id
			LEFT JOIN clients AS cl_expert ON cl_expert.id = of.client_id
			LEFT JOIN build_types AS constr_tp ON constr_tp.id = app.build_type_id
			LEFT JOIN construction_types AS obj_tp ON obj_tp.id = app.build_type_id
			LEFT JOIN fund_sources AS fnd ON fnd.id = app.fund_source_id
			LEFT JOIN conclusion_dictionary_detail AS constr_tp_dict ON constr_tp_dict.conclusion_dictionary_name='tConstractionType' AND constr_tp_dict.code=constr_tp.dt_code
			LEFT JOIN conclusion_dictionary_detail AS obj_tp_dict ON obj_tp_dict.conclusion_dictionary_name='tObjectType' AND obj_tp_dict.code=obj_tp.object_type_code			
			LEFT JOIN conclusion_dictionary_detail AS fn_tp ON fn_tp.conclusion_dictionary_name='tFinanceType' AND fn_tp.code=fnd.finance_type_code
			LEFT JOIN conclusion_dictionary_detail AS bd_tp ON bd_tp.conclusion_dictionary_name='tBudgetType' AND bd_tp.code=fnd.budget_type_code
			WHERE ct.id=%d"
			,$contract_id
		));
		if(!is_array($ar) || !count($ar)){
			throw new Exception('Документ не найден!');
		}
		
		$xml = ViewXML::getXMLHeader().
			sprintf('&lt;Conclusion ConclusionGUID="%s" SchemaVersion="01.00" SchemaLink="https://" &gt;'
				,isset($ar['reg_number'])? $ar['reg_number']:""
			);
			
		//ExpertOrganization
		$this->concl_xml_add_org('ExpertOrganization',json_decode($ar['expert_org']), $xml);
		
		//Approver
		$dir_name = '';
		$dir_post = '';
		$expert_org_resp = json_decode($ar['expert_org_resp']);
		if($expert_org_resp->rows &amp;&amp; count($expert_org_resp->rows)){
			if($expert_org_resp->rows[0]->fields &amp;&amp; $expert_org_resp->rows[0]->fields->name){
				$dir_name = $expert_org_resp->rows[0]->fields->name;
			}
			if($expert_org_resp->rows[0]->fields &amp;&amp; $expert_org_resp->rows[0]->fields->post){
				$dir_post = $expert_org_resp->rows[0]->fields->post;
			}
			
		}
		$this->concl_xml_add_work_person('Approver',$dir_name,$dir_post,$xml);
		
		//ExaminationObject
		$this->concl_xml_add_ExaminationObject($ar, $xml);
		
		//Документация
		$this->concl_xml_add_documents($ar, $xml);
		
		//Объект
		$this->concl_xml_add_object($ar, $xml);

		//Заявитель
		$this->concl_xml_add_contragent('Declarant', json_decode($ar['applicant']), $xml);

		//источник финансирования, бюджет
		$this->concl_xml_add_finance($ar, $xml);

		//Исполнители, кто подготовил
		$contractors = json_decode($ar['contractors']);
		foreach($contractors as $contractor){
			$xml.= $this->concl_get_contragent('Designer',$contractor,TRUE);
		}
		
		//Застройщик
		if(isset($ar['developer'])){
			$this->concl_xml_add_contragent('ProjectDocumentsDeveloper', json_decode($ar['developer']), $xml);			
		}

		//Технич.заказчик
		if(isset($ar['customer'])){
			$customer = json_decode($ar['customer']);
			if(isset($customer)  &amp;&amp; isset($customer->customer_is_developer)  &amp;&amp; isset($ar['developer'])){
				$this->concl_xml_add_contragent('ProjectDocumentsTechnicalCustomer', json_decode($ar['developer']), $xml);
				
			}else{
				$this->concl_xml_add_contragent('ProjectDocumentsTechnicalCustomer', json_decode($ar['customer']), $xml);
			}			
			
		}else if(isset($ar['customer'])){
			$this->concl_xml_add_contragent('ProjectDocumentsTechnicalCustomer', json_decode($ar['customer']), $xml);
		}
		
		//Эксперты
		json_decode($ar['result_sign_expert_list']);
		$this->concl_xml_add_experts($contract_id, $ar, $xml);

		$xml.= '&lt;/Conclusion&gt;';		
		
		ViewXML::addHTTPHeaders();
		echo $xml;
		
		return TRUE;
	}
	
	/**
	 * returns pure XML
	 */
	public function fill_expert_conclusions($pm){
		$ln = strlen('&lt;conclusion&gt;');		
	
		$xml = '&lt;conclusions&gt;';
	
		//*** PD
		$q_id = $this->getDbLink()->query(sprintf(
			"SELECT conclusion
			FROM expert_conclusions
			WHERE contract_id = %d AND conclusion_type='pd'"
			,$this->getExtDbVal($pm,'doc_id')
		));
				
		$xml.= '&lt;pd&gt;';		
		while($exp_concl = $this->getDbLink()->fetch_array($q_id)){
			//$conclusion = trim($exp_concl['conclusion']);
			//$xml.= substr($conclusion, $ln, strlen($conclusion) - $ln - $ln - 1);					
			$xml.= $exp_concl['conclusion'];
		}
		$xml.= '&lt;/pd&gt;';
		//***********

		//*** Eng
		$q_id = $this->getDbLink()->query(sprintf(
			"SELECT conclusion
			FROM expert_conclusions
			WHERE contract_id = %d AND conclusion_type='eng'"
			,$this->getExtDbVal($pm,'doc_id')
		));
				
		$xml.= '&lt;eng&gt;';		
		while($exp_concl = $this->getDbLink()->fetch_array($q_id)){
			//$conclusion = trim($exp_concl['conclusion']);
			//$xml.= substr($conclusion, $ln, strlen($conclusion) - $ln - $ln - 1);					
			$xml.= $exp_concl['conclusion'];
		}
		$xml.= '&lt;/eng&gt;';
		//***********

		//*** Estim
		$q_id = $this->getDbLink()->query(sprintf(
			"SELECT conclusion
			FROM expert_conclusions
			WHERE contract_id = %d AND conclusion_type='val_estim'"
			,$this->getExtDbVal($pm,'doc_id')
		));
				
		$xml.= '&lt;val_estim&gt;';		
		while($exp_concl = $this->getDbLink()->fetch_array($q_id)){
			//$conclusion = trim($exp_concl['conclusion']);
			//$xml.= substr($conclusion, $ln, strlen($conclusion) - $ln - $ln - 1);					
			$xml.= $exp_concl['conclusion'];
		}
		$xml.= '&lt;/val_estim&gt;';
		//***********
		
		$xml.= '&lt;/conclusions&gt;';		
		ViewXML::addHTTPHeaders();
		echo $xml;
		
		return TRUE;
	}

	private static function GUID() { 
		if (function_exists('com_create_guid') === true) { 
			return trim(com_create_guid(), '{}'); 
		} 

		return sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535), 
			mt_rand(16384, 20479), mt_rand(32768, 49151), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535)); 
	} 

	public function create_guid(){
		$guid = self::GUID();
		if ($guid === FALSE) {
			throw new Exception('Ошибка формирование guid.');
		}
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Guid_Model',
				'values'=>array(
						new Field('guid',DT_STRING,array('value'=>$guid))
					)
				)
			)
		);		
	}

</xsl:template>

</xsl:stylesheet>
