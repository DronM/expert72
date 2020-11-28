-- Function: doc_flow_out_client_ban_inf(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_ban_inf(in_application_id int);

/**
 * returns
 *	bool allow_client_out_documents разрешение на отправку исх. писем даже после запрета
 *	date work_end_date - дата окончания работ
 *	date ban_from дата закрытия, после которой нельзя отправлять
 */
CREATE OR REPLACE FUNCTION doc_flow_out_client_ban_inf(in_application_id int)
  RETURNS record AS
$$
	SELECT
		coalesce(ct.allow_client_out_documents,FALSE) AS allow_client_out_documents,
		ct.work_end_date,
		bank_day_next(
			ct.work_end_date,
			(SELECT -1 * coalesce(sv.ban_client_responses_day_cnt,const_ban_client_responses_day_cnt_val())
			FROM services AS sv
			WHERE
				sv.expertise_type = app.expertise_type
				AND sv.service_type = app.service_type 
			)
		) AS ban_from
	FROM contracts AS ct
	LEFT JOIN applications AS app ON app.id=ct.application_id
	WHERE ct.application_id=in_application_id
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_ban_inf(in_application_id int) OWNER TO ;
