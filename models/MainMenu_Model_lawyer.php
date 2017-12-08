<?php
require_once(FRAME_WORK_PATH.'basic_classes/Model.php');

class MainMenu_Model_lawyer extends Model{
	public function dataToXML(){
		return '<model id="MainMenu_Model" sysModel="1">
		<menu id="MainMenuContent_Model" xmlns="http://www.katren.org/crm/doc/mainmenu"/>
		</model>';
	}
}
?>