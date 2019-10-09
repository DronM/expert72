<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowInside'"/>
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
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public function remove_file($pm){
		$this->remove_afile($pm,'inside');
	}

	public function remove_sig($pm){
		$this->remove_asig($pm,'inside');
	}

	public function delete($pm){
		$this->delete_attachments($pm,'inside');
	}
	
	public function get_sig_details($pm){
		$this->addNewModel(
			Application_Controller::getSigDetailsQuery($this->getExtDbVal($pm,'id')),
			'FileSignatures_Model'
		);
	
	}
	
	public function sign_file($pm){
		$file_data = NULL;
		if(isset($_FILES) &amp;&amp; isset($_FILES['file_data'])){
			$file_data = $_FILES['file_data'];
		}
	
		DocFlow_Controller::signFile(
			$this,
			$pm,
			$file_data,
			'inside'
		);
	}

</xsl:template>

</xsl:stylesheet>
