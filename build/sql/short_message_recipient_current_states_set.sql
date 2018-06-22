-- Function: short_message_recipient_current_states_set(v_recipient_id int, v_state_id int)

-- DROP FUNCTION short_message_recipient_current_states_set(v_recipient_id int, v_state_id int);

CREATE OR REPLACE FUNCTION short_message_recipient_current_states_set(v_recipient_id int, v_state_id int)
RETURNS void as $$
BEGIN
    UPDATE short_message_recipient_current_states
    SET
    	recipient_state_id = v_state_id
    WHERE recipient_id = v_recipient_id;
    IF FOUND THEN
        RETURN;
    END IF;
    BEGIN
        INSERT INTO short_message_recipient_current_states (recipient_id, recipient_state_id)
        VALUES (v_recipient_id,v_state_id);
    EXCEPTION WHEN OTHERS THEN
	    UPDATE short_message_recipient_current_states
	    SET
	    	recipient_state_id = v_state_id
	    WHERE recipient_id = v_recipient_id;
    END;
    RETURN;
END;
$$ language plpgsql;
ALTER FUNCTION short_message_recipient_current_states_set(v_recipient_id int, v_state_id int) OWNER TO ;
