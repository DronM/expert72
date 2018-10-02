-- Function: expert_works_process()

-- DROP FUNCTION expert_works_process();

CREATE OR REPLACE FUNCTION expert_works_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_expert_exists boolean;
	v_experts_for_notification JSONB;
	v_expert_row JSONB;
	v_new_expert_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT'  OR TG_OP='UPDATE') ) THEN		
		--Add expert to contracts.experts_for_notification if not exists
		
		SELECT
			NEW.expert_id=ANY(
				(SELECT array_agg(sub.expert_id)
				FROM (
					SELECT
						(jsonb_array_elements(experts_for_notification->'rows')->'fields'->'expert'->'keys'->>'id')::int AS expert_id
			
					FROM contracts
					WHERE id=NEW.contract_id
				     ) AS sub
				)::int[]
			),
			experts_for_notification
		INTO v_expert_exists,v_experts_for_notification
		FROM contracts
		WHERE id=NEW.contract_id;		
		
		/*
		SELECT
			NEW.expert_id=ANY(experts_for_notification_ar),
			experts_for_notification
		INTO v_expert_exists,v_experts_for_notification
		FROM contracts
		WHERE id=NEW.contract_id;
		*/
		
		IF coalesce(v_expert_exists,FALSE)=FALSE THEN
			v_new_expert_id = 0;
			FOR v_expert_row IN SELECT * FROM jsonb_array_elements(v_experts_for_notification->'rows')
			LOOP
				v_new_expert_id = greatest(v_new_expert_id,(v_expert_row->'fields'->>'id')::int);
			END LOOP;		
			v_new_expert_id = v_new_expert_id + 1;
			
			UPDATE contracts
			SET experts_for_notification = 
				json_build_object(
					'id','ExpertNotification_Model',
					'rows',(SELECT jsonb_agg(sub.expert)
						FROM
						(SELECT jsonb_array_elements(
								CASE
									WHEN v_experts_for_notification->'rows' IS NULL THEN '[]'::JSONB
									ELSE v_experts_for_notification->'rows'
								END
							) AS expert
						UNION ALL
						SELECT 
							jsonb_build_object(
								'fields',
								jsonb_build_object(
									'id',v_new_expert_id,
									'expert',( SELECT employees_ref((SELECT employees FROM employees WHERE id=NEW.expert_id)) )
								)
							) AS expert
						) AS sub
					)
				)
			WHERE id=NEW.contract_id;
		END IF;
		
		--Письмо отделу по поводу изменений
		PERFORM expert_works_change_mail(NEW);
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN		
		--Delete expert from contracts.experts_for_notification if there are no works left 
		IF (SELECT count(*) FROM expert_works WHERE contract_id=OLD.contract_id AND expert_id=OLD.expert_id)=0 THEN
			v_experts_for_notification = '[]'::JSONB;
			FOR v_expert_row IN SELECT jsonb_array_elements(experts_for_notification->'rows') FROM contracts WHERE id=OLD.contract_id
			LOOP
				IF (v_expert_row->'fields'->'expert'->'keys'->>'id')::int<>OLD.expert_id THEN
					v_experts_for_notification = v_experts_for_notification || v_expert_row;
				END IF;
			END LOOP;		
			--RAISE EXCEPTION 'v_experts_for_notification=%',v_experts_for_notification;
			UPDATE contracts
			SET
				experts_for_notification=json_build_object(
					'id','ExpertNotification_Model',
					'rows',v_experts_for_notification
				)
			WHERE id=OLD.contract_id;
		END IF;
	
		PERFORM expert_works_change_mail(OLD);
	
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION expert_works_process() OWNER TO ;

