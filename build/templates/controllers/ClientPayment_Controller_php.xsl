<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'ClientPayment'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once('functions/ExtProg.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public function get_from_1c($pm){
		$xml = NULL;
		$from = $this->getExtVal('date_from')? $this->getExtVal('date_from') : mktime();
		$to = $this->getExtVal('date_to')? $this->getExtVal('date_to') : mktime();
		ExtProg::get_payments($from,$to,$xml);
		
		if ($xml &amp;&amp; $xml->rec &amp;&amp; $xml->rec->count()){
			$this->getDbLinkMaster()->query(sprintf(
				"DELETE FROM client_payments WHERE pay_date BETWEEN '%s' AND '%s'",
				date('Y-m-d',$d_from),
				date('Y-m-d',$d_to)
			));
			$q = 'INSERT INTO client_payments (contract_id, pay_date, total) VALUES %s';
			/**
			 * contract_ext_id
			 * contract_name
			 * pay_date
		 	 * total
		 	 */
		 	$q_ins = '';		
			foreach($xml->rec as $payment){
				$q_ins.= ($q_ins=='')? '':',';
				$q_ins.= sprintf(
					"(contracts_find('%s','%s','%s'),'%s',%f)",
					(string)$payment->contract_ext_id,
					(string)$payment->contract_number,
					(string)$payment->contract_date,
					(string)$payment->pay_date,
					(float)$payment->total
				);
			}
			$this->getDbLinkMaster()->query($q.$q_ins);
		}
	}
</xsl:template>

</xsl:stylesheet>
