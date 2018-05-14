-- Function: format_interval_rus(interval)

-- DROP FUNCTION format_interval_rus(interval);

CREATE OR REPLACE FUNCTION format_interval_rus(interval)
  RETURNS text AS
$$

	WITH
	sec AS (SELECT EXTRACT('epoch' FROM $1) AS v)
	SELECT
		CASE WHEN ((SELECT v FROM sec)/(24*60*60))>=1 THEN
			( floor((SELECT v FROM sec)/(24*60*60)) )::text||'д.' ELSE '' END
		||
		CASE WHEN ( (SELECT v FROM sec) - floor((SELECT v FROM sec)/(24*60*60))*24*60*60 )>=1 THEN
			(
			floor(((SELECT v FROM sec) - floor((SELECT v FROM sec)/(24*60*60))*24*60*60) /(60*60))
			)::text||'ч.' ELSE '' END
		||
		CASE WHEN (
			floor(((SELECT v FROM sec)
			 - floor((SELECT v FROM sec)/(24*60*60)) *24*60*60
			 - floor(((SELECT v FROM sec) - floor((SELECT v FROM sec)/(24*60*60))*24*60*60) /(60*60)) *60*60
			)/60)
			)>=1 THEN
			floor(((SELECT v FROM sec)
			 - floor((SELECT v FROM sec)/(24*60*60)) *24*60*60
			 - floor(((SELECT v FROM sec) - floor((SELECT v FROM sec)/(24*60*60))*24*60*60) /(60*60)) *60*60
			)/60)::text
			||'м.'
			ELSE ''
		END
		||
		CASE WHEN (
			floor(
			(SELECT v FROM sec)
			- floor((SELECT v FROM sec)/(24*60*60))*24*60*60
			- floor(((SELECT v FROM sec) - floor((SELECT v FROM sec)/(24*60*60))*24*60*60) /(60*60)) * 60*60
			- floor(((SELECT v FROM sec)
					 - floor((SELECT v FROM sec)/(24*60*60)) *24*60*60
					 - floor(((SELECT v FROM sec) - floor((SELECT v FROM sec)/(24*60*60))*24*60*60) /(60*60)) *60*60
					)/60)*60
			)			
			)>=1 THEN
				floor(
				(SELECT v FROM sec)
				- floor((SELECT v FROM sec)/(24*60*60))*24*60*60
				- floor(((SELECT v FROM sec) - floor((SELECT v FROM sec)/(24*60*60))*24*60*60) /(60*60)) * 60*60
				- floor(((SELECT v FROM sec)
						 - floor((SELECT v FROM sec)/(24*60*60)) *24*60*60
						 - floor(((SELECT v FROM sec) - floor((SELECT v FROM sec)/(24*60*60))*24*60*60) /(60*60)) *60*60
						)/60)*60
				)		
				||' с.'
			ELSE ''
		END
		;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION format_interval_rus(interval) OWNER TO ;
