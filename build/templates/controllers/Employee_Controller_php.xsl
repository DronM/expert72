<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Employee'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once('common/downloader.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	private function upload_file($pm){
		if (
		(
			!$pm->getParamValue('old_id')
			|| ($_SESSION['role_id']=='admin' || intval(json_decode($_SESSION['employees_ref'])->keys->id)==intval($pm->getParamValue('old_id')))
		)
		&amp;&amp;
		(isset($_FILES['picture_file']) &amp;&amp; is_array($_FILES['picture_file']['name']) &amp;&amp; count($_FILES['picture_file']['name']))
		){
			$pm->setParamValue('picture', pg_escape_bytea($this->getDbLink()->link_id,file_get_contents($_FILES['picture_file']['tmp_name'][0])) );
			$pm->setParamValue('picture_info',
				sprintf('{"name":"%s","id":"1","size":"%s"}',
				$_FILES['picture_file']['name'][0],
				filesize($_FILES['picture_file']['tmp_name'][0])
				)
			);
			
		}
	}

	public function insert($pm){
		$this->upload_file($pm);
		parent::insert($pm);
	}
	
	public function update($pm){
		$this->upload_file($pm);
		parent::update($pm);
	}

	public function delete_picture($pm){
		$this->getDbLinkMaster()->query(sprintf(
			"UPDATE employees
			SET
				picture=NULL,
				picture_info=NULL
			WHERE id=%d",
			intval(json_decode($_SESSION['employees_ref'])->keys->id)
		));
	}
	public function download_picture($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				picture,
				picture_info
			FROM employees
			WHERE id=%d",
			intval(json_decode($_SESSION['employees_ref'])->keys->id)
		));
		
		if (!is_array($ar) || !count($ar)){
			throw new Exception('Doc not found!');
		}
		
		$picture_info = json_decode($ar['picture_info']);
		
		$data = pg_unescape_bytea($ar['picture']);
		ob_clean();
		header('Content-Length: '.$picture_info->size);
		header('Connection: close');
		header('Content-Type: ' . getMimeTypeOnExt($picture_info->name));
		header('Content-Disposition: attachment;filename="' . $picture_info->name . '";');
		
		echo $data;
		
		return TRUE;
		
	}
	
</xsl:template>

</xsl:stylesheet>
