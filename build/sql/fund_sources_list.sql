-- VIEW: fund_sources_list

--DROP VIEW fund_sources_list;

CREATE OR REPLACE VIEW fund_sources_list AS
	SELECT
		fnd.*
		,conclusion_dictionary_detail_ref(fn) AS finance_types_ref
		,conclusion_dictionary_detail_ref(bdgt) AS budget_types_ref
		
	FROM fund_sources AS fnd
	LEFT JOIN conclusion_dictionary_detail AS fn ON fnd.finance_type_code = fn.code AND fn.conclusion_dictionary_name='tFinanceType'
	LEFT JOIN conclusion_dictionary_detail AS bdgt ON fnd.budget_type_code = bdgt.code AND bdgt.conclusion_dictionary_name='tBudgetType'
	;
	
ALTER VIEW fund_sources_list OWNER TO ;
