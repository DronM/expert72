<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'User'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

//require_once('functions/res_rus.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/GlobalFilter.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelWhereSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

require_once('common/PwdGen.php');
require_once(FUNC_PATH.'ExpertEmailSender.php');
require_once(USER_CONTROLLERS_PATH.'Captcha_Controller.php');
require_once(FUNC_PATH.'pki.php');

require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');

class <xsl:value-of select="@id"/>_Controller extends ControllerSQL{

	const PWD_LEN = 6;
	const ER_USER_NOT_DEFIND = "Пользователь не определен!@1000";
	const ER_NO_EMAIL = "Не задан адрес электронный почты!@1001";
	const ER_LOGIN_TAKEN = "Имя пользователя занято.@1002";
	const ER_NAME_OR_EMAIL_TAKEN = "Логин или адрес электронной почты заняты.@1003";
	const ER_WRONG_CAPTCHA = "Неверный код с картинки.@1004";
	const ER_BANNED = "Доступ запрещен!@1005";
	const ER_REG = "Ошибка регистрации пользователя!@1006";

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}
		
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public function insert($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();
	
		$email = $params->getVal('email');
		$tel = $params->getVal('phone_cel');
	
		if (!strlen($email)){
			throw new Exception(User_Controller::ER_NO_EMAIL);
		}
		$new_pwd = (DEBUG&amp;&amp;defined('DEF_NEW_USER_PWD'))? DEF_NEW_USER_PWD:gen_pwd(self::PWD_LEN);
		$pm->setParamValue('pwd',$new_pwd);
		
		$model_id = $this->getInsertModelId();
		$model = new $model_id($this->getDbLinkMaster());
		$inserted_id_ar = $this->modelInsert($model,TRUE);
		
		$this->pwd_notify($inserted_id_ar['id'],"'".$new_pwd."'",FALSE);
			
		$fields = array();
		foreach($inserted_id_ar as $key=>$val){
			array_push($fields,new Field($key,DT_STRING,array('value'=>$val)));
		}			
		$this->addModel(new ModelVars(
			array('id'=>'InsertedId_Model',
				'values'=>$fields)
			)
		);
		
		$this->update_session_vars($pm);
			
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
	private function set_logged($ar,&amp;$pubKey){
		$this->setLogged(TRUE);
		
		$_SESSION['user_id']		= $ar['id'];
		$_SESSION['user_name']		= $ar['name'];
		$_SESSION['user_name_full']	= $ar['name_full'];
		$_SESSION['role_id']		= $ar['role_id'];
		$_SESSION['locale_id'] 		= $ar['locale_id'];
		$_SESSION['user_time_locale'] 	= $ar['user_time_locale'];
		$_SESSION['color_palette'] 	= $ar['color_palette'];
		$_SESSION['cades_load_timeout'] = $ar['cades_load_timeout'];
		$_SESSION['cades_chunk_size'] 	= $ar['cades_chunk_size'];
		$_SESSION['user_email_confirmed']= $ar['email_confirmed'];
		$_SESSION['user_email'] 	= $ar['email'];
		$_SESSION['win_message_style'] = $ar['win_message_style'];				
						
		if ($ar['role_id']!='client'){
			$_SESSION['employees_ref']		= $ar['employees_ref'];
			$_SESSION['departments_ref']		= $ar['departments_ref'];
			$_SESSION['department_boss']		= ($ar['department_boss']=='t');
			$_SESSION['recipient_states_ref']	= $ar['recipient_states_ref'];
			$_SESSION['cloud_key_exists']		= $ar['cloud_key_exists'];
			$_SESSION['snils'] 			= $ar['snils'];
		}
		
		//global filters				
		if ($ar['role_id']=='client'){
			$_SESSION['allow_ext_contracts'] = $ar['allow_ext_contracts'];
						
			$_SESSION['global_user_id'] = $ar['id'];			
			
			<xsl:for-each select="/metadata/models/model/globalFilter[@id='user_id']">
			<xsl:variable name="model_id" select="concat(../@id,'_Model')"/>
			<xsl:variable name="field_id">
				<xsl:choose>
					<xsl:when test="@fieldId">'<xsl:value-of select="@fieldId"/>'</xsl:when>
					<xsl:otherwise>'user_id'</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>			
			$model = new <xsl:value-of select="$model_id"/>($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById(<xsl:value-of select="$field_id"/>);
			$field->setValue($ar['id']);
			$filter->addField($field,'=');
			GlobalFilter::set('<xsl:value-of select="$model_id"/>',$filter);
			</xsl:for-each>
		}
		else{
			$_SESSION['global_employee_id'] = json_decode($ar['employees_ref'])->keys->id;
			<xsl:for-each select="/metadata/models/model/globalFilter[@id='employee_id']">
			<xsl:variable name="model_id" select="concat(../@id,'_Model')"/>
			<xsl:variable name="field_id">
				<xsl:choose>
					<xsl:when test="@fieldId">'<xsl:value-of select="@fieldId"/>'</xsl:when>
					<xsl:otherwise>'employee_id'</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>			
			$model = new <xsl:value-of select="$model_id"/>($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById(<xsl:value-of select="$field_id"/>);
			$field->setValue($_SESSION['global_employee_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('<xsl:value-of select="$model_id"/>',$filter);
			</xsl:for-each>
			
			$model = new ShortMessageRecipientList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('recipient_id');
			$field->setValue($_SESSION['global_employee_id']);
			$filter->addField($field,'&lt;&gt;');
			GlobalFilter::set('ShortMessageRecipientList_Model',$filter);
			
			if ($ar['role_id']=='expert' || $ar['role_id']=='expert_ext'){
				$_SESSION['global_expert_id'] = json_decode($ar['employees_ref'])->keys->id;
				
				<xsl:for-each select="/metadata/models/model/globalFilter[@id='expert_id']">
				<xsl:variable name="model_id_md" select="../@id"/>
				<xsl:variable name="model_id" select="concat($model_id_md,'_Model')"/>
				<xsl:variable name="field_id">
					<xsl:choose>
						<xsl:when test="@fieldId">'<xsl:value-of select="@fieldId"/>'</xsl:when>
						<xsl:otherwise>'expert_id'</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>			

				$model = new <xsl:value-of select="$model_id"/>($this->getDbLink());
				$filter = new ModelWhereSQL();
				<xsl:choose>
					<xsl:when test="//metadata/models/model[@id=$model_id_md]/field[@id='contract_main_expert_id']">
					//expert_id + contract_main_expert_id
					$filter->addExpression(
						'expert_main_expert',
						sprintf('(expert_id=%d OR contract_main_expert_id=%d)'
						,$_SESSION['global_expert_id']
						,$_SESSION['global_expert_id']
						)
					);
					</xsl:when>
					<xsl:otherwise>
					$field = clone $model->getFieldById(<xsl:value-of select="$field_id"/>);
					$field->setValue($_SESSION['global_expert_id']);
					$filter->addField($field,'=');
					</xsl:otherwise>
				</xsl:choose>
				GlobalFilter::set('<xsl:value-of select="$model_id"/>',$filter);
				</xsl:for-each>				
			}
		}
		
		$log_ar = $this->getDbLinkMaster()->query_first(
			sprintf("SELECT pub_key FROM logins
			WHERE session_id='%s' AND user_id =%d AND date_time_out IS NULL",
			session_id(),intval($ar['id']))
		);
		if (!isset($log_ar['pub_key'])){
			//no user login
			
			$pubKey = uniqid();
			
			$log_ar = $this->getDbLinkMaster()->query_first(
				sprintf("UPDATE logins SET 
					user_id = %d,
					pub_key = '%s',
					date_time_in = now(),
					set_date_time = now()
					FROM (
						SELECT
							l.id AS id
						FROM logins l
						WHERE l.session_id='%s' AND l.user_id IS NULL
						ORDER BY l.date_time_in DESC
						LIMIT 1										
					) AS s
					WHERE s.id = logins.id
					RETURNING logins.id",
					intval($ar['id']),$pubKey,session_id()
				)
			);				
			if (!isset($log_ar['id'])){
				//нет вообще юзера
				$log_ar = $this->getDbLinkMaster()->query_first(
					sprintf(
						"INSERT INTO logins
						(date_time_in,ip,session_id,pub_key,user_id)
						VALUES(now(),'%s','%s','%s',%d)
						RETURNING id",
						$_SERVER["REMOTE_ADDR"],
						session_id(),
						$pubKey,
						$ar['id']
					)
				);								
			}
			$_SESSION['LOGIN_ID'] = $ar['id'];			
		}
		else{
			//user logged
			$pubKey = trim($log_ar['pub_key']);
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
	
	private function do_login($pm,&amp;$pubKey,&amp;$pwd){		
		$pwd = $this->getExtVal($pm,'pwd');
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
			$this->set_logged($ar,$pubKey);
			
		}
	}
	
	/**
	 * @returns {DateTime}
	 */
	private function calc_session_expiration_time(){
		return time()+
			(
				(defined('SESSION_EXP_SEC')&amp;&amp;intval(SESSION_EXP_SEC))?
				SESSION_EXP_SEC :
				( (defined('SESSION_LIVE_SEC')&amp;&amp;intval(SESSION_LIVE_SEC))? SESSION_LIVE_SEC : 365*24*60*60)
			);
	}
	
	public function login($pm){		
		$pubKey = '';
		$pwd = '';
		$this->do_login($pm,$pubKey,$pwd);
		$this->add_auth_model($pubKey,session_id(),md5($pwd),$this->calc_session_expiration_time());
	}
	
	private function add_auth_model($pubKey,$sessionId,$pwdHash,$expiration){
	
		$_SESSION['token'] = $pubKey.':'.md5($pubKey.$sessionId);
		$_SESSION['tokenExpires'] = $expiration;
		
		$fields = array(
			new Field('access_token',DT_STRING, array('value'=>$_SESSION['token'])),
			new Field('tokenExpires',DT_DATETIME,array('value'=>date('Y-m-d H:i:s',$expiration)))
		);
		
		if(defined('SESSION_EXP_SEC') &amp;&amp; intval(SESSION_EXP_SEC)){
			$_SESSION['tokenr'] = $pubKey.':'.md5($pubKey.$_SESSION['user_id'].$pwdHash);			
			array_push($fields,new Field('refresh_token',DT_STRING,array('value'=>$_SESSION['tokenr'])));
		}
		
		setcookie("token",$_SESSION['token'],$expiration,'/');
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Auth_Model',
				'values'=>$fields
			)
		));		
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
		
	private function pwd_notify($userId,$pwd,$confirmEmail){
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
		
		if($confirmEmail){
			$email_key = "'".$this->gen_confirm_key($userId)."'";
			$this->email_confirm_notify($userId,$email_key);
		}		
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
			"SELECT
				id,
				email_confirmed
			FROM users
			WHERE email=%s",
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
				$this->pwd_notify($ar['id'],$pwd,($ar['email_confirmed']!='t'));
			
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
	
	private function gen_confirm_key($userId){
		$ar_email_key = $this->getDbLinkMaster()->query_first(sprintf(
			"INSERT INTO user_email_confirmations (key,user_id)
			values (md5(CURRENT_TIMESTAMP::text),%d)
			RETURNING key",
			$userId
		));
		return $ar_email_key['key'];
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

			if (count($ar) &amp;&amp; $ar['ex']=='t'){
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

				ExpertEmailSender::regMail(
					$this->getDbLinkMaster(),
					sprintf("email_new_account(%d,%s)",
						$inserted_id_ar['id'],
						$this->getExtDbVal($pm,'pwd')
					),
					NULL,
					'new_account'
				);
				
				//From same server!!!!
				$ar = $this->getDbLinkMaster()->query_first(
					sprintf(
					"SELECT 
						u.*
					FROM user_view AS u
					WHERE u.id=%d",
					$inserted_id_ar['id']
					));
				$pub_key = '';
				$this->set_logged($ar,$pub_key);
			
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
		
		return $this->getDbLink()->query_first(sprintf(
			"SELECT
				(SELECT TRUE FROM users WHERE %s) AS ex",
			$cond
		));
	}
	
	public function name_check($pm){
		$ar = $this->field_check($pm,'name');
		if (count($ar) &amp;&amp; $ar['ex']=='t'){
			throw new Exception(self::ER_LOGIN_TAKEN);
		}
	}

	public function email_confirm($pm){
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
				"UPDATE user_email_confirmations
				SET confirmed=TRUE
				WHERE
					key=%s
					AND coalesce(confirmed,FALSE)=FALSE
					AND now() BETWEEN dt AND (dt+'24 hours'::interval)
				RETURNING user_id",
				$this->getExtDbVal($pm,'key')
			));
			if (!count($ar) || !isset($ar['user_id'])){
				throw new Exception('Неверная или устаревшая ссылка. Отправьте заново подтверждение из личного кабинета.');
			}

			$this->getDbLinkMaster()->query(sprintf(
				"UPDATE users
				SET email_confirmed=TRUE
				WHERE id=%d",
				$ar['user_id']
			));
			
			$this->getDbLinkMaster()->query('COMMIT');
			
			$_SESSION['user_email_confirmed']= 't';
		}	
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			
			throw $e;
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
		
		$new_email = $pm->getParamValue('email');
		if (isset($new_email)){
			$_SESSION['user_email_confirmed'] = FALSE;
			$_SESSION['user_email'] = $new_email;
			$_SESSION['email_confirm_sent'] = FALSE;
			$this->send_email_confirm($pm);
		}
		
		$win_message_style = $pm->getParamValue('win_message_style');
		if (isset($win_message_style)){
			$_SESSION['win_message_style'] = $win_message_style;
		}
		
		$this->update_session_vars($pm);
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
	
		if (count($ar) &amp;&amp; $ar['deleted']=='t' ){
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
	
	private function update_session_vars($pm){
		$session_vars = ['color_palette','cades_load_timeout','cades_chunk_size'];
		
		foreach($session_vars as $id){
			$val = $pm->getParamValue($id);		
			if (isset($val)){
				$_SESSION[$id] = $val;
			}
		
		}
			
	}
	
	public function send_email_confirm($pm){		
		if (isset($_SESSION['email_confirm_sent']) &amp;&amp; $_SESSION['email_confirm_sent']){
			throw new Exception('На указанный адрес уже было отправлено письмо!');
		}
		$email_key = $this->gen_confirm_key($_SESSION['user_id']);
		$this->email_confirm_notify($_SESSION['user_id'],"'".$email_key."'");
		
		$_SESSION['email_confirm_sent'] = TRUE;
	}
	
	public function private_delete($pm){		
		//Self owned private key only!!!
		
		$user_id = $this->getExtDbVal($pm,'user_id');
		if($_SESSION['role_id']!='admin' &amp;&amp; $_SESSION['user_id']!=$user_id){
			throw new Exception('Access denied!');
		}
		
		$this->getDbLinkMaster()->query(sprintf(
		"UPDATE users
		SET
			private_pem = NULL,
			private_file = NULL,
			cert_pem = NULL
		WHERE id=%d AND private_file IS NOT NULL AND private_file->>'id'=%s",
		$user_id,
		$this->getExtDbVal($pm,'file_id')
		));
		
	}
	
	public static function encrypt($data, $key) {
		return trim(base64_encode(mcrypt_encrypt(MCRYPT_RIJNDAEL_256, md5($key), $data, MCRYPT_MODE_ECB, mcrypt_create_iv(mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB), MCRYPT_RAND))));
	}
	public static function decrypt($data, $key) {
		return trim(mcrypt_decrypt(MCRYPT_RIJNDAEL_256, md5($key), base64_decode($data), MCRYPT_MODE_ECB, mcrypt_create_iv(mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB), MCRYPT_RAND)));
	}	
	
	public function private_put($pm){		
		$user_id = $this->getExtDbVal($pm,'user_id');
		if($_SESSION['role_id']!='admin' &amp;&amp; $_SESSION['user_id']!=$user_id){
			throw new Exception('Access denied!');
		}
		
		if (isset($_FILES['private_file_data'])){
			try{	
				$file_name = $_FILES['private_file_data']['name'][0];
				$file_size = $_FILES['private_file_data']['size'][0];
				$file_pfx = $_FILES['private_file_data']['tmp_name'][0];
				
				$pki_m = pki_create_manager();			
				$pem_content = $pki_m->getPEMContentFromPFX($file_pfx,$this->getExtVal($pm,'pwd'));
				$cert_content = $pki_m->getCertContentFromPFX($file_pfx,$this->getExtVal($pm,'pwd'));
				if(!$pem_content || !strlen($pem_content) || !$cert_content || !strlen($cert_content)){
					throw new Exception('Ошибка чтения файла!');
				}
			}
			finally{
				unlink($file_pfx);
			}
			
			$this->getDbLinkMaster()->query(sprintf(
			"UPDATE users
			SET
				private_pem = '%s',
				cert_pem = '%s',
				private_file = json_build_object(
					'id','%s',
					'name','%s',					
					'size',%d
				)
			WHERE id=%d",
			self::encrypt($pem_content, file_get_contents(PKI_PATH.'pki.1')),
			self::encrypt($cert_content, file_get_contents(PKI_PATH.'pki.1')),
			md5(uniqid()),
			$file_name,			
			$file_size,
			$user_id
			));
			
		}			
	}
	
</xsl:template>

</xsl:stylesheet>
