<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'ExpertiseProlongation'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	private function calc_date($contractIdDb,$dateTypeDb,$dayCountDb){
		$ar = $this->getDbLink()->query_first(sprintf(
		"WITH
		contr AS (SELECT
				app.office_id AS office_id,
				ct.work_end_date
			FROM contracts ct
			LEFT JOIN applications app ON app.id=ct.application_id
			WHERE ct.id=%d
		)
		SELECT contracts_work_end_date(
			(SELECT office_id FROM contr),
			%s,
			(SELECT work_end_date FROM contr),
			%d
		) AS contact_work_end_date",
		$contractIdDb,
		$dateTypeDb,
		$dayCountDb
		));
	
		return $ar['contact_work_end_date'];
	}

	public function calc_work_end_date($pm){
		$d = $this->calc_date(
			$this->getExtDbVal($pm,'contract_id'),
			$this->getExtDbVal($pm,'date_type'),
			$this->getExtDbVal($pm,'day_count')
		);
	
		$this->addModel(new ModelVars(
			array('id'=>'Result_Model',
				'values'=>array(new Field('work_end_date',DT_DATE,array('value'=>$d)))
				)
			)
		);	
	}

	public function insert($pm){
		if($_SESSION['role_id']!='admin'){
			//auto calc
			$pm->setParamValue(
				'new_end_date',
				$this->calc_date(
					$this->getExtDbVal($pm,'contract_id'),
					$this->getExtDbVal($pm,'date_type'),
					$this->getExtDbVal($pm,'day_count')
				)
			);
			$pm->setParamValue('employee_id',json_decode($_SESSION['employees_ref'])->keys->id);
		}
		else{
			if (!$pm->getParamValue('employee_id')){
				$pm->setParamValue('employee_id',json_decode($_SESSION['employees_ref'])->keys->id);
			}
			if (!$pm->getParamValue('new_end_date')){
				$pm->setParamValue(
					'new_end_date',
					$this->calc_date(
						$this->getExtDbVal($pm,'contract_id'),
						$this->getExtDbVal($pm,'date_type'),
						$this->getExtDbVal($pm,'day_count')
					)
				);			
			}
		}
		parent::insert($pm);
	}
	
</xsl:template>

</xsl:stylesheet>
