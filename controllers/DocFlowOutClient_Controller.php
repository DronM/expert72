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



require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');

class DocFlowOutClient_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtDateTimeTZ('date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('reg_number'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('application_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('subject'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('content'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('sent'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DocFlowOutClient_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('reg_number'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('application_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('subject'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('content'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('sent'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocFlowOutClient_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DocFlowOutClient_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DocFlowOutClientDialog_Model');		

			
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

		$this->addPublicMethod($pm);
		
		$this->setListModelId('DocFlowOutClientList_Model');
		
			
		$pm = new PublicMethod('get_application_dialog');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
				
	$opts=array();
			
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('remove_file');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('application_id',$opts));
	
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('file_id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	public function insert($pm){
		$pm->setParamValue("user_id",$_SESSION['user_id']);
		parent::insert($pm);
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
				$files_q_id = $this->getDbLink()->query(sprintf(
					"SELECT fl.*
					FROM application_document_files AS fl
					WHERE fl.application_id=%d AND NOT fl.deleted
					ORDER BY document_type,document_id,file_name,deleted_dt ASC NULLS LAST",
				$applicationId
				));		
				//fl.file_id IN (SELECT ofl.file_id FROM doc_flow_out_client_document_files AS ofl WHERE ofl.doc_flow_out_client_id=%d)	
			}
						
			$document_exists = ( $ar_obj['document_exists']=='t' && !is_null($docId) );
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
		if (!count($ar) || ($_SESSION['role_id']!='admin' && $ar['user_id']!=$_SESSION['user_id']) || $ar['sent']=='t'){
			throw new Exception('Forbidden!');
		}
		parent::delete($pm);
	}

}
?>