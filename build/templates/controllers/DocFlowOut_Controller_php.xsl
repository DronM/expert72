<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowOut'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	private function find_afile($fileId,$fileIdDb,$docIdDb,$sigFile,&amp;$fl,&amp;$fileName,&amp;$exception){
		$ar = $this->getDbLink()->query_first(sprintf(
			"(SELECT
				app_f.file_name,
				app_f.document_type,
				CASE
					WHEN app_f.document_type='documents' THEN app_f.file_path
					ELSE app_f.document_id::text
				END AS file_path,
				TRUE AS is_application,
				application_id AS application_id
			FROM doc_flow_out_client_document_files AS t
			LEFT JOIN doc_flow_in ON doc_flow_in.from_doc_flow_out_client_id=t.doc_flow_out_client_id
			LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id				
			WHERE t.file_id=%s AND doc_flow_in.id=%d)
			UNION ALL
			(SELECT
				t.file_name,
				'documents' AS document_type,
				t.file_path AS file_path,
				TRUE AS is_application,
				out.to_application_id AS application_id
			FROM doc_flow_attachments AS t
			LEFT JOIN doc_flow_out AS out ON t.doc_id=out.id
			WHERE t.doc_type='doc_flow_out'::data_types AND t.doc_id=%d AND t.file_id=%s)				
			",
			$fileIdDb,
			$docIdDb,
			$docIdDb,
			$fileIdDb
		));
	
		if (!count($ar)){
			$exception = new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			return FALSE;
		}
	
		$postf = $sigFile? '.sig':'';
		$document_type_path = Application_Controller::dirNameOnDocType($ar['document_type']);
		$document_type_path.= ($document_type_path=='')? '':DIRECTORY_SEPARATOR;
		if (
		(
			$ar['is_application']=='t'
			&amp;&amp; (!file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
					Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
					$document_type_path.
					$ar['file_path'].DIRECTORY_SEPARATOR.
					$fileId.$postf)
					&amp;&amp;(
						defined('FILE_STORAGE_DIR_MAIN') &amp;&amp;
						!file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
						$document_type_path.
						$ar['file_path'].DIRECTORY_SEPARATOR.
						$fileId.$postf)							
					)
				)
		)
		|| (
			$ar['is_application']!='t'
			&amp;&amp; !file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$fileId.$postf)
		)
		){
			$exception = new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			return FALSE;
		}
	
		$fileName = $ar['file_name'].$postf;
	
		return TRUE;
	}

	private function get_afile($pm,$sigFile){
		try{
			$er_st = 500;
			
			$exception = NULL;
			$fl = NULL;
			$file_name = NULL;
			if (!$this->find_afile(
				$this->getExtVal($pm,'file_id'),
				$this->getExtDbVal($pm,'file_id'),
				$this->getExtDbVal($pm,'doc_id'),
				$sigFile,
				$fl,
				$file_name,
				$exception
			)){
				$er_st = 404;
				throw $exception;
			}
		
			$mime = getMimeTypeOnExt($file_name);
			ob_clean();
			downloadFile($fl, $mime,'attachment;',$file_name);
			return TRUE;	
		}
		catch(Exception $e){
			$this->setHeaderStatus($er_st);
			throw $e;
		}	
	}

	public static function isDocSent($docId,&amp;$dbLink){
		$ar = $dbLink->query_first(sprintf(
			"SELECT state
			FROM doc_flow_out_processes
			WHERE doc_flow_out_id=%d
			ORDER BY date_time DESC
			LIMIT 1",
			$docId
		));
		
		return (is_array($ar) &amp;&amp; count($ar) &amp;&amp; $ar['state']=='registered');
	}

	public function remove_file($pm){
	
		$is_sent = self::isDocSent($this->getExtDbVal($pm,'doc_id'),$this->getDbLink());
		if ($_SESSION['role_id']!='admin' &amp;&amp; $is_sent){
			throw new Exception('Forbidden!');
		}
		
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			
			$this->remove_afile($pm,'out');
			
			if ($is_sent){
				$this->getDbLinkMaster()->query(sprintf(
					"INSERT INTO doc_flow_out_corrections
					(doc_flow_out_id,file_id,date_time,employee_id,is_new)
					VALUES (%d,%s,now(),%d,FALSE)",
					$this->getExtDbVal($pm,'doc_id'),
					$this->getExtDbVal($pm,'file_id'),
					intval(json_decode($_SESSION['employees_ref'])->keys->id)
				));
			}
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}		
	}

	public function remove_sig($pm){
		$this->remove_asig($pm,'out');
	}

	public function delete($pm){
		$this->delete_attachments($pm,'out');
	}
	
	public function get_next_num($pm){
		$this->get_next_num_on_type(
			'out',
			$this->getExtDbVal($pm,'doc_flow_type_id'),
			$this->getExtDbVal($pm,'ext_contract')
		);
	}

	public function get_next_contract_number($pm){
		$model = new ModelSQL($this->getDbLinkMaster(),array('id'=>'NewNum_Model'));
		$model->query(
			sprintf(
			"SELECT
				contracts_next_number(
					app.service_type,
					now()::date,
					%s
				) AS num
			FROM applications AS app
			WHERE app.id=%d",
			$this->getExtDbVal($pm,'ext_contract'),
			$this->getExtDbVal($pm,'application_id')
			)		
		,TRUE);
		$this->addModel($model);	
	}
	
	public function get_app_state($pm){
		$this->addNewModel(
			sprintf(
				"SELECT
					doc_flow_out.to_application_id,
					st.state
				FROM doc_flow_out
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=doc_flow_out.to_application_id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time				
				WHERE doc_flow_out.id=%d",
				$this->getExtDbVal($pm,'id')
			),
			'AppState_Model'
		);
	}
	
	private function update_contract_data($pm){
		$fld = NULL;
		$app_id = 0;
		if ($pm->getParamValue('expertise_result')){
			$fld = sprintf('expertise_result=%s',$this->getExtDbVal($pm,'expertise_result'));
		}
		if ($pm->getParamValue('expertise_reject_type_id') &amp;&amp; $this->getExtDbVal($pm,'expertise_reject_type_id')>0){
			$fld = (is_null($fld))? '':($fld.',');
			$fld.= sprintf('expertise_reject_type_id=%d',$this->getExtDbVal($pm,'expertise_reject_type_id'));
		}
		
		if (!is_null($fld)){
			if ($pm->getParamValue('to_application_id')){
				$app_id = $this->getExtDbVal($pm,'to_application_id');
			}
			else if ($pm->getParamValue('old_id')){
				$app_id = $this->getDbLink()->query_first_col(sprintf("SELECT to_application_id FROM doc_flow_out WHERE id=%d",
				$this->getExtDbVal($pm,'old_id')
				));
			
			}
			if ($app_id){
				$this->getDbLinkMaster()->query(sprintf("UPDATE contracts SET %s WHERE application_id=%d",
				$fld,$app_id
				));
			}
		}
	}


	public function insert($pm){
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			$this->update_contract_data($pm);
			
			parent::insert($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}
	
	public function update($pm){
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			$this->update_contract_data($pm);
			
			parent::update($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}

	public function get_file($pm){
		return $this->get_afile($pm,FALSE);
	}

	public function get_file_sig($pm){
		return $this->get_afile($pm,TRUE);
	}

	private function move_file($oldFile,$newFile){
		$dir = dirname($newFile);
		if(!file_exists($dir))mkdir($dir,0777,TRUE);
		if (!rename($oldFile, $newFile))throw new Exception('Не удалось переместить файл.');
	}

	public function alter_file_folder($pm){
		if (!$pm->getParamValue('new_folder_id') || $pm->getParamValue('new_folder_id')=='0'){
			$new_folder = 'Исходящие';
		}
		else{
			$ar = $this->getDbLink()->query_first(sprintf("SELECT name FROM application_doc_folders WHERE id=%d",$this->getExtDbVal($pm,'new_folder_id')));
			if (!count($ar)){
				throw new Exception('Folder not found!');
			}
			$new_folder = $ar['name'];
		}
		
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT
			att.file_path,
			d_out.to_application_id AS application_id
		FROM doc_flow_attachments AS att
		LEFT JOIN doc_flow_out AS d_out ON att.doc_type='doc_flow_out' AND att.doc_id=d_out.id
		WHERE att.file_id=%s AND d_out.id=%d",
		$this->getExtDbVal($pm,'file_id'),
		$this->getExtDbVal($pm,'doc_flow_out_id')
		));
		if (!count($ar)){
			throw new Exception('Document not found!');
		}
		
		$old_rel_file = Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
					$ar['file_path'].DIRECTORY_SEPARATOR.
					$this->getExtVal($pm,'file_id');

		$new_rel_file = Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
					$new_folder.DIRECTORY_SEPARATOR.
					$this->getExtVal($pm,'file_id');

		try{
			$this->getDbLinkMaster()->query('BEGIN');
			
			$this->getDbLinkMaster()->query(sprintf(
			"UPDATE doc_flow_attachments
			SET file_path = '%s'
			WHERE file_id=%s",
			$new_folder,
			$this->getExtDbVal($pm,'file_id')			
			));
			$moved = FALSE;
			if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$old_rel_file)){
				$this->move_file($fl,FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$new_rel_file);
				$moved = TRUE;
			}
			if (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$old_rel_file)){
				$this->move_file($fl,FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$new_rel_file);
				$moved = TRUE;
			}
			//sig
			if (file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$old_rel_file.'.sig')){
				$this->move_file($fl,FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$new_rel_file.'.sig');
				$moved = TRUE;
			}
			if (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$old_rel_file.'.sig')){
				$this->move_file($fl,FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$new_rel_file.'.sig');
				$moved = TRUE;
			}
			
			if (!$moved){
				throw new Exception('Файл не найден!');
			}
			
			$this->getDbLinkMaster()->query('COMMIT');
		
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}
	}
	
	public function add_sig_to_file($pm){
		$doc_id = $this->getExtDbVal($pm,'doc_id');
		
		$state = $this->get_state($doc_id,"out");
		if (
			($state=='registered'||$state=='approved'||$state=='approved_with_notes'||$state=='not_approved')
			&amp;&amp; $_SESSION['role_id']!='admin'){
			throw new Exception(self::ER_ALLOWED_TO_ADMIN);
		}
		
		
		if (isset($_FILES['sig_data'])){
			$exception = NULL;
			$fl = NULL;
			$file_name = NULL;
			if (!$this->find_afile(
				$this->getExtVal($pm,'file_id'),
				$this->getExtDbVal($pm,'file_id'),
				$this->getExtDbVal($pm,'doc_id'),
				$sigFile,
				$fl,
				$file_name,
				$exception
			)){
				throw $exception;
			}
			
			//$_FILES['sig_data']['tmp_name']
			
		}
	}

	public function get_file_hash($pm){
		$exception = NULL;
		$fl = NULL;
		$file_name = NULL;
		if (!$this->find_afile(
			$this->getExtVal($pm,'file_id'),
			$this->getExtDbVal($pm,'file_id'),
			$this->getExtDbVal($pm,'doc_id'),
			FALSE,
			$fl,
			$file_name,
			$exception
		)){
			throw $exception;
		}
		
		$pki_man = pki_create_manager();
		$hash = pki_get_hash(
			$fl,
			$this->getExtDbVal($pm,'file_id'),
			$pki_man,$this->getDbLinkMaster()
		);
		if (is_null($hash)){
			throw new Exception('Ошибка чтения файла');
		}
		
		ob_clean();
		header('Content-Type: text/plain');
		echo $hash;
		return TRUE;
	}

	public function get_sig_details($pm){
		if ($_SESSION['role_id']=='client'){
			//открывает только свои заявления!!!
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					CASE WHEN af.file_id IS NOT NULL THEN TRUE ELSE FALSE END AS user_check_passed
				FROM application_document_files AS af
				LEFT JOIN applications AS a ON a.id=af.application_id
				WHERE af.file_id=%s AND a.user_id=%d",
			$this->getExtDbVal($pm,'id'),
			$_SESSION['user_id']
			));			
			if (!count($ar) || $ar['user_check_passed']!='t'){
				throw new Exception(self::ER_OTHER_USER_APP);
			}			
		}
				
	
		$this->addNewModel(
			Application_Controller::getSigDetailsQuery($this->getExtDbVal($pm,'id')),
			'FileSignatures_Model'
		);
	
	}

	public function get_object($pm){
		if (!is_null($pm->getParamValue("id"))){
			parent::get_object($pm);
		}
		else{
			//new document
			$this->addNewModel(
			"SELECT json_agg(fld.files) As files
			FROM (
				SELECT
					json_build_object(
						'fields',
						json_build_object(
							'id',id,
							'descr',name,
							'required',false,
							'require_client_sig',require_client_sig
						),
						'files','[]'::json
					) AS files
				FROM application_doc_folders
				ORDER BY name
			) AS fld",
			'DocFlowOutDialog_Model'
			);			
		}
	}
	
	public function sign_file($pm){		
		$file_data = NULL;
		if(isset($_FILES) &amp;&amp; isset($_FILES['file_data'])){
			$file_data = $_FILES['file_data'];
		}
	
		DocFlow_Controller::signFile(
			$this,
			$pm,
			$file_data,
			'out'
		);
	}
	
	public function get_ext_list($pm){
		$this->setListModelId('DocFlowOutExtList_Model');
		parent::get_list($pm);
	
	}
	
	public function set_require_client_sig($pm){
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
				"UPDATE doc_flow_attachments
				SET require_client_sig = %s
				WHERE doc_id=%d AND file_id=%s
				RETURNING doc_id"
				,$this->getExtDbVal($pm,'require_client_sig')
				,$this->getExtDbVal($pm,'doc_id')
				,$this->getExtDbVal($pm,'file_id')
			));
			
			if(!is_array($ar) || !count($ar) || !isset($ar['doc_id'])){
				throw new Exception('Document not found!');
			}
			/*
			НЕ БУДЕМ СТАВИТ ГАЛОЧКУ: все по честному, есть отметка, что файл не нужен,
			все определяется клиентским исх.письмом, конкретно функцией
			doc_flow_out_client_files_for_signing
			$this->getDbLinkMaster()->query(sprintf(
				"UPDATE application_document_files
				SET file_signed_by_client = NOT %s
				WHERE file_id=%s"
				,$this->getExtDbVal($pm,'require_client_sig')
				,$this->getExtDbVal($pm,'file_id')
			));
			*/
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}		
	}

</xsl:template>

</xsl:stylesheet>
