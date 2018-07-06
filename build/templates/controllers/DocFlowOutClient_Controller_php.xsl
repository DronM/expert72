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

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	
	const CONTRACT_FOLDER = 'Договорные документы';
	const ER_NO_CONTRACT_SIG = 'Нет файла эцп с контрактом!';
	const ER_NO_DOC = 'Document not found!';
	const ER_WRONG_STATE = 'Невозможно создать исходящий документ по заявлению с данным статусом!';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	private function move_contract_files($appId,$docFlowId,&amp;$files){
	
		if (count($files['name'])!=2){
			throw new Exception(self::ER_NO_CONTRACT_SIG);
		}
	
		//sig-data indexes ".sig" - 4 chars
		$sig_ind = (strtolower(substr($files['name'][0],strlen($files['name'][0])-4,4))=='.sig')? 0 : NULL;		
		if (is_null($sig_ind)){
			$sig_ind = (strtolower(substr($files['name'][1],strlen($files['name'][1])-4,4))=='.sig')? 1 : NULL;
			if (is_null($sig_ind)){
				throw new Exception(self::ER_NO_CONTRACT_SIG);
			}
		}
		$data_ind = ($sig_ind==1)? 0:1;

		$dir = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			Application_Controller::APP_DIR_PREF.$appId.DIRECTORY_SEPARATOR.
			self::CONTRACT_FOLDER;
			
		//*************** А если уже был контракт? надо удалять... *************************
		/*
		if (file_exists($dir)){
			rrmdir($dir);
		}
		*/
		$this->getDbLinkMaster()->query(sprintf(
		"DELETE FROM doc_flow_out_client_document_files
		WHERE file_id IN (
			SELECT file_id
			FROM application_document_files
			WHERE application_id=%d AND file_path='%s')",
		$appId,
		self::CONTRACT_FOLDER
		));
		
		$this->getDbLinkMaster()->query(sprintf(
		"DELETE FROM application_document_files WHERE application_id=%d AND file_path='%s'",
		$appId,
		self::CONTRACT_FOLDER
		));
		//***********************************************
				
		mkdir($dir,0777,TRUE);
	
		$file_id = md5(uniqid());
	
		if (!move_uploaded_file($files['tmp_name'][$data_ind],$dir.DIRECTORY_SEPARATOR.$file_id)){
			throw new Exception('Ошибка загрузки контракта');
		}
		//sig
		if (!move_uploaded_file($files['tmp_name'][$sig_ind],$dir.DIRECTORY_SEPARATOR.$file_id.'.sig')){
			throw new Exception('Ошибка загрузки подписи контракта');
		}
		
		$this->getDbLinkMaster()->query(sprintf(
			"INSERT INTO application_document_files
			(file_id,application_id,document_id,document_type,date_time,
			file_name,file_path,file_signed,file_size)
			VALUES
			('%s',%d,0,'documents',now(),'%s','%s',TRUE,%f)",
			$file_id,
			$appId,
			$files['name'][$data_ind],
			self::CONTRACT_FOLDER,
			$files['size'][$data_ind]
		));
		//Отметка к письму				
		$this->getDbLinkMaster()->query(sprintf(
			"INSERT INTO doc_flow_out_client_document_files
			(file_id,doc_flow_out_client_id)
			VALUES
			('%s',%d)",
			$file_id,
			$docFlowId
		));				
	}

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
			throw new Exception(Application_Controller::ER_OTHER_USER_APP);
		}
		if ($ar['state']!='waiting_for_contract' &amp;&amp; $ar['state']!='waiting_for_pay' &amp;&amp; $ar['state']!='expertise'){
			throw new Exception(self::ER_WRONG_STATE);
		}
	
		$pm->setParamValue("user_id",$_SESSION['user_id']);
		$this->getDbLinkMaster()->query("BEGIN");
		try{			
			$inserted_id_ar = parent::insert($pm);
			
			if (isset($_FILES['contract_files'])){
				$this->move_contract_files($app_id,$inserted_id_ar['id'],$_FILES['contract_files']);
			}
			
			$this->getDbLinkMaster()->query("COMMIT");			
		}		
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
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
		
		
		$this->getDbLinkMaster()->query("BEGIN");
		try{			
			parent::update($pm);
			
			if (isset($_FILES['contract_files'])){
				$this->move_contract_files(
					$app_id,
					$this->getExtDbVal($pm,'old_id'),
					$_FILES['contract_files']
				);
			}
			
			$this->getDbLinkMaster()->query("COMMIT");			
		}		
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
		return $inserted_id_ar;
	}	

	/**	
	 * @params {string} file path+name
	 * @params {string} fileName returns file name for downloading
	 * @returns {string} file path+name
	 */
	public function get_file_on_type($docFlowId,$fileId,$isSig,&amp;$file,&amp;$fileName,&amp;$appId){
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT
			d.application_id,
			d.user_id,
			d.sent
		FROM doc_flow_out_client AS d
		WHERE d.id=%d",
		$docFlowId
		));
		if (!count($ar)||$ar['user_id']!=$_SESSION['user_id']||$ar['sent']=='t'){
			throw new Exception(self::ER_NO_DOC);
		}			
				
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT
			file_id,
			file_name,
			file_path,
			file_signed,
			application_id
		FROM application_document_files
		WHERE file_id=%s",
		$fileId
		));
		if (!count($ar)){
			throw new Exception(self::ER_NO_DOC);
		}
					
		$rel_dir = Application_Controller::APP_DIR_PREF.$ar['application_id'].DIRECTORY_SEPARATOR.self::CONTRACT_FOLDER;
		$postf = $isSig? '.sig':'';
		if (file_exists($file = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$ar['file_id'].$postf)
		||( 
			defined('FILE_STORAGE_DIR_MAIN')
			&amp;&amp;file_exists($file = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_dir.DIRECTORY_SEPARATOR.$ar['file_id'].$postf)
		)
		){
			$fileName = $ar['file_name'].$postf;
			$appId = $ar['application_id'];
			return TRUE;
		}
	}

	private function download_contract_file_on_type($pm,$isSig){
		$file = NULL;
		$fileName = NULL;
		$appId = 0;
		if ($this->get_file_on_type($this->getExtDbVal($pm,'id'),$this->getExtDbVal($pm,'file_id'),$isSig,$file,$fileName,$appId)){
			$mime = getMimeTypeOnExt($fileName);
			ob_clean();
			downloadFile($file, $mime,'attachment;',$fileName);
			return TRUE;
		}
	}

	public function download_contract_file($pm){
		$this->download_contract_file_on_type($pm,FALSE);
	}
	public function download_contract_file_sig($pm){
		$this->download_contract_file_on_type($pm,TRUE);
	}
	public function remove_contract_file($pm){
		$file = NULL;
		$fileName = NULL;
		$appId = 0;
		if ($this->get_file_on_type($this->getExtDbVal($pm,'id'),$this->getExtDbVal($pm,'file_id'),FALSE,$file,$fileName,$appId)){
		
			$this->getDbLinkMaster()->query("BEGIN");
			try{
				Application_Controller::removeAllZipFile($appId);
				unlink($file);
				
				$file = NULL;
				if ($this->get_file_on_type($this->getExtDbVal($pm,'id'),$this->getExtDbVal($pm,'file_id'),TRUE,$file,$fileName,$appId)){
					unlink($file);
				}

				$this->getDbLinkMaster()->query(sprintf("DELETE FROM doc_flow_out_client_document_files WHERE file_id=%s",$this->getExtDbVal($pm,'file_id')));
				$this->getDbLinkMaster()->query(sprintf("DELETE FROM application_document_files WHERE file_id=%s",$this->getExtDbVal($pm,'file_id')));
				
				$this->getDbLinkMaster()->query("COMMIT");
			}
			catch(Exception $e){
				$this->getDbLinkMaster()->query("ROLLBACK");
				throw $e;
			}
		}
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
				throw new Exception("No app found!");
			
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
		/*
		if ($_SESSION['role_id']=='client'){
			$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				d.user_id
			FROM doc_flow_out_client AS d
			WHERE d.id=(
				SELECT f.doc_flow_out_client_id
				FROM doc_flow_out_client_document_files AS f
				WHERE f.file_id=%s
				)",
			$file_id_for_db
			));
			if (!count($ar) || $ar['user_id']!=$_SESSION['user_id']){
				throw new Exception('Forbidden!');
			}
		}
		*/
		try{
			$dbLinkMaster= $this->getDbLinkMaster();
			
			$dbLinkMaster->query("BEGIN");
			
			$dbLinkMaster->query(sprintf("DELETE FROM doc_flow_out_client_document_files WHERE file_id=%s", $file_id_for_db));
			
			Application_Controller::removeFile($dbLinkMaster, $file_id_for_db);		
			
			$dbLinkMaster->query("COMMIT");
		}
		catch(Exception $e){
			$dbLinkMaster->query("ROLLBACK");
			throw $e;
		}
	}

	public function delete($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT
			d.user_id,
			d.sent
		FROM doc_flow_out_client AS d
		WHERE d.id=%d",
		$this->getExtDbVal($pm,'id')
		));
		if (!count($ar) || ($_SESSION['role_id']!='admin' &amp;&amp; $ar['user_id']!=$_SESSION['user_id']) || $ar['sent']=='t'){
			throw new Exception(self::ER_NO_DOC);
		}
		parent::delete($pm);
	}
</xsl:template>

</xsl:stylesheet>
