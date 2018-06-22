<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'ShortMessage'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public function get_recipient_list($pm){
		$list_model = new ShortMessageRecipientList_Model($this->getDbLink());
		$this->modelGetList($list_model,$pm);
	}
	
	public function set_recipient_state($pm){
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
			"SELECT
				short_message_recipient_current_states_set(%d,%d),
				short_message_recipient_states_ref((SELECT t FROM short_message_recipient_states t WHERE t.id=%d)) AS states_ref",
		json_decode($_SESSION['employees_ref'])->keys->id,
		$this->getExtDbVal($pm,'recipient_state_id'),
		$this->getExtDbVal($pm,'recipient_state_id')
		));
		$_SESSION['recipient_states_ref'] = $ar['states_ref'];
	}
	
	public function get_list($pm){
		$model = new ShortMessageList_Model($this->getDbLink());
		$model->setLastRowSelectOnInit(true);
		$model->getSelectQueryText(sprintf(
		"WITH
			rec AS (SELECT %d AS v),
			to_rec AS (SELECT %d AS v)
		SELECT
			sub.*
		FROM (
			SELECT * FROM short_messages_list
			WHERE recipient_id=(SELECT rec.v FROM rec) AND to_recipient_id=(SELECT to_rec.v FROM to_rec)
			UNION ALL
			SELECT * FROM short_messages_list
			WHERE recipient_id=(SELECT to_rec.v FROM to_rec) AND to_recipient_id=(SELECT rec.v FROM rec)
		) AS sub
		ORDER BY sub.date_time",
		json_decode($_SESSION['employees_ref'])->keys->id,
		$this->getExtDbVal($pm,'to_recipient_id')
		));
		$from = null; $count = null;
		$limit = $this->limitFromParams($pm,$from,$count);
		if ($from){
			$model->setListFrom($from);
		}
		if ($count){
			$model->setRowsPerPage($count);
		}				
		$model->select(FALSE,NULL,NULL,
			$limit,NULL,NULL,NULL,
			FALSE,TRUE);
		//
		$this->addModel($model);
	}
	
	public function get_recipient_state($pm){
		$this->getDbLinkMaster()->query(sprintf(
		"SELECT
			CASE WHEN st.id IS NULL THEN pdfn_short_message_recipient_states_free()
			ELSE short_message_recipient_states_ref(st)
			END AS recipient_states_ref
		FROM short_message_recipient_current_states AS cur_st
		LEFT JOIN short_message_recipient_states AS st ON st.id=cur_st.recipient_state_id
		WHERE recipient_id=%d",
		json_decode($_SESSION['employees_ref'])->keys->id
		));
	}
	
	public function send_message($pm){
		//files
		
		if (isset($_FILES['files'])){
			$files = array();
			for($i=0;$i&lt;count($_FILES['files']['tmp_name']);$i++){
				$file_id = md5(uniqid());
				if (!move_uploaded_file(
					$_FILES['files']['tmp_name'][$i],
					DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$file_id
					)
				){
					throw new Exception('Ошибка загрузки файла '.$_FILES['files']['name'][$i]);
				}
				$file_o = new stdClass();
				$file_o->file_name = $_FILES['files']['name'][$i];
				$file_o->file_size = $_FILES['files']['size'][$i];
				$file_o->file_id = $file_id;
				array_push($files,$file_o);
			}
			if (count($files)){
				$files_str = json_encode($files);
			}
			
		}
		else{
			$files_str = 'NULL';
		}
	
		$importance_type_id = $this->getExtDbVal($pm,"doc_flow_importance_type_id");
		$content = $this->getExtDbVal($pm,"content");
		$ids = explode(',',$this->getExtVal($pm,"recipient_ids"));
		$q = '';
		
		$empl_id = intval(json_decode($_SESSION['employees_ref'])->keys->id);
		
		$this->getDbLinkMaster()->query('BEGIN');
		try{
			foreach($ids as $id){
				$id_clean = intval($id);
				if ($id_clean){
					$ar = $this->getDbLinkMaster()->query_first(sprintf(
					"INSERT INTO short_messages (recipient_id,to_recipient_id)
					VALUES (%d,%d) RETURNING id",
					$empl_id,$id_clean
					));
				
					$this->getDbLinkMaster()->query(sprintf(
					"INSERT INTO reminders
					(recipient_employee_id,
					content,
					docs_ref,register_docs_ref,
					files,
					doc_flow_importance_type_id)
					VALUES
					(%d,
					%s,
					json_build_object(	
						'keys',json_build_object('id',%d),	
						'descr','Сообщение',
						'dataType','short_messages'
					),
					json_build_object(	
						'keys',json_build_object('id',%d),	
						'descr','Сообщение',
						'dataType','short_messages'
					),					
					%s,
					%d)",
					$id_clean,
					$content,
					$ar['id'],
					$ar['id'],
					$files_str,
					$importance_type_id
					));
				}
			}
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query("ROLLBACK");
			throw $e;
		}
	}
	
</xsl:template>

</xsl:stylesheet>
