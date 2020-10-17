-- Function: contracts_ext_to_contract(in_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_contract_id int);

CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_contract_number text;
	v_application_id int;
	v_service_type service_types;
	r RECORD;
	v_doc_flow_types jsonb;
	v_doc_flow_type_ids int ARRAY;
	v_doc_flow_type_nums int ARRAY;
	v_doc_flow_type_prefs text ARRAY;
	v_doc_flow_type_id_idx int;
BEGIN  

	-- 1) Исправить тип заявления ext_contract=FALSE
	-- вернуть даннные по заявлению
	UPDATE applications
	SET
		ext_contract=FALSE
	WHERE id = (SELECT t.application_id FROM contracts AS t WHERE t.id=in_contract_id)
	RETURNING
		id
		,service_type
	INTO
		v_application_id
		,v_service_type
	;
	
	SELECT
		array_agg(id)
		,array_agg(0)
		,array_agg(''::text)
	INTO
		v_doc_flow_type_ids
		,v_doc_flow_type_nums
		,v_doc_flow_type_prefs
	FROM doc_flow_types;
	
	
	-- 2) Все наши входящие письма: ext_contract=FALSE + новая нумерация + Тема?
	-- Выборка всех писем по-порядку
	FOR r IN
		SELECT
			d.id
			,d.doc_flow_type_id
			,tp.num_prefix
		FROM doc_flow_in AS d
		LEFT JOIN doc_flow_type_types AS tp ON tp.id=d.doc_flow_type_id
		WHERE from_application_id=v_application_id
		ORDER BY date_time
	LOOP
		--find index
		SELECT array_position(v_doc_flow_type_ids,r.doc_flow_type_id) INTO v_doc_flow_type_id_idx;
		
		-- initial data if empty
		IF v_doc_flow_type_nums[1] = 0 THEN
			-- set prefix and max number
			v_doc_flow_type_prefs[1] = r.num_prefix;
			SELECT
				coalesce(max(substr(reg_number,length(r.num_prefix)+1)::int),0)+1
			INTO
				v_doc_flow_type_nums[v_doc_flow_type_id_idx]
			FROM doc_flow_in
			WHERE substr(reg_number,1,length(r.num_prefix))=r.num_prefix;			
		END IF;
		
		-- update document
		UPDATE doc_flow_in
		SET
			reg_number = v_doc_flow_type_prefs[v_doc_flow_type_id_idx] || v_doc_flow_type_nums[v_doc_flow_type_id_idx]
		WHERE id=r.id;	
RAISE NOTICE 'v_doc_flow_type_id_idx=%, pref=%, num=%',
	v_doc_flow_type_id_idx,
	v_doc_flow_type_prefs[v_doc_flow_type_id_idx],
	v_doc_flow_type_nums[v_doc_flow_type_id_idx]
	;		
		-- inc next number
		v_doc_flow_type_nums[v_doc_flow_type_id_idx] = v_doc_flow_type_nums[v_doc_flow_type_id_idx] + 1;
	END LOOP;
RAISE EXCEPTION 'STOP';	
	-- 4) сам контракт: Нумерация/номер заключения
	v_contract_number = contracts_next_number(v_service_type, date_time::date, FALSE)
	UPDATE contracts
	SET
		contract_number = v_contract_number
		,expertise_result_number = contracts_expertise_result_number(v_contract_number, date_time::date)
	WHERE id=in_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_contract_id int) OWNER TO ;--
