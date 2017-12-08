-- VIEW: constr_type_technical_features_list

--DROP VIEW constr_type_technical_features_list;

CREATE OR REPLACE VIEW constr_type_technical_features_list AS
	SELECT
		construction_type
	FROM constr_type_technical_features
	ORDER BY construction_type
	;
	
ALTER VIEW constr_type_technical_features_list OWNER TO ;
