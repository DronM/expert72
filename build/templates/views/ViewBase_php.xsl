<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
<xsl:template match="/"><![CDATA[<?php]]>
require_once(FRAME_WORK_PATH.'basic_classes/ViewHTMLXSLT.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelStyleSheet.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelJavaScript.php');

require_once(FRAME_WORK_PATH.'basic_classes/ModelTemplate.php');
require_once(USER_CONTROLLERS_PATH.'Constant_Controller.php');
require_once(USER_CONTROLLERS_PATH.'DocFlowTask_Controller.php');
require_once(USER_CONTROLLERS_PATH.'DocFlowInClient_Controller.php');
require_once(USER_CONTROLLERS_PATH.'MainMenuConstructor_Controller.php');

<xsl:apply-templates select="metadata/enums/enum[@id='role_types']"/>
class ViewBase extends ViewHTMLXSLT {	

	private $dbLink;

	protected static function getMenuClass(){
		//USER_MODELS_PATH
		$menu_class = NULL;
		$fl = NULL;
		if (file_exists($fl = OUTPUT_PATH.'MainMenu_Model_'.$_SESSION['user_id'].'.php')){
			$menu_class = 'MainMenu_Model_'.$_SESSION['user_id'];
		}
		else if (file_exists($fl = OUTPUT_PATH.'MainMenu_Model_'.$_SESSION['role_id'].'_'.$_SESSION['user_id'].'.php')){
			$menu_class = 'MainMenu_Model_'.$_SESSION['role_id'].'_'.$_SESSION['user_id'];
		}
		else if (file_exists($fl = OUTPUT_PATH.'MainMenu_Model_'.$_SESSION['role_id'].'.php')){
			$menu_class = 'MainMenu_Model_'.$_SESSION['role_id'];
		}
		if (!is_null($menu_class) &amp;&amp; !is_null($fl)){
			require_once($fl);
		}
		return $menu_class;
	}

	protected function addMenu(&amp;$models){
		if (isset($_SESSION['role_id'])){
			//USER_MODELS_PATH
			$menu_class = self::getMenuClass();
			if (is_null($menu_class)){
				//no menu exists yet
				$this->initDbLink();
				$contr = new MainMenuConstructor_Controller($this->dbLink);
				$contr->genMenuForUser($_SESSION['user_id'], $_SESSION['role_id']);
				$menu_class = self::getMenuClass();
				if (is_null($menu_class)){
					throw new Exception('No menu found!');
				}				
			}
			$models['mainMenu'] = new $menu_class();
		}	
	}
	
	protected function initDbLink(){
		if (!$this->dbLink){
			$this->dbLink = new DB_Sql();
			
			if (LK_TEST){
				$db_server = DB_SERVER;
				$db_user = DB_USER;
				$db_password = DB_PASSWORD;
				$port = DB_PORT;
				$this->dbLink->database	= DB_NAME;
			}
			else if (
			$_SESSION['role_id']=='client'
			||($_SESSION['role_id']=='admin' &amp;&amp; $_SESSION['user_name']=='adminlk')
			){
				//Клиент - всегда доступ ТОЛЬКО клиентский с любого сервера
				$db_server = DB_SERVER_LK;
				$db_user = DB_USER_LK;
				$db_password = DB_PASSWORD_LK;
				$port = DB_PORT_LK;
				$this->dbLink->database	= DB_NAME_LK;
			}
			else{
				//не клиент, здесь доступ из офиса
				$db_server = DB_SERVER_OFFICE;
				$db_user = DB_USER_OFFICE;
				$db_password = DB_PASSWORD_OFFICE;						
				$port = DB_PORT_OFFICE;
				$this->dbLink->database	= DB_NAME;
			}
					
			$this->dbLink->persistent=true;
			$this->dbLink->appname = APP_NAME;
			$this->dbLink->technicalemail = TECH_EMAIL;
			$this->dbLink->reporterror = DEBUG;
			try{			
				$this->dbLink->connect($db_server,$db_user,$db_password,$port);
			}
			catch (Exception $e){
				//do nothing
			}
		}	
	}
	
	protected function addConstants(&amp;$models){
		if (isset($_SESSION['role_id'])){
			$this->initDbLink();
		
			if ($this->dbLink){
				$contr = new Constant_Controller($this->dbLink);
				$list = array(<xsl:apply-templates select="/metadata/constants/constant[@autoload='TRUE']"/>);
				$models['ConstantValueList_Model'] = $contr->getConstantValueModel($list);						
			}
		}	
	}

