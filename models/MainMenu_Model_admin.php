<?php
require_once(FRAME_WORK_PATH.'basic_classes/Model.php');

class MainMenu_Model_admin extends Model{
	public function dataToXML(){
		return '<model id="MainMenu_Model" sysModel="1">
		<menu id="MainMenuContent_Model">
	

<menuitem id="1" descr="Справочники" viewid="" viewdescr="" default="" glyphclass="icon-pencil3">


<menuitem id="2" descr="Банки" c="Bank_Controller" f="get_list" t="BankList" viewdescr="Справочники Банки" default="" isgroup="0"/>
<menuitem id="3" descr="Пользователи" c="User_Controller" f="get_list" t="UserList" viewdescr="Справочники Пользователи" default="1"/>
<menuitem id="4" descr="Электронная почта" c="MailForSending_Controller" f="get_list" t="MailForSendingList" viewdescr="Справочники Электронная почта" default="" glyphclass=""/>
<menuitem id="5" descr="Шаблоны писем" c="EmailTemplate_Controller" f="get_list" t="EmailTemplateList" viewdescr="Справочники Шаблоны писем" default="" glyphclass=""/>
<menuitem id="6" descr="Контрагенты" c="Client_Controller" f="get_list" t="ClientList" viewdescr="Справочники Контрагенты" default="" glyphclass=""/>
<menuitem id="7" descr="Шаблоны заявлений ПД" c="ApplicationPdTemplate_Controller" f="get_list" t="ApplicationPdTemplateList" viewdescr="Справочники Шаблоны заявлений ПД" default="" glyphclass="" updated="1"/><menuitem  id="11" descr="Шаблоны заявлений достоверность" c="ApplicationDostTemplate_Controller" f="get_list" t="ApplicationDostTemplateList" viewdescr="Справочники Шаблоны заявлений достоверность" default="" glyphclass="" updated="1"></menuitem>

<menuitem  id="10" descr="Места проведения экспертизы" c="Office_Controller" f="get_list" t="OfficeList" viewdescr="Справочники Места проведения экспертизы" default="" glyphclass=""></menuitem></menuitem>

<menuitem id="8" descr="Документы" viewid="" viewdescr="" default="" glyphclass=""/>

<menuitem id="9" descr="Отчеты1" viewid="" viewdescr="" default="" glyphclass="" updated="1"/>
</menu>
		</model>';
	}
}
?>