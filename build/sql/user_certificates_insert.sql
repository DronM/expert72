-- Function: user_certificate_insert(in_user_id int, in_fingerprint varchar(40))

 DROP FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40));
/*
CREATE OR REPLACE FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40))
  RETURNS void AS
$$
	INSERT INTO user_certificates VALUES (in_fingerprint,in_user_id,now())
	ON CONFLICT (fingerprint,user_id) DO UPDATE
		SET date_time=now()
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40)) OWNER TO ;
*/
