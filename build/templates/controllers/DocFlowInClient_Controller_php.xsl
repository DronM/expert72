<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowInClient'"/>
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
	public function get_file($pm){
		$user_constr = ($_SESSION['role_id']=='client')?
				(" AND user_id=".$_SESSION['user_id']) : '';
				
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				files
			FROM doc_flow_in_client
			WHERE id=%d".$user_constr,
			$this->getExtDbVal($pm,'doc_id')
		));
		if (!count($ar) || !count($files=json_decode($ar['files']))){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		$file_id = $this->getExtVal($pm,'file_id');
		$new_files = [];
		$found = FALSE;
		$file_name = NULL;
		foreach($files as $file){
			if ($file->file_id==$file_id){
				$file_name = $file->file_name;
				$found = TRUE;
			}
			else{
				array_push($new_files,$file);
			}
		}
		if (!$found ||
			(!file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$file_id)
			&amp;&amp; ( defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN') &amp;&amp; !file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$file_id) )
			) 
		){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
	
		$mime = getMimeTypeOnExt($file_name);
		ob_clean();
		downloadFile($fl, $mime,'attachment;',$file_name);
		return TRUE;	
	}


	public function set_viewed($pm){
		if ($_SESSION['role_id']=='client'){
			//check
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					user_id=%d AS check_passed
				FROM doc_flow_in_client
				WHERE id=%d",
				$_SESSION['user_id'],
				$this->getExtDbVal($pm,'doc_id')				
			));
			if (!count($ar) || $ar['check_passed']!='t'){
				throw new Exception('Wrong user app!');
			}
			
			$this->getDbLinkMaster()->query(sprintf(
				"UPDATE doc_flow_in_client
				SET
					viewed=TRUE,
					viewed_dt=now()
				WHERE id=%d",
				$this->getExtDbVal($pm,'doc_id')
			));
			
		}
		
		$this->addModel(self::get_unviwed_count_model($this->getDbLink()));
	}
	public static function get_unviwed_count_model($dbLink){
		$ar = $dbLink->query_first(sprintf(
			"SELECT
				count(*) AS cnt
			FROM doc_flow_in_client
			WHERE NOT viewed AND user_id=%d",
			$_SESSION['user_id']
		));
		$cnt = 0;
		if (count($ar)){
			$cnt = intval($ar['cnt']);
		}
		$model = new ModelVars(
			array('name'=>'UnviewedCount_Model',
				'id'=>'UnviewedCount_Model',
				'sysModel'=>TRUE,
				'values'=>array(
					new Field('cnt',DT_STRING,
						array('value'=>$cnt))
				)
			)
		);
		return $model;		
	}
	
	public function update($pm){
		$reg_number_out = $this->getExtDbVal($pm,'reg_number_out');
		if ($pm->getParamValue('reg_number_out')){
			$this->getDbLinkMaster()->query(sprintf(
			"SELECT doc_flow_in_client_reg_numbers_insert(%d,%s)",
			$this->getExtDbVal($pm,'old_id'),
			$reg_number_out
			));
		}
	}
	
</xsl:template>

</xsl:stylesheet>
