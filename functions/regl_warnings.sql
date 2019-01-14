<?php
	require_once('db_con.php');
	
	$dbLink->query("SELECT email_warn_expert_work_end(3)");
	$dbLink->query("SELECT email_warn_work_end(3)");
?>
