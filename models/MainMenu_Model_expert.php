<?php
require_once(FRAME_WORK_PATH.'basic_classes/Model.php');

class MainMenu_Model_expert extends Model{
	public function dataToXML(){
		return '<model id="MainMenu_Model" sysModel="1">
		<menu  id="MainMenuContent_Model"><menuitem  id="1" descr="Документы Входяшие документы" c="DocFlowIn_Controller" f="get_list" t="DocFlowInList" viewdescr="Документы Исходящие документы" default="" glyphclass="icon-redo2" updated="1"></menuitem><menuitem  id="2" descr="Исходящие документы" c="DocFlowOut_Controller" f="get_list" t="DocFlowOutList" viewdescr="Документы Исходящие документы" default="" glyphclass="icon-undo2" updated="1"></menuitem><menuitem  id="4" descr="Согласования" c="DocFlowApprovement_Controller" f="get_list" t="DocFlowApprovementList" viewdescr="Документы Согласования" default="" glyphclass=""></menuitem><menuitem  id="5" descr="Контракты" c="Contract_Controller" f="get_list" t="ContractList" viewdescr="Документы Контракты" default="true" glyphclass="" updated="1"></menuitem><menuitem  id="6" descr="Шаблоны печатных форм" c="ReportTemplateFile_Controller" f="get_list" t="ReportTemplateFileList" viewdescr="Справочники Шаблоны печатных форм" default="" glyphclass=""></menuitem><menuitem  id="7" descr="Контакты" c="Contact_Controller" f="get_list" t="ContactList" viewdescr="Справочники Контакты" default="" glyphclass="icon-users"></menuitem><menuitem  id="8" descr="Шаблоны согласований" c="DocFlowApprovementTemplate_Controller" f="get_list" t="DocFlowApprovementTemplateList" viewdescr="Справочники Шаблоны согласований" default="" glyphclass="icon-tree7" updated="1"></menuitem></menu>
		</model>';
	}
}
?>