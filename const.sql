Query=SELECT
				'doc_per_page_count' AS id,
				const_doc_per_page_count_val()::text AS val,
				(SELECT c.val_type FROM const_doc_per_page_count c) AS val_type UNION ALL SELECT
				'grid_refresh_interval' AS id,
				const_grid_refresh_interval_val()::text AS val,
				(SELECT c.val_type FROM const_grid_refresh_interval c) AS val_type UNION ALL SELECT
				'application_check_days' AS id,
				const_application_check_days_val()::text AS val,
				(SELECT c.val_type FROM const_application_check_days c) AS val_type UNION ALL SELECT
				'reminder_refresh_interval' AS id,
				const_reminder_refresh_interval_val()::text AS val,
				(SELECT c.val_type FROM const_reminder_refresh_interval c) AS val_type UNION ALL SELECT
				'cades_verify_after_signing' AS id,
				const_cades_verify_after_signing_val()::text AS val,
				(SELECT c.val_type FROM const_cades_verify_after_signing c) AS val_type UNION ALL SELECT
				'cades_include_certificate' AS id,
				const_cades_include_certificate_val()::text AS val,
				(SELECT c.val_type FROM const_cades_include_certificate c) AS val_type UNION ALL SELECT
				'cades_signature_type' AS id,
				const_cades_signature_type_val()::text AS val,
				(SELECT c.val_type FROM const_cades_signature_type c) AS val_type UNION ALL SELECT
				'cades_hash_algorithm' AS id,
				const_cades_hash_algorithm_val()::text AS val,
				(SELECT c.val_type FROM const_cades_hash_algorithm c) AS val_type