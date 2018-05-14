<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'ReportTemplateFile'"/>
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
require_once(FRAME_WORK_PATH.'basic_classes/ModelWhereSQL.php');
require_once(USER_CONTROLLERS_PATH.'DocFlowTask_Controller.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	private static function getExt($name){
		$ext = '';
		$fl_parts = explode('.',$name);
		if (count($fl_parts)){
			$ext = $fl_parts[count($fl_parts)-1];
		}
		return '.'.$ext;	
	}
	private static function getTemplFile($fileId,$fileName){
		return OUTPUT_PATH.$fileId. '_tmpl'. self::getExt($fileName);
	}

	private function upload_file($pm){
		if (isset($_FILES['template_file']) &amp;&amp; is_array($_FILES['template_file']['name']) &amp;&amp; count($_FILES['template_file']['name'])){
			if ($this->getExtVal($pm,'old_id')){
				$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT
						file_inf->>'id' AS file_id,
						file_inf->>'name' AS file_name
					FROM report_template_files
					WHERE id=%d",
				$this->getExtDbVal($pm,'old_id')
				));
				$old_file = self::getTemplFile($ar['file_id'],$ar['file_name']);
				if (file_exists($old_file)){
					unlink($old_file);
				}
			}
			$file_id = md5($_FILES['template_file']['tmp_name'][0]);
		
			$fl = self::getTemplFile($file_id,$_FILES['template_file']['name'][0]);
			move_uploaded_file($_FILES['template_file']['tmp_name'][0], $fl);
			
			$pm->setParamValue('file_inf',
				sprintf('{"name":"%s","id":"%s","size":"%s"}',
				$_FILES['template_file']['name'][0],
				$file_id,
				filesize($fl)
				)
			);
			$pm->setParamValue('file_data', pg_escape_bytea($this->getDbLink()->link_id,file_get_contents($fl)) );
		}
	}
	
	
	public function insert($pm){
		if ($_SESSION['role_id']!='admin' || ($_SESSION['role_id']=='admin' &amp;&amp; !$pm->getParamValue('employee_id')) ){
			$ref = json_decode($_SESSION['employees_ref']);
			if ($ref){
				$pm->setParamValue('employee_id',$ref->keys->id);
			}
		}
		$this->upload_file($pm);
		parent::insert($pm);
	}
	
	public function update($pm){
		if ($_SESSION['role_id']!='admin' &amp;&amp; $pm->getParamValue('employee_id')){
			throw new Exception('Запрещено менять автора!');
		}
	
		$this->upload_file($pm);
		parent::update($pm);
	}

	public function delete($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				file_inf->>'id' AS file_id,
				file_inf->>'name' AS file_name,
				employee_id
			FROM report_template_files
			WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		
		if (!count($ar)){
			throw new Exception('Шаблон не найден!');
		}
		
		$ref = json_decode($_SESSION['employees_ref']);
		if ($_SESSION['role_id']!='admin' &amp;&amp; $ar['employee_id']!=$ref->keys->id ){
			throw new Exception('Запрещено удалять чужой шаблон!');
		}
		
		$tmp_file = self::getTemplFile($ar['file_id'],$ar['file_name']);
		if (file_exists($tmp_file)){
			unlink($tmp_file);
		}
		parent::delete($pm);
	}

	public function delete_file($pm){
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				file_inf->>'id' AS file_id,
				file_inf->>'name' AS file_name,
				employee_id
			FROM report_template_files
			WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		$employees_ref = json_decode($_SESSION['employees_ref']);
		if ($_SESSION['role_id']!='admin' &amp;&amp; $ar['employee_id']!=$employees_ref->id){
			throw new Exception('Запрещено удалять чужой шаблон!');
		}
		
		$tmp_file = self::getTemplFile($ar['file_id'],$ar['file_name']);
		if (file_exists($tmp_file)){
			unlink($tmp_file);
		}	
		$ar = $this->getDbLink()->query_first(sprintf(
			"UPDATE report_template_files
			SET
				file_data=NULL,
				file_inf=NULL
			WHERE id=%d",
		$this->getExtDbVal($pm,'id')
		));
		
	}

	public function download_file($pm){
		DocFlowTask_Controller::set_employee_id($this->getDbLink());
		$check_q = '';
		if ($_SESSION['role_id']!='admin'){
			$check_q = sprintf(
			" AND employee_id=%d OR 'employees%s' =ANY (permission_ar) OR 'departments%s' =ANY (permission_ar)",
			$_SESSION['employee_id'],
			$_SESSION['employee_id'],
			$_SESSION['department_id']
			);
			
		}
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				file_inf->>'id' AS file_id,
				file_inf->>'name' AS file_name
			FROM report_template_files
			WHERE id=%d".$check_q,
		$this->getExtDbVal($pm,'id')
		));
		
		if (!count($ar)){
			throw new Exception('File not found!');
		}
		
		$tmp_file = self::getTemplFile($ar['file_id'],$ar['file_name']);
		if (!file_exists($tmp_file)){
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					file_inf->>'id' AS file_id,
					file_inf->>'name' AS file_name,
					file_data
				FROM report_template_files
				WHERE id=%d",
			$this->getExtDbVal($pm,'id')
			));
		
			file_put_contents($tmp_file,pg_unescape_bytea($ar['file_data']));
		}
		
		$mime = getMimeTypeOnExt($ar['file_name']);
		ob_clean();
		downloadFile($tmp_file, $mime,'attachment;',$ar['file_name']);
		
		return TRUE;
	}

	/**
	 * Обработка OpenOffice шаблона через ZipArchive
	 * @param {string} tmpFile template file 
	 * @param {array} data asociative array of filed=value
	 * @param {string} outFile output file
	 */
	private static function render($tmpFile,$data,$outFile){
		$CONTENT_NAME = 'content.xml';
		
		//Создание копии для исходного файла
		copy($tmpFile,$outFile);
		
		//Открываем архиватором
		$zip = new ZipArchive();
		$res = $zip->open($outFile);
		if ($res===TRUE) {
			$unzipped = OUTPUT_PATH.uniqid().'_'.$CONTENT_NAME;
			$tmp_data = $zip->getFromName($CONTENT_NAME);
			if($tmp_data===FALSE) {
				throw new Exception('Content not found in archive!');
			}
			$zip->deleteName($CONTENT_NAME);
			foreach($data as $f_id=>$f_val){
				$tmp_data = str_replace('{'.$f_id.'}',$f_val,$tmp_data);
			}
			file_put_contents($unzipped, $tmp_data);
			try{
				$zip->addFile($unzipped, $CONTENT_NAME);        
				$zip->close();	
			}
			finally{
				unlink($unzipped);
			}			
		}
		else{
			throw new Exception('Error opening file as archive, code:'.$res);
		}
	}

	public function apply_template_file($pm){
		DocFlowTask_Controller::set_employee_id($this->getDbLink());
		$check_q = '';
		if ($_SESSION['role_id']!='admin'){
			$check_q = sprintf(
			" AND tf.employee_id=%d OR 'employees%s' =ANY (tf.permission_ar) OR 'departments%s' =ANY (tf.permission_ar)",
			$_SESSION['employee_id'],
			$_SESSION['employee_id'],
			$_SESSION['department_id']
			);
			
		}
	
		$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				t.fields,
				t.in_params,
				tf.file_inf->>'name' AS file_name,
				tf.file_inf->>'id' AS file_id,
				t.db_entity
			FROM report_template_files AS tf
			LEFT JOIN report_templates AS t ON t.id=tf.report_template_id
			WHERE tf.report_template_id=%d".$check_q,
		$this->getExtDbVal($pm,'id')
		));
		if (!count($ar)){
			throw new Exception('File not found!');
		}
		
		$tmp_file = self::getTemplFile($ar['file_id'],$ar['file_name']);
		if (!file_exists($tmp_file)){
			//no template file in cashe
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT
					t.fields,
					t.in_params,
					tf.file_inf->>'name' AS file_name,
					tf.file_inf->>'id' AS file_id,
					t.db_entity,
					tf.file_data
				FROM report_template_files AS tf
				LEFT JOIN report_templates AS t ON t.id=tf.report_template_id
				WHERE tf.report_template_id=%d",
			$this->getExtDbVal($pm,'id')
			));
			file_put_contents($tmp_file,pg_unescape_bytea($ar['file_data']));
		}
		$out_file = OUTPUT_PATH.uniqid().self::getExt($ar['file_name']);		
		
		$field_model = json_decode($ar['fields']);
		$params = json_decode($this->getExtVal($pm,'params'));
		
		$columns = '';
		$cond = '';
		if (is_array($field_model->rows)){
			foreach ($field_model->rows as $row) {
				if (is_object($row->fields)){			
					$columns.= ($columns=='')? '':', ';
					$columns.= '"'.$row->fields->id.'"';
				}
			}
		}
		foreach($params as $param){
			$field_id = '"'.$param->id.'"';
	
			if (is_object($param->val)){
				foreach ($param->val->keys as $key => $key_val) {
					$val = $key_val;
					//first key
					break;
				}
			}
			else{
				$val = $param->val;
			}
			$val = "'".$val."'";
			if (isset($param->cond) &amp;&amp; $param->cond){
				$cond.= ($cond=='')? 'WHERE ':' AND ';
				$cond.= sprintf('%s=%s',$field_id, $val);
			}
			else{
				$columns.= ($columns=='')? '':', ';
				$columns.= sprintf('%s AS %s', $val, $field_id);
			}
		}
		
		
		//Данные
		//throw new Exception(sprintf('SELECT %s FROM "%s" %s', $columns,$ar['db_entity'],$cond));
		$data = $this->getDbLink()->query_first(sprintf('SELECT %s FROM "%s" %s LIMIT 1', $columns,$ar['db_entity'],$cond));
		//tmp_file + данные = out_file
		
		try{
			self::render($tmp_file,$data,$out_file);
			if (!file_exists($out_file)){
				throw new Error('Can not render template!');
			}
		
			$mime = getMimeTypeOnExt($ar['file_name']);
			ob_clean();
			downloadFile($out_file, $mime,'attachment;',$ar['file_name']);
		}
		finally{
			if (file_exists($out_file)){
				unlink($out_file);
			}
		}
		return TRUE;
	}
	public function get_list($pm){
		if ($_SESSION['role_id']=='admin'){
			parent::get_list($pm);
		}
		else{
			//permissions
			$list_model = $this->getListModelId();
			$model = new $list_model($this->getDbLink());
			
			$where = new ModelWhereSQL();
			DocFlowTask_Controller::set_employee_id($this->getDbLink());
			$where->addExpression('permission_ar',
				sprintf(
				"employee_id=%d OR 'employees%s' =ANY (permission_ar) OR 'departments%s' =ANY (permission_ar)
				",
				$_SESSION['employee_id'],
				$_SESSION['employee_id'],
				$_SESSION['department_id']
				)
			);
			$model->select(FALSE,$where,NULL,
				NULL,NULL,NULL,NULL,
				NULL,TRUE
			);
			$this->addModel($model);
		}
	}
	
</xsl:template>

</xsl:stylesheet>
