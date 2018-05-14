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



require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');
require_once(FRAME_WORK_PATH.'basic_classes/Field.php');
require_once('common/ClientSearch.php');

class ClientSearch_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			
		$pm = new PublicMethod('search');
		
				
	$opts=array();
	
		$opts['length']=250;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('query',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	public function search($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();
		
		$resp = ClientSearch::search($params->getVal("query"));
		$json = json_decode($resp);
		$model = new Model(array('id'=>'SearchResult_Model'));		
		/*
		$row = array(
			new Field('name',DT_STRING,array('value'=>$json->suggestions[0]->value)),
			new Field('dirname',DT_STRING,array('value'=>$json->suggestions[0]->data->management->name)),
			new Field('dirpost',DT_STRING,array('value'=>$json->suggestions[0]->data->management->post)),
			new Field('inn',DT_STRING,array('value'=>$json->suggestions[0]->data->inn)),
			new Field('kpp',DT_STRING,array('value'=>$json->suggestions[0]->data->kpp)),
			new Field('ogrn',DT_STRING,array('value'=>$json->suggestions[0]->data->ogrn)),
			new Field('okpo',DT_STRING,array('value'=>$json->suggestions[0]->data->okpo)),
			new Field('okved',DT_STRING,array('value'=>$json->suggestions[0]->data->okved)),
			new Field('status',DT_STRING,array('value'=>$json->suggestions[0]->data->state->registration_date)),
			new Field('address',DT_STRING,array('value'=>$json->suggestions[0]->data->address->value))
		);
		*/
		$row = array(
			new Field('param',DT_STRING,array('value'=>'Наименование')),
			new Field('val',DT_STRING,array('value'=>$json->suggestions[0]->value))
		);
		$model->insert($row);					
		//
		if ($json->suggestions[0]->data){
			if ($json->suggestions[0]->data->management){
				$row = array(
					new Field('param',DT_STRING,array('value'=>'ФИО руководителя')),
					new Field('val',DT_STRING,array('value'=>$json->suggestions[0]->data->management->name))
				);
				$model->insert($row);					
				//
				$row = array(
					new Field('param',DT_STRING,array('value'=>'Должность руководителя')),
					new Field('val',DT_STRING,array('value'=>$json->suggestions[0]->data->management->post))
				);
				$model->insert($row);					
			}			
			//
			if ($json->suggestions[0]->data->inn){
				$row = array(
					new Field('param',DT_STRING,array('value'=>'ИНН')),
					new Field('val',DT_STRING,array('value'=>$json->suggestions[0]->data->inn))
				);
				$model->insert($row);					
			}
			//
			if ($json->suggestions[0]->data->kpp){
				$row = array(
					new Field('param',DT_STRING,array('value'=>'КПП')),
					new Field('val',DT_STRING,array('value'=>$json->suggestions[0]->data->kpp))
				);
				$model->insert($row);					
			}
			//
			if ($json->suggestions[0]->data->ogrn){
				$row = array(
					new Field('param',DT_STRING,array('value'=>'ОГРН')),
					new Field('val',DT_STRING,array('value'=>$json->suggestions[0]->data->ogrn))
				);
				$model->insert($row);					
			}
			//
			if ($json->suggestions[0]->data->okpo){
				$row = array(
					new Field('param',DT_STRING,array('value'=>'ОКПО')),
					new Field('val',DT_STRING,array('value'=>$json->suggestions[0]->data->okpo))
				);
				$model->insert($row);					
			}
			//
			if ($json->suggestions[0]->data->okved){
				$row = array(
					new Field('param',DT_STRING,array('value'=>'ОКВЭД')),
					new Field('val',DT_STRING,array('value'=>$json->suggestions[0]->data->okved))
				);
				$model->insert($row);					
			}
			//
			/*
			if ($json->suggestions[0]->data->state && $json->suggestions[0]->data->state->registration_date){
				$row = array(
					new Field('param',DT_STRING,array('value'=>'Дата регистрации')),
					new Field('val',DT_STRING,array('value'=>date('Y-m-d',$json->suggestions[0]->data->state->registration_date)))
				);
				$model->insert($row);					
			}
			*/
			//
			if ($json->suggestions[0]->data->address && $json->suggestions[0]->data->address->value){
				$row = array(
					new Field('param',DT_STRING,array('value'=>'Адрес')),
					new Field('val',DT_STRING,array('value'=>$json->suggestions[0]->data->address->value))
				);
				$model->insert($row);					
			}
		}				
		$this->addModel($model);
	}

}
?>