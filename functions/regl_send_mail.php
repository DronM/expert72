<?php
require_once("db_con.php");
require_once("ExpertEmailSender.php");

ExpertEmailSender::sendAllMail(TRUE,$dbLink);
?>
