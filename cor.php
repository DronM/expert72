<?php
//$dir = '/home/andrey/www/htdocs/expert72/client_files/Заявление№1458/Достоверность';
$dir = '/home/andrey/storage/Documents/Заявление№1732/Достоверность';

$document_id = '';
unlink('cor.sql');
function iterate_rec($dir,$document_id,&$ind){
	$objects = scandir($dir); 
	$f_name = 'cor.sql';
	foreach ($objects as $object) { 
		if ($object != "." && $object != "..") { 
			if (is_dir($dir."/".$object)){
				$document_id = $object;
				echo 'found DIR '.$object.'</br>';
				iterate_rec($dir."/".$object,$document_id,$ind);
				/*
				file_put_contents($f_name,
					sprintf("DELETE FROM application_document_files
					where application_id=1732 AND document_id=%s;".PHP_EOL,
					$object,$document_id),
					FILE_APPEND
				);
				*/
			}
			else{				
				if (substr($object,strlen($object)-4,4)!='.sig'){
					echo 'found file '.$object.'</br>';
					file_put_contents($f_name,
						sprintf("UPDATE application_document_files
						set file_id_old=file_id,file_id='%s'
						WHERE application_id=1732 AND document_id=%d AND file_size=%d;".PHP_EOL,
						$object,$document_id,filesize($dir."/".$object)),
						FILE_APPEND
					);
				
					/*
					$ft = filemtime($dir."/".$object);
					$file_dt1 = date('Y-m-d H:i:s',$ft-1);
					$file_dt2 = date('Y-m-d H:i:s',$ft+1);
					file_put_contents($f_name,
						sprintf("INSERT INTO application_document_files
						(file_id, application_id, document_id, document_type, date_time, 
            					file_name, file_path, file_signed, file_size)
            					values 
            					('%s',1732,%d,'cost_eval_validity','%s',
            					%d,%s,TRUE,%f)
						';".PHP_EOL,
						$object,$document_id,date('Y-m-d H:i:s',$ft),
						$ind,'',filesize($dir."/".$object)),
						FILE_APPEND
					);
					*/
					$ind++;
				}
			}
		} 
	}
}
$ind = 1;
iterate_rec($dir,$document_id,$ind);

?>
