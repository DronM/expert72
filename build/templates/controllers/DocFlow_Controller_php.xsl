<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocFlow'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once('common/downloader.php');
require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');

require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{

	const CLIENT_OUT_FOLDER = 'Исходящие заявителя';

	const ER_STORAGE_FILE_NOT_FOUND = 'Файл не найден!@1001';
	const ER_INVALID_DOC_FLOW_TYPE = 'Invalid document type!@1002';
	const ER_EMPLOYEE_NOT_DEFINED = 'К пользователю не привязан сотрудник!@1003';
	const ER_ALLOWED_TO_ADMIN = 'Действие разрешено только администратору!@1004';
	const ER_NOT_FOUND = 'Document not found!';
	const ER_SIG_NOT_FOUND = 'ЭЦП не найдена!';
	const ER_SIG_OTHER_OWNER = 'Владелец ЭЦП %s. Вам запрещено удалять чужую подпись';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public static function getDefAppDir($type){
		$res = NULL;
		if ($type=='out'){
			$res = 'Исходящие';
		}
		else if ($type=='in'){
			$res = 'Исходящие заявителя';
		}
		else if ($type=='inside'){
			$res = 'Внутренние';
		}
		else{
			$res = 'UndefinedType';
		}
		return $res;
	}

	public function delete_attachments($pm,$type){
		$old_state = $this->get_state($this->getExtDbVal($pm,'id'),$type);
		if ($old_state!='dirt_copy' &amp;&amp; $_SESSION['role_id']!='admin'){
			throw new Exception(self:: ER_ALLOWED_TO_ADMIN);
		}
	
		try{
			$this->getDbLinkMaster()->query("BEGIN");
		
			//**************
			if ($type=='inside'){
				$q_id = $this->getDbLink()->query(sprintf(
					"SELECT
						at.file_id,
						at.file_signed,
						at.file_path,
						ct.application_id AS to_application_id
					FROM doc_flow_attachments AS at
					LEFT JOIN doc_flow_inside AS ins ON at.doc_type='doc_flow_inside' AND at.doc_id=ins.id
					LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
					WHERE doc_id=%d AND doc_type='doc_flow_inside'::data_types",
					$this->getExtDbVal($pm,'id')
				));
			}
			else if ($type=='out'){
				$q_id = $this->getDbLink()->query(sprintf(
					"SELECT
						at.file_id,
						at.file_signed,
						at.file_path,
						out.to_application_id
					FROM doc_flow_attachments AS at
					LEFT JOIN doc_flow_out AS out ON at.doc_type='doc_flow_out' AND at.doc_id=out.id
					WHERE doc_id=%d AND doc_type='doc_flow_out'::data_types",
					$this->getExtDbVal($pm,'id')
				));
			}		
			else{
				$q_id = $this->getDbLink()->query(sprintf(
					"SELECT
						at.file_id,
						at.file_signed,
						at.file_path,
						NULL AS to_application_id
					FROM doc_flow_attachments AS at
					WHERE doc_id=%d AND doc_type='doc_flow_in'::data_types",
					$this->getExtDbVal($pm,'id')
				));
			}		
			while($ar = $this->getDbLink()->fetch_array()){
				$fl = NULL;
				if ($ar['to_application_id']){
					//Файл из папки заявления
					if (
					file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'].
						DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id'))
					||(defined('FILE_STORAGE_DIR_MAIN')
					&amp;&amp; file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'].
						DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id'))
					)
					){
						unlink($fl);
					}
				}
				else{
					//Общий документооборот
					if (file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id'))){
						unlink($fl);
					}
				}
			
				if ($ar['file_signed'] &amp;&amp; file_exists($fl.='.sig')){
					unlink($fl);			
				}
			}			

			$this->getDbLinkMaster()->query(sprintf(
				"DELETE FROM doc_flow_attachments WHERE doc_id=%d AND doc_type='doc_flow_%s'::data_types",
				$this->getExtDbVal($pm,'id'),
				$type
			));			
			//**************
			
			parent::delete($pm);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}		
	}
	
	/**
	 * Удаление ЭЦП
	 * Разрешено:
	 *	- админу любую ЭЦП
	 *	- сотруднику только последнюю ЭЦП, если: сотрудник=владец ЭЦП или владелец ЭЦП не определен (поле employee_id пустое)
	 * @param {PublicMethod} pm Public method
	 * @param {string} type in|out|inside
	 */
	protected function remove_asig($pm,$type){
		
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
			"SELECT
				att.file_id,
				att.file_path,
				att.file_name,
				(SELECT count(*) FROM file_signatures AS sig WHERE sig.file_id=att.file_id) AS sig_cnt,
				CASE
					WHEN att.doc_type='doc_flow_out' THEN out.to_application_id
					WHEN att.doc_type='doc_flow_inside' THEN ct.application_id
					ELSE NULL
				END AS to_application_id
				
			FROM doc_flow_attachments AS att
			LEFT JOIN doc_flow_out AS out ON att.doc_type='doc_flow_out' AND att.doc_id=out.id
			LEFT JOIN doc_flow_inside AS ins ON att.doc_type='doc_flow_inside' AND att.doc_id=ins.id
			LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
			WHERE att.doc_id=%d AND att.file_id=%s AND att.doc_type='doc_flow_%s'",
			$this->getExtDbVal($pm,'doc_id'),
			$this->getExtDbVal($pm,'file_id'),
			$type
		));
		if (!count($ar) || $ar['sig_cnt']==0){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}
		
		$cur_sig = NULL;
		$application_id = NULL;
		$cur_sig_exists = $this->get_doc_file(
			$this->getExtDbVal($pm,'doc_id'),
			$type,
			$ar['file_path'],
			$ar['file_id'],
			TRUE,
			$cur_sig,
			$application_id
		);
		
		if(
		($ar['to_application_id']
		&amp;&amp; !file_exists($file_doc=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			Application_Controller::APP_DIR_PREF.$application_id.DIRECTORY_SEPARATOR.
			$ar['file_path'].DIRECTORY_SEPARATOR.
			$ar['file_id'])
		&amp;&amp;
		(!defined('FILE_STORAGE_DIR_MAIN')
			||
			(defined('FILE_STORAGE_DIR_MAIN') &amp;&amp;
			!file_exists($file_doc=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
				Application_Controller::APP_DIR_PREF.$application_id.DIRECTORY_SEPARATOR.
				$ar['file_path'].DIRECTORY_SEPARATOR.
				$ar['file_id'])
			)
		)
		)
		|| (
			!$ar['to_application_id']
			&amp;&amp; !file_exists($file_doc = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$ar['file_id'])
		)
		){
			throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
		}				
		
		if ($_SESSION['role_id']!='admin'){
			$state = $this->get_state($id,$type);
			if ($state=='registered' &amp;&amp; $_SESSION['role_id']!='admin'){
				throw new Exception(self::ER_ALLOWED_TO_ADMIN);
			}
		
			//Определим владельца последней подписи
			$sig_owner_ar = $this->getDbLinkMaster()->query_first(sprintf(
				"WITH
				doc_files AS
					(SELECT
						json_array_elements(files) AS files
					FROM doc_flow_inside_dialog
					WHERE id=%d
					),
				file_sigs AS 
					(SELECT
						json_array_elements(att2.files->'signatures') AS signature
					FROM (
						SELECT
							json_array_elements(doc_files.files->'files') AS files
						FROM doc_files
					) AS att2	
					WHERE att2.files->>'file_id'=%s
					)
				SELECT
					file_sigs.signature->'owner'->>'Фамилия'|| ' '||coalesce(file_sigs.signature->'owner'->>'Имя','') AS owner_name,
					(file_sigs.signature->>'employee_id')::int AS owner_employee_id
	
				FROM file_sigs
				ORDER BY (file_sigs.signature->>'verif_date_time')::timestampTZ DESC
				LIMIT 1",
			$this->getExtDbVal($pm,'doc_id'),
			$this->getExtDbVal($pm,'file_id')
			));
		
			if(!count($sig_owner_ar)){
				throw new Exception(self::ER_SIG_NOT_FOUND);
			}
		
			if (
			isset($sig_owner_ar['owner_employee_id'])
			&amp;&amp; intval($sig_owner_ar['owner_employee_id'])
			&amp;&amp; intval(json_decode($_SESSION['employees_ref'])->keys->id)!=intval($sig_owner_ar['owner_employee_id'])
			){
				throw new Exception(sprintf(self::ER_SIG_OTHER_OWNER,$sig_owner_ar['owner_name']));
			}
		}
		
		//можно удалить последнюю ЭЦП
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			if ($ar['sig_cnt']==1){
				$this->getDbLinkMaster()->query(sprintf(
					"UPDATE doc_flow_attachments
					SET file_signed=FALSE
					WHERE file_id=%s
					",
					$this->getExtDbVal($pm,'file_id')
				));
				
				$this->getDbLinkMaster()->query(sprintf(
					"DELETE FROM file_verifications
					WHERE file_id=%s",
					$this->getExtDbVal($pm,'file_id')
				));
				
				if($cur_sig_exists)unlink($cur_sig);
			}
			else{						
				//find previous sig
				$max_ind = NULL;
				if (!$ar['to_application_id']){
					$prev_sig = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						$fileId.'.sig.s'.Application_Controller::getMaxIndexInDir(DOC_FLOW_FILE_STORAGE_DIR,$fileId);
					$new_cur_sig = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						$ar['file_id'].'.sig';								
				}
				else{
					$prev_sig = Application_Controller::getMaxIndexSigFile(
						Application_Controller::APP_DIR_PREF.$application_id.DIRECTORY_SEPARATOR.$ar['file_path'],
						$ar['file_id'],
						$max_ind
					);				
				
					$new_cur_sig = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$application_id.DIRECTORY_SEPARATOR.
						$ar['file_path'].DIRECTORY_SEPARATOR.
						$ar['file_id'].'.sig';		
				}
				
				if($cur_sig_exists)unlink($cur_sig);
				rename($prev_sig,$new_cur_sig);
			
				$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,PKI_MODE);
				pki_log_sig_check($new_cur_sig, $file_doc, $this->getExtDbVal($pm,'file_id'), $pki_man, $this->getDbLinkMaster());
			}
			
			$this->getDbLinkMaster()->query("COMMIT");
			
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}	
	}
	
	/**
	 * @param {int} docIdForDb
	 * @param {string} type in,out,inside
	 * @param {string} filePath
	 * @param {string} fileId
	 * @param {bool} isSig
	 * @param {sring} fl
	 * @param {sring} applicationId
	 * @returns {bool} file existance
	 */
	private function get_doc_file($docIdForDb,$type,$filePath,$fileId,$isSig,&amp;$fl,&amp;$applicationId){
		if ($type=='out' || $type=='inside'){
			$q = '';
			if ($type=='out'){
				$q = sprintf(
					"SELECT to_application_id
					FROM doc_flow_out
					WHERE id=%d",
					$docIdForDb
				);
			}
			else{
				$q = sprintf(
					"SELECT ct.application_id AS to_application_id
					FROM doc_flow_inside AS ins
					LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
					WHERE ins.id=%d",
					$docIdForDb
				);
			}
			$app_ar = $this->getDbLink()->query_first($q);
			if (count($app_ar) &amp;&amp; ($applicationId = $app_ar['to_application_id']) ){
				$rel_fl = Application_Controller::APP_DIR_PREF.$applicationId.DIRECTORY_SEPARATOR.
				$filePath.DIRECTORY_SEPARATOR.$fileId. ($isSig? '.sig':'');
			
				if (
				file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_fl)
				|| (
					defined('FILE_STORAGE_DIR_MAIN')
					&amp;&amp; file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$rel_fl)
				)
				){
					return TRUE;
				}
			}
		}
		
		if (!$fl){
			$fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$fileId. ($isSig? '.sig':'');
		}
		
		return file_exists($fl);	
	}
	
	
	protected function remove_afile($pm,$type){
		
		$state = $this->get_state($id,$type);
		if ($state=='registered' &amp;&amp; $_SESSION['role_id']!='admin'){
			throw new Exception(self::ER_ALLOWED_TO_ADMIN);
		}
		
		$this->getDbLinkMaster()->query('BEGIN');
		try{
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
				"DELETE FROM doc_flow_attachments
				WHERE doc_id=%d AND file_id=%s AND doc_type='doc_flow_%s'
				RETURNING file_id,file_signed,file_path,file_name",
				$this->getExtDbVal($pm,'doc_id'),
				$this->getExtDbVal($pm,'file_id'),
				$type
			));
			if (!count($ar)){
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			}
			
			/*
			$fl = NULL;
			if (
			($type=='out' &amp;&amp; $ar['doc_type']=='doc_flow_out')
			||($type=='inside' &amp;&amp; $ar['doc_type']=='doc_flow_inside')
			){
				$q = '';
				if ($type=='out'){
					$q = sprintf(
						"SELECT to_application_id
						FROM doc_flow_out
						WHERE id=%d",
						$this->getExtDbVal($pm,'doc_id')
					);
				}
				else{
					$q = sprintf(
						"SELECT ct.application_id AS to_application_id
						FROM doc_flow_inside AS ins
						LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
						WHERE ins.id=%d",
						$this->getExtDbVal($pm,'doc_id')
					);
				}
				$app_ar = $this->getDbLink()->query_first($q);
				if (count($app_ar) &amp;&amp; $app_ar['to_application_id']){
					$fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$app_ar['to_application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'].DIRECTORY_SEPARATOR.$ar['file_id'];
				}
			}
			
			if (!$fl){
				$fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$ar['file_id'];
			}
			*/
			
			$fl = NULL;
			$app_id = NULL;
			if ($this->get_doc_file(
				$this->getExtDbVal($pm,'doc_id'),
				$type,
				$ar['file_path'],
				$ar['file_id'],
				FALSE,
				$fl,
				$app_id
			)){
				unlink($fl);
			}
			if ($ar['file_signed'] &amp;&amp; file_exists($fl.='.sig')){
				unlink($fl);			
			}
			
			$this->getDbLinkMaster()->query("COMMIT");
			
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}	
	}
		
	
	public function get_state($id,$type){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT state
			FROM doc_flow_%s_processes
			WHERE doc_flow_%s_id = %d
			ORDER BY date_time DESC
			LIMIT 1",
		$type,$type,
		$id
		));
		return $ar['state'];
	}

	private function get_afile($pm,$sigFile){
		try{
			$er_st = 500;
			
			$posf = $sigFile? '.sig':'';
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					at.file_name,
					at.file_path,
					CASE
						WHEN at.doc_type='doc_flow_out' THEN out.to_application_id
						WHEN at.doc_type='doc_flow_inside' THEN ct.application_id
						ELSE NULL
					END AS to_application_id
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out AS out ON at.doc_type='doc_flow_out' AND at.doc_id=out.id
				LEFT JOIN doc_flow_inside AS ins ON at.doc_type='doc_flow_inside' AND at.doc_id=ins.id
				LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
				WHERE at.file_id=%s AND at.doc_id=%d",
				$this->getExtDbVal($pm,'file_id'),
				$this->getExtDbVal($pm,'doc_id')
			));
		
			if (!count($ar)){
				$er_st = 404;
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			}
		
			$fl = NULL;
			if (
			(
				$ar['to_application_id']
				&amp;&amp; (!file_exists($fl = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
						$ar['file_path'].
						DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id').$posf)
						&amp;&amp;(
							defined('FILE_STORAGE_DIR_MAIN') &amp;&amp;
							!file_exists($fl = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
							Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.
							$ar['file_path'].
							DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id').$posf)							
						)
					)
			)
			|| (
				!$ar['to_application_id']
				&amp;&amp; !file_exists($fl = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$this->getExtVal($pm,'file_id').$posf)
			)
			){
				$er_st = 404;
				throw new Exception(self::ER_STORAGE_FILE_NOT_FOUND);
			}
		
			ob_clean();
			downloadFile($fl, 'application/octet-stream','attachment;',$ar['file_name'].$posf);
			return TRUE;	
		}
		catch(Exception $e){
			$this->setHeaderStatus($er_st);
			throw $e;
		}	
	}
	
	public function get_file($pm){
		return $this->get_afile($pm,FALSE);
	}

	public function get_file_sig($pm){
		return $this->get_afile($pm,TRUE);
	}
	
	protected function get_next_num_on_type($docFlowType,$typeId){
		$model = new ModelSQL($this->getDbLinkMaster(),array('id'=>'NewNum_Model'));
		$model->query(
			sprintf("SELECT doc_flow_%s_next_num(%d) AS num",$docFlowType,$typeId)		
		,TRUE);
		$this->addModel($model);	
	}
	
</xsl:template>

</xsl:stylesheet>
