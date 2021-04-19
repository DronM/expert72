-- VIEW: construction_types_dialog

--DROP VIEW construction_types_dialog;

CREATE OR REPLACE VIEW construction_types_dialog AS
	SELECT
		ct_tp.*
		,conclusion_dictionary_detail_ref(dict) AS object_types_ref
		
	FROM construction_types AS ct_tp
	LEFT JOIN conclusion_dictionary_detail AS dict ON ct_tp.object_type_code = dict.code AND dict.conclusion_dictionary_name='tObjectType'
	;
	
ALTER VIEW construction_types_dialog OWNER TO ;
