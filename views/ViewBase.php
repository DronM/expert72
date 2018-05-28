<?php
require_once(FRAME_WORK_PATH.'basic_classes/ViewHTMLXSLT.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelStyleSheet.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelJavaScript.php');

require_once(FRAME_WORK_PATH.'basic_classes/ModelTemplate.php');
require_once(USER_CONTROLLERS_PATH.'Constant_Controller.php');
require_once(USER_CONTROLLERS_PATH.'DocFlowTask_Controller.php');
require_once(USER_CONTROLLERS_PATH.'DocFlowInClient_Controller.php');


			require_once('models/MainMenu_Model_admin.php');
			require_once('models/MainMenu_Model_client.php');
			require_once('models/MainMenu_Model_lawyer.php');
			require_once('models/MainMenu_Model_expert.php');
			require_once('models/MainMenu_Model_boss.php');
			require_once('models/MainMenu_Model_accountant.php');
		
class ViewBase extends ViewHTMLXSLT {	

	private $dbLink;

	protected function addMenu(&$models){
		if (isset($_SESSION['role_id'])){
			if (file_exists(USER_MODELS_PATH.'MainMenu_Model_'.$_SESSION['user_id'].'.php')){
				$menu_class = 'MainMenu_Model_'.$_SESSION['user_id'];
			}
			else if (file_exists(USER_MODELS_PATH.'MainMenu_Model_'.$_SESSION['role_id'].'_'.$_SESSION['user_id'].'.php')){
				$menu_class = 'MainMenu_Model_'.$_SESSION['role_id'].'_'.$_SESSION['user_id'];
			}
			else{
				$menu_class = 'MainMenu_Model_'.$_SESSION['role_id'];
			}
			
			$models['mainMenu'] = new $menu_class();
		}	
	}
	
	protected function initDbLink(){
		if (!$this->dbLink){
			$this->dbLink = new DB_Sql();
			$this->dbLink->persistent=true;
			$this->dbLink->appname = APP_NAME;
			$this->dbLink->technicalemail = TECH_EMAIL;
			$this->dbLink->reporterror = DEBUG;
			$this->dbLink->database= DB_NAME;			
			$this->dbLink->connect(DB_SERVER,DB_USER,DB_PASSWORD,(defined('DB_PORT'))? DB_PORT:NULL);
		}	
	}
	
	protected function addConstants(&$models){
		if (isset($_SESSION['role_id'])){
			$this->initDbLink();
		
			$contr = new Constant_Controller($this->dbLink);
			$list = array('doc_per_page_count','grid_refresh_interval','application_check_days','reminder_refresh_interval');
			$models['ConstantValueList_Model'] = $contr->getConstantValueModel($list);						
			
		}	
	}

