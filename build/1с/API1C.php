<?php
	require_once('downloader.php');
	require_once('functions.php');
	
	define('COMMAND', 'cmd');
	define('PAR_DATE_FROM', 'date_from');
	define('PAR_DATE_TO', 'date_to');
	define('PAR_DOC', 'doc_ext_id');
	define('PAR_STAMP', 'stamp');//number 1/0
	define('PAR_PARAMS', 'params');
	
	define('ER_PAR_DOC', '�� ����� ������������� ���������!');
	define('ER_PAR_DATE', '�� ������ ����!');
	define('ER_PAR_PARAMS', '�� ����� �������� � �������� ������!');
	define('ER_MAKE_AKT', '������ ��� ������������ ����.');
	
	
	//********* ������� *************
	set_time_limit(300);
	
	/**
	 * ���������� ������ ����� �� ���� ������ �� �������
	 */
	define('CMD_GET_PAYMENTS', 'get_payments');	

	/**
	 * @param {string} params
	 * ���������� ������ ������, ������� ������� � 1� ���� ��� �� ����
	 */
	define('CMD_GET_ORDER_LIST', 'get_order_list');	

	/**
	 * @param {string} doc_id ������ �������� ����
	 * ���������� �������� ����� �����
	 */
	define('CMD_PRINT_ORDER', 'print_order');	

	/**
  	 * @param {string} doc_ref ������ �������� ���
	 * ���������� �������� ����� ����
	 */
	define('CMD_PRINT_AKT', 'print_akt');	

	/**
  	 * @param {string} doc_ref ������ �������� ���
	 * ���������� �������� ����� ����
	 */
	define('CMD_PRINT_INVOICE', 'print_invoice');	

	/**
  	 * @param {string} params ���������
	 * ���������� ������
	 */
	define('CMD_MAKE_AKT', 'make_akt');	

	/**
  	 * @param {string} params ���������
	 * ���������� ������
	 */
	define('CMD_MAKE_ORDER', 'make_order');	

	define('COM_OBJ_NAME', 'v8Server.Connection');
	
	$xml_status = 'true';
	$xml_body = '';
	$SENT_FILE = FALSE;
	
	try{		
		if (!isset($_REQUEST[COMMAND])){
			//error
			throw new Exception('No command');
		}
		$com = $_REQUEST[COMMAND];
		
		if ($com==CMD_GET_PAYMENTS){
			if (!isset($_REQUEST[PAR_DATE_FROM])){
				throw new Exception(ER_PAR_DATE);
			}		
			if (!isset($_REQUEST[PAR_DATE_TO])){
				throw new Exception(ER_PAR_DATE);
			}		
			$v8 = new COM(COM_OBJ_NAME);			
			$xml_body = get_payments($v8,strtotime($_REQUEST[PAR_DATE_FROM]),strtotime($_REQUEST[PAR_DATE_TO]));
		}
		
		else if ($com==CMD_PRINT_ORDER){
			$par_doc_id = $_REQUEST[PAR_DOC];
			if (!$par_doc_id){
				throw new Exception(ER_PAR_DOC);
			}
			$par_stamp = (isset($_REQUEST[PAR_STAMP]))? (($_REQUEST[PAR_STAMP]=='1')? TRUE:FALSE) : FALSE;
			$v8 = new COM(COM_OBJ_NAME);
			$obr = get_ext_obr($v8);
			$file = $obr->����������������($par_doc_id,$par_stamp);
			downloadfile($file);
			unlink($file);
			$SENT_FILE = TRUE;		
		}
		
		else if ($com==CMD_PRINT_AKT){
			$par_doc_id = $_REQUEST[PAR_DOC];
			if (!$par_doc_id){
				throw new Exception(ER_PAR_DOC);
			}
			$par_stamp = (isset($_REQUEST[PAR_STAMP]))? (($_REQUEST[PAR_STAMP]=='1')? TRUE:FALSE) : FALSE;
			$v8 = new COM(COM_OBJ_NAME);
			$obr = get_ext_obr($v8);
			$file = $obr->���������������($par_doc_id,$par_stamp);
			downloadfile($file);
			unlink($file);
			$SENT_FILE = TRUE;		
		}

		else if ($com==CMD_PRINT_INVOICE){
			$par_doc_id = $_REQUEST[PAR_DOC];
			if (!$par_doc_id){
				throw new Exception(ER_PAR_DOC);
			}
			$par_stamp = (isset($_REQUEST[PAR_STAMP]))? (($_REQUEST[PAR_STAMP]=='1')? TRUE:FALSE) : FALSE;
			$v8 = new COM(COM_OBJ_NAME);
			$obr = get_ext_obr($v8);
			$file = $obr->�����������������������($par_doc_id,$par_stamp);
			downloadfile($file);
			unlink($file);
			$SENT_FILE = TRUE;		
		}
		
		else if ($com==CMD_MAKE_AKT){
			if (!$_REQUEST[PAR_PARAMS]){
				throw new Exception(ER_PAR_PARAMS);
			}
			$params = unserialize(stripslashes($_REQUEST[PAR_PARAMS]));
			cyr_ar_decode($params);
			
			$v8 = new COM(COM_OBJ_NAME);
			
			$struc_client = NULL;			
			client1c_struc_from_params($v8,$params,$struc_client);

			$struc_contract = NULL;			
			contract1c_struc_from_params($v8,$params,$struc_contract);
			
			$struc_params = NULL;			
			params_struc($v8,$params,$struc_params);
			
			$obr = get_ext_obr($v8);
			$invoice_ref = NULL;
			$res_struc = $obr->����������($struc_client,$struc_contract,$struc_params,floatval($params['total']));
			$akt_ref = $res_struc->���;
			$invoice_ref = $res_struc->���;
			if ($akt_ref->������()){
				throw new Exception(ER_MAKE_AKT);
			}
			
			$xml_body = sprintf(
				'<doc_ext_id>%s</doc_ext_id>
				<invoice_ext_id>%s</invoice_ext_id>
				<client_ext_id>%s</client_ext_id>
				<contract_ext_id>%s</contract_ext_id>
				<doc_number>%s</doc_number>
				<doc_date>%s</doc_date>
				<doc_total>%f</doc_total>
				<invoice_number>%s</invoice_number>
				<invoice_date>%s</invoice_date>',
				$v8->String($akt_ref->�����������������������()),
				$v8->String($invoice_ref->�����������������������()),
				$v8->String($akt_ref->����������->�����������������������()),
				$v8->String($akt_ref->�������->�����������������������()),
				$v8->String($akt_ref->�����),
				date1c_to_ISO($v8,$akt_ref->����),
				float1c_to_float($akt_ref->��������������),
				$v8->String($invoice_ref->�����),
				date1c_to_ISO($v8,$invoice_ref->����)
			);
		}
		
		else if ($com==CMD_MAKE_ORDER){
			if (!$_REQUEST[PAR_PARAMS]){
				throw new Exception(ER_PAR_PARAMS);
			}
			$params = unserialize(stripslashes($_REQUEST[PAR_PARAMS]));
			cyr_ar_decode($params);
			
			$v8 = new COM(COM_OBJ_NAME);
			
			$struc_client = NULL;			
			client1c_struc_from_params($v8,$params,$struc_client);

			$struc_contract = NULL;			
			contract1c_struc_from_params($v8,$params,$struc_contract);

			$struc_params = NULL;			
			params_struc($v8,$params,$struc_params);
			
			$obr = get_ext_obr($v8);
			$order_ref = $obr->�����������($struc_client,$struc_contract,$struc_params,floatval($params['total']));
			
			$xml_body = sprintf(
				'<doc_ext_id>%s</doc_ext_id>
				<client_ext_id>%s</client_ext_id>
				<contract_ext_id>%s</contract_ext_id>
				<doc_number>%s</doc_number>
				<doc_date>%s</doc_date>',
				$v8->String($order_ref->�����������������������()),
				$v8->String($order_ref->����������->�����������������������()),
				$v8->String($order_ref->�������->�����������������������()),
				$v8->String($order_ref->�����),
				date1c_to_ISO($v8,$order_ref->����)
			);
		}
		
		else if ($com==CMD_GET_ORDER_LIST){
			if (!$_REQUEST[PAR_PARAMS]){
				throw new Exception(ER_PAR_PARAMS);
			}
			$params = unserialize(stripslashes($_REQUEST[PAR_PARAMS]));
			cyr_ar_decode($params);

			$v8 = new COM(COM_OBJ_NAME);			
			$xml_body = get_orders($v8,$params);
		}
	}
	catch (Exception $e){
		//error
		$xml_status = 'false';		
		$xml_body.='<error><![CDATA['.cyr_str_encode($e->getMessage()).']]></error>';		
		//$xml_body.='<error>'.cyr_str_encode($e->getMessage()).'</error>';		
	}
	if (!$SENT_FILE){
		$res_xml = '<?xml version="1.0" encoding="UTF-8"?>';
		$res_xml .= '<response status="'.$xml_status.'">';
		$res_xml .= $xml_body.'</response>';
		
		echo $res_xml;
	}
?>
