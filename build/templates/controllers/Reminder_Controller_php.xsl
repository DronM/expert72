<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Reminder'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(USER_CONTROLLERS_PATH.'DocFlowTask_Controller.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public function get_unviewed_list($pm){
		$m = $this->addNewModel(sprintf(
			"SELECT
				id,
				date_time,
				content,docs_ref
			FROM reminders
			WHERE
				recipient_employee_id=%d
				AND NOT viewed
				AND date_time &lt;= now()
				AND date_time::date > (now()::date - ((const_reminder_show_days_val()||' days')::interval)*2)
			ORDER BY date_time ASC",
			json_decode($_SESSION['employees_ref'])->keys->id
			),
		"ReminderUnviewedList_Model",
		FALSE //NOT XML!
		);
		if ($m->getRowCount()){
			$this->addModel(DocFlowTask_Controller::get_short_list_model($this->getDbLink()));
		}
	}
	
	public function set_viewed($pm){
		$this->getDbLinkMaster()->query(sprintf(
			"UPDATE reminders SET viewed=TRUE,viewed_dt=now() WHERE id=%d",
			$this->getExtDbVal($pm,'id')
		));
	}
	

</xsl:template>

</xsl:stylesheet>
