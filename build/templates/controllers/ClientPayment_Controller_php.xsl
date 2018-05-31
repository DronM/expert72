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

	//php /var/www/expert72/functions/regl_get_payments.php 2018-05-21 2018-05-22
	//php /var/www/expert72/functions/regl_get_payments.php 2018-05-23 2018-05-23
	
	public function get_from_1c($pm){
		$xml = NULL;
		if ($pm->getParamValue('date_from')){
			$from = $this->getExtVal($pm,'date_from');
		}
		else{
			$ar = $this->getDbLink()->query_first('SELECT bank_day_next(now()::date,-1) AS d');
			$from = strtotime($ar['d']);
		}
		$to = $pm->getParamValue('date_to')? $this->getExtVal($pm,'date_to') : mktime();//mktime()
		ExtProg::get_payments($from,$to,$xml);
		
		if ($xml &amp;&amp; $xml->rec &amp;&amp; $xml->rec->count()){			
			$errors_no_contr = '';		
			$interactive = $pm->getParamValue('interactive');
			$this->getDbLinkMaster()->query('BEGIN');
			try{
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
						"SELECT contracts_find('%s','%s','%s'::date) AS contract_id",
						(string)$payment->contract_ext_id,
						(string)$payment->contract_number,
						(string)$payment->contract_date
					));
					if (is_array($ar) &amp;&amp; count($ar) &amp;&amp; intval($ar['contract_id'])){
						$q_ins.= ($q_ins=='')? '':',';
						$q_ins.= sprintf(
							"(%d,'%s',%f,'%s'::date,'%s')",
							intval($ar['contract_id']),
							(string)$payment->pay_date,
							(float)$payment->total,
							(string)$payment->pay_docum_date,
							(string)$payment->pay_docum_number
						);
					}
					else{
						$errors_no_contr.= ($errors_no_contr=='')? '':PHP_EOL;
						$errors_no_contr.= sprintf('При загрузке оплаты из 1с от %s на сумму %f, не смогли найти контракт %s от %s.',
							date('d/m/Y',strtotime((string)$payment->pay_date)),
							round((float)$payment->total,2),
							(string)$payment->contract_number,
							date('d/m/Y',strtotime((string)$payment->contract_date))
						);
					}
				}
				if (strlen($q_ins)){
					$this->getDbLinkMaster()->query($q.$q_ins);
					$this->getDbLinkMaster()->query("COMMIT");
				}
				if ($interactive!=1 &amp;&amp; strlen($errors_no_contr) ){
					$this->getDbLinkMaster()->query(sprintf(
					"INSERT INTO mail_for_sending
					(to_addr,to_name,body,subject,email_type)
					SELECT
						email,
						name_full,
						%s,
						'Ошибка загрузки оплат',
						'new_remind'::email_types
					FROM users
					WHERE id=4",
					$errors_no_contr
					));
				}				
			}
			catch(Exception $e){
				$this->getDbLinkMaster()->query("ROLLBACK");
				if ($interactive==1){
					throw $e;
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
					round((float)$payment->total,2),
					(string)$payment->contract_number,
					date('d/m/Y',strtotime((string)$payment->contract_date))
					));
				}				
			}
			if ($interactive==1 &amp;&amp; strlen($errors_no_contr) ){
				$errors_no_contr = str_replace(PHP_EOL,' ',$errors_no_contr);
				throw new Exception($errors_no_contr);
			}
		}
	}
	
	public function insert($pm){
		$employees_ref = json_decode($_SESSION['employees_ref']);
		if ($employees_ref &amp;&amp; $employees_ref->keys &amp;&amp; $employees_ref->keys->id){
			$pm->setParamValue('employee_id', $employees_ref->keys->id);
		}
		parent::insert($pm);
	}
	
</xsl:template>

</xsl:stylesheet>
