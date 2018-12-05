<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'ApplicationProcess'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');

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
		$pm->setParamValue('user_id',$_SESSION['user_id']);
		parent::insert($pm);
	}

	public function delete($pm){
		if ($_SESSION['role_id']!='admin'){
			throw new Exception('Статусы удалять может только администратор!');
		}
		
		$q = sprintf("DELETE FROM application_processes%s
		WHERE application_id=%d AND date_trunc('second',date_time)=date_trunc('second',%s::timestampTZ)",
			Application_Controller::LKPostfix(),
			$this->getExtDbVal($pm,'application_id'),
			$this->getExtDbVal($pm,'date_time')
		);
		//throw new Exception($q);
		$this->getDbLinkMaster()->query($q);
		//parent::delete($pm);
	}

</xsl:template>

</xsl:stylesheet>
