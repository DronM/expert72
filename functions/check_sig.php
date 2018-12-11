<?php
require_once('db_con.php');
require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

$pki_man = pki_create_manager();

$file_id = '';
$file_doc = '';
$file_sig = $file_doc.'.sig';

$verif_res = pki_log_sig_check($file_sig, $file_doc, "'".$fileId."'", $pki_man, $dbLink,TRUE);
pki_throw_error($verif_res,$dbFileId,$dbLink);

?>
