<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="permission_php.xsl"/>

<!-- -->
<xsl:variable name="ROLE_ID" select="'admin'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/"><![CDATA[<?php]]>
/**
	DO NOT MODIFY THIS FILE!	
	Its content is generated automaticaly from template placed at build/permissions/permission_php.tmpl.	
 */
function method_allowed($contrId,$methId){
$permissions = array();
<xsl:apply-templates select="metadata/permissions/permission[@roleId=$ROLE_ID or @roleId=$ALL]"/>
return array_key_exists($contrId.'_'.$methId,$permissions);
}
<![CDATA[?>]]>
</xsl:template>
			
			
<xsl:template name="perm_for_role">
	<xsl:param name="contr"/>
	<xsl:param name="meth"/>
	<xsl:param name="role"/>
	<xsl:param name="val"/>
	<xsl:if test="$role=$ROLE_ID">
	$permissions['<xsl:value-of select="$contr"/>_Controller_<xsl:value-of select="$meth"/>']=<xsl:value-of select="$val"/>;
	</xsl:if>
</xsl:template>
			
</xsl:stylesheet>
