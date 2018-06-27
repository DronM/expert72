<?php
require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInterval.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtArray.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtXML.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */



class ShortMessage_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			
		$pm = new PublicMethod('send_message');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('content',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('files',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('recipient_ids',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('doc_flow_importance_type_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ShortMessageList_Model');		

			
		/* get_list */
		$pm = new PublicMethod('get_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

			$f_params = array();
			
				$f_params['required']=true;
			$param = new FieldExtInt('to_recipient_id'
			,$f_params);
		$pm->addParam($param);		
		
		$this->addPublicMethod($pm);
		
		$this->setListModelId('ShortMessageList_Model');
		
			
		$pm = new PublicMethod('get_recipient_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_unviewed_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('set_recipient_state');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('recipient_state_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_recipient_state');
		
		$this->addPublicMethod($pm);

		
	}	
	

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
			for($i=0;$i<count($_FILES['files']['tmp_name']);$i++){
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
	

}
?>