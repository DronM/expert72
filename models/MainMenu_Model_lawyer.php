<?php
require_once(FRAME_WORK_PATH.'basic_classes/Model.php');

class MainMenu_Model_accountant extends Model{
	public function dataToXML(){
		return '<model id="MainMenu_Model" sysModel="1">
		<menu  id="MainMenuContent_Model"><menuitem  id="1" descr="Документы Входяшие документы" c="DocFlowIn_Controller" f="get_list" t="DocFlowInList" viewdescr="Документы Исходящие документы" default="true" glyphclass="null" updated="1"></menuitem><menuitem  id="2" descr="Исходящие документы" c="DocFlowOut_Controller" f="get_list" t="DocFlowOutList" viewdescr="Документы Исходящие документы" default="" glyphclass="icon-undo2" updated="1"></menuitem><menuitem  id="3" descr="Рассмотрения" c="DocFlowExamination_Controller" f="get_list" t="DocFlowExaminationList" viewdescr="Документы Рассмотрения" default="" glyphclass=""></menuitem><menuitem  id="4" descr="Согласования" c="DocFlowApprovement_Controller" f="get_list" t="DocFlowApprovementList" viewdescr="Документы Согласования" default="" glyphclass=""></menuitem><menuitem  id="15" descr="Заявления" c="Application_Controller" f="get_list" t="ApplicationList" viewdescr="Документы Заявления" default="" glyphclass=""></menuitem><menuitem  id="6" descr="Контракты" viewid="" viewdescr="" default="" glyphclass="icon-book3"><menuitem id="7" descr="Контракты ПД" c="Contract_Controller" f="get_pd_list" t="ContractPdList" viewdescr="Документы Контракты ПД" default="" glyphclass="null" updated="1"></menuitem><menuitem id="9" descr="Контракты Достоверность" c="Contract_Controller" f="get_cost_eval_validity_list" t="ContractCostEvalValidityList" viewdescr="Документы Контракты Достоверность" default="" glyphclass="null" updated="1"></menuitem><menuitem id="10" descr="Контракты модификация" c="Contract_Controller" f="get_modification_list" t="ContractModificationList" viewdescr="Документы Контракты Модификация" default="" glyphclass="null" updated="1"></menuitem><menuitem id="11" descr="Контракты аудит" c="Contract_Controller" f="get_audit_list" t="ContractAuditList" viewdescr="Документы Контракты Аудит" default="" glyphclass="null" updated="1"></menuitem></menuitem><menuitem  id="12" descr="Шаблоны печатных форм" c="ReportTemplateFile_Controller" f="get_list" t="ReportTemplateFileList" viewdescr="Справочники Шаблоны печатных форм" default="" glyphclass=""></menuitem><menuitem  id="13" descr="Контакты" c="Contact_Controller" f="get_list" t="ContactList" viewdescr="Справочники Контакты" default="" glyphclass="icon-users"></menuitem><menuitem  id="14" descr="Шаблоны согласований" c="DocFlowApprovementTemplate_Controller" f="get_list" t="DocFlowApprovementTemplateList" viewdescr="Справочники Шаблоны согласований" default="" glyphclass="icon-tree7" updated="1"></menuitem></menu>
		</model>';
	}
}
?>
