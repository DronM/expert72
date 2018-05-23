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

require_once(ABSOLUTE_PATH.'functions/ExtProg.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	//php /var/www/expert72/functions/regl_get_payments.php
	
	public function get_from_1c($pm){
		$xml = NULL;
		$from = $pm->getParamValue('date_from')? $this->getExtVal($pm,'date_from') : mktime();//strtotime('2018-05-17')
		$to = $pm->getParamValue('date_to')? $this->getExtVal($pm,'date_to') : mktime();
		ExtProg::get_payments($from,$to,$xml);
		
		if ($xml &amp;&amp; $xml->rec &amp;&amp; $xml->rec->count()){
			$this->getDbLinkMaster()->query(sprintf(
				"DELETE FROM client_payments WHERE pay_date BETWEEN '%s' AND '%s'",
				date('Y-m-d',$from),
				date('Y-m-d',$to)
			));
			$q = 'INSERT INTO client_payments (contract_id, pay_date, total,pay_docum_date,pay_docum_number) VALUES ';
			/**
			 * contract_ext_id
			 * contract_name
			 * pay_date
		 	 * total
		 	 * pay_docum_date
		 	 * pay_docum_number
		 	 */
		 	$q_ins = '';		
			foreach($xml->rec as $payment){
				$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT contracts_find('%s','%s','%s'::date,'%s'::date,'%s') AS contract_id",
					(string)$payment->contract_ext_id,
					(string)$payment->contract_number,
					(string)$payment->contract_date,
					(string)$payment->pay_docum_date,
					(string)$payment->pay_docum_number
				));
				if (is_array($ar) &amp;&amp; count($ar) &amp;&amp; intval($ar['contract_id'])){
					$q_ins.= ($q_ins=='')? '':',';
					$q_ins.= sprintf(
						"(%d,'%s',%f)",
						intval($ar['contract_id']),
						(string)$payment->pay_date,
						(float)$payment->total
					);
				}
				else{
					$this->getDbLinkMaster()->query(sprintf(
					"INSERT INTO mail_for_sending
					(to_addr,to_name,body,subject,email_type)
					SELECT
						email,
						name_full,
						'При загрузке оплаты из 1с от %s на сумму %f, не смогли найти контракт %s от %s',
						'Ошибка загрузки оплат',
						'new_remind'::email_types
					FROM users
					WHERE id=4
					",
					date('d/m/Y',strtotime((string)$payment->pay_date)),
					(float)$payment->total,
					(string)$payment->contract_number,
					date('d/m/Y',strtotime((string)$payment->contract_date))
					));
				}
			}
			if (strlen($q_ins))
				$this->getDbLinkMaster()->query($q.$q_ins);
		}
	}
</xsl:template>

</xsl:stylesheet>
