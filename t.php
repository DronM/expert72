<?php
//echo pathinfo('/home/andrey/www/htdocs/expert72/version.php', PATHINFO_EXTENSION);
/*
$ar = json_decode('{"id": "DownloadFileType_Model", "rows": [{"fields": {"ext":"pdf"}}, {"fields": {"ext":"odt"}}, {"fields": {"ext":"ods"}}, {"fields": {"ext":"xls"}}, {"fields": {"ext":"xlsx"}}, {"fields": {"ext":"doc"}}, {"fields": {"ext":"docx"}}]}',TRUE);
$ext_ar = array();
foreach($ar['rows'] as $row){
	array_push($ext_ar,strtolower($row['fields']['ext']));
	
}
//var_dump($ext_ar);
echo 'PDF='.in_array('ccc',$ext_ar).'</br>';
*/

//require_once('functions/morpher.php');

//$xml = declension('Кучерявый Алексей Александрович');
//var_dump($xml);

$ar = json_decode('{"inn": "9999999999", "kpp": "7203010011", "bank": "{\"bank\":{\"RefType\":{\"keys\":{\"bik\":\"040001002\"},\"descr\":\"ПУ БАНКА РОССИИ N 43192\"}},\"acc_number\":\"99999999999999999999\"}", "name": "ООО \"Катрэн+\"", "ogrn": "555555555555", "name_full": "Общество с ограниченной ответственностью  \"Катрэн+\"", "client_type": "enterprise", "post_address": "{\"region\":{\"RefType\":{\"keys\":{\"region_code\":\"7200000000000\"},\"descr\":\"Тюменская обл\"}},\"raion\":{\"RefType\":{\"keys\":null,\"descr\":null}},\"naspunkt\":{\"RefType\":{\"keys\":null,\"descr\":null}},\"gorod\":{\"RefType\":{\"keys\":{\"gorod_code\":\"7200000100000\"},\"descr\":\"Тюмень г\"}},\"ulitsa\":{\"RefType\":{\"keys\":{\"ulitsa_code\":\"72000001000016600\"},\"descr\":\"Республики ул\"}},\"dom\":\"10\",\"korpus\":null,\"kvartira\":null}", "legal_address": "{\"region\":{\"RefType\":{\"keys\":{\"region_code\":\"7200000000000\"},\"descr\":\"Тюменская обл\"}},\"raion\":{\"RefType\":{\"keys\":null,\"descr\":null}},\"naspunkt\":{\"RefType\":{\"keys\":null,\"descr\":null}},\"gorod\":{\"RefType\":{\"keys\":{\"gorod_code\":\"7200000100000\"},\"descr\":\"Тюмень г\"}},\"ulitsa\":{\"RefType\":{\"keys\":{\"ulitsa_code\":\"72000001000016600\"},\"descr\":\"Республики ул\"}},\"dom\":\"10\",\"korpus\":null,\"kvartira\":null}", "fillOnCustomer": "По заказчику", "fillOnClientList": "Выбрать из списка клиентов", "fillOnContractor": "По исполнителю", "responsable_persons": "{\"id\":\"ClientResponsablePerson_Model\",\"rows\":[{\"fields\":{\"id\":1,\"name\":\"Михалевич Андрей Александрович\",\"post\":\"Директор\",\"tel\":\"9222695251\",\"person_type\":\"boss\"},\"inserted\":\"1\"}]}", "responsable_person_head": "{\"name\":\"Михалевич Андрей\",\"post\":\"Директор\",\"tel\":\"9222695251\",\"email\":\"katren_shd@rambler.ru\"}", "base_document_for_contract": "Устав"}',TRUE);
$b = json_decode($ar['bank'],TRUE);
var_dump($b['bank']['RefType']['keys']['bik']);//['RefType']
?>
