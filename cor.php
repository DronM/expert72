<?php
$dir = '/home/andrey/www/htdocs/expert72/client_files/Заявление№1458/Достоверность';

$document_id = '';
unlink('cor.sql');
function iterate_rec($dir,$document_id){
	$objects = scandir($dir); 
	$f_name = 'cor.sql';
	foreach ($objects as $object) { 
		if ($object != "." && $object != "..") { 
			if (is_dir($dir."/".$object)){
				$document_id = $object;
				echo 'found DIR '.$object.'</br>';
				iterate_rec($dir."/".$object,$document_id);
			}
			else{
				//echo 'found file '.subst($object,strlen($object)-4,4).'</br>';
				if (substr($object,strlen($object)-4,4)!='.sig'){
					$file_dt = date('Y-m-d H:i:s',filemtime($dir."/".$object));
					file_put_contents($f_name,
						sprintf("UPDATE application_document_files
						SET file_id_old=file_id,file_id='%s'
						where application_id=1660 AND document_id=%s
						AND date_time::timestamp(0)='%s';".PHP_EOL,
						$object,$document_id,$file_dt),
						FILE_APPEND
					);
				}
			}
		} 
	}
}

iterate_rec($dir,$document_id);

?>
