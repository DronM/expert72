<?php
require_once(FRAME_WORK_PATH.'basic_classes/Model.php');

class MainMenu_Model_expert extends Model{
	public function dataToXML(){
		return '<model id="MainMenu_Model" sysModel="1">
		<menu  id="MainMenuContent_Model"><menuitem  id="1" descr="Документы Входяшие документы" c="DocFlowIn_Controller" f="get_list" t="DocFlowInList" viewdescr="Документы Исходящие документы" default="" glyphclass="icon-redo2" updated="1"></menuitem><menuitem  id="2" descr="Исходящие документы" c="DocFlowOut_Controller" f="get_list" t="DocFlowOutList" viewdescr="Документы Исходящие документы" default="" glyphclass="icon-undo2" updated="1"></menuitem><menuitem  id="4" descr="Согласования" c="DocFlowApprovement_Controller" f="get_list" t="DocFlowApprovementList" viewdescr="Документы Согласования" default="" glyphclass=""></menuitem><menuitem  id="6" descr="Шаблоны печатных форм" c="ReportTemplateFile_Controller" f="get_list" t="ReportTemplateFileList" viewdescr="Справочники Шаблоны печатных форм" default="" glyphclass=""></menuitem><menuitem  id="8" descr="Шаблоны согласований" c="DocFlowApprovementTemplate_Controller" f="get_list" t="DocFlowApprovementTemplateList" viewdescr="Справочники Шаблоны согласований" default="" glyphclass="icon-tree7" updated="1"></menuitem><menuitem  id="9" descr="Контракты" viewid="" viewdescr="" default="" glyphclass="icon-book3"><menuitem id="10" descr="Контракты ПД" c="Contract_Controller" f="get_pd_list" t="ContractPdList" viewdescr="Документы Контракты ПД" default="" glyphclass="icon-book3"></menuitem><menuitem id="11" descr="Контракты Достоверность" c="Contract_Controller" f="get_cost_eval_validity_list" t="ContractCostEvalValidityList" viewdescr="Документы Контракты Достоверность" default="" glyphclass="icon-book3"></menuitem></menuitem></menu>
		</model>';
	}
}
?>