	public function __construct($name){
		parent::__construct($name);
		<xsl:apply-templates select="metadata/cssScripts"/>		
		
		if (!DEBUG){			
			<xsl:apply-templates select="metadata/jsScripts/jsScript[@standalone='TRUE']"/>
			$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'lib.js'));
			$script_id = VERSION;
		}
		else{		
			<xsl:apply-templates select="metadata/jsScripts"/>
			if (isset($_SESSION['scriptId'])){
				$script_id = $_SESSION['scriptId'];
			}
			else{
				$script_id = VERSION;
			}			
		}
		<!-- custom vars-->
		$this->getVarModel()->addField(new Field('role_id',DT_STRING));
		$this->getVarModel()->addField(new Field('user_name',DT_STRING));
		if (isset($_SESSION['role_id']) &amp;&amp; $_SESSION['role_id']!='client'){
			$this->getVarModel()->addField(new Field('employees_ref',DT_STRING));
			$this->getVarModel()->addField(new Field('departments_ref',DT_STRING));
			$this->getVarModel()->addField(new Field('department_boss',DT_STRING));												
			$this->getVarModel()->addField(new Field('recipient_states_ref',DT_STRING));
			$this->getVarModel()->addField(new Field('cloud_key_exists',DT_BOOL));
			$this->getVarModel()->addField(new Field('snils',DT_STRING));
		}
		if (isset($_SESSION['role_id'])){
			$this->getVarModel()->addField(new Field('user_name_full',DT_STRING));
			$this->getVarModel()->addField(new Field('temp_doc_storage',DT_STRING));
			$this->getVarModel()->addField(new Field('temp_doc_storage_hours',DT_INT));
			//user attrs
			$this->getVarModel()->addField(new Field('color_palette',DT_STRING));
			$this->getVarModel()->addField(new Field('cades_load_timeout',DT_INT));
			$this->getVarModel()->addField(new Field('cades_chunk_size',DT_INT));
			
			$this->getVarModel()->addField(new Field('user_email',DT_STRING));
			$this->getVarModel()->addField(new Field('user_email_confirmed',DT_STRING));
			$this->getVarModel()->addField(new Field('win_message_style',DT_STRING));
			
			if (defined('CUSTOM_APP_UPLOAD_SERVER')){
				$this->getVarModel()->addField(new Field('custom_app_upload_server',DT_STRING));
			}
			
			if (isset($_SESSION['role_id']) &amp;&amp; $_SESSION['role_id']=='client'){
				$this->getVarModel()->addField(new Field('allow_ext_contracts',DT_BOOL));
			}
		}
		$this->getVarModel()->addField(new Field('cryptopro_plugin',DT_STRING));
		
		<!-- custom vars-->
		$this->getVarModel()->insert();
		$this->setVarValue('scriptId',$script_id);
		
		//'http://'.$_SERVER['HTTP_HOST'].'/'.APP_NAME.'/'		
		$currentPath = $_SERVER['PHP_SELF'];
		$pathInfo = pathinfo($currentPath);
		$hostName = $_SERVER['HTTP_HOST'];
		$protocol = isset($_SERVER['HTTPS'])? 'https://':'http://';
		$dir = $protocol.$hostName.$pathInfo['dirname'];
		if (substr($dir,strlen($dir)-1,1)!='/'){
			$dir.='/';
		}
		$this->setVarValue('basePath', $dir);
		
		$this->setVarValue('version',trim(VERSION));
		$this->setVarValue('debug',DEBUG);
		if (isset($_SESSION['locale_id'])){
			$this->setVarValue('locale_id',$_SESSION['locale_id']);
		}
		else if (!isset($_SESSION['locale_id']) &amp;&amp; defined('DEF_LOCALE')){
			$this->setVarValue('locale_id', DEF_LOCALE);
		}		
		
		if (isset($_SESSION['role_id'])){
			$this->setVarValue('temp_doc_storage',TEMP_DOC_STORAGE);
			$this->setVarValue('temp_doc_storage_hours',TEMP_DOC_STORAGE_HOURS);
			
			//user
			$this->setVarValue('color_palette',$_SESSION['color_palette']);
			$this->setVarValue('cades_load_timeout',$_SESSION['cades_load_timeout']);
			$this->setVarValue('cades_chunk_size',$_SESSION['cades_chunk_size']);
			
			$this->setVarValue('user_email',$_SESSION['user_email']);
			$this->setVarValue('user_email_confirmed',$_SESSION['user_email_confirmed']);
			$this->setVarValue('win_message_style',$_SESSION['win_message_style']);
		
			$this->setVarValue('role_id',$_SESSION['role_id']);
			$this->setVarValue('user_name',$_SESSION['user_name']);
			$this->setVarValue('user_name_full',$_SESSION['user_name_full']);
			$this->setVarValue('locale_id',$_SESSION['locale_id']);
			$this->setVarValue('curDate',round(microtime(true) * 1000));
			//$this->setVarValue('token',$_SESSION['token']);
			//$this->setVarValue('tokenr',$_SESSION['tokenr']);
			
			if (defined('CUSTOM_APP_UPLOAD_SERVER')){
				$this->getVarModel()->addField(new Field('custom_app_upload_server',DT_STRING));
				$this->setVarValue('custom_app_upload_server',CUSTOM_APP_UPLOAD_SERVER);
			}
			
			if ($_SESSION['role_id']!='client'){
				$this->setVarValue('employees_ref',$_SESSION['employees_ref']);
				$this->setVarValue('departments_ref',$_SESSION['departments_ref']);
				$this->setVarValue('department_boss',$_SESSION['department_boss']);
				$this->setVarValue('recipient_states_ref',$_SESSION['recipient_states_ref']);
				$this->setVarValue('cloud_key_exists',$_SESSION['cloud_key_exists']);
				$this->setVarValue('snils',$_SESSION['snils']);
			}
			else if ($_SESSION['role_id']=='client'){
				$this->setVarValue('allow_ext_contracts',$_SESSION['allow_ext_contracts']);
			}
			
			//wget -O crypto_plugin.txt https://www.cryptopro.ru/sites/default/files/products/cades/latest_2_0.txt
			$pl_ver = '';
			if (file_exists($pl=ABSOLUTE_PATH.'cryptopro_plugin.txt')){
				$pl_ver = trim(file_get_contents($pl));
			}
			$this->setVarValue('cryptopro_plugin',$pl_ver);
		}
		
		//Global Filters
		<!--
		<xsl:for-each select="/metadata/globalFilters/field">
		if (isset($_SESSION['global_<xsl:value-of select="@id"/>'])){
			$val = $_SESSION['global_<xsl:value-of select="@id"/>'];
			$this->setVarValue('<xsl:value-of select="@id"/>',$val);
		}
		</xsl:for-each>		
		-->				
	}
		
	
	public function write(ArrayObject &amp;$models,$errorCode=NULL){
		$this->addMenu($models);
		
		<!-- constant autoload -->
		$this->addConstants($models);
		
		//titles form Config
		$models->append(new ModelVars(
			array('name'=>'Page_Model',
				'sysModel'=>TRUE,
				'id'=>'Page_Model',
				'values'=>array(
					new Field('PAGE_TITLE',DT_STRING,array('value'=>PAGE_TITLE)),
					new Field('PAGE_HEAD_TITLE_GUEST',DT_STRING,array('value'=>PAGE_HEAD_TITLE_GUEST)),
					new Field('PAGE_HEAD_TITLE_USER',DT_STRING,array('value'=>PAGE_HEAD_TITLE_USER)),
					new Field('DEFAULT_COLOR_PALETTE',DT_STRING,array('value'=>DEFAULT_COLOR_PALETTE))					
				)
			)
		));
		
		if (isset($_SESSION['role_id']) &amp;&amp; $_SESSION['role_id']!='client' &amp;&amp; $this->dbLink){
			$models->append(DocFlowTask_Controller::get_short_list_model($this->dbLink));
		}
		else if (isset($_SESSION['role_id']) &amp;&amp; $_SESSION['role_id']=='client' &amp;&amp; $this->dbLink){
			$models->append(DocFlowInClient_Controller::get_unviwed_count_model($this->dbLink));
		}
		
		parent::write($models,$errorCode);
	}	
}	
<![CDATA[?>]]>
</xsl:template>

<xsl:template match="constants/constant[@autoload='TRUE']">
<xsl:if test="position() &gt; 1">,</xsl:if>'<xsl:value-of select="@id"/>'</xsl:template>

<!--			
<xsl:template match="enum/value">require_once('models/MainMenu_Model_<xsl:value-of select="@id"/>.php');</xsl:template>
-->

<xsl:template match="jsScripts/jsScript">
<xsl:choose>
<xsl:when test="@resource">
	if (
	(isset($_SESSION['locale_id']) &amp;&amp; $_SESSION['locale_id']=='<xsl:value-of select="@resource"/>')
	||
	(!isset($_SESSION['locale_id']) &amp;&amp; DEF_LOCALE=='<xsl:value-of select="@resource"/>')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'<xsl:value-of select="@file"/>'));
	}
</xsl:when>
<xsl:otherwise>$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'<xsl:value-of select="@file"/>'));</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="cssScripts/cssScript">$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'<xsl:value-of select="@file"/>'));</xsl:template>

</xsl:stylesheet>
