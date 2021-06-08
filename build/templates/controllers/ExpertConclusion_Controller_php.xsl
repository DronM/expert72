<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'ExpertConclusion'"/>
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

	public function insert($pm){
		//doc owner
		if(!$pm->getParamValue('date_time')){
			$pm->setParamValue('date_time',date('Y-m-d H:i:s'));
		}
		if($_SESSION['role_id']=='expert' ||$_SESSION['role_id']=='expert_ext'){
			$pm->setParamValue('expert_id',$_SESSION['expert_id']);
		}
		
		return parent::insert($pm);		
	}
	
	public function update($pm){
		if( ($_SESSION['role_id']=='expert' ||$_SESSION['role_id']=='expert_ext')
		&amp;&amp;$pm->getParamValue('expert_id')
		&amp;&amp;$pm->getParamValue('expert_id')!=$_SESSION['expert_id']
		){
			throw new Exception("Запрещено менять сотрудника!");
		}
	
		$pm->setParamValue('last_modified',date('Y-m-d H:i:s'));
		
		parent::update($pm);		
	}

</xsl:template>

</xsl:stylesheet>
