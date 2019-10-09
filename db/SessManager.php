<?php
/*
Newer class than SessionManager.
*/
class SessManager{
	private $dbLink;
	
	function __construct() {
		// set our custom session functions.
		session_set_save_handler(array($this, 'open'), array($this, 'close'), array($this, 'read'), array($this, 'write'), array($this, 'destroy'), array($this, 'gc'));
	 
		// This line prevents unexpected effects when using objects as save handlers.
		register_shutdown_function('session_write_close');
	}
	function start_session($session_name, $dbLinkMaster, $dbLink,$secure=FALSE,$expSec=0) {
		$this->dbLinkMaster = $dbLinkMaster;
		$this->dbLink = $dbLink;
		// Make sure the session cookie is not accessable via javascript.
		$httponly = true;
	 
		// Hash algorithm to use for the sessionid. (use hash_algos() to get a list of available hashes.)
		$session_hash = 'sha512';
	 
		// Check if hash is available
		if (in_array($session_hash, hash_algos())) {
		  // Set the has function.
		  ini_set('session.hash_function', $session_hash);
		}
		// How many bits per character of the hash.
		// The possible values are '4' (0-9, a-f), '5' (0-9, a-v), and '6' (0-9, a-z, A-Z, "-", ",").
		ini_set('session.hash_bits_per_character', 5);
	 
		// Force the session to only use cookies, not URL variables.
		ini_set('session.use_only_cookies', 1);
	 
		// Get session cookie parameters 
		$cookieParams = session_get_cookie_params(); 
		// Set the parameters
		session_set_cookie_params($cookieParams["lifetime"], $cookieParams["path"], $cookieParams["domain"], $secure, $httponly); 
		// Change the session name 
		session_name($session_name);
		// Now we cat start the session
		session_start();
		// This line regenerates the session and delete the old one. 
		// It also generates a new encryption key in the database. 
		//session_regenerate_id(true);    
	}
	function open() {
		return TRUE;
	}	
	function close() {
		return TRUE;
	}
	function read($id) {
		$ar = $this->dbLink->query_first(
			sprintf("SELECT data FROM sessions WHERE id = md5('%s') LIMIT 1",$id)
		);
		if ($ar && count($ar)>0){
			return $this->decrypt($ar['data'],$id);
		}
	}
	function write($id, $data) {
		//throw new Exception('ID='.$id);
		$this->dbLinkMaster->query(sprintf(
			"SELECT sess_write(md5('%s'),'%s','%s')",
			$id,$this->encrypt($data,$id),isset($_SERVER["REMOTE_ADDR"])? $_SERVER["REMOTE_ADDR"] : '127.0.0.1'
		));
		
		return true;
	}
	function destroy($id) {
		$this->dbLinkMaster->query(sprintf("DELETE FROM sessions WHERE id=md5('%s')",$id));
		$this->dbLinkMaster->query(sprintf(
			"UPDATE logins
			SET date_time_out = '%s'
			WHERE session_id=md5('%s')",
			date('Y-m-d H:i:s'),$id)
		);
			
		return true;
	}	
	function gc($lifetime) {
		$this->dbLinkMaster->query(sprintf(
			"SELECT sess_gc('%d seconds'::interval)",
			$lifetime
		));
			
		return true;
	}
	
	private function encrypt($data, $key) {
		//return $data;
		$salt = 'cH!swe!retReGu7W6bEDRup7usuDUh9THeD2CHeGE*ewr4n39=E@rAsp7c-Ph@pH';
		$key = substr(hash('sha256', $salt.$key.$salt), 0, 32);
		$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB);
		$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
		$encrypted = base64_encode(mcrypt_encrypt(MCRYPT_RIJNDAEL_256, $key, $data, MCRYPT_MODE_ECB, $iv));
		return $encrypted;
	}
	private function decrypt($data, $key) {
		//return $data;
		$salt = 'cH!swe!retReGu7W6bEDRup7usuDUh9THeD2CHeGE*ewr4n39=E@rAsp7c-Ph@pH';
		$key = substr(hash('sha256', $salt.$key.$salt), 0, 32);
		$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB);
		$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
		$decrypted = mcrypt_decrypt(MCRYPT_RIJNDAEL_256, $key, base64_decode($data), MCRYPT_MODE_ECB, $iv);
		return $decrypted;
	}	
	
}
?>
