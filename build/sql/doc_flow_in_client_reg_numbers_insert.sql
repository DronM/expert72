-- Function: doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text)

-- DROP FUNCTION doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text);

CREATE OR REPLACE FUNCTION doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text)
  RETURNS void AS
$$
BEGIN
    UPDATE doc_flow_in_client_reg_numbers
    SET
    	reg_number = in_reg_number_out
    WHERE doc_flow_in_client_id = in_doc_flow_in_client_id;
    IF FOUND THEN
        RETURN;
    END IF;
    BEGIN
        INSERT INTO doc_flow_in_client_reg_numbers (doc_flow_in_client_id,reg_number) VALUES (in_doc_flow_in_client_id,in_reg_number_out);
    EXCEPTION WHEN OTHERS THEN
	    UPDATE doc_flow_in_client_reg_numbers
	    SET
	    	reg_number = in_reg_number_out
	    WHERE doc_flow_in_client_id = in_doc_flow_in_client_id;
    END;
    RETURN;
END;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text) OWNER TO ;
