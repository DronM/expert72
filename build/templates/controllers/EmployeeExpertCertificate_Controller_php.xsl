<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'EmployeeExpertCertificate'"/>
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

	public function complete_on_cert_id($pm){
	
		//one expert
		
		$cert_cond = '';
		//конкретные сертификаты одного эксперта
		if($pm->getParamValue('cert_id')){
			$cert_cond = " AND lower(certs.cert_id) LIKE '%%'||lower(".$this->getExtDbVal($pm,'cert_id').")||'%%'";
		}
		//if($pm->getParamValue('expert_type')){
		//	$cert_cond .= " AND lower(certs.expert_type) LIKE '%%'||lower(".$this->getExtDbVal($pm,'expert_type').")||'%%'";
		//}
		
		$q = sprintf(
			"SELECT
				certs.*				
			FROM employee_expert_certificates_list AS certs
			WHERE certs.employee_id = %d ".$cert_cond."
			ORDER BY certs.date_to DESC
			LIMIT 10"
			,$this->getExtDbVal($pm,'employee_id')
		);				
		$this->addNewModel($q,'EmployeeExpertCertificateList_Model');			
	}

</xsl:template>

</xsl:stylesheet>
