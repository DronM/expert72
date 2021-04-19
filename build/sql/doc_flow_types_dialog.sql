-- VIEW: doc_flow_types_dialog

--DROP VIEW doc_flow_types_dialog;

CREATE OR REPLACE VIEW doc_flow_types_dialog AS
	SELECT
		d_tp.*
		,conclusion_dictionary_detail_ref(dict) AS document_types_ref
	FROM doc_flow_types AS d_tp
	LEFT JOIN conclusion_dictionary_detail AS dict ON d_tp.document_type = dict.code AND dict.conclusion_dictionary_name='tDocumentType'
	;
	
ALTER VIEW doc_flow_types_dialog OWNER TO ;
