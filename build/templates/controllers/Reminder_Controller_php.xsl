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
		$eml_id = json_decode($_SESSION['employees_ref'])->keys->id;
		$m = $this->addNewModel(sprintf(
			"SELECT
				r.id,
				r.date_time,
				r.content,
				r.docs_ref,
				doc_flow_importance_types_ref(tp) AS doc_flow_importance_types_ref,
				r.files,
				emp.name AS short_message_sender
			FROM reminders AS r
			LEFT JOIN short_messages AS ms ON
				r.register_docs_ref->>'dataType'='short_messages' AND (r.register_docs_ref->'keys'->>'id')::int=ms.id
			LEFT JOIN employees AS emp ON emp.id=ms.recipient_id
			LEFT JOIN doc_flow_importance_types AS tp ON tp.id=r.doc_flow_importance_type_id
			WHERE
				r.recipient_employee_id=%d
				AND NOT r.viewed
				AND r.date_time &lt;= now()
				AND r.date_time::date > (now()::date - ((const_reminder_show_days_val()||' days')::interval)*2)
			ORDER BY date_time ASC",
			$eml_id
			),
		"ReminderUnviewedList_Model",
		FALSE //NOT XML!
		);
		if ($m->getRowCount()){
			$this->addModel(DocFlowTask_Controller::get_short_list_model($this->getDbLink()));
		}
		
		//чат
		/*
		$this->addNewModel(sprintf(
			"SELECT count(*)
			FROM short_messages AS m
			LEFT JOIN short_message_views AS v ON v.short_message_id=m.id
			WHERE (to_recipient_id IS NULL OR to_recipient_id=%d) AND v.date_time IS NULL",
			$eml_id
			),
		"ShortMessageUnviewedCount_Model",
		TRUE
		);
		*/
	}
	
	public function set_viewed($pm){
		$id_list = '';
		$id_list_ar = explode(',',$this->getExtVal($pm,'id_list'));
		foreach($id_list_ar as $id){
			$id_clear = intval($id);
			if ($id_clear){
				$id_list.= ($id_list=='')? '':',';	
				$id_list.= $id_clear;
			}
		}
		
		$this->getDbLinkMaster()->query(sprintf(
			"UPDATE reminders SET viewed=TRUE,viewed_dt=now() WHERE id IN(%s)",
			$id_list
		));
	}
	

</xsl:template>

</xsl:stylesheet>
