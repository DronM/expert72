
<?php
	require_once('common/NoXMLSpace.class.php');
	
	require_once('Config.php');
	$xslt_file = USER_VIEWS_PATH. 'conclusionCorrect.xsl';
	
	$doc = new DOMDocument();     
	$xsl = new XSLTProcessor();
	$doc->load($xslt_file);
	$xsl->importStyleSheet($doc);
	
	$xmlDoc = new DOMDocument();
	$xmlDoc->loadXML(file_get_contents(ABSOLUTE_PATH.'build/concl_test.xml'));
	
	/*if(!$xmlDoc->schemaValidate($xsd_file)){
		throw new Exception('Заключение не соответствует схеме!');
	}
	*/
	
	//$xmlDoc->formatOutput=TRUE;
	//$xmlDoc->save('page.xml');
	$outFile = OUTPUT_PATH.'concl_test.xml';
	
$xmlAsString = $xsl->transformToXML($xmlDoc);	

$doc = new DOMDocument();
$doc->loadXML($xmlAsString);
$xpath = new DOMXPath($doc);
foreach ($xpath->query('//text()') as $text) {
    $text->data = trim($text->data);
}
$doc->normalizeDocument();
$doc->formatOutput = TRUE;
$doc->save($outFile);	
//$xml = simplexml_load_string($xmlAsString);
//NoXMLSpace::noSpace($xml);
//$xml->asXml($outFile);
	//file_put_contents($outFile, $xmlAsString);

/*$doc = new DOMDocument();
$doc->loadXML($xmlAsString);
$xp    = new DOMXPath($doc);
$texts = $xp->query('//*[*]/text()');
foreach ($texts as $text) {
    $text->nodeValue = preg_replace('~\s+~u', '', $text->textContent);
}
$doc->save($outFile);	
*/	
	//file_put_contents($outFile, $xmlAsString);
	
	/*$xmlDoc_f = new DOMDocument();
	$xmlDoc_f->loadXML($xmlAsString);
	$xmlDoc_f->formatOutput=TRUE;
	$xmlDoc_f->preserveWhiteSpace = FALSE;
	$xmlDoc_f->save(OUTPUT_PATH.'concl_test_f.xml');
	*/
?>
