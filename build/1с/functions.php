<?php
	/* ���������� ������������������������������ */
	define("CONST_1C_OBR_NAME",'API1C');

	/* ���������� ����������������� �������� ������ ���*/
	define("CONST_1C_KPS_CODE",'00000000000000130');	

	/* ���������� ��� ����� ���*/
	define("CONST_1C_KEK",'130');
	define("CONST_1C_KEK_INVOICE",'130');	

	/* ���������� ������� ����� ���*/
	define("CONST_1C_LSCHET",'40603810500994000122');
	
	/* ������ ���������� ������� ��� ����� */
	define("CONST_1C_PAY_COMMENT",'������ �� ���������');

	/* ��� ������������ ��� ��� ������ � 1� �����������*/	
	define("CONST_1C_RUK",'��������� ������� �������������');

	/* ��� ������������ ��� ��� ������ � 1� �����������*/	
	define("CONST_1C_BUH",'������������� ������� ������������');

	/* ����������� ����������� ���������� */	
	define("CONST_1C_DOC_COMMENT",'#Web');

	/* ������������������������������� */	
	define("CONST_1C_IFO",'������������������� ������������');
	
	/* ����������������������� */
	define("CONST_1C_ACT_NAME",'������ �������� ����������� ����');
	
	//*******************************************************************************
	
	function cyr_str_encode($str){
		return $str;
	}

	function cyr_str_decode($str){
		return iconv('UTF-8','Windows-1251',$str);
	}

	function cyr_ar_decode(&$ar){
		foreach($ar as $k=>$v){
			$ar[$k] = cyr_str_decode($v);
		}
	}
	
	function get_ext_obr($v8){

		$ext_form = $v8->�����������->������������������������������->�������������������(CONST_1C_OBR_NAME,TRUE);
		if ($ext_form->������()){
			throw new Exception('�� ������� ������� ��������� "'.CONST_1C_OBR_NAME.'"');
		}
		$f = $v8->��������������������������();
		$d = $ext_form->������������������->��������();
		$d->��������($f);
		return $v8->����������������->�������($f,FALSE);
	}

	function get_payments($v8,$dFrom,$dTo){
		$q_obj = $v8->NewObject('������');
		$q_obj->����� ="
		�������
		���.����,
		���.������������������������,
		���.�����������������������,
		����.�������,
		����.�������.������������� ��� �������������,
		����.�������.������������ ��� ������������,
		��������(�����(����NULL(����.�����,0)) ��� �����(15,2)) AS �����
		�� ��������.������������������� ��� ���
		����� ���������� ��������.�������������������.������������������ ��� ����
		�� ����.������=���.������
		��� ���.���� ����� ���������(".date('Y,m,d,0,0,0',$dFrom).") � ���������(".date('Y,m,d,23,59,59',$dTo).") � ���.��������
		������������� �� ���.����,���.������������������������,���.�����������������������,����.�������,����.�������.�������������,����.�������.������������";
		$sel = $q_obj->���������()->�������();
		$xml_body = '';
		while ($sel->���������()){
			$sm = str_replace(' ','',$sel->�����);
			$sm = str_replace(',','.',$sm);
			$sm = floatval($sm);
			//throw new Exception($v8->String($v8,$sel->������������));
			if ($sm<>0){
				$xml_body.='<rec>'.
					sprintf('<contract_ext_id>%s</contract_ext_id>', $v8->String($sel->�������->�����������������������())).
					sprintf('<contract_number>%s</contract_number>', $v8->String($sel->�������������)).
					sprintf('<contract_date>%s</contract_date>', date1c_to_ISO($v8,$sel->������������)).					
					sprintf('<pay_date>%s</pay_date>', date1c_to_ISO($v8,$sel->����)).					
					sprintf('<total>%f</total>', $sm).
					sprintf('<pay_docum_number>%s</pay_docum_number>', $v8->String($sel->������������������������)).
					sprintf('<pay_docum_date>%s</pay_docum_date>', date1c_to_ISO($v8,$sel->�����������������������)).
					'</rec>';
			}
		}
		return $xml_body;						
	}
	
	function client1c_struc_from_params($v8,&$params,&$struc){
		if ($params['client_ext_id']){
			$client_id = $v8->NewObject('�����������������������',$params['client_ext_id']);
			$client_ref = $v8->�����������->�����������->��������������($client_id);
		}
		else{			
			$client_ref = $v8->�����������->�����������->������������();
		}
		$struc = $v8->NewObject('���������');			
		$struc->��������('ref',$client_ref);
		$struc->��������('name',$params['client_name']);
		$struc->��������('name_full',$params['client_name_full']);
		$struc->��������('inn',$params['client_inn']);
		$struc->��������('kpp',$params['client_kpp']);
		$struc->��������('ogrn',$params['client_ogrn']);
		$struc->��������('okpo',$params['client_okpo']);		
		$struc->��������('address_legal',$params['client_address_legal']);
		$struc->��������('address_post',$params['client_address_post']);
		$struc->��������('client_type',$params['client_type']);
		
		$bank_accounts = $v8->NewObject('������');
		if ($params['client_bank_accounts']){			
			$acc_ar = json_decode($params['client_bank_accounts']);
			foreach($acc_ar as $acc){
				if ($acc->fields && $acc->fields->bik && $acc->fields->acc_number){
					$bnk_ref = $v8->�����������->�����->�����������($acc->fields->bik);
					if (!$bnk_ref->������()){
						$bnk = $v8->NewObject('���������');
						$bnk->��������('ref',$bnk_ref);
						$bnk->��������('acc_number',$acc->fields->acc_number);
						$bank_accounts->��������($bnk);
					}
				}
			}
		}
		$struc->��������('bank_accounts',$bank_accounts);
	}
	
	function contract1c_struc_from_params($v8,&$params,&$struc){
		if ($params['contract_ext_id']){
			$contract_id = $v8->NewObject('�����������������������',$params['contract_ext_id']);
			$contract_ref = $v8->�����������->��������->��������������($contract_id);
		}
		else{
			$contract_ref = $v8->�����������->��������->������������();
		}
		$struc = $v8->NewObject('���������');
		$struc->��������('ref',$contract_ref);
		$struc->��������('name',$params['contract_name']);
		$struc->��������('number',$params['contract_number']);
		$struc->��������('date',dateISO_to_date1c($params['contract_date']));
		$struc->��������('contract_type',$params['contract_type']);				
	}

	function params_struc($v8,&$params,&$struc){
		$struc = $v8->NewObject('���������');
		$struc->��������('�������������',date('YmdHis'));
		$struc->��������('������������',$v8->�����������->����������->�������������������(CONST_1C_RUK));
		$struc->��������('�����������',$v8->�����������->����������->�������������������(CONST_1C_BUH));
		$struc->��������('��',$params['acc_number']);
		$struc->��������('���', CONST_1C_KEK);
		$struc->��������('�����������������������', CONST_1C_ACT_NAME);		
		$struc->��������('���', CONST_1C_KPS_CODE);
		$struc->��������('�����������������', CONST_1C_PAY_COMMENT);
		$struc->��������('���', $v8->������������->���->���������);
		$struc->��������('�����������', CONST_1C_DOC_COMMENT);
		$struc->��������('���', CONST_1C_IFO);
		$struc->��������('item_1c_descr', $params['item_1c_descr']);
		$struc->��������('item_1c_descr_full', $params['item_1c_descr_full']);
		$struc->��������('item_1c_doc_descr', $params['item_1c_doc_descr']);
		$struc->��������('document_type', $params['document_type']);		
		$struc->��������('reg_number', $params['reg_number']);
		
		$pay_list = $v8->NewObject('���������������');
		$pay_list->�������->��������("�������������");
		$pay_list->�������->��������("��������������");
		$payments = json_decode($params['payment']);
		foreach($payments as $payment){
			$pay = $pay_list->��������();
			$pay->������������� = dateISO_to_date1c($payment->pay_docum_date);
			$pay->�������������� = $payment->pay_docum_number;
		}
		$struc->��������('������������', $pay_list);
	}
	
	function float1c_to_float($float1c){
		$float1c = str_replace(' ','',$float1c);
		$float1c = str_replace(',','.',$float1c);
		return floatval($float1c);	
	}
	
	function date1c_to_ISO($v8,$date1c){
		$d_str = $v8->String($date1c);
		
		$d_parts = explode(' ',$d_str);
		$y = 0;
		$m = 0;
		$d = 0;
		$min = 0;
		$sec = 0;
		$h = 0;
		if (count($d_parts)>=1){
			$d_ar = explode('.',$d_parts[0]);
			if (count($d_ar)>=3){
				$d = intval($d_ar[0]);
				$m = intval($d_ar[1]);
				$y = intval($d_ar[2]);
				if ($y<100){
					$y+= 2000;
				}
			}
		}
		if (count($d_parts)>=2){
			$d_ar = explode(':',$d_parts[1]);
			if (count($d_ar)>=3){
				$h = intval($d_ar[0]);
				$min = intval($d_ar[1]);
				$sec = intval($d_ar[2]);
			}
		}
		$d = (($d<10)? '0':'').(string)$d;
		$m = (($m<10)? '0':'').(string)$m;
		$h = (($h<10)? '0':'').(string)$h;
		$min = (($min<10)? '0':'').(string)$min;
		$sec = (($sec<10)? '0':'').(string)$sec;
		return ($y.'-'.$m.'-'.$d.' '.$h.':'.$min.':'.$sec);
	}
	
	function dateISO_to_date1c($d){
		$res = str_replace('-','',$d);
		$res = str_replace(' ','',$res);
		$res = str_replace(':','',$res);
		$res = str_replace('T','',$res);
		return $res;
	}
	
	function get_orders($v8,$params){
		$contract_ref = NULL;		
		if ($params['contract_ext_id']){
			$contract_id = $v8->NewObject('�����������������������',$params['contract_ext_id']);
			$contract_ref = $v8->�����������->��������->��������������($contract_id);
			$client_ext_id = $v8->String($contract_ref->����������->�����������������������());
		}
		else{			
			$struc_client = NULL;					
			client1c_struc_from_params($v8,$params,$struc_client);						
			$struc_contract = NULL;			
			contract1c_struc_from_params($v8,$params,$struc_contract);					
			$obr = get_ext_obr($v8);
			$obr->���������������������($struc_client);
			$obr->�����������������($struc_contract,$struc_client);

			$contract_ref = $struc_contract->ref; 
			$client_ext_id = $v8->String($struc_client->ref->�����������������������());
		}

		$q_obj = $v8->NewObject('������');
		$q_obj->����� ="
		�������
		������,
		�����,
		����,
		��������(����NULL(��������������,0) ��� �����(15,2)) AS �����
		�� ��������.������������
		��� �������=&������� � �� ���������������
		";
		$q_obj->������������������('�������',$contract_ref);
		$sel = $q_obj->���������()->�������();
		
		$xml_body = sprintf('<contract_ext_id>%s</contract_ext_id>',$v8->String($contract_ref->�����������������������())).
			sprintf('<client_ext_id>%s</client_ext_id>',$client_ext_id);
		while ($sel->���������()){
			$sm = float1c_to_float($sel->�����);
			if ($sm<>0){
				$xml_body.='<rec>'.
					sprintf('<ext_id>%s</ext_id>',$v8->String($sel->������->�����������������������())).
					sprintf('<number>%s</number>',$v8->String($sel->�����)).
					sprintf('<date>%s</date>',date1c_to_ISO($v8,$sel->����)).					
					sprintf('<total>%f</total>',$sm).
					'</rec>';
			}
		}
		return $xml_body;
	}
?>
