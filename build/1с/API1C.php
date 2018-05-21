<?php
	require_once('downloader.php');
	require_once('functions.php');
	
	define('COMMAND', 'cmd');
	define('PAR_DATE_FROM', 'date_from');
	define('PAR_DATE_TO', 'date_to');
	define('PAR_DOC', 'doc_ext_id');
	define('PAR_STAMP', 'stamp');//number 1/0
	define('PAR_PARAMS', 'params');
	
	define('ER_PAR_DOC', 'Не задан идентификатор документа!');
	define('ER_PAR_DATE', 'Не задана дата!');
	define('ER_PAR_PARAMS', 'Не задан параметр с массивом данных!');
	define('ER_MAKE_AKT', 'Ошибка при формировании акта.');
	
	
	//********* команды *************
	set_time_limit(300);
	
	/**
	 * Возвращает список оплат от даты начала по текущую
	 */
	define('CMD_GET_PAYMENTS', 'get_payments');	

	/**
	 * @param {string} params
	 * Возвращает список счетов, создает договор в 1с если его не было
	 */
	define('CMD_GET_ORDER_LIST', 'get_order_list');	

	/**
	 * @param {string} doc_id ссылка документ счет
	 * Возвращает печатную форму счета
	 */
	define('CMD_PRINT_ORDER', 'print_order');	

	/**
  	 * @param {string} doc_ref ссылка документ акт
	 * Возвращает печатную форму акта
	 */
	define('CMD_PRINT_AKT', 'print_akt');	

	/**
  	 * @param {string} doc_ref ссылка документ акт
	 * Возвращает печатную форму акта
	 */
	define('CMD_PRINT_INVOICE', 'print_invoice');	

	/**
  	 * @param {string} params структура
	 * Возвращает ссылку
	 */
	define('CMD_MAKE_AKT', 'make_akt');	

	/**
  	 * @param {string} params структура
	 * Возвращает ссылку
	 */
	define('CMD_MAKE_ORDER', 'make_order');	

	define('COM_OBJ_NAME', 'v83Server.Connection');
	
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
			$file = $obr->ПечатьСчетаВФайл($par_doc_id,$par_stamp);
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
			$file = $obr->ПечатьАктаВФайл($par_doc_id,$par_stamp);
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
			$file = $obr->ПечатьСчнтаФактурыВФайл($par_doc_id,$par_stamp);
			downloadfile($file);
			unlink($file);
			$SENT_FILE = TRUE;		
		}
		
		else if ($com==CMD_MAKE_AKT){
			if (!$_REQUEST[PAR_PARAMS]){
				throw new Exception(ER_PAR_PARAMS);
			}
			$params = unserialize(stripslashes($_REQUEST[PAR_PARAMS]));
			
			$v8 = new COM(COM_OBJ_NAME);
			
			$struc_client = NULL;			
			client1c_struc_from_params($v8,$params,$struc_client);

			$struc_contract = NULL;			
			contract1c_struc_from_params($v8,$params,$struc_contract);
			
			$struc_params = NULL;			
			params_struc($v8,$params,$struc_params);
			
			$obr = get_ext_obr($v8);
			$invoice_ref = NULL;
			$akt_ref = $obr->СоздатьАкт($struc_client,$struc_contract,$struc_params,floatval($params['total']),$invoice_ref);
			if ($akt_ref->Пустая()){
				throw new Exception(ER_MAKE_AKT);
			}
			
			$xml_body = sprintf(
				'<doc_ext_id>%s</doc_ext_id>
				<invoice_ext_id>%s</invoice_ext_id>
				<client_ext_id>%s</client_ext_id>
				<contract_ext_id>%s</dogovor_ext_id>
				<doc_number>%s</doc_number>
				<doc_date>%s</doc_date>
				<doc_total>%f</doc_total>
				<invoice_number>%s</invoice_number>
				<invoice_date>%s</invoice_date>',
				$v8->String($akt_ref->УникальныйИдентификатор()),
				$v8->String($invoice_ref->УникальныйИдентификатор()),
				$v8->String($akt_ref->Контрагент->УникальныйИдентификатор()),
				$v8->String($akt_ref->Договор->УникальныйИдентификатор()),
				$v8->String($akt_ref->Номер),
				date1c_to_ISO($v8,$akt_ref->Дата),
				float1c_to_float($akt_ref->СуммаДокумента),
				$v8->String($invoice_ref->Номер),
				date1c_to_ISO($v8,$invoice_ref->Дата)
			);
		}
		
		else if ($com==CMD_MAKE_ORDER){
			if (!$_REQUEST[PAR_PARAMS]){
				throw new Exception(ER_PAR_PARAMS);
			}
			$params = unserialize(stripslashes($_REQUEST[PAR_PARAMS]));
			
			$v8 = new COM(COM_OBJ_NAME);
			
			$struc_client = NULL;			
			client1c_struc_from_params($v8,$params,$struc_client);

			$struc_contract = NULL;			
			contract1c_struc_from_params($v8,$params,$struc_contract);

			$struc_params = NULL;			
			params_struc($v8,$params,$struc_params);
			
			$obr = get_ext_obr($v8);
			$order_ref = $obr->СоздатьСчет($struc_client,$struc_contract,floatval($params['total']),$struc_params);
			
			$xml_body = sprintf(
				'<order_ext_id>%s</akt_order_id>
				<client_ext_id>%s</client_ext_id>
				<dogovor_ext_id>%s</dogovor_ext_id>
				<order_number>%s</order_number>
				<order_date>%s</order_date>',
				$v8->String($order_ref->УникальныйИдентификатор()),
				$v8->String($order_ref->Контрагент->УникальныйИдентификатор()),
				$v8->String($order_ref->Договор->УникальныйИдентификатор()),
				$v8->String($order_ref->Номер),
				date1c_to_ISO($v8,$order_ref->Дата)
			);
		}
		
		else if ($com==CMD_GET_ORDER_LIST){
			if (!$_REQUEST[PAR_PARAMS]){
				throw new Exception(ER_PAR_PARAMS);
			}
			$params = unserialize(stripslashes($_REQUEST[PAR_PARAMS]));
			
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
