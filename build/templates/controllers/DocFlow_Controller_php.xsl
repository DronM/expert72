<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlow'"/>
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
require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{

	const ER_STORAGE_FILE_NOT_FOUND = 'Файл не найден!@1001';
	const ER_INVALID_DOC_FLOW_TYPE = 'Invalid document type!@1002';
	const ER_EMPLOYEE_NOT_DEFINED = 'К пользователю не привязан сотрудник!@1003';
	const ER_ALLOWED_TO_ADMIN = 'Действие разрешено только администратору!@1004';
	const ER_NOT_FOUND = 'Document not found!';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public static function getDefAppDir($type){
		return ($type=='out')? 'Исходящие':'Входящие';
	}

	public function delete_attachments($pm,$type){
		$old_state = $this->get_state($this->getExtDbVal($pm,'id'),$type);
		if ($old_state!='dirt_copy' &amp;&amp; $_SESSION['role_id']!='admin'){
			throw new Exception(self:: ER_ALLOWED_TO_ADMIN);
		}
	
		try{
			$this->getDbLinkMaster()->query("BEGIN");
		
			//**************
			$q_id = $this->getDbLink()->query(sprintf(
				"SELECT
					at.file_id,
					at.file_signed,
					at.file_path,
					out.to_application_id
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out AS out ON at.doc_type='doc_flow_out' AND at.doc_id=out.id
				WHERE doc_id=%d AND doc_type='doc_flow_%s'::data_types",
				$this->getExtDbVal($pm,'id'),
				$type
			));
		
			while($ar = $this->getDbLink()->fetch_array()){
				$fl = NULL;
				if ($ar['to_application_id']){
					//Файл из папки заявления
					$fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'];
				}
				else{
					//Общий документооборот
					$fl = DOC_FLOW_FILE_STORAGE_DIR;
				}
				$fl.= DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id');
			
				if (file_exists($fl)){
					unlink($fl);
				}
				if ($ar['file_signed'] &amp;&amp; file_exists($fl.='.sig')){
					unlink($fl);			
				}
			}			

			$this->getDbLinkMaster()->query(sprintf(
				"DELETE FROM doc_flow_attachments WHERE doc_id=%d AND doc_type='doc_flow_%s'::data_types",
				$this->getExtDbVal($pm,'id'),
				$type
			));			
			//**************
			
			parent::delete($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}		
	}
	
	public function remove_afile($pm,$type){
		
		$state = $this->get_state($id,$type);
		if ($state=='registered' &amp;&amp; $_SESSION['role_id']!='admin'){
			throw new Exception(self::ER_ALLOWED_TO_ADMIN);
		}
		
		$this->getDbLinkMaster()->query('BEGIN');
		try{
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
				"DELETE FROM doc_flow_attachments
				WHERE doc_id=%d AND file_id=%s
				RETURNING file_id,file_signed,doc_type,file_path,file_name",
				$this->getExtDbVal($pm,'doc_id'),
				$this->getExtDbVal($pm,'file_id')
			));
			if (!count($ar)){
				throw new Exception(ER_NOT_FOUND);
			}
			
			$fl = NULL;
			if ($type=='out' &amp;&amp; $ar['doc_type']=='doc_flow_out'){
				$app_ar = $this->getDbLink()->query_first(sprintf(
					"SELECT to_application_id
					FROM doc_flow_out
					WHERE id=%d",
					$this->getExtDbVal($pm,'doc_id')
				));
				if (count($app_ar) &amp;&amp; $app_ar['to_application_id']){
					$fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$app_ar['to_application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'].DIRECTORY_SEPARATOR.$ar['file_id'];
				}
			}
			
			if (!$fl){
				$fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$ar['file_id'];
			}
			
			
			if (file_exists($fl)){
				unlink($fl);
			}
			if ($ar['file_signed'] &amp;&amp; file_exists($fl.='.sig')){
				unlink($fl);			
			}
			
			$this->getDbLinkMaster()->query("COMMIT");
			
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}	
	}
		
	
	public function get_state($id,$type){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT state
			FROM doc_flow_%s_processes
			WHERE doc_flow_%s_id = %d
			ORDER BY date_time DESC
			LIMIT 1",
		$type,$type,
		$id
		));
		return $ar['state'];
	}

	private function get_afile($pm,$sigFile){
		$posf = $sigFile? '.sig':'';
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				at.file_name,
				at.file_path,
				out.to_application_id
			FROM doc_flow_attachments AS at
			LEFT JOIN doc_flow_out AS out ON at.doc_type='doc_flow_out' AND at.doc_id=out.id
			WHERE at.file_id=%s AND at.doc_id=%d",
			$this->getExtDbVal($pm,'file_id'),
			$this->getExtDbVal($pm,'doc_id')
		));
		
		if (!count($ar)){
			throw new Exception(ER_NOT_FOUND);
		}
		
		$fl = NULL;
		if ($ar['to_application_id']){
			//Файл из папки заявления
			$fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
				Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
				$ar['file_path'];
		}
		else{
			//Общий документооборот
			$fl = DOC_FLOW_FILE_STORAGE_DIR;
		}
		$fl.= DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id').$posf;
		
		if (!file_exists($fl)){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
	
		ob_clean();
		downloadFile($fl, 'application/octet-stream','attachment;',$ar['file_name'].$posf);
		return TRUE;	
	}
	
	public function get_file($pm){
		return $this->get_afile($pm,FALSE);
	}

	public function get_file_sig($pm){
		return $this->get_afile($pm,TRUE);
	}
	
	protected function get_next_num_on_type($docFlowType,$typeId){
		$this->addNewModel(
			sprintf("SELECT doc_flow_%s_next_num(%d) AS num",$docFlowType,$typeId),
			'NewNum_Model'
		);
	}
	
</xsl:template>

</xsl:stylesheet>
