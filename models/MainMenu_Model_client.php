<?php
require_once(FRAME_WORK_PATH.'basic_classes/Model.php');

class MainMenu_Model_client extends Model{
	public function dataToXML(){
		return '<model id="MainMenu_Model" sysModel="1">
		<menu  id="MainMenuContent_Model"><menuitem id="1" descr="Заявления на проведение экспертизы" c="Application_Controller" f="get_list" t="ApplicationList" viewdescr="Документы Заявления" default="" glyphclass=""></menuitem></menu>
		</model>';
	}
}
?>