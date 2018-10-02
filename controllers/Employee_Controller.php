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



require_once('common/downloader.php');

class Employee_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtString('name'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('department_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('post_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('picture'
				,array());
		$pm->addParam($param);
		$param = new FieldExtJSON('picture_info'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('snils'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
			$f_params = array();
			$param = new FieldExtText('picture_file'
			,$f_params);
		$pm->addParam($param);		
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Employee_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('name'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('department_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('post_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('picture'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtJSON('picture_info'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('snils'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
			$f_params = array();
			$param = new FieldExtText('picture_file'
			,$f_params);
		$pm->addParam($param);		
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Employee_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Employee_Model');

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('EmployeeDialog_Model');		

			
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
		
		$this->setListModelId('EmployeeList_Model');
		
			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('name'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('EmployeeList_Model');

			
		$pm = new PublicMethod('download_picture');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_picture');
		
		$this->addPublicMethod($pm);

		
	}	
	
	private function upload_file($pm){
		if (
		(
			!$pm->getParamValue('old_id')
			|| ($_SESSION['role_id']=='admin' || intval(json_decode($_SESSION['employees_ref'])->keys->id)==intval($pm->getParamValue('old_id')))
		)
		&&
		(isset($_FILES['picture_file']) && is_array($_FILES['picture_file']['name']) && count($_FILES['picture_file']['name']))
		){
			$pm->setParamValue('picture', pg_escape_bytea($this->getDbLink()->link_id,file_get_contents($_FILES['picture_file']['tmp_name'][0])) );
			$pm->setParamValue('picture_info',
				sprintf('{"name":"%s","id":"1","size":"%s"}',
				$_FILES['picture_file']['name'][0],
				filesize($_FILES['picture_file']['tmp_name'][0])
				)
			);
			
		}
	}

	public function insert($pm){
		$this->upload_file($pm);
		parent::insert($pm);
	}
	
	public function update($pm){
		$this->upload_file($pm);
		parent::update($pm);
	}

	public function delete_picture($pm){
		$this->getDbLinkMaster()->query(sprintf(
			"UPDATE employees
			SET
				picture=NULL,
				picture_info=NULL
			WHERE id=%d",
			intval(json_decode($_SESSION['employees_ref'])->keys->id)
		));
	}
	public function download_picture($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				picture,
				picture_info
			FROM employees
			WHERE id=%d",
			intval(json_decode($_SESSION['employees_ref'])->keys->id)
		));
		
		if (!is_array($ar) || !count($ar)){
			throw new Exception('Doc not found!');
		}
		
		$picture_info = json_decode($ar['picture_info']);
		
		$data = pg_unescape_bytea($ar['picture']);
		ob_clean();
		header('Content-Length: '.$picture_info->size);
		header('Connection: close');
		header('Content-Type: ' . getMimeTypeOnExt($picture_info->name));
		header('Content-Disposition: attachment;filename="' . $picture_info->name . '";');
		
		echo $data;
		
		return TRUE;
		
	}
	

}
?>