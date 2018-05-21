<?php
	/* Справочник ДополнительныеОтчетыИОбработки */
	define("CONST_1C_OBR_NAME",'Web Functions');

	/* Справочник Классификационные признаки счетов Код*/
	define("CONST_1C_KPS_CODE",'00000000000000000');

	/* Справочник КЭК КОСГУ Код*/
	define("CONST_1C_KEK",'130');
	define("CONST_1C_KEK_INVOICE",'130');	

	/* Справочник Лицевые счета Код*/
	define("CONST_1C_LSCHET",'999999999999999999999999999999');
	
	/* строка назначение платежа для счета */
	define("CONST_1C_PAY_COMMENT",'Оплата по контракту');

	/* ФИО руководителя как оно задоно в 1с Сотрудниках*/	
	define("CONST_1C_RUK",'Кучерявый Алексей Анатальевич');

	/* ФИО руководителя как оно задоно в 1с Сотрудниках*/	
	define("CONST_1C_BUH",'Руковишникова Наталья Владимировна');

	/* Комментарий создаваемых документов */	
	define("CONST_1C_DOC_COMMENT",'#Web');

	//*******************************************************************************
	
	function get_ext_obr($v8){
		$ext_form = $v8->Справочники->ДополнительныеОтчетыИОбработки->НайтиПоНаименованию(CONST_1C_OBR_NAME,TRUE);
		if ($ext_form->Пустая()){
			throw new Exception('Не найдена внешняя обработка "'.CONST_1C_OBR_NAME.'"');
		}
		$f = $v8->ПолучитьИмяВременногоФайла();
		$d = $ext_form->ХранилищеОбработки->Получить();
		$d->Записать($f);
		return $v8->ВнешниеОбработки->Создать($f,FALSE);
	}

	function get_payments($v8,$dFrom,$dTo){
		$q_obj = $v8->NewObject('Запрос');
		$q_obj->Текст ="
		ВЫБРАТЬ
		Док.Договор,
		Док.Договор.НомерДоговора КАК НомерДоговора,
		Док.Договор.ДатаДоговора КАК ДатаДоговора,
		ВЫРАЗИТЬ(СУММА(ЕСТЬNULL(Док.СуммаДокумента,0)) КАК ЧИСЛО(15,2)) AS Сумма
		ИЗ Документ.КассовоеПоступление КАК Док
		ГДЕ Док.Дата МЕЖДУ ДАТАВРЕМЯ(".date('Y,m,d,0,0,0',$dFrom).") И ДАТАВРЕМЯ(".date('Y,m,d,23,59,59',$dTo).")
		СГРУППИРОВАТЬ ПО Док.Договор,Док.Договор.НомерДоговора,Док.Договор.ДатаДоговора";
		$sel = $q_obj->Выполнить()->Выбрать();
		$xml_body = '';
		while ($sel->Следующий()){
			$sm = str_replace(' ','',$sel->Сумма);
			$sm = str_replace(',','.',$sm);
			$sm = floatval($sm);
			if ($sm<>0){
				$xml_body.='<rec>'.
					sprintf('<contract_ext_id>%s</contract_ext_id>',
						$v8->String($sel->Договор->УникальныйИдентификатор())
					).
					sprintf('<contract_number>%s</contract_number>',
						$v8->String($sel->НомерДоговора)
					).
					sprintf('<contract_date>%s</contract_date>',
						date1c_to_ISO($v8,$sel->ДатаДоговора);
					).					
					sprintf('<total>%f</total>',
						$sm
					).
					'</rec>';
			}
		}
		return $xml_body;						
	}
	
	function client1c_struc_from_params($v8,&$params,&$struc){
		$client_id = $v8->NewObject('УникальныйИдентификатор',$params['client_ext_id']);
		$client_ref = $v8->Справочники->Контрагенты->ПолучитьСсылку($client_id);
		$struc = $v8->NewObject('Структура');			
		$struc->Вставить('ref',$client_ref);
		$struc->Вставить('name',$params['client_name']);
		$struc->Вставить('name_full',$params['client_name_full']);
		$struc->Вставить('inn',$params['client_inn']);
		$struc->Вставить('kpp',$params['client_kpp']);
		$struc->Вставить('ogrn',$params['client_ogrn']);
		$struc->Вставить('okpo',$params['client_okpo']);		
		$struc->Вставить('address_legal',$params['client_address_legal']);
		$struc->Вставить('address_post',$params['client_address_post']);
		$struc->Вставить('client_type',$params['client_type']);
		
		$bank_accounts = $v8->NewObject('Массив');
		if ($params['client_bank_accounts']){			
			$acc_ar = json_decode($params['client_bank_accounts']);
			foreach($acc_ar as $acc){
				if ($acc->fields && $acc->fields->bik && $acc->fields->acc_number){
					$bnk_ref = $v8->Справлчники->Банки->НайтиПоКоду($acc->fields->bik);
					if (!$bnk_ref->Пустая()){
						$bnk = $v8->NewObject('Структура');
						$bnk->Вставить('ref',$bnk_ref);
						$bnk->Вставить('acc_number',$acc->fields->acc_number);
						$bank_accounts->Добавить($bnk);
					}
				}
			}
		}
		$struc->Вставить('bank_accounts',$bank_accounts);
	}
	
	function contract1c_struc_from_params($v8,&$params,&$struc){
		$contract_id = $v8->NewObject('УникальныйИдентификатор',$params['contract_ext_id']);
		$contract_ref = $v8->Справочники->Договоры->ПолучитьСсылку($contract_id);
	
		$struc = $v8->NewObject('Структура');
		$struc->Вставить('ref',$contract_ref);
		$struc->Вставить('name',$params['contract_name']);
		$struc->Вставить('number',$params['contract_number']);
		$struc->Вставить('date',dateISO_to_date1c($params['contract_date']));
		$struc->Вставить('contract_type',$params['contract_type']);				
	}

	function params_struc($v8,&$params,&$struc){
		$struc = $v8->NewObject('Структура');
		$struc->Вставить('ДатаДокумента',date('YmdHis'));
		$struc->Вставить('Руководитель',$v8->Справочники->Сотрудники->НайтиПоНаименованию(CONST_1C_RUK));
		$struc->Вставить('ГлБухгалтер',$v8->Справочники->Сотрудники->НайтиПоНаименованию(CONST_1C_BUH));
		$struc->Вставить('ЛС',CONST_1C_LSCHET);
		$struc->Вставить('КПС', CONST_1C_KEK);
		$struc->Вставить('КПССчетаФактуры', CONST_1C_KEK_INVOICE);
		$struc->Вставить('КОСГУ', CONST_1C_KPS_CODE);
		$struc->Вставить('НазначениеПлатежа', CONST_1C_PAY_COMMENT);
		$struc->Вставить('КФО', $v8->Перечисления->КВД->Внебюджет);
		$struc->Вставить('Комментарий', CONST_1C_DOC_COMMENT);
		$struc->Вставить('item_1c_descr', $params['item_1c_descr']);
		$struc->Вставить('item_1c_descr_full', $params['item_1c_descr_full']);
		$struc->Вставить('item_1c_doc_descr', $params['item_1c_doc_descr']);
		$struc->Вставить('document_type', $params['document_type']);		
	}
	
	function float1c_to_float($float1c){
		$float1c = str_replace(' ','',$float1c);
		$float1c = str_replace(',','.',$float1c);
		return floatval($float1c);	
	}
	
	function date1c_to_ISO($v,$date1c){
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
		return date('Y-m-dTH:i:s',mktime($h,$min,$sec,$m,$d,$y));
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
			$contract_id = $v8->NewObject('УникальныйИдентификатор',$params['contract_ext_id']);
			$contract_ref = $v8->Справочники->Договоры->ПолучитьСсылку($contract_id);
			$client_ext_id = $v8->String($contract_ref->Контрагент->УникальныйИдентификатор());
		}
		else{
			$struc_client = NULL;			
			client1c_struc_from_params($v8,$params,$struc_client);
			$struc_contract = NULL;			
			contract1c_struc_from_params($v8,$params,$struc_contract);		
			$obr = get_ext_obr($v8);
			$obr->ОпределитьКонтрагента($struc_client);
			$obr->ОпределитьДоговор($struc_contract,$struc_client);
			$contract_ref = $struc_contract->ref; 
			$client_ext_id = $v8->String($struc_client->ref->УникальныйИдентификатор());
		}	
		$q_obj = $v8->NewObject('Запрос');
		$q_obj->Текст ="
		ВЫБРАТЬ
		Ссылка,
		Номер,
		Дата,
		ВЫРАЗИТЬ(ЕСТЬNULL(СуммаДокумента,0) КАК ЧИСЛО(15,2)) AS Сумма
		ИЗ Документ.СчетНаОплату
		ГДЕ Док.Договор=&Договор
		";
		$q_obj->УстановитьПараметр('Договор',$contract_ref);
		$sel = $q_obj->Выполнить()->Выбрать();
		
		$xml_body = sprintf('<contrcat_ext_id>%s<contrcat_ext_id>',$v8->String($contract_ref->УникальныйИдентификатор())).
			sprintf('<client_ext_id>%s<client_ext_id>',$client_ext_id);
		while ($sel->Следующий()){
			$sm = float1c_to_float($sel->Сумма);
			if ($sm<>0){
				$xml_body.='<rec>'.
					sprintf('<ext_id>%s</ext_id>',$v8->String($sel->Ссылка->УникальныйИдентификатор())).
					sprintf('<number>%s</number>',$v8->String($sel->Номер)).
					sprintf('<date>%s</date>',date1c_to_ISO($v8,$sel->Дата)).					
					sprintf('<total>%f</total>',$sm).
					'</rec>';
			}
		}
		return $xml_body;
	}
?>
