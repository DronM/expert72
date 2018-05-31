<?php
require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInterval.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtArray.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtXML.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */



require_once(ABSOLUTE_PATH.'functions/ExtProg.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class ClientPayment_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('contract_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDate('pay_date'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDate('pay_docum_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('pay_docum_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('total'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('ClientPayment_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('contract_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('pay_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('pay_docum_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('pay_docum_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('total'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('employee_id'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('ClientPayment_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('ClientPayment_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ClientPayment_Model');		

			
		/* get_list */
		$pm = new PublicMethod('get_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

		$this->addPublicMethod($pm);
		
		$this->setListModelId('ClientPaymentList_Model');
		
			
		$pm = new PublicMethod('get_from_1c');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtDate('date_from',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtDate('date_to',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('interactive',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

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
		
		if ($xml && $xml->rec && $xml->rec->count()){			
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
					if (is_array($ar) && count($ar) && intval($ar['contract_id'])){
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
				if ($interactive!=1 && strlen($errors_no_contr) ){
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
			if ($interactive==1 && strlen($errors_no_contr) ){
				$errors_no_contr = str_replace(PHP_EOL,' ',$errors_no_contr);
				throw new Exception($errors_no_contr);
			}
		}
	}
	
	public function insert($pm){
		$employees_ref = json_decode($_SESSION['employees_ref']);
		if ($employees_ref && $employees_ref->keys && $employees_ref->keys->id){
			$pm->setParamValue('employee_id', $employees_ref->keys->id);
		}
		parent::insert($pm);
	}
	

}
?>