<?php
require_once(FRAME_WORK_PATH.'basic_classes/Controller.php');

require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtXML.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */



require_once('common/captcha/Captcha.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class Captcha_Controller extends Controller{
	public function __construct(){
		parent::__construct();
			
		$pm = new PublicMethod('get');
		
		$this->addPublicMethod($pm);

		
	}	
	
	public static function makeModel(){
		$img = Captcha::getResource();
		$_SESSION['captcha'] = Captcha::getKeystring();
		
		ob_start();
		imagepng($img);
		$buffer = ob_get_contents();
		ob_end_clean();		
		
		return new ModelVars(
			array('name'=>'Vars',
				'id'=>'Captcha_Model',
				'values'=>array(
					new Field('img',DT_STRING,
						array('value'=>base64_encode($buffer))
					)
				)
			)
		);
		
	}
	
	public function get($pm){
		$this->addModel(self::makeModel());
	}

}
?>