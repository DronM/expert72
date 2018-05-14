-- Function: doc_flow_out_processes_process()

-- DROP FUNCTION doc_flow_out_processes_process();

CREATE OR REPLACE FUNCTION doc_flow_out_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_email text;
	i integer;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		SELECT string_agg(sub.email,',')
		FROM
		(SELECT
			array_to_string(regexp_matches(json_array_elements((NEW.to_addr_names->>'contacts')::json->'rows')->'fields'->>'name','(<.*@{1}.*.{1}.*>)$'),',','') AS email
		) AS sub
		INTO v_email;
	
		
		IF array_upper(v_email, 1)>=1 THEN
			INSERT INTO 
				(date_time,from_addr,from_name,
				to_addr
				reply_addr,reply_name,
				body,
				sender_addr,
				subject
				)
			VALUES
				(now(),,,
				substr(v_email[1],2,length(v_email[1])-2),
				,,
				NEW.content,
				,
				NEW.subject
				);
			
		END IF;
		
		FROM doc_flow_attachments
		doc_type='doc_flow_out' doc_id=NEW.id
		file_name
		
		mail_for_sending_attachments
		mail_for_sending_id,
		file_name
		
		FOR i IN 1 .. array_upper(v_email, 1)
		LOOP
		   RAISE NOTICE '%', v_email[i];      -- single quotes!
		END LOOP;		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
	
		RETURN NEW;
		
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_processes_process() OWNER TO ;
