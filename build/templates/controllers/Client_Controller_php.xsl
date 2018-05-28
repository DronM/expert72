<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Client'"/>
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
		$pm->setParamValue('user_id',$_SESSION['user_id']);
		$this->getDbLinkMaster()->query("BEGIN");
		try{
			$inserted_ar = parent::insert($pm);
			
			if ($this->getExtVal($pm,'responsable_persons')){
				$this->getDbLinkMaster()->query(sprintf("SELECT contacts_add_persons(
						%d,'clients'::data_types,1,
						json_build_object(
							'responsable_persons',%s::json,
							'name',%s
						)
					)",
					$inserted_ar['id'],
					$this->getExtDbVal($pm,'responsable_persons'),
					$this->getExtDbVal($pm,'name')
				));
			}			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
		
		return $inserted_ar;
	}
	
	public function update($pm){
		//throw new Exception("responsable_persons=".$this->getExtDbVal($pm,'responsable_persons'));
		$this->getDbLinkMaster()->query("BEGIN");		
		try{		
			parent::update($pm);

			if ($this->getExtVal($pm,'responsable_persons')){
				$resp = json_decode($this->getExtVal($pm,'responsable_persons'));
				
				if ($this->getExtVal($pm,'name')){
					$firm_name = $this->getExtDbVal($pm,'name');
				}
				else{
					//no name
					$ar = $this->getDbLink()->query_first(sprintf(
						"SELECT name FROM clients WHERE id=%d",
						$this->getExtDbVal($pm,'old_id')
					));
					$firm_name = "'".$ar['name']."'";
				}				
				
				$this->getDbLinkMaster()->query(sprintf("DELETE FROM contacts WHERE parent_id=%d AND parent_type = 'clients'",
					$this->getExtDbVal($pm,'old_id')
				));
			
				$this->getDbLinkMaster()->query(sprintf("SELECT contacts_add_persons(
						%d,'clients'::data_types,1,
						json_build_object(
							'responsable_persons',%s::json,
							'name',%s
						)
					)",
					$this->getExtDbVal($pm,'old_id'),
					$this->getExtDbVal($pm,'responsable_persons'),
					$firm_name
				));
			}			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}
	
</xsl:template>

</xsl:stylesheet>
