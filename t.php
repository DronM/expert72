<?php
phpinfo();
return;
//http://localhost/expert72/index.php?c=Contract_Controller&v=Child&f=get_object&t=ContractDialog&id=4#

echo intval('01');
//header("HTTP/1.0 404 Not Found");
//throw new Exception("Error");
exit;

$v = '{"keys" : {"id" : 2}, "descr" : "Администраторов Администратор Администраторович", "dataType" : "employees"}';
print_r(json_decode($v)->keys->id);
exit;


try{
	try{
		throw new Exception("Test!");
	}
	catch (Exception $e){
		throw $e;
	}
}
catch (Exception $e2){
	echo $e2->getMessage();
}
exit;

$out_file = '/home/andrey/www/htdocs/expert72/output/Документ.odt';
$tmp_file = '/home/andrey/www/htdocs/expert72/output/c2a989fd0386aebea403de5dbce9975d_tmpl.odt';
copy($tmp_file,$out_file);
$CONTENT_NAME = 'content.xml';
$zip = new ZipArchive();
if ($zip->open($out_file)!==TRUE) {
	throw new Exception('Error');
}
$unzipped = '/home/andrey/www/htdocs/expert72/output/'.uniqid().'_'.$CONTENT_NAME;
$data = ['id'=>125,'applicant_name'=>'ООО Рога и Копыта','date'=>'23/01/2018'];
$tmp_data = $zip->getFromName($CONTENT_NAME);
if($tmp_data===FALSE) {
	throw new Exception('Error');
}
$zip->deleteName($CONTENT_NAME);
foreach($data as $f_id=>$f_val){
	$tmp_data = str_replace('{'.$f_id.'}',$f_val,$tmp_data);
}
file_put_contents($unzipped, $tmp_data);
$zip->deleteName($CONTENT_NAME);
$zip->addFile($unzipped, $CONTENT_NAME);        
$zip->close();
unlink($unzipped);
exit;
/*
require_once('functions/db_con.php');
require_once(FRAME_WORK_PATH.'Constants.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');

$s= "andrey' or 'a'='a' '";
$s_out = NULL;
FieldSQLString::formatForDb($dbLink,$s,$s_out);
echo sprintf('SELECT name FROM users where name=%s',$s_out);

exit;

*/

/*
require_once('functions/Morpher.php');

$res = Morpher::declension($dbLink,array('s'=>'Иванов Петр Сергеевич','flags'=>'name'));
echo var_dump($res);
exit;
*/

