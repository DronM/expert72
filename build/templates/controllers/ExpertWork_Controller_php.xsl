<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'ExpertWork'"/>
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
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	private function delete_files_on_id($id){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				files
			FROM expert_works
			WHERE id=%d",
		$id
		));
		$files = json_decode($ar['files']);
		foreach($files as $file){
			if (file_exists($fl=DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$file->id)){
				unlink($fl);
			}
		}				
	}

	private function upload_file($pm){
		if (isset($_FILES['file_data'])){
		//throw new Exception("file_data set!!!");
			if ($this->getExtVal($pm,'old_id')){
				$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT
						files
					FROM expert_works
					WHERE id=%d",
				$this->getExtVal($pm,'old_id')
				));
				$files = json_decode($ar['files']);
				if(!isset($files)){
					$files = [];
				}
			}
			else{
				$files = [];
			}
			
			$i = 0;
			foreach($_FILES['file_data']['tmp_name'] as $file_name){
				$file_id = md5(uniqid().$file_name);
				$fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR. $file_id;
				move_uploaded_file($file_name, $fl);
				array_push($files,
					json_decode(sprintf(
					'{"name":"%s","id":"%s","size":"%s","date":"%s"}',
						$_FILES['file_data']['name'][$i],
						$file_id,
						filesize($fl),
						date('Y-m-d H:i:s')
					))
				);
				$i++;
			}
						
			$pm->setParamValue('files',json_encode($files));
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

	public function delete($pm){
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			$this->delete_files_on_id($this->getExtDbVal($pm,'id'));
			
			parent::delete($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
		
	}
	
	public function download_file($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT 
				r.files->>'id' AS file_id,
				r.files->>'name' AS file_name
	
			FROM (
			SELECT
				jsonb_array_elements(files) AS files
			FROM expert_works
			WHERE
				contract_id=%d AND section_id=%d AND expert_id=%d
				AND files IS NOT NULL
				AND %s = ANY (ARRAY(SELECT f->>'id' FROM jsonb_array_elements(files) AS f))
			) AS r
			WHERE r.files->>'id'=%s",
		$this->getExtDbVal($pm,'contract_id'),
		$this->getExtDbVal($pm,'section_id'),
		$this->getExtDbVal($pm,'expert_id'),
		$this->getExtDbVal($pm,'file_id'),
		$this->getExtDbVal($pm,'file_id')
		));
		if (count($ar) &amp;&amp; file_exists($fl=DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$ar['file_id'])){
			$mime = getMimeTypeOnExt($ar['file_name']);
			ob_clean();
			downloadFile($fl, $mime,'attachment;',$ar['file_name']);
			return TRUE;
		}
	}

	public function delete_file($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				files
			FROM expert_works
			WHERE
				contract_id=%d AND section_id=%d AND expert_id=%d AND files IS NOT NULL
				AND %s =ANY (ARRAY(SELECT f->>'id' FROM jsonb_array_elements(files) AS f))",
		$this->getExtDbVal($pm,'contract_id'),
		$this->getExtDbVal($pm,'section_id'),
		$this->getExtDbVal($pm,'expert_id'),
		$this->getExtDbVal($pm,'file_id')
		));
		if (count($ar)){		
			$files = json_decode($ar['files']);
			$new_files = [];
			$file_id = $this->getExtVal($pm,'file_id');
			foreach($files as $file){
				if ($file->id!=$file_id){
					array_push($new_files,$file);
				}
			}
			if (file_exists($fl=DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$file_id)){
				$new_db_files = (count($new_files))? ("'".json_encode($new_files)."'") : 'NULL';
				unlink($fl);
				$this->getDbLinkMaster()->query(sprintf(
					"UPDATE expert_works
					SET files=%s
					WHERE contract_id=%d AND section_id=%d AND expert_id=%d",
				$new_db_files,
				$this->getExtDbVal($pm,'contract_id'),
				$this->getExtDbVal($pm,'section_id'),
				$this->getExtDbVal($pm,'expert_id')				
				));
			}
		}
	}

</xsl:template>

</xsl:stylesheet>
