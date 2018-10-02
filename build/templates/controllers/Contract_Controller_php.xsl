<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Contract'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(FRAME_WORK_PATH.'basic_classes/ModelWhereSQL.php');
require_once(USER_CONTROLLERS_PATH.'DocFlowTask_Controller.php');
require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');

require_once(FRAME_WORK_PATH.'basic_classes/ConditionParamsSQL.php');

require_once('functions/ExtProg.php');
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

	public function get_object($pm){		
		$columns = '*';
		$tb = 'contracts_dialog';
		$fields = $this->getExtVal($pm,'fields');
		if ($fields &amp;&amp; strlen($fields) &amp;&amp; $fields!='null'){
			$aval_fields = ['experts_for_notification'];
			$fields_ar = explode(',',$fields);
			foreach($fields_ar as $field){
				if (array_search($field,$aval_fields)!==FALSE){
					if ($columns=='*'){
						$columns = '';
					}
					else{
						$columns.= ',';
					}
					$columns.= $field;
				}
			}
			if($columns!='*'){
				$tb = 'contracts';
			}
		}
	
		$ar_obj = $this->getDbLink()->query_first(sprintf(
		"SELECT %s FROM %s WHERE id=%d",
		$columns,
		$tb,
		$this->getExtDbVal($pm,'id')
		));
	
		if (!is_array($ar_obj) || !count($ar_obj)){
			throw new Exception("No contract found!");
		
		}
		
		//$deleted_cond = ($_SESSION['role_id']=='client')? "AND deleted=FALSE":"";
		
		$files_q_id = $this->getDbLink()->query(sprintf(
			"SELECT
				adf.file_id,
				adf.document_id,
				adf.document_type,
				adf.date_time,
				adf.file_name,
				adf.file_path,
				adf.file_signed,
				adf.file_size,
				adf.deleted,
				adf.deleted_dt,
				mdf.doc_flow_out_client_id,
				m.date_time AS doc_flow_out_date_time,
				reg.reg_number AS doc_flow_out_reg_number,
				CASE
					WHEN sign.signatures IS NULL THEN
						jsonb_build_array(
							jsonb_build_object(
								'id',adf.file_id,
								'owner',NULL,
								'create_dt',NULL,
								'check_result',NULL,
								'check_time',NULL,
								'error_str',NULL
							)
						)
					ELSE sign.signatures
				END AS signatures
				
			FROM application_document_files AS adf
			LEFT JOIN doc_flow_out_client_document_files AS mdf ON mdf.file_id=adf.file_id
			LEFT JOIN doc_flow_out_client AS m ON m.id=mdf.doc_flow_out_client_id
			LEFT JOIN doc_flow_out_client_reg_numbers AS reg ON reg.doc_flow_out_client_id=m.id
			LEFT JOIN (
				SELECT
					f_sig.file_id,
					jsonb_agg(
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'create_dt',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						)
					) As signatures
				FROM file_signatures AS f_sig
				LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
				LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
				GROUP BY f_sig.file_id
			) AS sign ON sign.file_id=adf.file_id			
			WHERE adf.application_id=%d
			ORDER BY adf.document_type,adf.document_id,adf.file_name,adf.deleted_dt ASC NULLS LAST",
		$ar_obj['application_id']
		));
		
		$documents = NULL;
		if ($ar_obj['documents']){
			$documents_json = json_decode($ar_obj['documents']);
			foreach($documents_json as $doc){
				Application_Controller::addDocumentFiles($doc->document,$this->getDbLink(),$doc->document_type,$files_q_id);
			}
			$ar_obj['documents'] = json_encode($documents_json);
		}
		$values = [];
		foreach($ar_obj as $k=>$v){
			array_push($values,new Field($k,DT_STRING,array('value'=>$v)));
		}
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ContractDialog_Model',
				'values'=>$values
				)
			)
		);		
			
	}
	
	public function get_list($pm){
		if ($_SESSION['role_id']=='admin' || $_SESSION['role_id']=='lawyer' || $_SESSION['role_id']=='boss'){
			parent::get_list($pm);
		}
		else{
			//permissions
			$list_model = $this->getListModelId();
			$model = new $list_model($this->getDbLink());
			
			$where = $this->conditionFromParams($pm,$model);
			if (!$where){
				$where = new ModelWhereSQL();
			}
			DocFlowTask_Controller::set_employee_id($this->getDbLink());
			$where->addExpression('permission_ar',
				sprintf(
				"(for_all_employees
				OR ( main_expert_id=%d OR 'employees%s' =ANY (permission_ar) OR 'departments%s' =ANY (permission_ar)
					OR ( %s AND main_department_id=%d )
				))",
				$_SESSION['employee_id'],
				$_SESSION['employee_id'],
				$_SESSION['department_id'],
				($_SESSION['department_boss']==TRUE)? 'TRUE':'FALSE',
				$_SESSION['department_id']
				)
			);
			
			$from = null; $count = null;
			$limit = $this->limitFromParams($pm,$from,$count);
			$calc_total = ($count>0);
			if ($from){
				$model->setListFrom($from);
			}
			if ($count){
				$model->setRowsPerPage($count);
			}		
			$order = $this->orderFromParams($pm,$model);
			$fields = $this->fieldsFromParams($pm);		
			$model->select(FALSE,$where,$order,
				$limit,$fields,NULL,NULL,
				$calc_total,TRUE
			);
			$this->addModel($model);
		}
	}

	private function get_list_on_type($pm,$documentType){
		$cond_fields = $pm->getParamValue('cond_fields');
		$cond_sgns = $pm->getParamValue('cond_sgns');
		$cond_vals = $pm->getParamValue('cond_vals');
		$cond_ic = $pm->getParamValue('cond_ic');
		$field_sep = $pm->getParamValue('field_sep');
		$field_sep = !is_null($field_sep)? $field_sep:',';
		
		$cond_fields = $cond_fields? $cond_fields.$field_sep : '';
		$cond_sgns = $cond_sgns? $cond_sgns.$field_sep : '';
		$cond_vals = $cond_vals? $cond_vals.$field_sep : '';
		$cond_ic = $cond_ic? $cond_ic.$field_sep : '';
		
		$pm->setParamValue('cond_fields',$cond_fields.'document_type');
		$pm->setParamValue('cond_sgns',$cond_sgns.'e');
		$pm->setParamValue('cond_vals',$cond_vals.$documentType);
		$pm->setParamValue('cond_ic',$cond_ic.'0');
		
		$this->get_list($pm);
	}
	
	public function get_pd_list($pm){
		$this->get_list_on_type($pm,'pd');
	}

	public function get_eng_survey_list($pm){
		$this->get_list_on_type($pm,'eng_survey');
	}
	public function get_cost_eval_validity_list($pm){
		$this->get_list_on_type($pm,'cost_eval_validity');
	}
	public function get_modification_list($pm){
		$this->get_list_on_type($pm,'modification');
	}
	public function get_audit_list($pm){
		$this->get_list_on_type($pm,'audit');
	}

	private function get_data_for_1c($contractId){
		return $this->getDbLink()->query_first(sprintf(
		"SELECT
			'Договор от '||to_char(contr.date_time,'DD.MM.YYYY')||' № '||contr.contract_number AS contract_name,
			'Договор' AS contract_type,
			contr.contract_ext_id,
			contr.contract_number,
			contr.contract_date,
			'Работы по контракту' AS item_1c_descr,
			'Работы по контракту' AS item_1c_descr_full,
			CASE
				WHEN contr.document_type='pd' THEN 'Проведение госудаственной экспертизы проектной документации'
				WHEN contr.document_type='eng_survey' THEN 'Проведение госудаственной экспертизы результатов инженерных изысканий'
				WHEN contr.document_type='cost_eval_validity' THEN 'Проведение проверки достоверности определения сметной стоимости'
				WHEN contr.document_type='modification' THEN 'Проведение модификации'
				WHEN contr.document_type='audit' THEN 'Проведение аудита'
				ELSE ''
			END||' объекта капитального строительства '||app.constr_name||' согласно договора № '||contr.contract_number||
			' от '||to_char(contr.contract_date,'DD.MM.YYYY')
			--kladr_parse_addr(d.constr_address)
			AS item_1c_doc_descr,
			
			coalesce(contr.expertise_cost_budget,0)+coalesce(contr.expertise_cost_self_fund,0) AS total,
			contr.reg_number,
			
			(SELECT
				jsonb_agg(json_build_object('pay_docum_date',pm.pay_docum_date,'pay_docum_number',pm.pay_docum_number))
			FROM client_payments AS pm
			WHERE pm.contract_id=contr.id
			) AS payment,
			
			cl.ext_id AS client_ext_id,
			cl.name AS client_name,
			cl.name_full AS client_name_full,
			cl.inn AS client_inn,
			cl.kpp AS client_kpp,
			cl.ogrn AS client_ogrn,
			cl.okpo AS client_okpo,
			cl.client_type AS client_type,
			kladr_parse_addr(cl.legal_address) AS client_legal_address,
			kladr_parse_addr(cl.post_address) AS client_post_address,
			bank_accounts->'rows' AS client_bank_accounts,
			CASE WHEN contr.expertise_type IS NOT NULL THEN contr.expertise_type::text ELSE contr.document_type::text END AS service_descr
		FROM contracts AS contr
		LEFT JOIN applications AS app ON app.id=contr.application_id		
		LEFT JOIN clients AS cl ON cl.id=contr.client_id
		WHERE contr.id=%d",
		$contractId
		));
	}

	private function set_contract_ext_id($contractId,$contractExtId){
		$this->getDbLinkMaster()->query_first(sprintf(
		"UPDATE contracts
		SET
			contract_ext_id='%s'
		WHERE id=%d",
		$contractExtId,
		$contractId
		));
	}
	private function set_client_ext_id($contractId,$clientExtId){
		$this->getDbLinkMaster()->query_first(sprintf(
		"UPDATE clients
		SET
			ext_id='%s'
		WHERE id=(SELECT t.client_id FROM contracts t WHERE t.id=%d)",
		$clientExtId,
		$contractId
		));
	}

	public function make_order($pm){
		$params = $this->get_data_for_1c($this->getExtDbVal($pm,'id'));
		$params['total'] = $this->getExtDbVal($pm,'total');
		$params['acc_number'] = $this->getExtDbVal($pm,'acc_number');
		if ($params['acc_number']=='null'){
			//не понимает с клиента???
			throw new Exception('Не выбран лицевой счет!');
		}
		
		if (!$params['client_inn'] || !$params['client_kpp']){
			throw new Exception('Не задан ИНН или КПП для контрагента');
		}
		if (!$params['contract_number'] || !$params['contract_date']){
			throw new Exception('Не задан номер или дата контракта!');
		}
		
		$res = [];
		ExtProg::make_order($params,$res);
		
		if (!$params['contract_ext_id'] &amp;&amp; $res['contract_ext_id']){
			$this->set_contract_ext_id($this->getExtDbVal($pm,'id'), $res['contract_ext_id']);
		}

		if (!$params['client_ext_id'] &amp;&amp; $res['client_ext_id']){
			$this->set_client_ext_id($this->getExtDbVal($pm,'id'), $res['client_ext_id']);
		}
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ExtDoc_Model',
				'values'=>array(
					new Field('doc_ext_id',DT_STRING,array('value'=>$res['doc_ext_id'])),
					new Field('doc_number',DT_STRING,array('value'=>$res['doc_number'])),
					new Field('doc_date',DT_DATETIME,array('value'=>$res['doc_date'])),
					new Field('doc_total',DT_FLOAT,array('value'=>$this->getExtVal($pm,'total')))
				)
			)
		));
		//ExtProg::print_order($res['doc_ext_id'],FALSE,array('name'=>'Счет№'.$res['doc_number'].'.pdf','disposition'=>'inline'));
	}
	public function make_akt($pm){
		$params = $this->get_data_for_1c($this->getExtDbVal($pm,'id'));
		if (!$params['client_inn'] || !$params['client_kpp']){
			throw new Exception('Не задан ИНН или КПП для контрагента');
		}
		if (!$params['contract_number'] || !$params['contract_date']){
			throw new Exception('Не задан номер или дата контракта!');
		}
		
		$res = [];
		ExtProg::make_akt($params,$res);
		
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
		"UPDATE contracts
		SET
			contract_ext_id='%s',
			akt_ext_id='%s',
			akt_date='%s',
			akt_number='%s',
			akt_total=%f,
			invoice_ext_id='%s',
			invoice_number='%s',
			invoice_date='%s'
		WHERE id=%d
		RETURNING client_id",
		$res['contract_ext_id'],
		$res['doc_ext_id'],
		$res['doc_date'],
		$res['doc_number'],
		$res['doc_total'],
		$res['invoice_ext_id'],
		$res['invoice_number'],
		$res['invoice_date'],
		$this->getExtDbVal($pm,'id')
		));

		if (!$params['client_ext_id'] &amp;&amp; $res['client_ext_id']){
			$this->getDbLinkMaster()->query(sprintf(
			"UPDATE clients
			SET
				ext_id='%s'
			WHERE id=%d",
			$res['client_ext_id'],
			$ar['client_id']
			));
		}
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ExtDoc_Model',
				'values'=>array(
					new Field('akt_ext_id',DT_STRING,array('value'=>$res['doc_ext_id'])),
					new Field('akt_number',DT_STRING,array('value'=>$res['doc_number'])),
					new Field('akt_date',DT_DATETIME,array('value'=>$res['doc_date'])),
					new Field('akt_total',DT_FLOAT,array('value'=>$res['doc_total'])),
					new Field('invoice_ext_id',DT_STRING,array('value'=>$res['invoice_ext_id'])),
					new Field('invoice_number',DT_STRING,array('value'=>$res['invoice_number'])),
					new Field('invoice_date',DT_DATETIME,array('value'=>$res['invoice_date']))
				)
			)
		));
		//ExtProg::print_akt($res['doc_ext_id'],FALSE,array('name'=>'Акт№'.$res['doc_number'].'.pdf','disposition'=>'inline'));
	}
	
	public function print_akt($pm){
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
		"SELECT
			akt_number,
			akt_ext_id
		FROM contracts
		WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		if (!count($ar)){
			header(HEADER_404);
			
		}
		ExtProg::print_akt($ar['akt_ext_id'],FALSE,array('name'=>'Акт№'.$ar['akt_number'].'.pdf','disposition'=>'inline'));
		return TRUE;
	}
	public function print_invoice($pm){
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
		"SELECT
			invoice_number,
			invoice_ext_id
		FROM contracts
		WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		if (!count($ar)){
			header(HEADER_404);
			
		}
		ExtProg::print_invoice($ar['invoice_ext_id'],FALSE,array('name'=>'СчетФактура№'.$ar['invoice_number'].'.pdf','disposition'=>'inline'));
		return TRUE;
		
	}
	
	public function print_order($pm){
		ExtProg::print_order($this->getExtVal($pm,'order_ext_id'),FALSE,array('name'=>'Счет№'.$this->getExtVal($pm,'order_number').'.pdf','disposition'=>'inline'));
		return TRUE;
	}
	
	public function get_order_list($pm){
		$params = $this->get_data_for_1c($this->getExtDbVal($pm,'id'));
		if (!$params['contract_number'] || !$params['contract_date'] || !$params['client_inn'] || !$params['client_kpp']){
			$field_val = NULL;
		}
		else{
			$res = [];
			ExtProg::get_order_list($params,$res);
		
			if (!$params['contract_ext_id'] &amp;&amp; $res['contract_ext_id']){
				$this->set_contract_ext_id($this->getExtDbVal($pm,'id'), $res['contract_ext_id']);
			}

			if (!$params['client_ext_id'] &amp;&amp; $res['client_ext_id']){
				$this->set_client_ext_id($this->getExtDbVal($pm,'id'), $res['client_ext_id']);
			}
			$field_val = json_encode($res['orders']);
		}		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'OrderList_Model',
				'values'=>array(
					new Field('list',DT_STRING,array('value'=>$field_val))
				)
			)
		));		
	}
	
	public function get_ext_data($pm){
		$res = $this->getDbLink()->query_first(sprintf(
		"SELECT
			akt_ext_id,
			akt_number,
			akt_date,
			akt_total,
			invoice_ext_id,
			invoice_number,
			invoice_date			
		FROM contracts
		WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		
		if (!count($res)){
			throw new Exception('Contract not found!');
		}
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'ExtDoc_Model',
				'values'=>array(
					new Field('akt_ext_id',DT_STRING,array('value'=>$res['akt_ext_id'])),
					new Field('akt_number',DT_STRING,array('value'=>$res['akt_number'])),
					new Field('akt_date',DT_DATETIME,array('value'=>$res['akt_date'])),
					new Field('akt_total',DT_FLOAT,array('value'=>$res['akt_total'])),
					new Field('invoice_ext_id',DT_STRING,array('value'=>$res['invoice_ext_id'])),
					new Field('invoice_number',DT_STRING,array('value'=>$res['invoice_number'])),
					new Field('invoice_date',DT_DATETIME,array('value'=>$res['invoice_date']))
				)
			)
		));
		
	}
	
	public function get_work_end_date($pm){
		$this->addNewModel(
			sprintf(
			"WITH contr AS (SELECT app.office_id AS office_id
				FROM contracts AS contr
				LEFT JOIN applications AS app ON app.id=contr.application_id
				WHERE contr.id=%d
			)
			SELECT
				contracts_work_end_date(
					(SELECT office_id FROM contr),
					%s,
					%s,
					%d
				) AS end_dt,
				contracts_work_end_date(
					(SELECT office_id FROM contr),
					%s,
					%s,
					%d
				) AS work_end_dt				
			",
			$this->getExtDbVal($pm,'contract_id'),
			$this->getExtDbVal($pm,'date_type'),
			$this->getExtDbVal($pm,'work_start_date'),
			$this->getExtDbVal($pm,'expertise_day_count'),
			$this->getExtDbVal($pm,'date_type'),
			$this->getExtDbVal($pm,'work_start_date'),
			$this->getExtDbVal($pm,'expert_work_day_count')
			),
		'Date_Model'
		);		
	}
	
	public function update($pm){
		$for_all_employees = $pm->getParamValue('for_all_employees');
		$permissions = $pm->getParamValue('permissions');
		if(
		$_SESSION['role_id']!='admin'
		&amp;&amp;
		( isset($for_all_employees) || isset($permissions) )
		){
			throw new Exception('Изменение набора прав контракта доступно только администратору!');
		}
		
		parent::update($pm);
	}
	
	public function get_object_inf($pm){
		$this->addNewModel(
			sprintf(
			"SELECT
				t.id,
				t.constr_name,
				kladr_parse_addr(t.constr_address) AS constr_address,
				t.grad_plan_number,
				t.kadastr_number,
				t.area_document,
				app.customer->>'name' AS customer_name,
				(SELECT
					string_agg(a2.contractor_name,', ')
				FROM (SELECT (jsonb_array_elements(app.contractors)->>'name')::text AS contractor_name) AS a2
				) AS contrcator_names,
				t.expertise_result,
				t.reg_number,
				t.expertise_result_date,
				format_date_rus(t.expertise_result_date,FALSE) AS expertise_result_date_descr,
				
				t.document_type
				
			FROM contracts AS t
			LEFT JOIN applications AS app ON app.id=t.application_id
			WHERE t.id=%d",
			$this->getExtDbVal($pm,'id')
			),
		'ObjectData_Model'
		);		
		
		$this->addNewModel(
			sprintf(
			"SELECT rep.* FROM
			(SELECT
				jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'name' AS n,
				jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'value' AS v
			FROM contracts AS t
			LEFT JOIN applications AS app ON app.id=t.application_id
			WHERE t.id=%d) AS rep
			ORDER BY rep.n
			",
			$this->getExtDbVal($pm,'id')
			),
		'FeatureList_Model'
		);		
		
	}
	
	public function get_reestr_expertise($pm){
		$cond = new ConditionParamsSQL($pm,$this->getDbLink());
		$dt_from = $cond->getDbVal('date_time','ge',DT_DATETIME);
		if (!isset($dt_from)){
			throw new Exception('Не задана дата начала!');
		}		
		$dt_to = $cond->getDbVal('date_time','le',DT_DATETIME);
		if (!isset($dt_to)){
			throw new Exception('Не задана дата окончания!');
		}		
		
		$exp_res_cond = '';
		$expertise_result = $cond->getVal('expertise_result','e',DT_STRING);
		if ($expertise_result=='positive'){
			$exp_res_cond.= " AND t.expertise_result='positive'";
		}
		else if ($expertise_result=='negative'){
			$exp_res_cond.= " AND t.expertise_result='negative'";
		}
		
		$model = new RepReestrExpertise_Model($this->getDbLink());
		$model->query(
			sprintf(
			"SELECT
				row_number() OVER (ORDER BY t.expertise_result_date) AS ord,
				
				(SELECT
					string_agg(a2.contractor_name,', ')
				FROM (SELECT (jsonb_array_elements(app.contractors)->>'name')::text AS contractor_name) AS a2
				) AS contrcator_names,
			
				(SELECT
					string_agg(e.n,', ')
	
					FROM (SELECT
						jsonb_array_elements(t.result_sign_expert_list->'rows')->'fields'->'employees_ref'->>'descr' AS n
					) AS e
	
				) AS experts,
				
				t.contract_number||' от '||to_char(t.contract_date,'DD/MM/YY') AS contract,
				
				t.constr_name,
				kladr_parse_addr(t.constr_address) AS constr_address,
				
				(SELECT
					string_agg(rep.n||':'||rep.v,', ')
					FROM (SELECT
						jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'name' AS n,
						jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'value' AS v
					) AS rep
				) AS constr_features,
				
				t.kadastr_number,
				t.grad_plan_number,				
				
				coalesce(app.developer->>'name','')||
				CASE WHEN app.developer->>'name' IS NOT NULL THEN ', ' ELSE '' END||
				coalesce(app.customer->>'name','')
				AS developer_customer,
								
				t.area_document,
				
				CASE
					WHEN t.expertise_result='negative' THEN 'Отрицательое заключение: '||rej.name
					ELSE 'Положительное заключение'
				END AS exeprtise_res_descr,
				
				CASE
					WHEN t.expertise_type='pd' THEN 'ПД'
					WHEN t.expertise_type='eng_survey' THEN 'РИИ'
					WHEN t.expertise_type='pd_eng_survey' THEN 'ПД и РИИ'
					ELSE '-'
				END AS exeprtise_type,
				
				t.reg_number,
				
				to_char(t.expertise_result_date,'DD/MM/YY') AS expertise_result_date,
				
				to_char(t.date_time,'DD/MM/YY') AS date_time,
				
				(SELECT to_char(max(p.pay_date),'DD/MM/YY') FROM client_payments AS p
				WHERE p.contract_id=t.id
				) AS pay_date,
				
				to_char(t.expertise_result_date,'DD/MM/YY') AS expertise_result_ret_date
				
			FROM contracts AS t
			LEFT JOIN applications AS app ON app.id=t.application_id
			LEFT JOIN expertise_reject_types AS rej ON rej.id=t.expertise_reject_type_id
			WHERE t.expertise_result_date BETWEEN %s AND (%s::timestamp+'1 day'::interval-'1 second'::interval)
				AND document_type='pd' AND t.expertise_result IS NOT NULL %s
			ORDER BY t.expertise_result_date",
			$dt_from,
			$dt_to,
			$exp_res_cond
			)
		);
		$this->addModel($model);
		
		$this->addNewModel(
			sprintf(
			"SELECT format_period_rus(%s::date,%s::date,NULL) AS period_descr
			",
			$dt_from,
			$dt_to
			),
		'Head_Model'
		);		
	
	}
	
	public function get_reestr_cost_eval($pm){
		$cond = new ConditionParamsSQL($pm,$this->getDbLink());
		$dt_from = $cond->getDbVal('date_time','ge',DT_DATETIME);
		if (!isset($dt_from)){
			throw new Exception('Не задана дата начала!');
		}		
		$dt_to = $cond->getDbVal('date_time','le',DT_DATETIME);
		if (!isset($dt_to)){
			throw new Exception('Не задана дата окончания!');
		}		
		
		$exp_res_cond = '';
		$expertise_result = $cond->getVal('expertise_result','e',DT_STRING);
		if ($expertise_result=='positive'){
			$exp_res_cond.= " AND t.expertise_result='positive'";
		}
		else if ($expertise_result=='negative'){
			$exp_res_cond.= " AND t.expertise_result='negative'";
		}
		
		$model = new RepReestrCostEval_Model($this->getDbLink());
		$model->query(
			sprintf(
			"SELECT
				row_number() OVER (ORDER BY t.expertise_result_date) AS ord,
				t.constr_name,
				
				CASE WHEN t.constr_address IS NOT NULL THEN kladr_parse_addr(t.constr_address)||', ' ELSE '' END||
				(SELECT
					string_agg(rep.n||':'||rep.v,', ')
					FROM (SELECT
						jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'name' AS n,
						jsonb_array_elements(t.constr_technical_features->'rows')->'fields'->>'value' AS v
					) AS rep
				)				
				AS constr_address_features,
				
				coalesce(app.customer->>'name','')||
				CASE WHEN app.customer->>'name' IS NOT NULL THEN ', ' ELSE '' END||
				coalesce(app.developer->>'name','')
				AS customer_developer,
				
				(SELECT
					string_agg(a2.contractor_name,', ')
				FROM (SELECT (jsonb_array_elements(a1.contractors)->>'name')::text AS contractor_name FROM applications AS a1 WHERE a1.id=t.application_id) AS a2
				) AS contrcator_names,
			
				CASE
					WHEN t.expertise_result='negative' THEN 'Отрицательое заключение: '||rej.name
					ELSE 'Положительное заключение'
				END AS exeprtise_res_descr,
			
				t.reg_number||' от '||to_char(t.expertise_result_date,'DD/MM/YY') AS exeprtise_res_number_date,			
			
				t.order_document,
				t.argument_document
				
			FROM contracts AS t
			LEFT JOIN applications AS app ON app.id=t.application_id
			LEFT JOIN expertise_reject_types AS rej ON rej.id=t.expertise_reject_type_id
			WHERE t.expertise_result_date BETWEEN %s AND (%s::timestamp+'1 day'::interval-'1 second'::interval)
				AND document_type='cost_eval_validity' AND t.expertise_result IS NOT NULL %s
			ORDER BY t.expertise_result_date",
			$dt_from,
			$dt_to,
			$exp_res_cond
			)
		);
		$this->addModel($model);
		
		$this->addNewModel(
			sprintf(
			"SELECT format_period_rus(%s::date,%s::date,NULL) AS period_descr
			",
			$dt_from,
			$dt_to
			),
		'Head_Model'
		);		
	
	}
	
	public function get_constr_name($pm){
		$this->addNewModel(sprintf(
			"SELECT constr_name FROM contracts WHERE id=%d",
			$this->getExtDbVal($pm,'id')
		),'ConstrName_Model');
	}
	
	public function get_reestr_pay($pm){
		$cond = new ConditionParamsSQL($pm,$this->getDbLink());
		$dt_from = $cond->getDbVal('date_time','ge',DT_DATE);
		if (!isset($dt_from)){
			throw new Exception('Не задана дата начала!');
		}		
		$dt_to = $cond->getDbVal('date_time','le',DT_DATE);
		if (!isset($dt_to)){
			throw new Exception('Не задана дата окончания!');
		}		
	
		$extra_cond = '';
		$client_id = $cond->getDbVal('client_id','e',DT_INT);
		if ($client_id &amp;&amp; $client_id!='null'){
			$extra_cond.= sprintf(' AND contracts.client_id=%d',$client_id);
		}
		$customer_name = $cond->getDbVal('customer_name','e',DT_STRING);
		if ($customer_name &amp;&amp; $customer_name!='null'){
			$extra_cond.= sprintf(" AND app.customer->>'name'=%s",$customer_name);
		}
		
		$model = new RepReestrPay_Model($this->getDbLink());
		$model->query(
			sprintf(
			"SELECT
				row_number() OVER (ORDER BY p.pay_date) AS ord,
				contracts.expertise_result_number,
				app.applicant->>'name' AS applicant,
				app.customer->>'name' AS customer,
				contracts.contract_number,
				contracts.constr_name,	
				to_char(contracts.work_start_date,'DD/MM/YY') As work_start_date,
				contracts.expertise_cost_budget,
				contracts.expertise_cost_self_fund,
				p.total,
				p.pay_docum_number,
				to_char(p.pay_docum_date,'DD/MM/YY') As pay_docum_date
			FROM client_payments AS p
			LEFT JOIN contracts ON contracts.id=p.contract_id
			LEFT JOIN applications AS app ON app.id=contracts.application_id
			WHERE p.pay_date BETWEEN %s AND %s %s
			ORDER BY p.pay_date",
			$dt_from,
			$dt_to,
			$extra_cond
			)
		);
		$this->addModel($model);
	
		$this->addNewModel(
			sprintf(
			"SELECT format_period_rus(%s::date,%s::date,NULL) AS period_descr
			",
			$dt_from,
			$dt_to
			),
		'Head_Model'
		);		
	
	}

	public function get_reestr_contract($pm){
		$cond = new ConditionParamsSQL($pm,$this->getDbLink());
		$dt_from = $cond->getDbVal('date_time','ge',DT_DATE);
		if (!isset($dt_from)){
			throw new Exception('Не задана дата начала!');
		}		
		$dt_to = $cond->getDbVal('date_time','le',DT_DATE);
		if (!isset($dt_to)){
			throw new Exception('Не задана дата окончания!');
		}		
	
		$extra_cond = '';
		$client_id = $cond->getDbVal('client_id','e',DT_INT);
		if ($client_id &amp;&amp; $client_id!='null'){
			$extra_cond.= sprintf(' AND contracts.client_id=%d',$client_id);
		}
		$customer_name = $cond->getDbVal('customer_name','e',DT_STRING);
		if ($customer_name &amp;&amp; $customer_name!='null'){
			$extra_cond.= sprintf(" AND app.customer->>'name'=%s",$customer_name);
		}
		
		$model = new RepReestrPay_Model($this->getDbLink());
		$model->query(
			sprintf(
			"SELECT
				row_number() OVER (ORDER BY %s) AS ord,
				contracts.expertise_result_number,
				to_char(contracts.date_time,'DD/MM/YY') AS date,
				(contracts.primary_contract_reg_number IS NOT NULL) AS primary_exists,				
				app.applicant->>'name' AS applicant,
				app.customer->>'name' AS customer,
				contracts.constr_name,	
				contracts.expertise_cost_budget,
				contracts.expertise_cost_self_fund,				
				
				coalesce(contracts.contract_number,'')||
					CASE contracts.contract_date IS NOT NULL THEN' от '||to_char(contracts.contract_date,'DD/MM/YY')
					ELSE ''
					END
				AS contract_number_date,
				
				coalesce(payments.total,0) AS total
				
				to_char(contracts.work_start_date,'DD/MM/YY') As work_start_date,
				
				employees.name AS main_expert,
				
				CASE
					WHEN expertise_result='positive' THEN to_char(expertise_result_date,'DD/MM/YY')
					ELSE ''
				END AS expertise_result_date_positive,
				
				'дата доработки???' AS aaa,
				
				AS akt_number_date,
				
				AS comment_text
				
			FROM contracts
			LEFT JOIN (
				SELECT
					p.contract_id,
					sum(total) AS total
				FROM client_payments p
				GROUP BY p.contract_id
			) AS payments ON contracts.id=payments.contract_id
			LEFT JOIN applications AS app ON app.id=contracts.application_id
			LEFT JOIN employees ON employees.id=contracts.main_expert_id
			WHERE %s
			ORDER %s",
			$order_field,
			$conditions,
			$order_field
			)
		);
		$this->addModel($model);
	
		$this->addNewModel(
			sprintf(
			"SELECT format_period_rus(%s::date,%s::date,NULL) AS period_descr
			",
			$dt_from,
			$dt_to
			),
		'Head_Model'
		);		
	
	}
	
</xsl:template>

</xsl:stylesheet>
