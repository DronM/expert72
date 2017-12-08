<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'OutMail'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once('functions/ExpertEmailSender.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public function reg_for_sending($outMailId){
		$attach = array();
		$this->getDbLink()->query(sprintf("SELECT file_name FROM out_mail_attachments WHERE out_mail_id=%d",$outMailId));
		while($ar = $this->getDbLink()->fetch_array()){
			array_push($attach,$ar['file_name']);
		}
		ExpertEmailSender::addEMail(
			$this->getDbLinkMaster(),
			sprintf("email_reg_out_mail(%d)",
				$outMailId
			),
			$attach,
			'out_mail'
		);
	
	}

	public function insert($pm){
		$link = $this->getDbLinkMaster();
		try{
			$link->query('BEGIN');
			$ar = parent::insert($pm);
			if ($this->getExtVal('sent')){
				$this->reg_for_sending($ar['id']);
			}
			
			$link->query('COMMIT');
		}
		catch(Exception $e){
			$link->query('ROLLBACK');
		}
		return $ar;
	}
	public function update($pm){
		$link = $this->getDbLinkMaster();
		try{
			$link->query('BEGIN');
			parent::update($pm);
			if ($this->getExtVal('sent')){
				$this->reg_for_sending($this->getExtVal('old_id'));
			}
			
			$link->query('COMMIT');
		}
		catch(Exception $e){
			$link->query('ROLLBACK');
		}
	}
	
</xsl:template>

</xsl:stylesheet>
