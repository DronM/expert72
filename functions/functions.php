<?php

	function cyr_str_decode($str){
		return iconv('UTF-8','Windows-1251',$str);
	}
	function cyr_str_encode($str){
		//Ответ отправляем в ANSI
		return $str;//iconv('Windows-1251','UTF-8',$str);
	}

?>
