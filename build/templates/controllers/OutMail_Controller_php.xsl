<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'OutMail'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once('functions/ExpertEmailSender.php');
require_once('common/downloader.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	
	const STORAGE_FILE_NOT_FOUND = 'Файл не найден!';
	const MAIL_SENT = 'Письмо отправлено!';

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public function reg_for_sending($outMailId){
		$attach = array();
		$this->getDbLink()->query(sprintf("SELECT file_name FROM out_mail_attachments WHERE out_mail_id=%d",$outMailId));
		while($ar = $this->getDbLink()->fetch_array()){
			array_push($attach,$ar['file_name']);
		}
		ExpertEmailSender::addEMail(
			$this->getDbLinkMaster(),
			sprintf("email_reg_out_mail(%d)",
				$outMailId
			),
			$attach,
			'out_mail'
		);
	
	}

	public function insert($pm){
		$link = $this->getDbLinkMaster();
		try{
			$link->query('BEGIN');
			$ar = parent::insert($pm);
			if ($this->getExtVal($pm,'sent')){
				$this->reg_for_sending($ar['id']);
			}
			
			$link->query('COMMIT');
		}
		catch(Exception $e){
			$link->query('ROLLBACK');
			throw $e;
		}
		return $ar;
	}
	public function update($pm){
		$link = $this->getDbLinkMaster();
		try{
			$link->query('BEGIN');
			parent::update($pm);
			if ($this->getExtVal($pm,'sent')){
				$this->reg_for_sending($this->getExtVal($pm,'old_id'));
			}
			
			$link->query('COMMIT');
		}
		catch(Exception $e){
			$link->query('ROLLBACK');
			throw $e;
		}
	}
	
	public function delete($pm){
		$ar = $this->getDbLink()->query_first(sprintf("SELECT sent FROM out_mail WHERE id=%d",$this->getExtDbVal($pm,'id')));
		if (!is_array($ar) || !count($ar)){
			throw new Exception('Не найден документ!');
		}
		
		if ($ar['sent']=='t'){
			throw new Exception('Невозможно удалять отправленное письмо!');
		}
		
		parent::delete($pm);
	
	}
	
	public function get_file($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				file_name
			FROM out_mail_attachments
			WHERE file_id=%s",
			$this->getExtDbVal($pm,'id')
		));
		if (!file_exists($fl = MAIL_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$this->getExtVal($pm,'id'))){
			throw new Exception(self::STORAGE_FILE_NOT_FOUND);
		}
	
		$mime = getMimeTypeOnExt($ar['file_name']);
		ob_clean();
		downloadFile($fl, $mime,'attachment;',$ar['file_name']);
		return TRUE;
	
	}
	
	public function remove_file($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				out_mail.sent AS sent
			FROM out_mail_attachments AS at
			LEFT JOIN out_mail ON out_mail.id=at.out_mail_id
			WHERE at.file_id=%s",
			$this->getExtDbVal($pm,'id')
		));
		if ($ar['sent']=='t'){
			throw new Exception(self::MAIL_SENT);
		}
		if (!file_exists($fl = MAIL_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$this->getExtVal($pm,'id'))){
			throw new Exception(self::STORAGE_FILE_NOT_FOUND);
		}
		try{
			$this->getDbLinkMaster()->query("BEGIN");
			
			//1) Mark in DB
			$this->getDbLinkMaster()->query_first(sprintf(
				"DELETE FROM out_mail_attachments
				WHERE file_id=%s",
			$this->getExtDbVal($pm,'id')		
			));
		
			//2) Remove file
			unlink($fl);
			
			$this->getDbLinkMaster()->query("COMMIT");
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}	
	
	}
	
	public function complete_addr_name($pm){
		$this->addNewModel(sprintf(
			"SELECT DISTINCT to_addr_name
			FROM out_mail
			WHERE lower(to_addr_name) LIKE '%%'||lower(%s)||'%%'
			LIMIT 10"
			,$this->getExtDbVal($pm,'to_addr_name')
		),
		'Addr_Model');
	}
	
</xsl:template>

</xsl:stylesheet>
