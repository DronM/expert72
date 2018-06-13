<?php
class ExtProg{

	private static function parseHeaders($headers){
	    $head = array();
	    foreach( $headers as $k=>$v )
	    {
		$t = explode( ':', $v, 2 );
		if( isset( $t[1] ) )
		    $head[ trim($t[0]) ] = trim( $t[1] );
		else{
		    $head[] = $v;
		    if( preg_match( "#HTTP/[0-9\.]+\s+([0-9]+)#",$v, $out ) )
		        $head['reponse_code'] = intval($out[1]);
		        $head['reponse_descr'] = $v;
		}
	    }
	    return $head;
	}
	
	/* $fileOpts = array('name',disposition,contentType,toFile boolean)*/
	private static function send_query($cmd,$params,&$xml,$fileOpts=NULL){
		$CON_TIMEOUT = 300;		
		
		if(!defined('HOST_1C')||!defined('PORT_1C')){
			throw new Exception('Нет настроек доступа к 1с!');
		}
		
		/*
		$par_str = '';
		foreach($params as $name=>$val){
			$par_str.= '&'.$name.'='.$val;
		}
		file_put_contents('output/q_'.uniqid().'.xml',$cmd.$par_str);
		if ($cmd=="print_order"){
			file_put_contents('output/print_fileOpts',var_export($fileOpts));
		}
		*/
		/*
		$par_str = '';
		foreach($params as $name=>$val){
			$par_str.= '&'.$name.'='.$val;
		}
		//throw new Exception('http://'.HOST_1C.'/API1c.php?cmd='.$cmd.$par_str);
		set_time_limit($CON_TIMEOUT);
		$res = @fopen('http://'.HOST_1C.':'.PORT_1C.'/API1c.php?cmd='.$cmd.$par_str,'r');
		if (!$res) {
			throw new Exception('Ошибка соединения с сервером 1с');
		}
		stream_set_timeout($res,$CON_TIMEOUT);		
		$contents = '';
		while (!feof($res)) {
		  $contents .= fread($res, 8192);
		}
		fclose($res);
		*/
		
		$params['cmd'] = $cmd;
		$options = array(
			'http' => array(
				'method'  => 'POST',
				'header'  => array(
					'Content-type: application/x-www-form-urlencoded; charset="utf-8"'
					),
				'content' => http_build_query($params)
			)
		);
		$context = stream_context_create($options);
		$contents = file_get_contents('http://'.HOST_1C.':'.PORT_1C.'/API1c.php', FALSE, $context);
		
		$header_res = self::parseHeaders($http_response_header);
		if ($header_res['reponse_code'] && $header_res['reponse_code']!=200){
			throw new Exception($header_res['reponse_descr']);
		}
		
		//ответ всегда в ANSI
		//file_put_contents('output/cont_'.uniqid().'.xml',$contents);		
		if (!is_null($fileOpts) && is_array($fileOpts)){
			if (!array_key_exists('name',$fileOpts)){
				$fileOpts['name'] = uniqid().'.pdf';
			}
		
			if (array_key_exists('toFile',$fileOpts) && $fileOpts['toFile']==TRUE){
				file_put_contents(OUTPUT_PATH.$fileOpts['name'],$contents);
				return OUTPUT_PATH.$fileOpts['name'];
			}
			else{
				if (!array_key_exists('contentType',$fileOpts)){
					$p = strpos($fileOpts['name'],'.');
					if ($p !== FALSE){
						$ext = substr($fileOpts['name'],$p+1);
						if (in_array($ext,array('zip','pdf','xls'))){
							$fileOpts['contentType'] = 'application/'.$ext;
						}
					}
					if (!array_key_exists('contentType',$fileOpts)){
						$fileOpts['contentType'] = 'application/octet-stream';
					}
				}
				if (!array_key_exists('disposition',$fileOpts)){
					$fileOpts['disposition'] = 'attachment';
				}
				ob_clean();//attachment
				header("Content-type: ".$fileOpts['contentType']);
				header("Content-Disposition: ".$fileOpts['disposition']."; filename=\"".$fileOpts['name']."\"");		
				header("Content-length: ".strlen($contents));
				header("Cache-control: private");
				echo $contents;
			}			
		}
		else if (!strlen($contents)){
			throw new Exception('Нет доступа к серверу 1с!');
		}
		else{
			$contents = @iconv('Windows-1251','UTF-8',$contents);
			//file_put_contents('output/cont_'.uniqid().'.xml',$contents);		
			//throw new Exception("ОШИБКА!!!=".$contents);//$contents
			
			try{
				$xml = new SimpleXMLElement($contents);
			}
			catch(Exception $e){
				throw new Exception('Ошибка парсинга ответа 1с:'.$e->getMessage().' Строка: '.$contents);
			}
			
			if ($xml['status']=='false'){
				$e = (string) $xml->error;
				throw new Exception($e);
			}							
		}		
	}

