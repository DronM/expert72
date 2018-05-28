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


class DocumentTemplate_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		
				$param = new FieldExtEnum('document_type',',','pd,eng_survey,cost_eval_validity,modification,audit'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('construction_type_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDate('create_date'
				,array('required'=>TRUE,
				'alias'=>'Дата создания'
			));
		$pm->addParam($param);
		$param = new FieldExtJSON('content'
				,array('required'=>TRUE,
				'alias'=>'Содержимое шаблона'
			));
		$pm->addParam($param);
		$param = new FieldExtJSON('content_for_experts'
				,array('required'=>TRUE,
				'alias'=>'Содержимое шаблона'
			));
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
				'alias'=>'Комментарий'
			));
		$pm->addParam($param);
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DocumentTemplate_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtEnum('old_document_type',',','pd,eng_survey,cost_eval_validity,modification,audit',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('old_construction_type_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtDate('old_create_date',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		
				$param = new FieldExtEnum('document_type',',','pd,eng_survey,cost_eval_validity,modification,audit'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('construction_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('create_date'
				,array(
			
				'alias'=>'Дата создания'
			));
			$pm->addParam($param);
		$param = new FieldExtJSON('content'
				,array(
			
				'alias'=>'Содержимое шаблона'
			));
			$pm->addParam($param);
		$param = new FieldExtJSON('content_for_experts'
				,array(
			
				'alias'=>'Содержимое шаблона'
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			
				'alias'=>'Комментарий'
			));
			$pm->addParam($param);
		
			$param = new FieldExtEnum('document_type',',','pd,eng_survey,cost_eval_validity,modification,audit',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('construction_type_id',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtDate('create_date',array(
			
				'alias'=>'Дата создания'
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DocumentTemplate_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtEnum('document_type'
		,',','pd,eng_survey,cost_eval_validity,modification,audit'));		
		
		$pm->addParam(new FieldExtInt('construction_type_id'
		));		
		
		$pm->addParam(new FieldExtDate('create_date'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DocumentTemplate_Model');

			
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
		
		$this->setListModelId('DocumentTemplateList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtEnum('document_type'
		,',','pd,eng_survey,cost_eval_validity,modification,audit'));
		
		$pm->addParam(new FieldExtInt('construction_type_id'
		));
		
		$pm->addParam(new FieldExtDate('create_date'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DocumentTemplate_Model');		

		
	}	
	
	private function add_sections($items,$documentType,$constructionTypeId,$createDate,&$queryStr,&$ind){
		foreach($items as $item){
			if (isset($item->items)){
				$this->add_sections($item->items,$documentType,$constructionTypeId,$createDate,$queryStr,$ind);
			}
			else{
				$queryStr.= ($queryStr=='')? '':',';
				$queryStr.= sprintf("(%s,%d,%s,%d,'%s',%d)",
				$documentType,$constructionTypeId,$createDate,
				intval($item->fields->id),$item->fields->descr,
				$ind
				);
				$ind++;
			}
		}
	
	}
	
	public function insert($pm){
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			$ar = parent::insert($pm);
			$cont = json_decode($pm->getParamValue('content_for_experts'));
			
			$document_type = $this->getExtDbVal($pm,'document_type');
			$construction_type_id = $this->getExtDbVal($pm,'construction_type_id');
			$create_date = $this->getExtDbVal($pm,'create_date');
			
			$queryStr = '';
			$ind = 0;
			$this->add_sections($cont->items,$document_type,$construction_type_id,$create_date,$queryStr,$ind);
			if (strlen($queryStr))
				$this->getDbLinkMaster()->query('INSERT INTO expert_sections
				(document_type,construction_type_id,create_date,section_id,section_name,section_index)
				VALUES '.$queryStr);
				
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}
	}	
	public function update($pm){
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			
			$model_name = $this->getUpdateModelId();
			$model = new $model_name($this->getDbLinkMaster());
			$this->methodParamsToModel($pm,$model);
			$q = $model->getUpdateQuery();		
			if (strlen($q)){
				$ar = $this->getDbLink()->query_first($q.' RETURNING document_type,construction_type_id,create_date,content_for_experts');	
				$cont = json_decode($ar['content_for_experts']);
				$ind = 0;
				$this->add_sections(
					$cont->items,
					"'".$ar['document_type']."'",
					$ar['construction_type_id'],
					"'".$ar['create_date']."'",
					$queryStr,
					$ind
				);
				if (strlen($queryStr))
					$this->getDbLinkMaster()->query('INSERT INTO expert_sections
					(document_type,construction_type_id,create_date,section_id,section_name,section_index)
					VALUES '.$queryStr);
				
			}
			
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}
	}	


}
?>