<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowIn'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{

	const ER_NO_ATTACH = 'У данного документ нет вложенных файлов!';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public function insert($pm){
		if ($_SESSION['role_id'!='client']){
			if ($_SESSION['employees_ref']){
				$ar = json_decode($_SESSION['employees_ref'],TRUE);
				$pm->setParamValue('employee_id',$ar['RefType']['id']);
			}
			else{
				throw new Exception(self:: ER_EMPLOYEE_NOT_DEFINED);
			}
		}
		
		return parent::insert($pm);
	}

	public function get_state($id,$type='in'){
		parent::get_state($id,$type);
	}

	public function delete($pm){
		$this->delete_attachments($pm,'in');
	}
	
	public function remove_file($pm){
		$this->remove_afile($pm,'in');
	}
	public function remove_sig($pm){
		$this->remove_asig($pm,'in');
	}
	
	public function get_next_num($pm){
		$this->get_next_num_on_type('in', $this->getExtDbVal($pm,'doc_flow_type_id'));
	}

	public function download_attachments($pm){
		$er_h_stat = 500;//unknown
		try{
			$doc_id = $this->getExtDbVal($pm,'doc_flow_in_id');
		
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					files,reg_number,from_application_id
				FROM doc_flow_in_dialog AS t
				WHERE id=%d",
				$doc_id
			));			
	
			if (!count($ar)){
				$er_h_stat = 400;
				throw new Exception(Application_Controller::ER_APP_NOT_FOUND);
			}
		
			$fl_name = sprintf('attach_%d.zip',$doc_id);		
			$rel_dir = Application_Controller::APP_DIR_PREF.$ar['from_application_id'].DIRECTORY_SEPARATOR.'Исходящие заявителя';
			$file_zip = NULL;
			if (
			!file_exists($file_zip = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$fl_name)
				&amp;&amp;
			(!defined('FILE_STORAGE_DIR_MAIN') || !file_exists($file_zip = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$fl_name))
			){
				//generate
				$files = json_decode($ar['files']);
				if (!count($files) || !count($files[0]->files)){
					$er_h_stat = 400;
					throw new Exception(self::ER_NO_ATTACH);
				}
				
				//take all file ids for getting document_ids from dataBase
				$file_ids = '';
				foreach($files[0]->files as $file){
					$file_ids.= ($file_ids=='')? '':',';
					$file_ids.= "'".$file->file_id."'";
				}
				$q_paths = $this->getDbLink()->query(sprintf(
					"SELECT
						file_id,document_id,document_type	
					FROM application_document_files AS t
					WHERE file_id IN (%s)",
					$file_ids
				));			
				$ar_paths = [];
				while($path = $this->getDbLink()->fetch_array($q_paths)){
					$ar_paths[$path['file_id']] = array('document_id'=>$path['document_id'],'document_type'=>$path['document_type']);
				}
				
				$file_zip = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$fl_name;
				mkdir(FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir,0777,TRUE);
				$zip = new ZipArchive();
				if ($zip->open($file_zip, ZIPARCHIVE::CREATE)!==TRUE) {
					throw new Exception(Application_Controller::ER_MAKE_ZIP);
				}
				$cnt = 0;
				foreach($files[0]->files as $file){
					$rel_file = Application_Controller::APP_DIR_PREF.$ar['from_application_id'].DIRECTORY_SEPARATOR.
						(($ar_paths[$file->file_id]['document_id']==0)? '' : Application_Controller::dirNameOnDocType($ar_paths[$file->file_id]['document_type']).DIRECTORY_SEPARATOR).
						(($ar_paths[$file->file_id]['document_id']==0)? $file->file_path : $ar_paths[$file->file_id]['document_id']).DIRECTORY_SEPARATOR.
						$file->file_id
					;
					if (
						(file_exists($file_for_zip=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_file) &amp;&amp; !is_dir($file_for_zip) )
						||(defined('FILE_STORAGE_DIR_MAIN') &amp;&amp;  (file_exists($file_for_zip=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_file)&amp;&amp;!is_dir($file_for_zip)) )
					){
						$rel_file_path = (($ar_paths[$file->file_id]['document_id']==0)? '' : Application_Controller::dirNameOnDocType($ar_paths[$file->file_id]['document_type']).DIRECTORY_SEPARATOR.$file->file_path ).DIRECTORY_SEPARATOR;
						$zip->addFile($file_for_zip, $rel_file_path.$file->file_name);
						
						if (
						$file->file_signed
						&amp;&amp;
						(file_exists($file_for_zip=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_file.Application_Controller::SIG_EXT)
						||(defined('FILE_STORAGE_DIR_MAIN') &amp;&amp;  file_exists($file_for_zip=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_file.Application_Controller::SIG_EXT) )
						)
						){
							$zip->addFile($file_for_zip, $rel_file_path.$file->file_name.Application_Controller::SIG_EXT);
						}
						
						$cnt++;
					}
				}

				if (!$cnt){
					$er_h_stat = 400;
					throw new Exception(self::ER_NO_ATTACH);
				}
				
				if($zip->close()===FALSE){
					$er_h_stat = 500;
					throw new Exception('Ошибка создания архива:'.$zip->getStatusString());
				}
			}

			ob_clean();
			$mime = getMimeTypeOnExt($fl_name);
			downloadFile($file_zip, $mime,'attachment;','Файлы по вход.документу №'.$ar['reg_number'].'.zip');
			return TRUE;
	
		}
		catch(Exception $e){
			$this->setHeaderStatus($er_h_stat);
			throw $e;
		}
	}
	

</xsl:template>

</xsl:stylesheet>
