<?php

class Morpher {

	const HOST = 'http://ws3.morpher.ru';

	function morpher_inflect($cmd,&$params){
		$params['format'] = 'json';
		$par_str = '';
		foreach($params as $n=>$v){
			$par_str.= ($par_str=='')? '':'&';
			$par_str.= $n.'='.urlencode($v);
		}
		$q = sprintf('%s/%s?%s',self::HOST,$cmd,$par_str);
		$res = @fopen($q,'r');
		
		if (!$res) {
			throw new Exception('Ошибка соединения с сервером morpher '.$q);
		}
		
		$contents = '';
		while (!feof($res)) {
			$contents .= fread($res, 8192);
		}
		fclose($res);
		return json_decode($contents,TRUE);
	}
	
	//https://ws3.morpher.ru/russian/spell?n=235&unit=рубль
	
	public static function declension($params,$dbLinkMaster=NULL,$dbLink=NULL){
		$ar = NULL;
		$link_read = $dbLink? $dbLink : $dbLinkMaster;
		if ($link_read){
			$ar = $link_read->query_first(sprintf("SELECT res FROM morpher WHERE src = '%s'",$params['s']));
		}
		$res = '';
		if (!is_array($ar) || !count($ar) || !isset($ar['res'])){
			$res = self::morpher_inflect('russian/declension',$params);
			if ($dbLinkMaster){
				try{
					$dbLinkMaster->query(sprintf("INSERT INTO morpher (src,res) VALUES ('%s','%s')",$params['s'],serialize($res)));
				}
				catch(Exception $e){			
				}
			}
		}
		else{
			$res = unserialize($ar['res']);
		}
		return $res;
	}
}

?>
