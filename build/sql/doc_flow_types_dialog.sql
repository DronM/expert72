-- VIEW: doc_flow_types_dialog

--DROP VIEW doc_flow_types_dialog;

CREATE OR REPLACE VIEW doc_flow_types_dialog AS
	SELECT
		doc_flow_types.*
	FROM doc_flow_types
	;
	
ALTER VIEW doc_flow_types_dialog OWNER TO ;
