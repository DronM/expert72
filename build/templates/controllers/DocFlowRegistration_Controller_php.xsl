<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowRegistration'"/>
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
require_once(USER_CONTROLLERS_PATH.'DocFlowExamination_Controller.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public function register($pm){
		if (!$pm->getParamValue("close_date_time") || $_SESSION['role_id']!='admin'){
			$close_date_time = 'now()';
		}
		else{
			$close_date_time = $this->getExtDbVal($pm,'close_date_time');	
		}
		$this->getDbLinkMaster()->query(sprintf(
			"UPDATE	doc_flow_registrations
			SET
				close_date_time=%s,
				comment_text=%s,
				closed=TRUE
			WHERE id=%d",				
			$close_date_time,
			$this->getExtDbVal($pm,'comment_text'),
			$this->getExtDbVal($pm,'id')
		));
	}

	private function send_email($regId){
		$q_id = $this->getDbLink()->query(sprintf(
			"SELECT
				att.file_id,
				att.file_name,						
				sub.subject,
				sub.content,
				string_agg(substr(sub.email,2,length(sub.email)-2),';') AS email
			FROM
			(SELECT
				doc_flow_out.id,
				doc_flow_out.subject,
				doc_flow_out.content,
				array_to_string(
					regexp_matches(
						json_array_elements(
							(doc_flow_out.to_addr_names->>'contacts')::json->'rows'
						)->'fields'->>'name',
						'(&lt;.*@{1}.*.{1}.*>)$'
					),
					',',''
				) AS email
			FROM doc_flow_out
			WHERE doc_flow_out.id=(
					SELECT (t.subject_doc->'keys'->>'id')::int
					FROM doc_flow_registrations t
					WHERE t.id=%d
				)
			) AS sub
			LEFT JOIN doc_flow_attachments AS att ON att.doc_id=sub.id AND att.doc_type='doc_flow_out'
			GROUP BY att.file_id,sub.subject,sub.content",
		$regId
		));
		$mail_id = 0;
		$att_dir = '';
		while($ar = $this->getDbLink()->fetch_array($q_id)){
			if (!$mail_id){
				//email
				$mail_id = EmailSender::addEMail(
					$this->getDbLinkMaster(),
					EMAIL_FROM_ADDR,EMAIL_FROM_NAME,
					$ar['email'],'',
					EMAIL_FROM_ADDR,EMAIL_FROM_NAME,
					EMAIL_FROM_ADDR,
					$ar['subject'],
					$ar['content'],
					'out_mail'			
				);
				if ($ar['file_id']){
					$att_dir = OUTPUT_PATH.'mail_'.$mail_id;
					mkdir($att_dir);
				}
			}
			if (file_exists($fl=DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$ar['file_id'])){
				symlink ($fl, $att_dir.DIRECTORY_SEPARATOR. $ar['file_name']);
				EmailSender::addAttachment(
					$this->getDbLinkMaster(),
					$mail_id,
					DIRECTORY_SEPARATOR. $ar['file_name']
				);
			}
		}
	}
	
	public function insert($pm){
		$this->getDbLinkMaster()->query("BEGIN");
		try{
			$ar_id = parent::insert($pm);
			
			$subject_doc = json_decode($pm->getParamValue('subject_doc'));
			if ($subject_doc
			&amp;&amp;$subject_doc->dataType
			&amp;&amp;$subject_doc->dataType=='doc_flow_out'
			&amp;&amp;$subject_doc->keys->id
			){
				$ar_st = $this->getDbLink()->query_first(sprintf(
				"SELECT
					CASE
						WHEN doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int THEN 'waiting_for_contract'::application_states
						WHEN doc_flow_type_id=(pdfn_doc_flow_types_app_resp_return()->'keys'->>'id')::int THEN 'returned'::application_states
						WHEN doc_flow_type_id=(pdfn_doc_flow_types_contr_wait_pay()->'keys'->>'id')::int THEN 'waiting_for_pay'::application_states
						WHEN doc_flow_type_id=(pdfn_doc_flow_types_contr_expertise()->'keys'->>'id')::int THEN 'expertise'::application_states
						WHEN doc_flow_type_id=(pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int THEN 'closed'::application_states
						ELSE NULL
					END AS app_state 
				FROM doc_flow_out
				WHERE id=%d",
				intval($subject_doc->keys->id)
				));
				
				if (count($ar_st) &amp;&amp; !is_null($ar_st['app_state'])){
					//смена статуса заявления
					$ar = $this->getDbLink()->query_first(sprintf("
					SELECT
						doc_flow_in.id AS doc_flow_in_id,
						exam.id AS examination_id,
						reg.employee_id,
						reg.date_time,
						doc_flow_out.to_application_id
					FROM doc_flow_registrations AS reg
					LEFT JOIN doc_flow_out ON doc_flow_out.id=(reg.subject_doc->'keys'->>'id')::int AND reg.subject_doc->>'dataType'='doc_flow_out'
					LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
					LEFT JOIN doc_flow_examinations AS exam ON doc_flow_in.id=(exam.subject_doc->'keys'->>'id')::int AND exam.subject_doc->>'dataType'='doc_flow_in'
					WHERE
						reg.id=%d
						AND doc_flow_out.to_application_id IS NOT NULL				
					",
					$ar_id['id']
					));
				
					if (count($ar)){
						if ($ar['examination_id']){
							$contr = new DocFlowExamination_Controller($this->getDbLinkMaster());
							$contr->setResolved(
								$ar['employee_id'],
								'NULL',
								"'".$ar['date_time']."'",
								"'".$ar_st['app_state']."'",
								$ar['examination_id']
							);
						}
						else{
							//нет рассмотрения, но нужно сменить статус!
							$ar_dt = $this->getDbLinkMaster()->query_first(sprintf("
							INSERT INTO application_processes (
								application_id,
								date_time,
								state,
								user_id,
								end_date_time
							)
							VALUES (
								%d,
								(SELECT
								greatest(
									(SELECT t.date_time FROM doc_flow_registrations t WHERE t.id=%d),
									app_proc.date_time+'1 second'::interval
								)
								FROM application_processes AS app_proc
								WHERE app_proc.application_id=%d
								ORDER BY app_proc.date_time DESC
								LIMIT 1),
								%s,
								(SELECT user_id FROM employees WHERE id=%d),
								NULL
							)",
							$ar['to_application_id'],
							$ar_id['id'],
							$ar['to_application_id'],
							"'".$ar_st['app_state']."'",
							$ar['employee_id']
							));
							
						}
					}
				
				}
			}			
			
			
			/*
			$state = $this->getExtVal($pm,'application_resolution_state');
			if ($state){
			}
			*/
			
			$this->send_email($ar_id['id']);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
		
	}
	
</xsl:template>

</xsl:stylesheet>