//echo pathinfo('/home/andrey/www/htdocs/expert72/version.php', PATHINFO_EXTENSION);
/*
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

//$ar = json_decode('{"inn": "9999999999", "kpp": "7203010011", "bank": "{\"bank\":{\"RefType\":{\"keys\":{\"bik\":\"040001002\"},\"descr\":\"ПУ БАНКА РОССИИ N 43192\"}},\"acc_number\":\"99999999999999999999\"}", "name": "ООО \"Катрэн+\"", "ogrn": "555555555555", "name_full": "Общество с ограниченной ответственностью  \"Катрэн+\"", "client_type": "enterprise", "post_address": "{\"region\":{\"RefType\":{\"keys\":{\"region_code\":\"7200000000000\"},\"descr\":\"Тюменская обл\"}},\"raion\":{\"RefType\":{\"keys\":null,\"descr\":null}},\"naspunkt\":{\"RefType\":{\"keys\":null,\"descr\":null}},\"gorod\":{\"RefType\":{\"keys\":{\"gorod_code\":\"7200000100000\"},\"descr\":\"Тюмень г\"}},\"ulitsa\":{\"RefType\":{\"keys\":{\"ulitsa_code\":\"72000001000016600\"},\"descr\":\"Республики ул\"}},\"dom\":\"10\",\"korpus\":null,\"kvartira\":null}", "legal_address": "{\"region\":{\"RefType\":{\"keys\":{\"region_code\":\"7200000000000\"},\"descr\":\"Тюменская обл\"}},\"raion\":{\"RefType\":{\"keys\":null,\"descr\":null}},\"naspunkt\":{\"RefType\":{\"keys\":null,\"descr\":null}},\"gorod\":{\"RefType\":{\"keys\":{\"gorod_code\":\"7200000100000\"},\"descr\":\"Тюмень г\"}},\"ulitsa\":{\"RefType\":{\"keys\":{\"ulitsa_code\":\"72000001000016600\"},\"descr\":\"Республики ул\"}},\"dom\":\"10\",\"korpus\":null,\"kvartira\":null}", "fillOnCustomer": "По заказчику", "fillOnClientList": "Выбрать из списка клиентов", "fillOnContractor": "По исполнителю", "responsable_persons": "{\"id\":\"ClientResponsablePerson_Model\",\"rows\":[{\"fields\":{\"id\":1,\"name\":\"Михалевич Андрей Александрович\",\"post\":\"Директор\",\"tel\":\"9222695251\",\"person_type\":\"boss\"},\"inserted\":\"1\"}]}", "responsable_person_head": "{\"name\":\"Михалевич Андрей\",\"post\":\"Директор\",\"tel\":\"9222695251\",\"email\":\"katren_shd@rambler.ru\"}", "base_document_for_contract": "Устав"}',TRUE);
//$b = json_decode('{"id":"ClientResponsablePerson_Model","rows":[{"fields":{"id":2,"name":"Кучерявый Алексей Анаттольевич","post":"Директор","email":"kkk"}}]}');
//$b = json_decode('[{"document_type" : "pd", "document_id" : "pd_1", "document" : [{"fields":{"id":1,"descr":"РАЗДЕл 1"},"parent_id":null,"items":[{"fields":{"id":4,"descr":"Раздел 1.1"},"parent_id":1}]},{"fields":{"id":2,"descr":"РАЗДЕЛ 2"},"parent_id":null},{"fields":{"id":3,"descr":"РАЗДЕЛ 3"},"parent_id":null,"items":[{"fields":{"id":5,"descr":"Раздел 3.1"},"parent_id":3},{"fields":{"id":6,"descr":"Раздел 3.2"},"parent_id":3}]}]}]');
$params = json_decode('[{"id":"id","val":{"RefType":{"keys":{"id":48},"descr":"Заявление №48 от 22/01/18"}},"cond":true},{"id":"test","val":"gdfg"},{"id":"test2","val":1111,"cond":false}]');
$field_model = json_decode('{"id":"ReportTemplateField_Model","rows":[{"fields":{"id":"id","descr":"Номер заявления"}},{"fields":{"id":"applicant_name","descr":"Наименование заявителя"}}]}');
//print_r($field_model->rows);
//exit;
$columns = '';
$cond = '';
if (is_array($field_model->rows)){
	foreach ($field_model->rows as $row) {
		if (is_object($row->fields)){			
			$columns.= ($columns=='')? '':', ';
			$columns.= $row->fields->id;
		}
	}
}
//print_r($columns);
//exit;
echo '</br>';
foreach($params as $param){
	$field_id = $param->id;
	
	if (is_object($param->val)){
		foreach ($param->val->RefType->keys as $key => $key_val) {
			$val = $key_val;
			//first key
			break;
		}
	}
	else{
		$val = $param->val;
	}
	$val = "'".$val."'";
	if (isset($param->cond) && $param->cond){
		$cond.= ($cond=='')? ' WHERE ':' AND ';
		$cond.= sprintf('%s=%s',$field_id, $val);
	}
	else{
		$columns.= ($columns=='')? '':', ';
		$columns.= sprintf('%s AS "%s"', $val, $field_id);
	}
}
echo "columns=".$columns.'</br>';
echo "cond=".$cond.'</br>';
exit;

foreach($b as $doc){
	print_r($doc->document);
	exit;
	foreach($doc as $obj){
		foreach($obj as $row){
			$row->files = ['name'=>'filename','size'=>1256542,'path'=>'sd/fd'];
			print_r($row);
			//var_dump($row[0]->fields);
			exit;
			echo $row->fields->id.'</br>';
		}
	}
}

//var_dump($b['bank']['RefType']['keys']['bik']);//['RefType']
?>