	public function __construct($name){
		parent::__construct($name);
		
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/icons/icomoon/styles.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/bootstrap.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/core.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/components.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/colors.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/icons/fontawesome/styles.min.css'));
		
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'custom-css/easyTree.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'ext/bootstrap-datepicker/bootstrap-datepicker.standalone.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'custom-css/style.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'custom-css/print.css'));
			
		
		if (!DEBUG){			
			$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/plugins/loaders/pace.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/libraries/jquery.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/libraries/bootstrap.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/plugins/loaders/blockui.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/app.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/bootstrap-datepicker/bootstrap-datepicker.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/bootstrap-datepicker/bootstrap-datepicker.ru.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/mustache/mustache.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/jshash-2.2/md5-min.js'));
			$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'lib.js'));
			$script_id = VERSION;
		}
		else{		
			
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/plugins/loaders/pace.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/libraries/jquery.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/libraries/bootstrap.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/plugins/loaders/blockui.min.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/app.js'));
		
		
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/easyTree.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/bootstrap-datepicker/bootstrap-datepicker.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/bootstrap-datepicker/bootstrap-datepicker.ru.min.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'jquery.maskedinput.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/mustache/mustache.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/jshash-2.2/md5-min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/resumablejs/resumable.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/DragnDrop/DragMaster.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/DragnDrop/DragObject.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/DragnDrop/DropTarget.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/extend.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/App.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/AppWin.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/CommonHelper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/DOMHelper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/DateHelper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/EventHelper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ConstantManager.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ServConnector.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/Response.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ResponseXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ResponseJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/PublicMethod.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/PublicMethodServer.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ControllerObj.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ControllerObjServer.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ControllerObjClient.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelObjectXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelServRespXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelObjectJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelServRespJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelXMLTree.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelJSONTree.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/Validator.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorString.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorBool.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorDate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorDateTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorInterval.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorInt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorFloat.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorEnum.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorArray.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorEmail.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/Field.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldString.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldEnum.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldBool.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldDate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldDateTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldDateTimeTZ.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldInt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldBigInt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldSmallInt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldFloat.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldPassword.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldText.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldInterval.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldJSONB.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldArray.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldBytea.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelFilter.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/RefType.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/rs_ru.js'));
	}

		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/DataBinding.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Command.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/CommandBinding.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Control.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/Control.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ControlContainer.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ControlContainer.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewAjx.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewAjx.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewAjxList.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Calculator.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/Calculator.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Button.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonCtrl.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonEditCtrl.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonEditCtrl.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonCalc.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonCalc.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonCalendar.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonCalendar.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonClear.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonClear.rs_ru.js'));
	}

		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ButtonCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonExpToExcel.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonExpToExcel.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonExpToPDF.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonExpToPDF.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonOpen.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonOpen.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonInsert.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonInsert.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonPrint.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonPrint.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonPrintList.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonPrintList.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonSelectRef.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonSelectRef.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonSelectDataType.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonSelectDataType.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonMakeSelection.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonMakeSelection.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonToggle.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Label.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Edit.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/Edit.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRefMultyType.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditRefMultyType.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditString.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditText.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditInt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditFloat.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditMoney.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditPhone.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditEmail.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditPercent.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditDate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditDateTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditInterval.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditPassword.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditCheckBox.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditContainer.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditContainer.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRadioGroup.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRadio.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditSelectRef.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditSelectRef.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditSelectOption.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditSelectOptionRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRadioGroupRef.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditRadioGroupRef.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/PrintObj.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditModalDialog.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditModalDialog.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ControlForm.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/HiddenKey.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditJSON.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditFile.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditFile.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditCompound.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditCompound.rs_ru.js'));
	}

		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ControlDate.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumn.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnBool.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnPhone.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnEmail.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnFloat.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnByte.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnDate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnDateTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnEnum.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCell.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellHead.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellFoot.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridHead.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridRow.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridFoot.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridBody.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Grid.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/Grid.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/VariantStorage.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCommands.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdContainer.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdContainer.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdContainerAjx.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdContainerObj.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdInsert.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdInsert.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdEdit.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdEdit.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdCopy.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdCopy.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdDelete.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdDelete.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdColManager.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdColManager.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdPrint.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdPrint.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdRefresh.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdRefresh.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdPrintObj.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdSearch.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdSearch.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdExport.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdExport.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdAllCommands.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdAllCommands.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdDOCUnprocess.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdDOCUnprocess.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdDOCShowActs.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdDOCShowActs.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdRowUp.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdRowUp.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdRowDown.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdRowDown.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdFilter.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdFilter.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdFilterView.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdFilterView.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdFilterSave.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdFilterSave.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdFilterOpen.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdFilterOpen.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewGridColManager.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewGridColManager.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewGridColParam.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewGridColParam.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewGridColVisibility.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewGridColVisibility.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewGridColOrder.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewGridColOrder.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/VariantStorageSaveView.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/VariantStorageSaveView.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/VariantStorageOpenView.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/VariantStorageOpenView.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridAjx.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridAjx.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/TreeAjx.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridAjxDOCT.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridAjxMaster.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCommandsAjx.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCommandsAjx.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCommandsDOC.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCommandsDOC.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridPagination.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridPagination.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridFilterInfo.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridFilter.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridFilter.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditPeriodDate.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditPeriodDate.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditPeriodDateTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonOK.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonOK.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonSave.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonSave.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonCancel.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonCancel.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewObjectAjx.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewObjectAjx.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewGridEditInlineAjx.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewGridEditInlineAjx.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewDOC.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewDOC.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowPrint.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowPrint.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowQuestion.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowQuestion.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowSearch.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowSearch.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowForm.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowForm.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowFormObject.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowFormObject.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowFormModalBS.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowFormModalBS.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowMessage.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellHeadDOCProcessed.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellHeadDOCDate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellHeadDOCNumber.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/actb.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/actb.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/RepCommands.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/RepCommands.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewReport.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewReport.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/PopUpMenu.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/PopOver.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/PeriodSelect.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/PeriodSelect.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowAbout.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowAbout.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/MainMenuTree.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/MainMenuTree.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonOrgSearch.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ConstantGrid.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ConstantGrid.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Captcha.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewTemplate.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ViewList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/MainMenuConstructor_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/User_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/UserList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/Bank_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/BankList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/MailForSending_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/Client_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ClientList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocumentTemplateDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ApplicationDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ApplicationList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ApplicationClientList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ContractList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ConstructionTypeDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowOutDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowOutList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowInList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DepartmentDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/EmployeeDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/EmployeeList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DepartmentList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/PostList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowTypeDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowInDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowImportanceTypeDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ReportTemplate_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ReportTemplateList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ReportTemplateFile_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/EmailTemplate_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowExamination_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowApprovement_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowRegistration_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowOutClientDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowInClientDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ContractDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/OfficeDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ReportTemplateFileApplyCmd_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ReportTemplateFileList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowApprovementTemplate_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DocFlowApprovementTemplateList_Form.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/UserDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/Login_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/FileUploader_View.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/FileUploader_View.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/PasswordRecovery_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/Registration_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MainMenuConstructorList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MainMenuConstructor_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ViewList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/UserProfile_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/About_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/Bank_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/BankList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ConstantList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/UserList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/UserDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/TimeZoneLocale_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MailForSendingList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MailForSending_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/EmailTemplateList_View.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/EmailTemplateList_View.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/EmailTemplate_View.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/EmailTemplate_View.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ClientList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/Client_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ClientSearch_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocumentTemplateList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocumentTemplateDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OfficeDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OfficeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/FileUploaderApplication_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/FileUploaderDocFlowOut_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/FileUploaderDocFlowIn_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/FileUploaderDocFlowOutClient_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/FileUploaderDocFlowInClient_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/FileUploaderContract_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocumentDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowBaseDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ApplicationList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/ApplicationList_View.rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ApplicationDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/ApplicationDialog_View.rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ViewBankAcc.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ViewRespPerson.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ViewPersonIdPaper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ViewPersonRegistrPaper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ViewKladr.js'));
		
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/ViewKladr.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ApplicationClientList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/ApplicationClientList_View.rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ConstructionTypeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ConstructionTypeDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/HolidayList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowOutList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowOutDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowInList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowInDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DepartmentList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/DepartmentList_View.rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DepartmentDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/DepartmentDialog_View.rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/EmployeeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/EmployeeList_View.rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/EmployeeDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/EmployeeDialog_View.rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowTypeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowTypeDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs/DocFlowTypeDialog_View.rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/PostList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/FundSourceList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowImportanceTypeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowImportanceTypeDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ReportTemplateList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ReportTemplateFileList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ReportTemplate_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ReportTemplateFile_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ReportTemplateApply_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowExaminationList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowExamination_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowApprovementList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowApprovement_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowRegistrationList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowRegistration_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/BuildTypeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowOutClientList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowOutClientDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowInClientList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowInClientDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowTaskList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ViewContact.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ReminderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowTaskShortList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ContractList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ContractPdList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ContractCostEvalValidityList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ContractModificationList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ContractAuditList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ContractDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ContactList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ExpertiseRejectTypeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OfficeDayScheduleList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/Reminder_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowApprovementTemplate_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DocFlowApprovementTemplateList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ClientPaymentList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/NewOrder_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ClientPaymentLoader_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ProjectManager_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'tmpl/App.templates.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/App.enums.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/App.predefinedItems.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ErrorControl.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/AppExpert.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditAddress.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientResponsableGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ConstrTechnicalFeatureGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ViewSectionSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ViewEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/UserEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/UserEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/UserNameEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/UserPwdEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/rs/UserPwdEdit.rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/Pagination.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/BankEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditUserClientBankAcc.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditRespPerson.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ApplicationClientEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ApplicationClientContainer.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditBankAcc.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditOGRN.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditINN.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditKPP.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditPersonIdPaper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/PersonIdPaperSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditPersonRegistrPaper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/OfficeSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DocFlowTypeSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EmployeeEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DepartmentSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DepartmentEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ConstructionTypeSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/FundSourceSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/BuildTypeSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ExpertiseRejectTypeSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DocFlowImportanceTypeSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/PostEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ApplicationEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ContractEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientNameEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientNameFullEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientAttrs.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientAddress.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ApplicationPrimaryCont.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ApplicationServiceCont.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ApplicationRegNumber.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ReportTemplateFileApplyCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DocFlowOutEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DocFlowInEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DocFlowRecipientRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditContactList.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditContact.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/Reminder.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditColorPalette.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/BtnNextNum.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ReportTemplateFieldGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ReportTemplateEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ReportTemplateFileApplyCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DocFlowApprovementRecipientGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DocFlowApprovementRecipientEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ApplicationTemplateContentTree.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/AccessPermissionGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/PermissionEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ExpertWorkGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/WorkHoursEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/WorkHourEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ViewLocalGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DocFlowApprovementTypeEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DocFlowApprovementSelectRecipientTmplCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientPaymentLoaderCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/Doc1c.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/Doc1cOrder.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/Doc1cAkt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/LinkedContractListGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ContractorListGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientResponsablePersonEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_role_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs_common_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Constant_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Enum_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/MainMenuConstructor_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/MainMenuContent_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/View_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/VariantStorage_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Bank_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/About_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/User_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/MailForSending_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/TimeZoneLocale_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Application_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Department_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Employee_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConstantList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/View_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ViewList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ViewSectionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MainMenuConstructor_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MainMenuConstructorList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MainMenuContent_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Bank_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/BankList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VariantStorage_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VariantStorageList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/About_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/TimeZoneLocale_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/User_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MailForSending_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MailForSendingList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MailForSendingAttachment_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DepartmentList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DepartmentDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/EmployeeList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/EmployeeDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_locales.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_role_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_role_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/EmailTemplate_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/EmailTemplate_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/EmailTemplateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_email_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserEmailConfirmation_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_locales.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_role_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_email_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserProfile_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Client_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Client_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ClientSearch_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Kladr_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Kladr_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ClientResponsablePerson_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientResponsablePerson_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocumentTemplate_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocumentTemplate_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocumentTemplateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ApplicationTemplateContent_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationTemplateContent_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ClientBankAccount_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientBankAccount_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Office_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Office_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OfficeList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Captcha_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_client_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_client_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Application_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_expertise_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_expertise_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ApplicationContractor_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/TechnicalFeature_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/TechnicalFeature_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationContractor_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationStateHistory_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_application_states.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_application_states.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ApplicationClient_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationClient_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/PersonIdPaper_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/PersonIdPaper_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientPersonIdPaper_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientPersonRegistrPaper_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationClientList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationDocumentFile_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationPrint_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationDocumentFile_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DownloadFileType_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DownloadFileType_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_responsable_person_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_responsable_person_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Morpher_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Holiday_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Holiday_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOut_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowOut_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOutList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Department_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Employe_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Employee_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowIn_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowInList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlow_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowIn_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowInDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowType_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowType_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationRespPerson_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationContact_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Contact_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Post_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Post_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Contact_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ContactList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowType_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowImportanceType_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOut_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowAttachment_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOutList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOutProcess_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_doc_flow_out_states.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_data_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_doc_flow_out_states.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_data_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ApplicationProcess_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowApprovement_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowIn_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowIn_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowInProcess_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowAcqaintance_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowFilfilment_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowExamination_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_doc_flow_in_states.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_doc_flow_in_states.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowTypeList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowTypeDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowImportanceType_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowImportanceTypeList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowImportanceTypeDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOutDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/FundSource_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConstructionType_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ConstructionType_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/FundSource_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_document_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_document_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocumentTemplate_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocumentTemplateAllList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ReportTemplate_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ReportTemplate_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ReportTemplateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ReportTemplateField_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ReportTemplateField_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ReportTemplateDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ReportTemplateInParam_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ReportTemplateInParam_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOutClientList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowInClientList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowExaminationList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowExamination_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/BuildType_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/BuildType_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOutClient_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowInClient_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowOutClient_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOutClientDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowInClient_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowInClientDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOutClientDocumentFile_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowExaminationDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowTask_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowTask_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowTaskList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_doc_flow_type_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_doc_flow_type_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ContactName_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ContactName_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowRegistration_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowRegistrationList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowRegistrationDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowRegistration_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Reminder_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Reminder_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ReminderUnviewedList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShortMessage_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowTaskShortList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MainMenuConstructorDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Contract_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Contract_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ContractList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ContractDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ReportTemplateFile_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ReportTemplateFileDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ReportTemplateFileList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ReportTemplateFile_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowApprovementList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowApprovementDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_doc_flow_approvement_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_doc_flow_approvement_orders.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_doc_flow_approvement_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_doc_flow_approvement_orders.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowApprovement_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowApprovementRecipientList_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowApprovementRecipientList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_doc_flow_approvement_results.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_doc_flow_approvement_results.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ExpertiseRejectType_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ExpertiseRejectType_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ExpertWork_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ExpertWork_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/AccessPermission_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/AccessPermission_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ExpertSection_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ContractSection_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ContractSection_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ExpertWorkList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OfficeDaySchedule_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/OfficeDaySchedule_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_expertise_results.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_expertise_results.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ViewLocal_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ViewLocal_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowApprovementTemplate_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DocFlowApprovementTemplate_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowApprovementTemplateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowApprovementTemplateDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientPayment_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ClientPayment_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientPaymentList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Order1CList_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Order1CList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ProjectManager_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/LinkedContractList_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LinkedContractList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_cost_eval_validity_pd_orders.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_cost_eval_validity_pd_orders.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_date_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_date_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ContractorList_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ContractorList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowOutClientRegNumber_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DocFlowInClientRegNumber_Model.js'));
	
			if (isset($_SESSION['scriptId'])){
				$script_id = $_SESSION['scriptId'];
			}
			else{
				$script_id = VERSION;
			}			
		}
		
		$this->getVarModel()->addField(new Field('role_id',DT_STRING));
		$this->getVarModel()->addField(new Field('user_name',DT_STRING));
		if (isset($_SESSION['role_id']) && $_SESSION['role_id']!='client'){
			$this->getVarModel()->addField(new Field('employees_ref',DT_STRING));			
		}
		if (isset($_SESSION['role_id'])){
			$this->getVarModel()->addField(new Field('user_name_full',DT_STRING));
			$this->getVarModel()->addField(new Field('temp_doc_storage',DT_STRING));
			$this->getVarModel()->addField(new Field('temp_doc_storage_hours',DT_INT));
			$this->getVarModel()->addField(new Field('color_palette',DT_STRING));				
		}
		
		
		$this->getVarModel()->insert();
		$this->setVarValue('scriptId',$script_id);
		
		//'http://'.$_SERVER['HTTP_HOST'].'/'.APP_NAME.'/'		
		$currentPath = $_SERVER['PHP_SELF'];
		$pathInfo = pathinfo($currentPath);
		$hostName = $_SERVER['HTTP_HOST'];
		$protocol = strtolower(substr($_SERVER["SERVER_PROTOCOL"],0,5))=='https://'?'https://':'http://';
		$this->setVarValue('basePath', $protocol.$hostName.$pathInfo['dirname']."/");
		
		$this->setVarValue('version',trim(VERSION));
		$this->setVarValue('debug',DEBUG);
		if (isset($_SESSION['locale_id'])){
			$this->setVarValue('locale_id',$_SESSION['locale_id']);
		}
		else if (!isset($_SESSION['locale_id']) && defined('DEF_LOCALE')){
			$this->setVarValue('locale_id', DEF_LOCALE);
		}		
		
		if (isset($_SESSION['role_id'])){
			$this->setVarValue('temp_doc_storage',TEMP_DOC_STORAGE);
			$this->setVarValue('temp_doc_storage_hours',TEMP_DOC_STORAGE_HOURS);
			$this->setVarValue('color_palette',$_SESSION['color_palette']);
		
			$this->setVarValue('role_id',$_SESSION['role_id']);
			$this->setVarValue('user_name',$_SESSION['user_name']);
			$this->setVarValue('user_name_full',$_SESSION['user_name_full']);
			$this->setVarValue('locale_id',$_SESSION['locale_id']);
			$this->setVarValue('curDate',round(microtime(true) * 1000));
			//$this->setVarValue('token',$_SESSION['token']);
			//$this->setVarValue('tokenr',$_SESSION['tokenr']);
			
			if ($_SESSION['role_id']!='client'){
				$this->setVarValue('employees_ref',$_SESSION['employees_ref']);
			}
		}
		
		//Global Filters
						
	}
		
	
	public function write(ArrayObject &$models,$errorCode=NULL){
		$this->addMenu($models);
		
		
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
		
		if (isset($_SESSION['role_id']) && $_SESSION['role_id']!='client'){
			$models->append(DocFlowTask_Controller::get_short_list_model($this->dbLink));
		}
		else if (isset($_SESSION['role_id']) && $_SESSION['role_id']=='client'){
			$models->append(DocFlowInClient_Controller::get_unviwed_count_model($this->dbLink));
		}
		
		parent::write($models,$errorCode);
	}	
}	
?>