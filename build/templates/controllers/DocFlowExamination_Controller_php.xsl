<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowExamination'"/>
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
require_once('common/file_func.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public function setResolved($emplForDb,$resolutionForDb,$closeDateTimeForDb,$applicationResolutionStateForDb,$examinationIdForDb){
		try{
			
			$this->getDbLinkMaster()->query('BEGIN');
			
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
			"UPDATE doc_flow_examinations
			SET
				resolution=%s,
				close_date_time=%s,
				application_resolution_state=%s,
				close_employee_id=%d,
				closed=TRUE
			WHERE id=%d
			RETURNING subject_doc",
			$resolutionForDb,
			$closeDateTimeForDb,
			$applicationResolutionStateForDb,
			$emplForDb,
			$examinationIdForDb
			));
			
			if($applicationResolutionStateForDb=="'filling'"){
				
				$subject_doc = json_decode($ar['subject_doc']);
				if ($subject_doc &amp;&amp; $subject_doc->dataType=='doc_flow_in'){
					$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT
						from_application_id AS application_id
					FROM doc_flow_in
					WHERE id=%d",
					intval($subject_doc->keys->id)
					));
					
					if (count($ar)){
					
						//Delete PDF Zip
						Application_Controller::removeAllZipFile($ar['application_id']);
						Application_Controller::removePDFFile($ar['application_id']);
					
						//Удалить заявление
						if (file_exists($dir =
								FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
								Application_Controller::APP_PRINT_PREF)
						){
							rrmdir($dir);
						}	
						if (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp;
						file_exists($dir =
								FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
								Application_Controller::APP_PRINT_PREF)
						){
							rrmdir($dir);
						}	
						$ar = $this->getDbLinkMaster()->query(sprintf(
						"UPDATE applications
						SET
							filled_percent = 92,
							app_print_expertise = NULL,
							app_print_cost_eval = NULL,
							app_print_modification = NULL,
							app_print_audit = NULL,
							cost_eval_validity_simult = CASE WHEN cost_eval_validity_simult IS NULL THEN NULL ELSE FALSE END
						WHERE id=%d",
						$ar['application_id']
						));
						
					}
				}
			}
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}
	}

	public function resolve($pm){
		$in_empl = $pm->getParamValue('close_employee_id');
		$this->setResolved(
			(isset($in_empl) &amp;&amp; intval($in_empl)>0)? $this->getExtDbVal($pm,'close_employee_id') : json_decode($_SESSION['employees_ref'])->keys->id,
			$this->getExtDbVal($pm,'resolution'),
			($pm->getParamValue('close_date_time'))? $this->getExtDbVal($pm,'close_date_time') : 'now()',
			($pm->getParamValue('application_resolution_state'))? $this->getExtDbVal($pm,'application_resolution_state') : 'NULL',
			$this->getExtDbVal($pm,'id')
		);
		/*
		try{
			$in_empl = $pm->getParamValue('close_employee_id');
			
			$this->getDbLinkMaster()->query('BEGIN');
			
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
			"UPDATE doc_flow_examinations
			SET
				resolution=%s,
				close_date_time=%s,
				application_resolution_state=%s,
				close_employee_id=%d,
				closed=TRUE
			WHERE id=%d
			RETURNING subject_doc",
			$this->getExtDbVal($pm,'resolution'),
			($pm->getParamValue('close_date_time'))? $this->getExtDbVal($pm,'close_date_time') : 'now()',
			($pm->getParamValue('application_resolution_state'))? $this->getExtDbVal($pm,'application_resolution_state') : 'NULL',
			(isset($in_empl) &amp;&amp; intval($in_empl)>0)? $this->getExtDbVal($pm,'close_employee_id') : json_decode($_SESSION['employees_ref'])->keys->id,
			$this->getExtDbVal($pm,'id')
			));
			
			if($pm->getParamValue('application_resolution_state')=='filling'){
				
				$subject_doc = json_decode($ar['subject_doc']);
				if ($subject_doc &amp;&amp; $subject_doc->dataType=='doc_flow_in'){
					$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT
						from_application_id AS application_id
					FROM doc_flow_in
					WHERE id=%d",
					intval($subject_doc->keys->id)
					));
					
					if (count($ar)){
					
						//Delete PDF Zip
						Application_Controller::removeAllZipFile($ar['application_id']);
						Application_Controller::removePDFFile($ar['application_id']);
					
						//Удалить заявление
						if (file_exists($dir =
								FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
								Application_Controller::APP_PRINT_PREF)
						){
							rrmdir($dir);
						}	
						if (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp;
						file_exists($dir =
								FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
								Application_Controller::APP_PRINT_PREF)
						){
							rrmdir($dir);
						}	
						
					}
				}
			}
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}
		*/
	}

	public function unresolve($pm){
		$this->getDbLinkMaster()->query(sprintf(
		"UPDATE doc_flow_examinations
		SET
			close_date_time=NULL,
			application_resolution_state = NULL,
			close_employee_id=NULL,
			closed=FALSE
		WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		$pm_obj = $this->getPublicMethod("get_object");
		$pm_obj->setParamValue('id',$pm->getParamValue('id'));
		$this->get_object($pm_obj);
	}

	public function return_app_to_correction($pm){
		$this->getDbLinkMaster()->query(sprintf(
		"INSERT INTO application_corrections
		(application_id, date_time, user_id, end_date_time, doc_flow_examination_id)
		(SELECT
			doc_flow_in.from_application_id,
			now(),
			%d,
			ex.end_date_time,
			ex.id
		FROM doc_flow_examinations AS ex
		LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
		WHERE ex.id=%d
		)",
		$_SESSION['user_id'],
		$this->getExtDbVal($pm,'id')
		));
	}
	
</xsl:template>

</xsl:stylesheet>
