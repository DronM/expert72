<?php
require_once(FRAME_WORK_PATH.'basic_classes/Model.php');

class MainMenu_Model_client extends Model{
	public function dataToXML(){
		return '<model id="MainMenu_Model" sysModel="1">
		<menu  id="MainMenuContent_Model"><menuitem id="1" descr="Заявления на проведение экспертизы" c="Application_Controller" f="get_list" t="ApplicationList" viewdescr="Формы Профиль пользователя" default="true" glyphclass=" icon-books" updated="1"></menuitem><menuitem id="3" descr="Входящие письма" c="DocFlowInClient_Controller" f="get_list" t="DocFlowInClientList" viewdescr="Документы Входящие клиента" default="" glyphclass="icon-arrow-right16" updated="1"></menuitem><menuitem id="5" descr="Исходящие письма" c="DocFlowOutClient_Controller" f="get_list" t="DocFlowOutClientList" viewdescr="Документы Исходящие клиента" default="" glyphclass="icon-arrow-left16" updated="1"></menuitem><menuitem id="2" descr="Профиль" c="User_Controller" f="get_profile" t="UserProfile" viewdescr="Формы Профиль пользователя" default="" glyphclass="icon-user" updated="1"></menuitem></menu>
		</model>';
	}
}
?>