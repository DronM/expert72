<?php
require_once(FRAME_WORK_PATH.'basic_classes/Controller.php');
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



require_once('common/Logger.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');
require_once(FRAME_WORK_PATH.'build/ProjectManager.php');

class ProjectManager_Controller extends Controller{

	const INVALID_UPDATE = 'Нет обновлений для данного проекта!';
	const BUILD_LOG = 'build.log';
	
	private $projManager;
	private $log;

	private function getProjectDir(){
		return substr(ABSOLUTE_PATH,0,strlen(ABSOLUTE_PATH)-1);
	}

	private function getJsDir(){
		return substr(USER_JS_PATH,0,strlen(USER_JS_PATH)-1);
	}

	private function getRepoDir(){
		$pathArray = explode(PATH_SEPARATOR, get_include_path());
		if (count($pathArray)>=2){
			return $pathArray[1].'/'. substr(FRAME_WORK_PATH,0,strlen(FRAME_WORK_PATH)-1).'/'. 'build';
		}
	}
	
	private function printLog(){	
		$lines = array();
		$it = $this->log->getLineIterator();
		$i = 0;
		while($it->valid()){		
			array_push($lines,new Field('line'.$i,DT_STRING,array('value'=>$it->current())));
			$i++;
			
			$it->next();
		}	
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Log_Model',
				'values'=>$lines
			)
		));		
	
		$this->log->dump();
	}
	
	public function __construct(){
		
			
		$pm = new PublicMethod('open_version');
		
				
	$opts=array();
	
		$opts['length']=15;				
		$pm->addParam(new FieldExtString('version',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('close_version');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('commit_description',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('minify_js');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('build_all');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('create_symlinks');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('pull');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('push');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('commit_description',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('zip_project');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('zip_db');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_version');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('apply_patch');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('apply_sql');
		
		$this->addPublicMethod($pm);

		
		
		$this->projManager = new ProjectManager(
			$this->getProjectDir(),
			$this->getRepoDir(),
			$this->getJsDir(),
			array(
				'buildGroup' => BUILD_GROUP,
				'buildFilePermission' => BUILD_FILE_PERMISSION,
				'buildDirPermission' => BUILD_DIR_PERMISSION
			)
		);					
		
		$this->log = new Logger(dirname($this->projManager->getMdFile()).'/'. self::BUILD_LOG,array(
			'buildGroup' => BUILD_GROUP,
			'buildFilePermission' => BUILD_FILE_PERMISSION,
			'buildDirPermission' => BUILD_DIR_PERMISSION
			)
		);
		
	}
	
	
	/* *****************************  */
	public function get_version($pm){
		$this->projManager->getVersion($struc);
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Version_Model',
				'values'=>array(
					new Field('version',DT_STRING,
						array('value'=>$struc['version'])),
					new Field('dateOpen',DT_STRING,
						array('value'=>$struc['dateOpen'])),
					new Field('dateClose',DT_INT,
						array('value'=>$struc['dateClose'])),
					new Field('lastBuild',DT_STRING,
						array('value'=>$struc['lastBuild']))						
				)
			)
		));					
	}
	
	public function open_version($pm){
		$this->projManager->openVersion($_REQUEST['version'],$this->log);
		$this->printLog();
	}
	
	public function close_version($pm){
		$struc = array();
		$this->projManager->getVersion($struc);
							
		$this->projManager->createVersionFile($struc['version'],$this->log);						
		$this->projManager->build($this->log);						
		$this->projManager->minifyJs($struc['version'],$this->log);
		$this->projManager->minifyCSS($struc['version'],$this->log);
		$this->projManager->closeVersion($this->log);			
		$this->projManager->prepareSQLForUpdate($this->log);
		$this->projManager->push($_REQUEST['commit_description'],$this->log);
		
		$this->printLog();
	}
	
	public function minify_js($pm){
		$struc = array();
		$this->projManager->getVersion($struc);
	
		$this->projManager->minifyJs($struc['version'],$this->log);
		$this->projManager->minifyCSS($struc['version'],$this->log);
		
		$this->printLog();
	}
	
	public function build_all($pm){
		$this->projManager->build($this->log);
		
		$this->printLog();
	}
	
	public function create_symlinks($pm){
		$this->projManager->createSymlinks($this->log);
	}
	
	public function pull($pm){
		$this->projManager->pull($this->log);
		$this->projManager->createSymlinks($this->log);	
		$this->printLog();
	}
	
	public function push($pm){
		$this->projManager->push($_REQUEST['commit_description'],$this->log);
		$this->printLog();
	}
	
	public function zip_project($pm){
		$this->projManager->zipProject($this->log);
		$this->printLog();
	}
	
	public function zip_db($pm){
		$this->projManager->zipDb($this->log);
		$this->printLog();
	}
	
	public function apply_patch($pm){	
		if(DEBUG){
			throw new Exception('Can not be done in debug mode!');
		}
	
		$this->projManager->pull($this->log);
		$this->printLog();
						
		//remove build directory
		exec('rm -f -r '. $this->getProjectDir().'/'. ProjectManager::BUILD_DIR);
		
		//remove updates/sql directory
		exec('rm -f -r '. $this->getProjectDir().'/'. ProjectManager::UPDATES_DIR.'/'. ProjectManager::SQL_DIR);
		
	}
	
	public function apply_sql($pm){
		$this->projManager->applySQL(
			array(
				'DB_PASSWORD' => DB_PASSWORD,
				'DB_SERVER_MASTER' => DB_SERVER_MASTER,
				'DB_NAME' => DB_NAME,
				'DB_USER' => DB_USER
			),
			$this->log
		);
		$this->printLog();
	}
	
}
?>