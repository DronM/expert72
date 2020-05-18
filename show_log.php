<?php
$cnt = 3;

//$file='/usr/share/nginx/error.log';
$file='log';

$linecount = 0;
$handle = fopen($file, "r");
while(!feof($handle)){
	$line = fgets($handle);
	$linecount++;
}
$linecount--;
echo 'LineCount='.$linecount;
echo '</br>';

$from = 9;

$from_ind = $linecount - $from - $cnt;
$shown = 0;
echo 'from_ind='.$from_ind.'</BR>';
$lines_to_print = [];
rewind($handle);
$l = 0;
while(!feof($handle)){
	$line = fgets($handle);
	if($shown>=$cnt){
		break;
	}
	else if($l >= $from_ind){
		array_push($lines_to_print,$line);
		$shown++;
	}
	$l++;
}
fclose($handle);

for($i=count($lines_to_print)-1;$i>=0;$i--){
	echo $lines_to_print[$i].'</br>';
}

/*
$from = $linecount - $cnt;
rewind($handle);
$l = 0;
while(!feof($handle)){
	$line = fgets($handle);
	if($l==$from+$cnt){
		break;
	}
	else if($l > $from){
		echo $line.'</br>';
	}
	$l++;
}

fclose($handle);
*/
/*

echo '</br>';
echo '</br>';

exec('tail '.$file, $error_logs);

  foreach($error_logs as $error_log) {

       echo "<br />".$error_log;
  }
*/
  
?>  
