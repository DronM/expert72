<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowIn'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>
class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public function insert($pm){
		if ($_SESSION['role_id'!='client']){
			if ($_SESSION['employees_ref']){
				$ar = json_decode($_SESSION['employees_ref'],TRUE);
				$pm->setParamValue('employee_id',$ar['RefType']['id']);
			}
			else{
				throw new Exception(self:: ER_EMPLOYEE_NOT_DEFINED);
			}
		}
		
		return parent::insert($pm);
	}

	public function get_state($id,$type='in'){
		parent::get_state($id,$type);
	}

	public function delete($pm){
		$this->delete_attachments($pm,'in');
	}
	
	public function remove_file($pm){
		$this->remove_afile($pm,'in');
	}
	
	public function get_next_num($pm){
		$this->get_next_num_on_type('in', $this->getExtDbVal($pm,'doc_flow_type_id'));
	}
	

</xsl:template>

</xsl:stylesheet>
