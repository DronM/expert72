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



//require_once('functions/res_rus.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/GlobalFilter.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelWhereSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

require_once('common/PwdGen.php');
require_once('functions/ExpertEmailSender.php');
require_once('controllers/Captcha_Controller.php');

class User_Controller extends ControllerSQL{

	const PWD_LEN = 6;
	const ER_USER_NOT_DEFIND = "Пользователь не определен!@1000";
	const ER_NO_EMAIL = "Не задан адрес электронный почты!@1001";
	const ER_LOGIN_TAKEN = "Имя пользователя занято.@1002";
	const ER_NAME_OR_EMAIL_TAKEN = "Логин или адрес электронной почты заняты.@1003";
	const ER_WRONG_CAPTCHA = "Неверный код с картинки.@1004";
	const ER_BANNED = "Доступ запрещен!@1005";
	const ER_REG = "Ошибка регистрации пользователя!@1006";

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtString('name'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtString('name_full'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtBool('banned'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('role_id',',','admin,client,lawyer,expert,boss,accountant'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtPassword('pwd'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('phone_cel'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('time_zone_locale_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('email'
				,array());
		$pm->addParam($param);
		
				$param = new FieldExtEnum('locale_id',',','ru'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('pers_data_proc_agreement'
				,array(
				'alias'=>'Согласие на обработку персональных данных'
			));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('create_dt'
				,array(
				'alias'=>'Дата создания'
			));
		$pm->addParam($param);
		$param = new FieldExtBool('email_confirmed'
				,array(
				'alias'=>'Адрес электр.почты подтвержден'
			));
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
				'alias'=>'Комментарий'
			));
		$pm->addParam($param);
		$param = new FieldExtText('color_palette'
				,array(
				'alias'=>'Цветовая схема'
			));
		$pm->addParam($param);
		$param = new FieldExtBool('reminders_to_email'
				,array(
				'alias'=>'Дублировать напоминания на электронную почту'
			));
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('User_Model');

			
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
		$param = new FieldExtString('name_full'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('banned'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('role_id',',','admin,client,lawyer,expert,boss,accountant'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtPassword('pwd'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('phone_cel'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('time_zone_locale_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('email'
				,array(
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('locale_id',',','ru'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('pers_data_proc_agreement'
				,array(
			
				'alias'=>'Согласие на обработку персональных данных'
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('create_dt'
				,array(
			
				'alias'=>'Дата создания'
			));
			$pm->addParam($param);
		$param = new FieldExtBool('email_confirmed'
				,array(
			
				'alias'=>'Адрес электр.почты подтвержден'
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			
				'alias'=>'Комментарий'
			));
			$pm->addParam($param);
		$param = new FieldExtText('color_palette'
				,array(
			
				'alias'=>'Цветовая схема'
			));
			$pm->addParam($param);
		$param = new FieldExtBool('reminders_to_email'
				,array(
			
				'alias'=>'Дублировать напоминания на электронную почту'
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('User_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('User_Model');

			
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
		
		$this->setListModelId('UserList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('UserDialog_Model');		

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('name'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('UserList_Model');

			
		$pm = new PublicMethod('get_profile');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('password_recover');
		
				
	$opts=array();
	
		$opts['length']=100;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('email',$opts));
	
				
	$opts=array();
	
		$opts['length']=10;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('captcha_key',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('register');
		
				
	$opts=array();
	
		$opts['length']=50;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('name',$opts));
	
				
	$opts=array();
	
		$opts['length']=250;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('name_full',$opts));
	
				
	$opts=array();
	
		$opts['length']=50;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('pwd',$opts));
	
				
	$opts=array();
	
		$opts['length']=100;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('email',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;
		$opts['value']=FALSE;				
		$pm->addParam(new FieldExtBool('pers_data_proc_agreement',$opts));
	
				
	$opts=array();
	
		$opts['length']=10;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('captcha_key',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('name_check');
		
				
	$opts=array();
	
		$opts['length']=100;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('name',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('login');
		
				
	$opts=array();
	
		$opts['alias']='Имя пользователя';
		$opts['length']=50;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('name',$opts));
	
				
	$opts=array();
	
		$opts['alias']='Пароль';
		$opts['length']=50;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtPassword('pwd',$opts));
	
				
			
		$this->addPublicMethod($pm);

			
			
		$pm = new PublicMethod('logout');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('logout_html');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('email_confirm');
		
				
	$opts=array();
	
		$opts['length']=36;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('key',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('hide');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}
		
	
	public function insert($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();
	
		$email = $params->getVal('email');
		$tel = $params->getVal('phone_cel');
	
		if (!strlen($email)){
			throw new Exception(User_Controller::ER_NO_EMAIL);
		}
		$new_pwd = DEF_NEW_USER_PWD;//gen_pwd(self::PWD_LEN);
		$pm->setParamValue('pwd',$new_pwd);
		
		$model_id = $this->getInsertModelId();
		$model = new $model_id($this->getDbLinkMaster());
		$inserted_id_ar = $this->modelInsert($model,TRUE);
		
		$this->pwd_notify($inserted_id_ar['id'],"'".$new_pwd."'");
			
		$fields = array();
		foreach($inserted_id_ar as $key=>$val){
			array_push($fields,new Field($key,DT_STRING,array('value'=>$val)));
		}			
		$this->addModel(new ModelVars(
			array('id'=>'InsertedId_Model',
				'values'=>$fields)
			)
		);
		
		$color_palette = $pm->getParamValue('color_palette');		
		if (isset($color_palette)){
			$_SESSION['color_palette'] = $color_palette;
		}
			
	}
	
	private function setLogged($logged){
		if ($logged){			
			$_SESSION['LOGGED'] = true;			
		}
		else{
			session_destroy();
			$_SESSION = array();
		}		
	}
	public function logout(){
		$this->getDbLinkMaster()->query(sprintf(
		"UPDATE logins
		SET
			date_time_out=now()::timestamp
		WHERE session_id='%s'",session_id()));
	
		$this->setLogged(FALSE);
	}
	
	public function logout_html(){
		$this->logout();
		header("Location: index.php");
	}
	
	/* array with user inf*/
	private function set_logged($ar){
		$this->setLogged(TRUE);
		
		$_SESSION['user_id']		= $ar['id'];
		$_SESSION['user_name']		= $ar['name'];
		$_SESSION['user_name_full']	= $ar['name_full'];
		$_SESSION['role_id']		= $ar['role_id'];
		$_SESSION['locale_id'] 		= $ar['locale_id'];
		$_SESSION['user_time_locale'] 	= $ar['user_time_locale'];
		$_SESSION['color_palette'] 	= $ar['color_palette'];				
		if ($ar['role_id']!='client'){
			$_SESSION['employees_ref'] = $ar['employees_ref'];
			$_SESSION['departments_ref'] = $ar['departments_ref'];
			$_SESSION['department_boss'] = ($ar['department_boss']=='t');
			$_SESSION['recipient_states_ref'] = $ar['recipient_states_ref'];
		}
		
		//global filters				
		if ($ar['role_id']=='client'){
			$_SESSION['global_user_id'] = $ar['id'];
						
			$model = new UserProfile_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('id');
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('UserProfile_Model',$filter);
						
			$model = new Application_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('user_id');
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('Application_Model',$filter);
						
			$model = new ApplicationDialog_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('user_id');
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('ApplicationDialog_Model',$filter);
						
			$model = new ApplicationList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('user_id');
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('ApplicationList_Model',$filter);
						
			$model = new DocFlowOutClient_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('user_id');
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('DocFlowOutClient_Model',$filter);
						
			$model = new DocFlowOutClientList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('user_id');
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('DocFlowOutClientList_Model',$filter);
						
			$model = new DocFlowOutClientDialog_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('user_id');
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('DocFlowOutClientDialog_Model',$filter);
						
			$model = new DocFlowInClient_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('user_id');
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('DocFlowInClient_Model',$filter);
						
			$model = new DocFlowInClientList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('user_id');
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('DocFlowInClientList_Model',$filter);
						
			$model = new DocFlowInClientDialog_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('user_id');
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('DocFlowInClientDialog_Model',$filter);
			
		}
		else{
			$_SESSION['global_employee_id'] = json_decode($ar['employees_ref'])->keys->id;
						
			$model = new Reminder_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('recipient_employee_id');
			$field->setValue($_SESSION['global_employee_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('Reminder_Model',$filter);
			
		}
		
		$log_ar = $this->getDbLinkMaster()->query_first(
			sprintf("SELECT pub_key FROM logins
			WHERE session_id='%s' AND user_id =%d AND date_time_out IS NULL",
			session_id(),intval($ar['id']))
		);
		if (!$log_ar['pub_key']){
			//no user login
			
			$this->pub_key = uniqid();
			
			$log_ar = $this->getDbLinkMaster()->query_first(
				sprintf("UPDATE logins SET 
					user_id = %d,
					pub_key = '%s'
				WHERE session_id='%s' AND user_id IS NULL
				RETURNING id",
				intval($ar['id']),$this->pub_key,session_id())
			);				
			if (!$log_ar['id']){
				//нет вообще юзера
				$log_ar = $this->getDbLinkMaster()->query_first(
					sprintf("INSERT INTO logins
					(date_time_in,ip,session_id,pub_key,user_id)
					VALUES('%s','%s','%s','%s',%d)
					RETURNING id",
					date('Y-m-d H:i:s'),$_SERVER["REMOTE_ADDR"],
					session_id(),$this->pub_key,intval($ar['id']))
				);								
			}
			$_SESSION['LOGIN_ID'] = $ar['id'];			
		}
		else{
			//user logged
			$this->pub_key = trim($log_ar['pub_key']);
		}
		
		if ($ar['role_id']=='client'){
			//custom session duration
			$sess_len = CLIENT_SESSION_EXP_SEC;
		}
		else{
			$sess_len = SESSION_EXP_SEC;
		}
		$_SESSION['sess_len'] = $sess_len;
		$_SESSION['sess_discard_after'] = time() + $sess_len;
	}
	
	private function do_login($pm){		
		$this->pwd = $this->getExtVal($pm,'pwd');
		$ar = $this->getDbLink()->query_first(
			sprintf(
			"SELECT 
				u.*
			FROM user_view AS u
			WHERE (u.name=%s OR u.email=%s) AND u.pwd=md5(%s)",
			$this->getExtDbVal($pm,'name'),
			$this->getExtDbVal($pm,'name'),
			$this->getExtDbVal($pm,'pwd')
			));
			
		if (!is_array($ar) || !count($ar) || !intval($ar['id'])){
			throw new Exception(ERR_AUTH);
		}
		else if ($ar['banned']=='t'){
			throw new Exception(self::ER_BANNED);
		}
		else{
			$this->set_logged($ar);
			
		}
	}
	
	private function login_ext($pm){
		
		$access_token = $this->pub_key.':'.md5($this->pub_key.session_id());
		$refresh_token = $this->pub_key.':'.md5($this->pub_key.$_SESSION['user_id'].md5($this->pwd));
		
		$_SESSION['token'] = $access_token;
		$_SESSION['tokenr'] = $refresh_token;
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Auth_Model',
				'values'=>array(
					new Field('access_token',DT_STRING,
						array('value'=>$access_token)),
					new Field('refresh_token',DT_STRING,
						array('value'=>$refresh_token)),
					new Field('expires_in',DT_INT,
						array('value'=>SESSION_EXP_SEC)),
					new Field('time',DT_STRING,
						array('value'=>round(microtime(true) * 1000)))
				)
			)
		));
		
		if (defined('PARAM_TOKEN')){
			if ($this->getExtVal($pm,'rememberMe')){
				setcookie(PARAM_TOKEN,$access_token,time()+SESSION_EXP_SEC,'expert72',$_SERVER['HTTP_HOST']);
			}
			else{
				setcookie(PARAM_TOKEN,NULL,-1,'expert72',$_SERVER['HTTP_HOST']);
			}
		}
	}
	
	public function login($pm){		
		$this->do_login($pm);
		//$this->login_ext($pm);
	}
	
	public function login_refresh($pm){
		$p = new ParamsSQL($pm,$this->getDbLink());
		$p->addAll();
		$refresh_token = $p->getVal('refresh_token');
		$refresh_p = strpos($refresh_token,':');
		if ($refresh_p===FALSE){
			throw new Exception(ERR_AUTH);
		}
		$refresh_salt = substr($refresh_token,0,$refresh_p);
		$refresh_salt_db = NULL;
		$f = new FieldExtString('salt');
		FieldSQLString::formatForDb($this->getDbLink(),$f->validate($refresh_salt),$refresh_salt_db);
		
		$refresh_hash = substr($refresh_token,$refresh_p+1);
		
		$ar = $this->getDbLink()->query_first(
		"SELECT
			l.id,
			trim(l.session_id) session_id,
			u.pwd u_pwd_hash
		FROM logins l
		LEFT JOIN users u ON u.id=l.user_id
		WHERE l.date_time_out IS NULL
			AND l.pub_key=".$refresh_salt_db);
		
		if (!$ar['session_id']
		||$refresh_hash!=md5($refresh_salt.$_SESSION['user_id'].$ar['u_pwd_hash'])
		){
			throw new Exception(ERR_AUTH);
		}	
				
		$link = $this->getDbLinkMaster();
		
		try{
			//продляем сессию, обновляем id
			$old_sess_id = session_id();
			session_regenerate_id();
			$new_sess_id = session_id();
			$pub_key = uniqid();
			
			$link->query('BEGIN');									
			$link->query(sprintf(
			"UPDATE sessions
				SET id='%s'
			WHERE id='%s'",$new_sess_id,$old_sess_id));
			
			$link->query(sprintf(
			"UPDATE logins
			SET
				set_date_time=now()::timestamp,
				session_id='%s',
				pub_key='%s'
			WHERE id=%d",$new_sess_id,$pub_key,$ar['id']));
			
			$link->query('COMMIT');
		}
		catch(Exception $e){
			$link->query('ROLLBACK');
			$this->setLogged(FALSE);
			throw new Exception(ERR_AUTH);
		}
		
		//новые данные		
		$access_token = $pub_key.':'.md5($pub_key.$new_sess_id);
		$refresh_token = $pub_key.':'.md5($pub_key.$_SESSION['user_id'].$ar['u_pwd_hash']);
		
		$_SESSION['token'] = $access_token;
		$_SESSION['tokenr'] = $refresh_token;
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Auth_Model',
				'values'=>array(
					new Field('access_token',DT_STRING,
						array('value'=>$access_token)),
					new Field('refresh_token',DT_STRING,
						array('value'=>$refresh_token)),
					new Field('expires_in',DT_INT,
						array('value'=>SESSION_EXP_SEC)),
					new Field('time',DT_STRING,
						array('value'=>round(microtime(true) * 1000)))						
				)
			)
		));		
	}
		
	private function pwd_notify($userId,$pwd){
		//email
		ExpertEmailSender::regMail(
			$this->getDbLinkMaster(),
			sprintf("email_reset_pwd(%d,%s)",
				$userId,
				$pwd
			),
			NULL,
			'reset_pwd'
		);
	}
	
	private function email_confirm_notify($userId,$key){
		//email
		ExpertEmailSender::regMail(
			$this->getDbLinkMaster(),
			sprintf("email_user_email_conf(%d,%s)",
				$userId,$key
			),
			NULL,
			'user_email_conf'
		);
	}
	
	public function password_recover($pm){		
		try{
			$this->check_captcha($pm);	
		
			$ar = $this->getDbLink()->query_first(sprintf(
			"SELECT id FROM users WHERE email=%s",
			$this->getExtDbVal($pm,'email')
			));
			if (!is_array($ar) || !count($ar)){
				throw new Exception('Адрес электронной почты не найден!');
			}		
		
			$pwd = "'".gen_pwd(self::PWD_LEN)."'";
		
			try{		
				$this->getDbLinkMaster()->query('BEGIN');
			
				$this->getDbLinkMaster()->query(sprintf(
					"UPDATE users SET pwd=md5(%s)
					WHERE id=%d",
					$pwd,$ar['id'])
				);
				$this->pwd_notify($ar['id'],$pwd);
			
				$this->getDbLinkMaster()->query('COMMIT');
			}
			catch(Exception $e){
				$this->getDbLinkMaster()->query('ROLLBACK');
				throw $e;		
			}
		}
		catch(Exception $e2){
			$this->addModel(Captcha_Controller::makeModel());
			throw $e2;				
		}
	}
	
	public function get_time($pm){
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Time_Model',
				'values'=>array(
					new Field('value',DT_STRING,
						array('value'=>round(microtime(true) * 1000)))
					)
				)
			)
		);		
	}
	
	private function check_captcha($pm){
		if (!isset($_SESSION['captcha'])){
			throw new Exception('Captcha is not generated!');
		}
		if ($_SESSION['captcha']!=$this->getExtVal($pm,'captcha_key')){
			throw new Exception(self::ER_WRONG_CAPTCHA);
		}
	}
	
	public function register($pm){
		/*
		1) Проверить капчу
		2) Проверить почту
		3) занести в users
		4) Подтверждение письма
		5) Отправить письмо для подтверждения мыла. после подтверждения можно заходить через мыло
		6) авторизовать
		*/
						
		try{
			$this->check_captcha($pm);
			
			//$ar = $this->field_check($pm,'email','name');
			$ar = $this->getDbLink()->query_first(sprintf(
				"SELECT TRUE AS ex FROM users WHERE name=%s OR email=%s",
				$this->getExtDbVal($pm,'name'),$this->getExtDbVal($pm,'email')
			));

			if ($this->getExtVal($pm,'pers_data_proc_agreement')!='1'){
				throw new Exception("Нет согласия на обработку персональных данных!");
			}

			if (count($ar) && $ar['ex']=='t'){
				throw new Exception(self::ER_NAME_OR_EMAIL_TAKEN);
			}
			
			try{
				$this->getDbLinkMaster()->query('BEGIN');
			
				$inserted_id_ar = $this->getDbLinkMaster()->query_first(sprintf(
				"INSERT INTO users (role_id,name,pwd,email,name_full,pers_data_proc_agreement,time_zone_locale_id)
				values ('client'::role_types,%s,md5(%s),%s,%s,TRUE,1)
				RETURNING id",
				$this->getExtDbVal($pm,'name'),
				$this->getExtDbVal($pm,'pwd'),
				$this->getExtDbVal($pm,'email'),
				$this->getExtDbVal($pm,'name_full')
				));

				if (!is_array($inserted_id_ar) || !count($inserted_id_ar) || !intval($inserted_id_ar['id'])){
					throw new Exception(self::ER_REG);
				}

				$ar_email_key = $this->getDbLinkMaster()->query_first(sprintf(
					"INSERT INTO user_email_confirmations (key,user_id)
					values (md5(CURRENT_TIMESTAMP::text),%d)
					RETURNING key",
					$inserted_id_ar['id']
				));
	
				ExpertEmailSender::regMail(
					$this->getDbLinkMaster(),
					sprintf("email_new_account(%d,%s)",
						$inserted_id_ar['id'],$this->getExtDbVal($pm,'pwd')
					),
					NULL,
					'reset_pwd'
				);
		
				$this->email_confirm_notify($inserted_id_ar['id'],"'".$ar_email_key['key']."'");
		
				//From same server!!!!
				$ar = $this->getDbLinkMaster()->query_first(
					sprintf(
					"SELECT 
						u.*
					FROM user_view AS u
					WHERE u.id=%d",
					$inserted_id_ar['id']
					));

				$this->set_logged($ar);
			
				$this->getDbLinkMaster()->query('COMMIT');
			}
			catch(Exception $e){
				$this->getDbLinkMaster()->query('ROLLBACK');
				throw new Exception($e);		
			}
		}				
		catch(Exception $e2){
			$this->addModel(Captcha_Controller::makeModel());
			throw new Exception($e2);		
		}
		
	}

	private function field_check($pm,$field1,$field2=NULL){
		$cond = sprintf('"%s"=%s',$field1,$this->getExtDbVal($pm,$field1));
		/*
		if (!is_null($field2)){
			$cond.= sprintf(' AND %s=%s',$field2,$this->getExtDbVal($pm,$field2));
		}
		throw new Exception("SELECT TRUE AS ex FROM users WHERE ".$cond);
		*/
		return $this->getDbLink()->query_first("SELECT TRUE AS ex FROM users WHERE ".$cond);
	}
	
	public function name_check($pm){
		$ar = $this->field_check($pm,'name');
		if (count($ar) && $ar['ex']=='t'){
			throw new Exception(self::ER_LOGIN_TAKEN);
		}
	}

	public function email_confirm($pm){
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
				"UPDATE user_email_confiramtions
				SET confirmed=TRUE
				WHERE key=%s AND confirmed=FALSE
				RETURNING user_id",
				$this->getExtDbVal($pm,'key')
			));
			if (!count($ar)){
				throw new Exception('ER');
			}

			$this->getDbLinkMaster()->query(sprintf(
				"UPDATE users
				SET email_confirmed=TRUE
				WHERE id=%d",
				$ar['user_id']
			));
			
			$this->getDbLinkMaster()->query('COMMIT');
			
			header('index.php?v=EmailConfirmed');
		}	
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			
			header('HTTP/1.0 404 Not Found');
		}
	}
	public function get_profile(){
		if (!$_SESSION['user_id']){
			throw new Exception(self::ER_USER_NOT_DEFIND);	
		}
		$m = new UserProfile_Model($this->getDbLink());		
		$f = $m->getFieldById('id');
		$f->setValue($_SESSION['user_id']);		
		$where = new ModelWhereSQL();
		$where->addField($f,'=');
		$m->select(FALSE,$where,null,null,null,null,null,null,true);		
		$this->addModel($m);
	}
	
	public function update($pm){
	
		parent::update($pm);
		
		$new_name = $pm->getParamValue('name');
		if (isset($new_name)){
			//New name
			/*
			if (file_exists($dir =
					FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
					$_SESSION['user_name']
				)
			){
				rename($dir,FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$new_name);
			}
			*/			
			$_SESSION['user_name'] = $new_name;
		}
		
		$color_palette = $pm->getParamValue('color_palette');		
		if (isset($color_palette)){
			$_SESSION['color_palette'] = $color_palette;
		}
	}
	
	public function hide($pm){
		if ($_SESSION['role_id']!='admin'){
			throw new Exception('Действие запрещено!');	
		}
	
		$pref = "'Удален_'";

		$ar = $this->getDbLinkMaster()->query_first(sprintf(
			"SELECT substring(name,1,length(%s))=%s AS deleted FROM users WHERE id=%d",
			$pref,
			$pref,
			$this->getExtDbVal($pm,'id')
		));
	
		if (count($ar) && $ar['deleted']=='t' ){
			throw new Exception('Уже удален!');	
		}
		
		$this->getDbLinkMaster()->query(sprintf(
			"UPDATE users
			SET
				name=%s||name,
				--pwd = md5(now()::text),
				banned = TRUE
			WHERE id=%d",
			$pref,
			$this->getExtDbVal($pm,'id')
		));
	}
	

}
?>