	public static function get_payments($dateFrom,$dateTo,&$xml){
		ExtProg::send_query('get_payments',array('date_from'=>date('Y-m-d',$dateFrom),'date_to'=>date('Y-m-d',$dateTo)),$xml);
	}
	
	public static function get_order_list(&$params,&$res){
		//debugg
		/*
		$res['contract_ext_id'] = uniqid();
		$res['client_ext_id'] = uniqid();
		$res['orders'] = [];
		array_push($res['orders'],array(
			'ext_id'=>uniqid(),
			'number'=>'123456',
			'date'=>'2018-05-14',
			'total'=>500000
		));		
		array_push($res['orders'],array(
			'ext_id'=>uniqid(),
			'number'=>'Ord-7777',
			'date'=>'2018-05-14',
			'total'=>200000
		));		
		
		return;
		*/
		$xml=null;
		ExtProg::send_query('get_order_list',
			array('params'=>serialize($params)),
			$xml
		);
		$res['contract_ext_id'] = (string)$xml->contract_ext_id;
		$res['client_ext_id'] = (string)$xml->client_ext_id;
		$res['orders'] = [];
		foreach ($xml->rec as $rec){
			array_push($res['orders'],array(
				'ext_id'=>(string)$rec->ext_id,
				'number'=>(string)$rec->number,
				'date'=>(string)$rec->date,
				'total'=>(float) $rec->total
			));
		}
	}

	public static function print_doc($cmd,$docId,$stamp=FALSE,$fileOpts=NULL){
		/*
		$contents = file_get_contents('/home/andrey/www/htdocs/expert72/uploads/0b97dcc2-30c3-4eb7-8680-211c0fe438ea');
		$fileOpts['contentType'] = 'application/pdf';
		ob_clean();//attachment
		header("Content-type: ".$fileOpts['contentType']);
		header("Content-Disposition: ".$fileOpts['disposition']."; filename=\"".$fileOpts['name']."\"");		

		header("Content-length: ".strlen($contents));
		header("Cache-control: private");
		echo $contents;
		return;	
		*/
		$xml=null;
		ExtProg::send_query($cmd,
			array('doc_ext_id'=>$docId,'stamp'=>($stamp? '1':'0')),
			$xml,$fileOpts
		);
	}			
	
	public static function print_order($docId,$stamp=FALSE,$fileOpts=NULL){
		self::print_doc('print_order',$docId,$stamp,$fileOpts);
	}			

	/**
	 */
	public static function print_akt($docId,$stamp=FALSE,$fileOpts=NULL){
		self::print_doc('print_akt',$docId,$stamp,$fileOpts);
	}			

	public static function print_invoice($docId,$stamp=FALSE,$fileOpts=NULL){
		self::print_doc('print_invoice',$docId,$stamp,$fileOpts);
	}			
	
	public static function make_order(&$params,&$res){
		/*
		$res['contract_ext_id']	= uniqid();
		$res['client_ext_id']	= uniqid();
		$res['doc_ext_id']	= uniqid();
		$res['doc_date']	= '2018-05-14';
		$res['doc_number']	= '123456';	
		return;
		*/
		$xml=null;
		ExtProg::send_query('make_order',
			array('params'=>serialize($params)),
			$xml
		);
		$res['contract_ext_id']	= (string)$xml->contract_ext_id;
		$res['client_ext_id']	= (string)$xml->client_ext_id;		
		$res['doc_ext_id']	= (string)$xml->doc_ext_id;
		$res['doc_date']	= (string)$xml->doc_date;
		$res['doc_number']	= (string)$xml->doc_number;
	}
	
	public static function make_akt(&$params,&$res){
		/*
		$res['doc_ext_id']	= uniqid();
		$res['doc_date']	= '2018-05-14';
		$res['doc_number']	= '111222333';
		$res['doc_total']	= 900000;
		$res['contract_ext_id']	= uniqid();
		$res['invoice_ext_id']	= uniqid();
		$res['invoice_number']	= 'Inv-123';
		$res['invoice_date']	= '2018-05-14';
		return;
		*/
		$xml=null;
		ExtProg::send_query('make_akt',
			array('params'=>serialize($params)),
			$xml
		);
		$res['doc_ext_id']	= (string)$xml->doc_ext_id;
		$res['doc_date']	= (string)$xml->doc_date;
		$res['doc_number']	= (string)$xml->doc_number;
		$res['doc_total']	= (float)$xml->doc_total;
		$res['contract_ext_id']	= (string)$xml->contract_ext_id;
		$res['invoice_ext_id']	= (string)$xml->invoice_ext_id;
		$res['invoice_number']	= (string)$xml->invoice_number;
		$res['invoice_date']	= (string)$xml->invoice_date;
	}
}
?>
