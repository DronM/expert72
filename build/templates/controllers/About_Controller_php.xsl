<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'About'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public function get_object($pm){
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'About_Model',
				'values'=>array(
					new Field('app_name',DT_STRING,array('value'=>APP_NAME)),
					new Field('author',DT_STRING,array('value'=>AUTHOR)),
					new Field('tech_mail',DT_STRING,array('value'=>TECH_EMAIL)),
					new Field('db_name',DT_STRING,array('value'=>DB_USER)),
					new Field('app_version',DT_STRING,array('value'=>VERSION)),
					new Field('fw_version',DT_STRING,array('value'=>FW_VERSION))
				)
			)
		));				
	}
</xsl:template>

</xsl:stylesheet>
