-- VIEW: applications_data

DROP VIEW applications_data;

CREATE OR REPLACE VIEW applications_data AS
	SELECT
		app.id,
		to_char(app.create_dt,'DD/MM/YYYY') AS "Дата",
		enum_expertise_types_val(app.expertise_type,'ru') AS "ВидЭкспертизы",
		
		app.applicant->>'name' AS "ЗаявительНаименование",
		app.applicant->>'name_full' AS "ЗаявительПолнНаименование",
		app.applicant->>'inn' AS "ЗаявительИНН",
		app.applicant->>'kpp' AS "ЗаявительКПП",
		app.applicant->>'ogrn' AS "ЗаявительОГРН",
		kladr_parse_addr((app.applicant->>'legal_address')::jsonb) AS "ЗаявительАдресЮридический",
		kladr_parse_addr((app.applicant->>'post_address')::jsonb) AS "ЗаявительАдресПочтовый",
		banks_format((app.applicant->>'bank')::jsonb) AS "ЗаявительБанк",
		
		app.applicant->>'name' AS "ЗаказчикНаименование",
		app.applicant->>'name_full' AS "ЗаказчикПолнНаименование",
		app.applicant->>'inn' AS "ЗаказчикИНН",
		app.applicant->>'kpp' AS "ЗаказчикКПП",
		app.applicant->>'ogrn' AS "ЗаказчикОГРН",
		kladr_parse_addr((app.applicant->>'legal_address')::jsonb) AS "ЗаказчикАдресЮридический",
		kladr_parse_addr((app.applicant->>'post_address')::jsonb) AS "ЗаказчикАдресПочтовый",
		banks_format((app.applicant->>'bank')::jsonb) AS "ЗаказчикБанк",
		
		(SELECT contractor->>'name' FROM (SELECT jsonb_array_elements(t.contractors) AS contractor FROM applications t WHERE t.id=app.id LIMIT 1) AS contractor) AS "ИсполнительНаименование",
		(SELECT contractor->>'name_full' FROM (SELECT jsonb_array_elements(t.contractors) AS contractor FROM applications t WHERE t.id=app.id LIMIT 1) AS contractor) AS "ИсполнительПолнНаименование",
		(SELECT contractor->>'inn' FROM (SELECT jsonb_array_elements(t.contractors) AS contractor FROM applications t WHERE t.id=app.id LIMIT 1) AS contractor) AS "ИсполнительИНН",
		(SELECT contractor->>'kpp' FROM (SELECT jsonb_array_elements(t.contractors) AS contractor FROM applications t WHERE t.id=app.id LIMIT 1) AS contractor) AS "ИсполнительКПП",
		(SELECT contractor->>'ogrn' FROM (SELECT jsonb_array_elements(t.contractors) AS contractor FROM applications t WHERE t.id=app.id LIMIT 1) AS contractor) AS "ИсполнительОГРН",
		(SELECT kladr_parse_addr((contractor->>'legal_address')::jsonb) FROM (SELECT jsonb_array_elements(t.contractors) AS contractor FROM applications t WHERE t.id=app.id LIMIT 1) AS contractor) AS "ИсполнительАдресЮридический",
		(SELECT kladr_parse_addr((contractor->>'legal_address')::jsonb) FROM (SELECT jsonb_array_elements(t.contractors) AS contractor FROM applications t WHERE t.id=app.id LIMIT 1) AS contractor) AS "ИсполнительАдресПочтовый",
		(SELECT banks_format((contractor->>'bank')::jsonb) FROM (SELECT jsonb_array_elements(t.contractors) AS contractor FROM applications t WHERE t.id=app.id LIMIT 1) AS contractor) AS "ИсполнительБанк",
		
		app.developer->>'name' AS "ЗастройщикНаименование",
		app.developer->>'name_full' AS "ЗастройщикПолнНаименование",
		app.developer->>'inn' AS "ЗастройщикИНН",
		app.developer->>'kpp' AS "ЗастройщикКПП",
		app.developer->>'ogrn' AS "ЗастройщикОГРН",
		kladr_parse_addr((app.developer->>'legal_address')::jsonb) AS "ЗастройщикАдресЮридический",
		kladr_parse_addr((app.developer->>'post_address')::jsonb) AS "ЗастройщикАдресПочтовый",
		banks_format((app.developer->>'bank')::jsonb) AS "ЗастройщикБанк",
		
		app.constr_name AS "ОбъектНаименование",
		kladr_parse_addr(app.constr_address) AS "ОбъектАдрес",  
		construction_types.name AS "ОбъектВид",
		
		app.total_cost_eval AS "СуммаПИР",
		
		app.limit_cost_eval AS "СметнаяСтоимость",
		
		fund_sources.name AS "ИсточникФинансирования",
		
		build_types.name AS "ВидСтроительства"
		
	FROM applications AS app
	LEFT JOIN fund_sources ON fund_sources.id=app.fund_source_id
	LEFT JOIN construction_types ON construction_types.id=app.construction_type_id
	LEFT JOIN build_types ON build_types.id=app.build_type_id
	
	;
	
ALTER VIEW applications_data OWNER TO ;
