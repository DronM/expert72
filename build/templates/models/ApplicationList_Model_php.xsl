<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Model_php.xsl"/>

<!-- -->
<xsl:variable name="MODEL_ID" select="'ApplicationList'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
<xsl:template match="/">
	<xsl:apply-templates select="metadata/models/model[@id=$MODEL_ID]"/>
</xsl:template>
		
<xsl:template match="model"><![CDATA[<?php]]>
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */
<xsl:call-template name="add_requirements"/> 

require_once(ABSOLUTE_PATH.'controllers/Application_Controller.php');

class <xsl:value-of select="@id"/>_Model extends <xsl:value-of select="@parent"/>{
	<xsl:call-template name="add_constructor"/>
	<xsl:call-template name="user_functions"/>
}
<![CDATA[?>]]>
</xsl:template>
		
<xsl:template name="user_functions">
	public function setTableName($v){
		parent::setTableName($v.Application_Controller::LKPostfix());
	}
</xsl:template>
			
</xsl:stylesheet>
