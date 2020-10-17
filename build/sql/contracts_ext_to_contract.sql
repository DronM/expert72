-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
	v_contract_number text;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
		
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- doc_flow_in_client NEW reg_number
	UPDATE doc_flow_in_client
	SET reg_number = (SELECT reg_number FROM doc_flow_out AS t WHERE t.id=doc_flow_in_client.doc_flow_out_id)
	WHERE application_id = v_application_id;

	UPDATE doc_flow_out_client
	SET reg_number = (SELECT reg_number FROM doc_flow_in AS t WHERE t.from_doc_flow_out_client_id=doc_flow_out_client.id)
	WHERE application_id = v_application_id;
	
	
	-- Контракт номер и номер экспертного заключения
	v_contract_number = contracts_next_number(v_service_type,now()::date,FALSE);
	UPDATE contracts
	SET
		contract_number = v_contract_number
		,expertise_result_number = contracts_expertise_result_number(v_contract_number,now()::date)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO ;
