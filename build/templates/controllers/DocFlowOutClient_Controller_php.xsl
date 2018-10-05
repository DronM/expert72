<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlowOutClient'"/>
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
require_once('common/file_func.php');

require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	
	const ER_NO_DOC = 'Document not found!';
	const ER_DOC_SENT = 'Документ отправлен!';
	const ER_WRONG_STATE = 'Невозможно отправить исходящий документ по заявлению с данным статусом!';
	const ER_NO_ATTACHMENTS = 'У документа нет вложений!';
	const ER_NO_DOC_FILE = 'Файл с данными не найден!';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public function insert($pm){
		//check app state
		$app_id = $this->getExtDbVal($pm,'application_id');
		
		$ar = $this->getDbLink()->query_first(sprintf("SELECT
			application_processes_last(%d) AS state,
			(SELECT ap.user_id=%d FROM applications AS ap WHERE ap.id=%d) AS user_check_passed
			",
			$app_id,
			$_SESSION['user_id'],
			$app_id
		));
	
		Application_Controller::checkApp($ar);
		if ($ar['user_check_passed']!='t'){
			throw new Exception(Application_Controller::ER_NO_DOC);
		}
		/*
		if ($this->getExtVal($pm,'sent')=='true' &amp;&amp; $ar['state']!='waiting_for_contract' &amp;&amp; $ar['state']!='waiting_for_pay' &amp;&amp; $ar['state']!='expertise'){
			throw new Exception(self::ER_WRONG_STATE);
		}
		*/
		
		if ($this->getExtVal($pm,'sent')=='true'){
			throw new Exception(self::ER_NO_ATTACHMENTS);
		}	
		$pm->setParamValue("user_id",$_SESSION['user_id']);
		$inserted_id_ar = parent::insert($pm);
		return $inserted_id_ar;
	}	

	public function update($pm){
		if ($pm->getParamValue('user_id')){
			$pm->setParamValue("user_id",$_SESSION['user_id']);
		}
		
		$app_id = NULL;
		if ($pm->getParamValue('application_id')){
			$app_id = $this->getExtDbVal('application_id');
			$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				user_id,
				(SELECT t.user_id FROM doc_flow_out_client t WHERE t.id=%d) AS doc_user_id
			FROM applications
			WHERE id=%d",
			$this->getExtDbVal($pm,'old_id'),
			$app_id
			));
			if (!count($ar)||$ar['user_id']!=$_SESSION['user_id']||$ar['doc_user_id']!=$_SESSION['user_id']){
				throw new Exception(self::ER_NO_DOC);
			}			
		}
		else{
			//no app_id
			$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				d.application_id,
				d.user_id
			FROM doc_flow_out_client AS d
			WHERE d.id=%d",
			$this->getExtDbVal($pm,'old_id')
			));
			if (!count($ar)){
				throw new Exception(self::ER_NO_DOC);
			}
			$app_id = $ar['application_id'];
		}
		
		if ($this->getExtVal($pm,'sent')=='true'){
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT count(*) AS cnt
				FROM doc_flow_out_client_document_files
				WHERE doc_flow_out_client_id=%d",
				$this->getExtDbVal($pm,'old_id')
			
			));
			if (!count($ar)||!intval($ar['cnt'])){
				throw new Exception(self::ER_NO_ATTACHMENTS);
			}
			
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					application_processes_last(%d) AS state,
					(SELECT ap.user_id=%d FROM applications AS ap WHERE ap.id=%d) AS user_check_passed,
					(SELECT d.doc_flow_out_client_type FROM doc_flow_out_client d WHERE d.id=%d) AS doc_flow_out_client_type,
					(SELECT d.sent FROM doc_flow_out_client d WHERE d.id=%d) AS doc_flow_out_client_sent
				",
				$app_id,
				$_SESSION['user_id'],
				$app_id,
				$this->getExtDbVal($pm,'old_id'),
				$this->getExtDbVal($pm,'old_id')
			));
	
			Application_Controller::checkApp($ar);
			if ($ar['user_check_passed']!='t'){
				throw new Exception(Application_Controller::ER_NO_DOC);
			}
			
			/*
			if ($ar['state']!='waiting_for_contract' &amp;&amp; $ar['state']!='waiting_for_pay' &amp;&amp; $ar['state']!='expertise'){
				throw new Exception(self::ER_WRONG_STATE);
			}
			*/
		
			if ($this->getExtVal($pm,'sent')=='true' &amp;&amp; $ar['doc_flow_out_client_sent']=='t'){
				throw new Exception(self::ER_DOC_SENT);
			}	

			/*
			if ($ar['doc_flow_out_client_type']=='contr_return' &amp;&amp; $ar['state']!='expertise'){
				throw new Exception(self::ER_WRONG_STATE);
			}
			*/	
			
		}		
		parent::update($pm);
	}	



	private function add_application($applicationId,$docId){
		$document_exists = FALSE;
		
		if (!is_null($applicationId)){		
		
			//Клиент видит только СВОЕ!!!
			$client_q_t = '';
			if ($_SESSION['role_id']=='client'){
				$client_q_t = ' AND app.user_id='.$_SESSION['user_id'];
			}
			
			$ar_obj = $this->getDbLink()->query_first(sprintf(
			"SELECT
				app.id,
				app.expertise_type,
				app.cost_eval_validity,
				app.modification,
				app.audit,
				app.construction_types_ref,
				app.documents,
				app.document_exists
			FROM applications_dialog AS app
			WHERE app.id=%d".$client_q_t,
			$applicationId
			));
		
			if (!is_array($ar_obj) || !count($ar_obj)){
				throw new Exception(ER_NO_DOC);
			
			}
			
			if (!is_null($docId)){
				/*
				$files_q_id = $this->getDbLink()->query(sprintf(
					"SELECT
						fl.*,
						mdf.doc_flow_out_client_id,
						m.date_time AS doc_flow_out_date_time,
						reg.reg_number AS doc_flow_out_reg_number
					FROM application_document_files AS fl
					LEFT JOIN doc_flow_out_client_document_files AS mdf ON mdf.file_id=fl.file_id
					LEFT JOIN doc_flow_out_client AS m ON m.id=mdf.doc_flow_out_client_id
					LEFT JOIN doc_flow_out_client_reg_numbers AS reg ON reg.doc_flow_out_client_id=m.id
					WHERE fl.application_id=%d AND NOT fl.deleted
					ORDER BY document_type,document_id,file_name,deleted_dt ASC NULLS LAST",
				$applicationId
				));
				*/
				$files_q_id = Application_Controller::attachmentsQuery(
					$this->getDbLink(),
					$applicationId,
					'AND coalesce(adf.deleted,FALSE)=FALSE'
				);
						
				//fl.file_id IN (SELECT ofl.file_id FROM doc_flow_out_client_document_files AS ofl WHERE ofl.doc_flow_out_client_id=%d)	
			}
						
			$document_exists = ( $ar_obj['document_exists']=='t' &amp;&amp; !is_null($docId) );
		}
		
		if (!$document_exists){
			$this->addNewModel("SELECT * FROM document_templates_all_json_list",'DocumentTemplateAllList_Model');			
			$documents = NULL;
		}
		else{
			$documents_json = json_decode($ar_obj['documents']);
			foreach($documents_json as $doc){
				Application_Controller::addDocumentFiles($doc->document,$this->getDbLink(),$doc->document_type,$files_q_id);
			}
			$documents = json_encode($documents_json);
		}
		if (!is_null($applicationId)){		
			$this->addModel(new ModelVars(
				array('name'=>'Vars',
					'id'=>'ApplicationDialog_Model',
					'values'=>array(
						new Field('id',DT_INT,array('value'=>$ar_obj['id']))
						,new Field('expertise_type',DT_STRING,array('value'=>$ar_obj['expertise_type']))
						,new Field('cost_eval_validity',DT_STRING,array('value'=>$ar_obj['cost_eval_validity']))
						,new Field('modification',DT_STRING,array('value'=>$ar_obj['modification']))
						,new Field('audit',DT_STRING,array('value'=>$ar_obj['audit']))
						,new Field('construction_types_ref',DT_STRING,array('value'=>$ar_obj['construction_types_ref']))
						,new Field('documents',DT_STRING,array('value'=>$documents))
						)
					)
				)
			);		
		}
	}	

	public function get_application_dialog($pm){
		$this->add_application($this->getExtDbVal($pm,'application_id'),$this->getExtDbVal($pm,'id'));
		$this->add_files_for_signing($this->getExtDbVal($pm,'application_id'));
	}

	public function get_object($pm){
	
		parent::get_object($pm);
		
		if (!is_null($pm->getParamValue('id'))){		
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT t.application_id FROM doc_flow_out_client AS t WHERE t.id=%d",
			$this->getExtDbVal($pm,'id')
			));
			$application_id = $ar['application_id'];
			$doc_id = $this->getExtDbVal($pm,'id');
		}
		else{
			$application_id = NULL;
			$doc_id = NULL;
		}			
		$this->add_application($application_id,$doc_id);
	}
	
	public function remove_file($pm){
		$file_id_for_db = $this->getExtDbVal($pm,'file_id');
		
		//checking
		//Файла может не быть в DocFlowOutClientDocuments!!!
		
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT
			app.id AS application_id,
			app.user_id,
			app_f.file_signed_by_client,
			(contr_docs.file_id IS NOT NULL) AS contr_return,
			app_f.file_path,
			app_f.file_id,
			(doc_files.file_id IS NOT NULL) AS this_app_file
		FROM applications AS app
		LEFT JOIN application_document_files AS app_f ON app_f.application_id=app.id AND app_f.file_id=%s
		LEFT JOIN doc_flow_attachments AS contr_docs ON contr_docs.file_id=app_f.file_id
		LEFT JOIN doc_flow_out_client_document_files AS doc_files ON doc_files.file_id=app_f.file_id
		WHERE app.id=%d",
		$file_id_for_db,
		$this->getExtDbVal($pm,'application_id')
		));
		if (!count($ar)
		|| ($_SESSION['role_id']!='admin' &amp;&amp; $ar['user_id']!=$_SESSION['user_id'])
		|| $ar['this_app_file']!='t'
		|| ($ar['contr_return']=='t' &amp;&amp; $ar['file_signed_by_client']!='t')
		){
			throw new Exception('Forbidden!');
		}

		if ($ar['contr_return']=='t'){
			//Возврат контракта
			$rel_file_doc = DIRECTORY_SEPARATOR.
				Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.
				$ar['file_path'].DIRECTORY_SEPARATOR.$ar['file_id'];
			
			$rel_file = $rel_file_doc.'.sig'.'.s1';

			if (
			!file_exists($file_doc=FILE_STORAGE_DIR.$rel_file_doc)
			&amp;&amp;
			(
				!defined('FILE_STORAGE_DIR_MAIN')
				|| !file_exists($file_doc=FILE_STORAGE_DIR_MAIN.$rel_file_doc)
			)
			){				
				throw new Exception(self::ER_NO_DOC_FILE);
			}			
			
			if (
			file_exists($file=FILE_STORAGE_DIR.$rel_file)
			|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file=FILE_STORAGE_DIR_MAIN.$rel_file))
			){
				try{
					$dbLinkMaster= $this->getDbLinkMaster();
			
					$dbLinkMaster->query("BEGIN");
				
					$dbLinkMaster->query(sprintf(
						"UPDATE application_document_files
						SET file_signed_by_client=FALSE
						WHERE file_id=%s",
					$file_id_for_db
					));				
				
					$dbLinkMaster->query(sprintf("DELETE FROM doc_flow_out_client_document_files WHERE file_id=%s", $file_id_for_db));
					
					$file_sig = substr($file,0,strlen($file)-3);
					if (rename($file,$file_sig)===FALSE){
						throw new Exception('Error restoring signature file!');
					}
					unlink($file);
					
					$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,PKI_MODE);
					pki_log_sig_check($file_sig, $file_doc, $file_id_for_db, $pki_man, $dbLinkMaster);
					
					$dbLinkMaster->query("COMMIT");
				}
				catch(Exception $e){
					$dbLinkMaster->query("ROLLBACK");
					throw $e;
				}
					
			}
			else{
				throw new Exception('Ошибка удаления файла подписи!');	
			}			
		}
		else{
			//Прочие вложения
			
			try{
				$dbLinkMaster= $this->getDbLinkMaster();
			
				$dbLinkMaster->query("BEGIN");
						
				Application_Controller::removeFile($dbLinkMaster, $file_id_for_db);		
			
				$dbLinkMaster->query(sprintf("DELETE FROM doc_flow_out_client_document_files WHERE file_id=%s", $file_id_for_db));
				$dbLinkMaster->query(sprintf("DELETE FROM application_document_files WHERE file_id=%s", $file_id_for_db));
			
				$dbLinkMaster->query("COMMIT");
			}
			catch(Exception $e){
				$dbLinkMaster->query("ROLLBACK");
				throw $e;
			}
		}
	}

	private function check_user_and_state($docIdDb){
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT
			d.user_id,
			d.sent,
			d.doc_flow_out_client_type,
			d.application_id
		FROM doc_flow_out_client AS d
		WHERE d.id=%d",
		$docIdDb
		));
		if (!count($ar)){
			throw new Exception(self::ER_NO_DOC);
		}
		else if ($_SESSION['role_id']!='admin' &amp;&amp; $ar['user_id']!=$_SESSION['user_id']){
			throw new Exception(self::ER_NO_DOC);
		}
		else if ($ar['sent']=='t'){
			throw new Exception(self::ER_DOC_SENT);
		}
	
		return $ar;
	}

	public function delete($pm){
		$this->delete_all_attachments($pm);
		
		parent::delete($pm);
	}
		
	/**
	 * Удаляет все вложения, восстанавливает файлы документации
	 */
	public function delete_all_attachments($pm){
	
		$doc_attrs = $this->check_user_and_state($this->getExtDbVal($pm,'id'));
		
		try{
			$dbLinkMaster= $this->getDbLinkMaster();
			
			$dbLinkMaster->query("BEGIN");
			
			$q_id = $dbLinkMaster->query(sprintf(
				"SELECT
					doc_f.file_id,
					app_f.file_path,
					app_f.document_id,
					app_f.document_type,
					app_f.file_signed,
					app_f.deleted
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=%d",
			$this->getExtDbVal($pm,'id')
			));
			
			$pki_man = NULL;			
			if ($doc_attrs['doc_flow_out_client_type']=='contr_return'){
				$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,PKI_MODE);							
			}
			
			while($ar= $dbLinkMaster->fetch_array($q_id)){
				if ($doc_attrs['doc_flow_out_client_type']=='contr_return'){
					$rel_file_doc = DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$doc_attrs['application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'].DIRECTORY_SEPARATOR.$ar['file_id'];
			
					$rel_file = $rel_file_doc.'.sig'.'.s1';					
					
					if (
					!file_exists($file_doc=FILE_STORAGE_DIR.$rel_file_doc)
					&amp;&amp;
					(
						!defined('FILE_STORAGE_DIR_MAIN')
						|| !file_exists($file_doc=FILE_STORAGE_DIR_MAIN.$rel_file_doc)
					)
					){				
						throw new Exception(self::ER_NO_DOC_FILE);
					}			
					
					$dbLinkMaster->query(sprintf(
						"UPDATE application_document_files
						SET file_signed_by_client=FALSE
						WHERE file_id=%s",
					"'".$ar['file_id']."'"
					));
											
					if (
					file_exists($file=FILE_STORAGE_DIR.$rel_file)
					|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file=FILE_STORAGE_DIR_MAIN.$rel_file))
					){						
						$file_sig = substr($file,0,strlen($file)-3);
						if (rename($file,$file_sig)===FALSE){
							throw new Exception('Error restoring signature file!');
						}
						unlink($file);
					}
										
					pki_log_sig_check($file_sig, $file_doc, "'".$ar['file_id']."'", $pki_man, $dbLinkMaster);
					
				}
				else{
					$dbLinkMaster->query(sprintf(
						"DELETE FROM application_document_files WHERE file_id=%s",
					"'".$ar['file_id']."'"
					));
					$file_rel = DIRECTORY_SEPARATOR.Application_Controller::APP_DIR_PREF.$doc_attrs['application_id'].DIRECTORY_SEPARATOR.
						(($ar['document_type']!='documents')? (Application_Controller::dirNameOnDocType($ar['document_type']).$ar['document_id']) : $ar['file_path']).DIRECTORY_SEPARATOR.
						$ar['file_id'];
					$unlink_file = ($ar['document_type']=='documents' || $ar['deleted']!='t');
					if (
					file_exists($file=FILE_STORAGE_DIR.$file_rel)
					|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file=FILE_STORAGE_DIR_MAIN.$file_rel))
					){							
						if ($unlink_file){
							unlink($file);
						}
						else{
							//move back to documentation
							rename($file,
								FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$doc_attrs['application_id'].DIRECTORY_SEPARATOR.
								Application_Controller::dirNameOnDocType($ar['document_type']).DIRECTORY_SEPARATOR.
								$ar['file_id']
							);
							
						}										
					}								

					if (
					$ar['file_signed']
					&amp;&amp;
					(file_exists($file=FILE_STORAGE_DIR.$file_rel.'.sig')
					|| (defined('FILE_STORAGE_DIR_MAIN') &amp;&amp; file_exists($file=FILE_STORAGE_DIR_MAIN.$file_rel.'.sig'))
					)
					){							
						if ($unlink_file){
							unlink($file);
						}
						else{
							//move back to documentation
							rename($file,
								FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
								Application_Controller::APP_DIR_PREF.$doc_attrs['application_id'].DIRECTORY_SEPARATOR.
								Application_Controller::dirNameOnDocType($ar['document_type']).DIRECTORY_SEPARATOR.
								$ar['file_id'].'.sig'
							);
							
						}										
					}								
				}
			}
						
			$dbLinkMaster->query(sprintf(
				"DELETE FROM doc_flow_out_client_document_files
				WHERE doc_flow_out_client_id=%d",
			$this->getExtDbVal($pm,'id')
			));
			
			Application_Controller::removeAllZipFile($doc_attrs['application_id']);
			Application_Controller::removePDFFile($doc_attrs['application_id']);
			
			$dbLinkMaster->query("COMMIT");
		}
		catch(Exception $e){
			$dbLinkMaster->query("ROLLBACK");
			throw $e;
		}
	}

	private function add_files_for_signing($applicationId){			
		$this->addNewModel(sprintf(
		"SELECT jsonb_agg(doc_flow_out_client_files_for_signing(%d)) AS attachment_files",
		$applicationId,
		$_SESSION['user_id']
		),"FileForSigningList_Model");
		
	}
	
	public function get_files_for_signing($pm){
		if ($_SESSION['role_id']=='client'){
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					user_id
				FROM applications
				WHERE id=%d",
			$this->getExtDbVal($pm,'application_id')
			));
			if (!count($ar) || $ar['user_id']!=$_SESSION['user_id']){
				throw new Exception(ER_NO_DOC);
			}
		}
	
		$this->add_files_for_signing($this->getExtDbVal($pm,'application_id'));
	}
	
	public function remove_document_file($pm){
		$file_id_for_db = $this->getExtDbVal($pm,'file_id');
		$doc_flow_out_client_id_for_db = $this->getExtDbVal($pm,'doc_flow_out_client_id');
		
		$this->check_user_and_state($doc_flow_out_client_id_for_db);
		
		try{
			$dbLinkMaster= $this->getDbLinkMaster();
		
			$dbLinkMaster->query("BEGIN");

			//Добавлен ЭТИМ документом!!!
			$ar = $dbLinkMaster->query_first(sprintf(
				"SELECT
					TRUE AS unlink_file
				FROM doc_flow_out_client_document_files
				WHERE file_id=%s",
			$file_id_for_db));
			$unlink_file = (count($ar) &amp;&amp; $ar['unlink_file']=='t')? TRUE:FALSE;
					
			Application_Controller::removeFile($dbLinkMaster, $file_id_for_db,$unlink_file);		
		
			if ($unlink_file){				
				$dbLinkMaster->query(sprintf("DELETE FROM doc_flow_out_client_document_files WHERE file_id=%s", $file_id_for_db));
			}
			else{
				//просто пометили на удаление - отметим принадлежность к этому письму
				$dbLinkMaster->query(sprintf(
					"INSERT INTO doc_flow_out_client_document_files
					(file_id,doc_flow_out_client_id)
					VALUES (%s,%d)",
				$file_id_for_db,
				$doc_flow_out_client_id_for_db
				));
			}		
			$dbLinkMaster->query("COMMIT");
		}
		catch(Exception $e){
			$dbLinkMaster->query("ROLLBACK");
			throw $e;
		}
	}
	
</xsl:template>

</xsl:stylesheet>
