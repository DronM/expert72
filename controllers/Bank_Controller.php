<?php
require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQL.php');

require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtXML.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */


class Bank_Controller extends ControllerSQL{

	const REFRESH_URL = 'http://cbrates.rbc.ru/bnk/bnk.zip';

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			
		/* get_list */
		$pm = new PublicMethod('get_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

		$this->addPublicMethod($pm);
		
		$this->setListModelId('BankList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtInt('browse_mode'));
		
		$pm->addParam(new FieldExtString('bik'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('BankList_Model');		

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('bik'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('BankList_Model');

		
	}	
	

	private static function bank_type($str){
		if ($str=="00"){
			$res = "ГРКЦ ";    
		}
		else if ($str=="10"){
			$res = "РКЦ ";    
		}
		else if ($str=="20"){
			$res = "Б ";    
		}
		else if ($str=="21"){
			$res = "КБ ";    
		}
		else if ($str=="22"){
			$res = "СБ ";    
		}
		else if ($str=="23"){
			$res = "АКБ ";    
		}
		else if ($str=="24"){
			$res = "ЧКБ ";    
		}
		else if ($str=="25"){
			$res = "КОПБ ";    
		}
		else if ($str=="26"){
			$res = "АПБ ";    
		}
		else if ($str=="30"){
			$res = "ФБ ";    
		}
		else if ($str=="31"){
			$res = "ФКБ ";    
		}
		else if ($str=="32"){
			$res = "Отд. ";    
		}
		else if ($str=="33"){
			$res = "ФАКБ ";    
		}
		else if ($str=="34"){
			$res = "ФЧКБ ";    
		}
		else if ($str=="35"){
			$res = "ФКОБ ";    
		}
		else if ($str=="36"){
			$res = "Отд. ";    
		}
		else if ($str=="40"){
			$res = "ПУ ";    
		}
		else if ($str=="50"){
			$res = "ЦХ ";    
		}
		else if ($str=="70"){
			$res = "КУ ";    
		}
		else if ($str=="71"){
			$res = "КЛ ";    
		}
		else if ($str=="72"){
			$res = "ОРЦБ ";    
		}
		else if ($str=="98"){
			$res = "ИСКЛ ";    
		}
		else if ($str=="99"){
			$res = "ОТЗВ ";    
		}
		else if ($str=="90"){
			$res = "ЛИКВ ";    
		}
		else{
			$res = '';
		}
		
		return $res;
	}  // ТипБанка(Стр)

	private static function get_type($str){
		if ($str=="1"){
			$res = "Г.";       // ГОРОД
		}
		else if ($str=="2"){
			$res = "П.";       // ПОСЕЛОК
		}
		else if ($str=="3"){
			$res = "С.";       // СЕЛО
		}
		else if ($str=="4"){
			$res = "ПГТ.";     // ПОСЕЛОК ГОРОДСКОГО ТИПА
		}
		else if ($str=="5"){
			$res = "СТ-ЦА.";   // СТАНИЦА
		}
		else if ($str=="6"){
			$res = "АУЛ.";     // АУЛ
		}
		else if ($str=="7"){
			$res = "РП.";      //  РАБОЧИЙ ПОСЕЛОК 
		}
		else{
			$res = '';
		}
		return $res;
	} // ТипГорода(Стр)

	public static function delTree($dir) {
		$files = array_diff(scandir($dir), array('.','..'));
		foreach ($files as $file) {
		(is_dir("$dir/$file")) ? delTree("$dir/$file") : unlink("$dir/$file");
		}
		return rmdir($dir);
	} 
	
	public static function refresh($link){
	
		function cyr_str_decode($str){
			return iconv('WINDOWS-1251','UTF-8',$str);
		}
		
		$resHandle = fopen(self::REFRESH_URL, 'r');
		if (!$resHandle) {
			throw new Exception('Ошибка чтения ресурса '.self::REFRESH_URL);
		}
		$contents = '';
		while (!feof($resHandle)) {
		  $contents .= fread($resHandle, 8192);
		}
		$fname = OUTPUT_PATH.uniqid();
		file_put_contents($fname,$contents);

//$fname = OUTPUT_PATH.'597f23b9749dd';
		try{
			$zip = new ZipArchive();
			if ($zip->open($fname) === TRUE) {
				$dir = OUTPUT_PATH.uniqid();
				mkdir($dir);
						
				$zip->extractTo($dir.DIRECTORY_SEPARATOR);
				$zip->close();

				//groups			    
				$handle = fopen($dir.DIRECTORY_SEPARATOR."reg.txt", "r");
				if ($handle) {
				    while (($line = fgets($handle)) !== false) {
					if (substr($line,0,2) == "//" || $line==''){
						continue;
					}
					$ar = preg_split("/[\t]/", $line);
					if (count($ar)>=3){
						$gr_code = $ar[0];
						$gr_descr = cyr_str_decode($ar[1]);
						$gor = cyr_str_decode($ar[2]);
						//echo(sprintf(
						$link->query(sprintf(						
						"SELECT banks_upsert('%s'::text,NULL,'%s'::text,NULL,NULL,NULL,TRUE)",
						$gr_code,$gr_descr,$gor));//.PHP_EOL
					}
				    }

				    fclose($handle);
				} else {
				    throw new Exception("ERROR opening reg file!");
				} 				
				
				//BIKS
				$handle = fopen($dir.DIRECTORY_SEPARATOR."bnkseek.txt", "r");
				if ($handle) {
				    while (($line = fgets($handle)) !== false) {
					if (substr($line,0,2) == "//" || $line==''){
						continue;
					}
					$ar = preg_split("/[\t]/", $line);
					if (count($ar)>=6){
						$PZN = self::bank_type($ar[0]);
						$gor = self::get_type($ar[2]).cyr_str_decode($ar[1]);
						
						$name = str_replace("  "," ",cyr_str_decode($ar[3]));
						$name = str_replace(". ",".",$name);
						
						/*
						$name = ($ar[4]=='+')?
							$name:
							trim((strpos($name,",".$PZN.",")>=0)? $PZN:'').' '.$name;
						*/
						$bik = trim($ar[5]);
						$korshet = trim($ar[6]);
						
						//echo(sprintf(
						$link->query(sprintf(						
						"SELECT banks_upsert('%s'::text,'%s'::text,'%s'::text,'%s'::text,NULL,'%s'::text,FALSE)",
						$bik,substr($bik,2,2),$name,$korshet,$gor));//.PHP_EOL
					}
				    }

				    fclose($handle);
				} else {
				    throw new Exception("ERROR opening bik file!");
				} 				
				
			    
			} else {
			    throw new Exception("ERROR opening archive!");
			}		
		}
		finally{
			if (isset($fname) && file_exists($fname)){
				unlink($fname);
			}
			if (isset($dir) && file_exists($dir)){
				self::delTree($dir);
			}
		}		
	}
	

}
?>