<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowOut'"/>
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

	public function remove_file($pm){
		$this->remove_afile($pm,'out');
	}

	public function delete($pm){
		$this->delete_attachments($pm,'out');
	}
	
	public function get_next_num($pm){
		$this->get_next_num_on_type('out', $this->getExtDbVal($pm,'doc_flow_type_id'));
	}

	public function get_next_contract_number($pm){
		$this->addNewModel(
			sprintf(
			"SELECT
				contracts_next_number(
					CASE
					WHEN applications.expertise_type IS NOT NULL THEN 'pd'::document_types
					WHEN applications.cost_eval_validity THEN 'cost_eval_validity'::document_types
					WHEN applications.modification THEN 'modification'::document_types
					WHEN applications.audit THEN 'audit'::document_types						
					END,
					now()::date
				) AS num
			FROM applications
			WHERE id=%d",
			$this->getExtDbVal($pm,'application_id')
			),
		'NewNum_Model'
		);		
	}
	
	public function get_app_state($pm){
		$this->addNewModel(
			sprintf(
				"SELECT
					doc_flow_out.to_application_id,
					st.state
				FROM doc_flow_out
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=doc_flow_out.to_application_id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time				
				WHERE doc_flow_out.id=%d",
				$this->getExtDbVal($pm,'id')
			),
			'AppState_Model'
		);
	}
	
	private function update_contract_data($pm){
		$fld = NULL;
		$app_id = 0;
		if ($pm->getParamValue('expertise_result')){
			$fld = sprintf('expertise_result=%s',$this->getExtDbVal($pm,'expertise_result'));
		}
		if ($pm->getParamValue('expertise_reject_type_id') &amp;&amp; $this->getExtDbVal($pm,'expertise_reject_type_id')>0){
			$fld = (is_null($fld))? '':($fld.',');
			$fld.= sprintf('expertise_reject_type_id=%d',$this->getExtDbVal($pm,'expertise_reject_type_id'));
		}
		
		if (!is_null($fld)){
			if ($pm->getParamValue('to_application_id')){
				$app_id = $this->getExtDbVal($pm,'to_application_id');
			}
			else if ($pm->getParamValue('old_id')){
				$app_id = $this->getDbLink()->query_first_col(sprintf("SELECT to_application_id FROM doc_flow_out WHERE id=%d",
				$this->getExtDbVal($pm,'old_id')
				));
			
			}
			if ($app_id){
				$this->getDbLinkMaster()->query(sprintf("UPDATE contracts SET %s WHERE application_id=%d",
				$fld,$app_id
				));
			}
		}
	}


	public function insert($pm){
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			$this->update_contract_data($pm);
			
			parent::insert($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}
	
	public function update($pm){
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			$this->update_contract_data($pm);
			
			parent::update($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}

</xsl:template>

</xsl:stylesheet>
