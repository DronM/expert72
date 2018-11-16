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

require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');
require_once(USER_CONTROLLERS_PATH.'DocFlow_Controller.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{

	const ER_STORAGE_FILE_NOT_FOUND = 'Файл не найден!@1001';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	private function get_file_on_type($pm,$isSig){
		$user_constr = ($_SESSION['role_id']=='client')?
				(" AND user_id=".$_SESSION['user_id']) : '';
				
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				att_f.file_id,
				att_f.file_name,
				att_f.file_path,
				doc_flow_in_client.application_id
			FROM doc_flow_in_client
			LEFT JOIN doc_flow_attachments AS att_f ON att_f.doc_type='doc_flow_out' AND att_f.doc_id=doc_flow_in_client.doc_flow_out_id
			WHERE doc_flow_in_client.id=%d AND att_f.file_id=%s".$user_constr,
			$this->getExtDbVal($pm,'doc_id'),
			$this->getExtDbVal($pm,'file_id')
		));
		if (!count($ar) || !$ar['application_id']){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		
		//
		$rel_file = Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				($ar['file_path']? $ar['file_path'] : DocFlow_Controller::getDefAppDir('out') ) .DIRECTORY_SEPARATOR.
				$ar['file_id'].($isSig? '.sig':'');
		if (
			!file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_file)
			&amp;&amp; ( defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; !file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_file) )
		){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
	
		$mime = getMimeTypeOnExt($ar['file_name']);
		ob_clean();
		downloadFile($fl, $mime,'attachment;',$ar['file_name'].($isSig? '.sig':''));
		return TRUE;	
	}

	public function get_file($pm){
		return $this->get_file_on_type($pm,FALSE);
	}
	public function get_file_sig($pm){
		return $this->get_file_on_type($pm,TRUE);
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
		
		$this->addModel(self::get_unviwed_count_model($this->getDbLinkMaster()));
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
	
	public function get_object($pm){
		parent::get_object($pm);
		
		//extra model
		$m = new ApplicationDocFolder_Model($this->getDbLink());
		$m->select();
		$this->addModel($m);
	}
	
</xsl:template>

</xsl:stylesheet>
