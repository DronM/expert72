-- VIEW: doc_flow_types_list

--DROP VIEW doc_flow_types_list;

CREATE OR REPLACE VIEW doc_flow_types_list AS
	SELECT
		d_tp.id,
		d_tp.name,
		d_tp.def_interval,
		d_tp.doc_flow_types_type_id,
		d_tp.num_prefix
		
	FROM doc_flow_types AS d_tp
	--LEFT JOIN conclusion_dictionary_detail AS dict ON d_tp.document_type = dict.code AND dict.conclusion_dictionary_name='tDocumentType'
	ORDER BY d_tp.doc_flow_types_type_id
	
	;
	
ALTER VIEW doc_flow_types_list OWNER TO ;
