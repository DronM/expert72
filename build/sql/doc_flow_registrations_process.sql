-- Function: doc_flow_registrations_process()

-- DROP FUNCTION doc_flow_registrations_process();

CREATE OR REPLACE FUNCTION doc_flow_registrations_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_doc_flow_out_id int;
	v_to_application_id int;
	v_doc_flow_type_id int;
	v_date_time timestampTZ;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
	
		v_doc_flow_out_id = (NEW.subject_doc->'keys'->>'id')::int;
		
		IF NOT const_client_lk_val() OR const_debug_val() THEN			
			--статус
			INSERT INTO doc_flow_out_processes (
				doc_flow_out_id, date_time,
				state,
				register_doc,
				doc_flow_importance_type_id,
				description,
				end_date_time
			)
			VALUES (
				v_doc_flow_out_id,NEW.date_time,
				'registered'::doc_flow_out_states,
				doc_flow_registrations_ref(NEW),
				NULL,
				'Зарегистрирован исходящий документ',
				NULL
			);	
		
			IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
				--Установка подписанта исходящего документа
				UPDATE
					doc_flow_out
				SET
					signed_by_employee_id = NEW.employee_id
				WHERE id=v_doc_flow_out_id
				RETURNING doc_flow_type_id,to_application_id
				INTO v_doc_flow_type_id,v_to_application_id;
			
				--При заключении по контракту - закрыть дату в контракте
				--Вид заключения и вид отрицательного выставляется из формы исх.письма
				/*
				IF v_doc_flow_type_id = (pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int THEN
					UPDATE contracts
					SET expertise_result_date = NEW.date_time::date				
					WHERE application_id=v_to_application_id;
				END IF;
				*/
			END IF;		
		END IF;
		
		IF const_client_lk_val() OR const_debug_val() THEN
			--если основание - заявление/контракт = ответное письмо клиенту
			INSERT INTO doc_flow_in_client (
				date_time,
				reg_number,
				application_id,
				user_id,
				subject,
				content,
				doc_flow_type_id,
				doc_flow_out_id
			)		
			SELECT
				NEW.date_time,
				t.reg_number,
				t.to_application_id,
				ap.user_id,
				--t.to_contract_id
				t.subject,
				t.content,
				t.doc_flow_type_id,
				v_doc_flow_out_id
			
			FROM doc_flow_out t
			LEFT JOIN applications ap ON ap.id=t.to_application_id			
			WHERE t.id=v_doc_flow_out_id AND t.to_application_id IS NOT NULL
			;
			
			IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
				--Если есть вложения с папками "в дело" - копируем в application_document_files
				INSERT INTO application_document_files
				(file_id,
				application_id,
				document_id,
				document_type,
				date_time,
				file_name,
				file_path,
				file_signed,
				file_size
				--,file_signed_by_client
				)
				SELECT
					at.file_id,
					out.to_application_id,
					0,
					'documents',
					at.file_date,
					at.file_name,
					at.file_path,
					at.file_signed,
					at.file_size
					--,NOT at.require_client_sig
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=(NEW.subject_doc->'keys'->>'id')::int
				WHERE
					at.doc_type='doc_flow_out'
					AND at.doc_id=(NEW.subject_doc->'keys'->>'id')::int
					AND at.file_path!='Исходящие'
				--Все кроме исходящих
				;
			END IF;
			
		END IF;
									
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			SELECT
				doc_flow_out_id,date_time
			FROM doc_flow_out_processes
			INTO v_doc_flow_out_id,v_date_time
			WHERE register_doc->>'dataType'='doc_flow_registrations'
				AND (register_doc->'keys'->>'id')::int=OLD.id;
	
			--статус
			DELETE FROM doc_flow_out_processes
			WHERE register_doc->>'dataType'='doc_flow_registrations'
				AND (register_doc->'keys'->>'id')::int=OLD.id;
							
			DELETE FROM doc_flow_in_client WHERE doc_flow_out_id=v_doc_flow_out_id;
		END IF;
								
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_registrations_process() OWNER TO ;
