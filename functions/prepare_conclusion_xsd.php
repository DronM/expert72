<?php
/**
 * В качестве источника берется оригинальный файл views/conclusion.xsd
 * на выходе получаем исправленный файл views/conclusion_corrected.xsd
 *
 *	Добавляем к xs:schema атрибут xmlns:xerces="http://xerces.apache.org"
 *	xs:assert/xs:annotation/xs:documentation превращает в трибут xs:assert xerces:message=""
 */
 
$source = dirname(__FILE__).'/../views/conclusion.xsd';
$target = dirname(__FILE__).'/../views/conclusion_corrected.xsd';

if(!file_exists($source)){
	die('Source file not found!');
}
if(!file_exists($xslt_file)){
	die('XSLT file not found!');
}

$dom = new DOMDocument();
$dom->load($source);

//1)
$schema_col = $dom->getElementsByTagName('schema');
if ($schema_col->length==0) {
   // no versions node
   throw new Exception('schema node not found!');
} 
$schema_col[0]->setAttribute('xmlns:xerces', "http://xerces.apache.org");
echo 'Добавили пространство имен</br>';

//2)
$assert_col = $dom->getElementsByTagName('assert');
for($i=0; $i<$assert_col->length; $i++){
	$ch = $assert_col->item($i)->childNodes;
	if($ch && $ch->length){
		for($j=0; $j<$ch->length; $j++){
			if($ch->item($j)->nodeName=='xs:annotation'){
				$ch2 = $ch->item($j)->childNodes;
				if($ch2 && $ch2->length){
					for($k=0; $k<$ch2->length; $k++){
						if($ch2->item($k)->nodeName=='xs:documentation'){
							$comment = trim($ch2->item($k)->nodeValue);
							if(strlen($comment)){
								$assert_col->item($i)->setAttribute("xerces:message", $comment);
								echo 'Добавили атрибут message '.$comment.'</br>';
							}
							break;
						}
					}
				}
				break;
			}
		}
	}
}

$dom->preserveWhiteSpace = false;
$dom->formatOutput = true;						
$dom->save($target);

?>

