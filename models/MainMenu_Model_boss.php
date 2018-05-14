<?php
require_once(FRAME_WORK_PATH.'basic_classes/Model.php');

class MainMenu_Model_boss extends Model{
	public function dataToXML(){
		return '<model id="MainMenu_Model" sysModel="1">
		<menu  id="MainMenuContent_Model"><menuitem  id="1" descr="Документы Входяшие документы" c="DocFlowIn_Controller" f="get_list" t="DocFlowInList" viewdescr="Документы Исходящие документы" default="" glyphclass="icon-redo2" updated="1"></menuitem><menuitem  id="2" descr="Исходящие документы" c="DocFlowOut_Controller" f="get_list" t="DocFlowOutList" viewdescr="Документы Исходящие документы" default="" glyphclass="icon-undo2" updated="1"></menuitem><menuitem  id="3" descr="Рассмотрения" c="DocFlowExamination_Controller" f="get_list" t="DocFlowExaminationList" viewdescr="Документы Рассмотрения" default="" glyphclass=""></menuitem><menuitem  id="4" descr="Согласования" c="DocFlowApprovement_Controller" f="get_list" t="DocFlowApprovementList" viewdescr="Документы Согласования" default="" glyphclass=""></menuitem><menuitem  id="5" descr="Контракты" c="Contract_Controller" f="get_list" t="ContractList" viewdescr="Документы Контракты" default="" glyphclass=""></menuitem></menu>
		</model>';
	}
}
?>
