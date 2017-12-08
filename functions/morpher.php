<?php
require_once('db_con.php');

function morpher_inflect($text){
    $credentials = array('Username'=>'test', 
                         'Password'=>'test');
    
    $header = new SOAPHeader('http://morpher.ru/', 
                         'Credentials', $credentials);        
    
    $url = 'http://morpher.ru/WebService.asmx?WSDL';

    $client = new SoapClient($url); 
    
    $client->__setSoapHeaders($header);

    $params = array('parameters'=>array('s'=>$text));

    $result = (array) $client->__soapCall('GetXml', $params); 

    $singular = (array) $result['GetXmlResult']; 

    return $singular;
}
 
function declension($dbLink,$src){
	$ar = $dbLink->query_first(sprintf("SELECT res FROM morpher WHERE src = '%s'",$src));
	$res = '';
	if (!is_array($ar) || !count($ar) || !isset($ar['res'])){
		$res = morpher_inflect($src);
		$dbLink->query(sprintf("INSERT INTO morpher (src,res) VALUES ('%s','%s')",$src,serialize($res)));
	}
	else{
		$res = unserialize($ar['res']);
	}
	return $res;
}

//$res = declension($dbLink,'Государственное автономное учреждение Тюменской области "Управление государственной экспертизы проектной документации"');
//var_dump($res);

?>
