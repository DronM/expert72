<?php
/**
	DO NOT MODIFY THIS FILE!	
	Its content is generated automaticaly from template placed at build/permissions/permission_php.tmpl.	
 */
function method_allowed($contrId,$methId){
$permissions = array();

				$permissions['User_Controller_insert']=TRUE;
			
				$permissions['User_Controller_update']=TRUE;
			
				$permissions['User_Controller_delete']=TRUE;
			
				$permissions['User_Controller_get_list']=TRUE;
			
				$permissions['User_Controller_get_object']=TRUE;
			
				$permissions['User_Controller_complete']=TRUE;
			
				$permissions['User_Controller_get_profile']=TRUE;
			
				$permissions['User_Controller_password_recover']=TRUE;
			
				$permissions['User_Controller_register']=TRUE;
			
				$permissions['User_Controller_name_check']=TRUE;
			
				$permissions['User_Controller_login']=TRUE;
			
				$permissions['User_Controller_logout']=TRUE;
			
				$permissions['User_Controller_logout_html']=TRUE;
			
				$permissions['User_Controller_email_confirm']=TRUE;
			
				$permissions['User_Controller_hide']=TRUE;
			
				$permissions['User_Controller_send_email_confirm']=TRUE;
			
				$permissions['User_Controller_private_delete']=TRUE;
			
				$permissions['User_Controller_private_put']=TRUE;
			
			$permissions['User_Controller_insert']=FALSE;
		
			$permissions['Captcha_Controller_get']=TRUE;
		
				$permissions['Application_Controller_insert']=TRUE;
			
				$permissions['Application_Controller_update']=TRUE;
			
				$permissions['Application_Controller_delete']=TRUE;
			
				$permissions['Application_Controller_get_object']=TRUE;
			
				$permissions['Application_Controller_get_print']=TRUE;
			
				$permissions['Application_Controller_get_list']=TRUE;
			
				$permissions['Application_Controller_get_ext_list']=TRUE;
			
				$permissions['Application_Controller_complete']=TRUE;
			
				$permissions['Application_Controller_complete_ext']=TRUE;
			
				$permissions['Application_Controller_complete_for_expert_maintenance']=TRUE;
			
				$permissions['Application_Controller_get_for_expert_maintenance_list']=TRUE;
			
				$permissions['Application_Controller_get_modified_documents_list']=TRUE;
			
				$permissions['Application_Controller_get_client_list']=TRUE;
			
				$permissions['Application_Controller_remove_file']=TRUE;
			
				$permissions['Application_Controller_get_file']=TRUE;
			
				$permissions['Application_Controller_get_file_sig']=TRUE;
			
				$permissions['Application_Controller_get_file_out_sig']=TRUE;
			
				$permissions['Application_Controller_zip_all']=TRUE;
			
				$permissions['Application_Controller_get_document_templates']=TRUE;
			
				$permissions['Application_Controller_get_document_templates_on_filter']=TRUE;
			
				$permissions['Application_Controller_get_document_templates_for_contract']=TRUE;
			
				$permissions['Application_Controller_remove_document_types']=TRUE;
			
				$permissions['Application_Controller_download_app_print']=TRUE;
			
				$permissions['Application_Controller_download_app_print_sig']=TRUE;
			
				$permissions['Application_Controller_delete_app_print']=TRUE;
			
				$permissions['Application_Controller_set_user']=TRUE;
			
				$permissions['Application_Controller_download_auth_letter_file']=TRUE;
			
				$permissions['Application_Controller_download_auth_letter_file_sig']=TRUE;
			
				$permissions['Application_Controller_delete_auth_letter_file']=TRUE;
			
				$permissions['Application_Controller_download_customer_auth_letter_file']=TRUE;
			
				$permissions['Application_Controller_download_customer_auth_letter_file_sig']=TRUE;
			
				$permissions['Application_Controller_delete_customer_auth_letter_file']=TRUE;
			
				$permissions['Application_Controller_all_sig_report']=TRUE;
			
				$permissions['Application_Controller_get_constr_name']=TRUE;
			
				$permissions['Application_Controller_get_sig_details']=TRUE;
			
				$permissions['Application_Controller_get_customer_list']=TRUE;
			
				$permissions['Application_Controller_get_contractor_list']=TRUE;
			
				$permissions['Application_Controller_get_constr_name_list']=TRUE;
			
				$permissions['Application_Controller_remove_unregistered_data_file']=TRUE;
			
				$permissions['Application_Controller_sign_file']=TRUE;
			
				$permissions['Constant_Controller_set_value']=TRUE;
			
				$permissions['Constant_Controller_get_list']=TRUE;
			
				$permissions['Constant_Controller_get_object']=TRUE;
			
				$permissions['Constant_Controller_get_values']=TRUE;
			
				$permissions['Kladr_Controller_get_region_list']=TRUE;
			
				$permissions['Kladr_Controller_get_raion_list']=TRUE;
			
				$permissions['Kladr_Controller_get_naspunkt_list']=TRUE;
			
				$permissions['Kladr_Controller_get_gorod_list']=TRUE;
			
				$permissions['Kladr_Controller_get_ulitsa_list']=TRUE;
			
				$permissions['Kladr_Controller_get_from_naspunkt']=TRUE;
			
				$permissions['Bank_Controller_get_list']=TRUE;
			
				$permissions['Bank_Controller_get_object']=TRUE;
			
				$permissions['Bank_Controller_complete']=TRUE;
			
				$permissions['Enum_Controller_get_enum_list']=TRUE;
			
				$permissions['VariantStorage_Controller_insert']=TRUE;
			
				$permissions['VariantStorage_Controller_upsert_filter_data']=TRUE;
			
				$permissions['VariantStorage_Controller_upsert_col_visib_data']=TRUE;
			
				$permissions['VariantStorage_Controller_upsert_col_order_data']=TRUE;
			
				$permissions['VariantStorage_Controller_upsert_all_data']=TRUE;
			
				$permissions['VariantStorage_Controller_update']=TRUE;
			
				$permissions['VariantStorage_Controller_delete']=TRUE;
			
				$permissions['VariantStorage_Controller_get_list']=TRUE;
			
				$permissions['VariantStorage_Controller_get_object']=TRUE;
			
				$permissions['VariantStorage_Controller_get_filter_data']=TRUE;
			
				$permissions['VariantStorage_Controller_get_col_visib_data']=TRUE;
			
				$permissions['VariantStorage_Controller_get_col_order_data']=TRUE;
			
				$permissions['VariantStorage_Controller_get_all_data']=TRUE;
			
			$permissions['Office_Controller_get_list']=TRUE;
		
			$permissions['ConstructionType_Controller_get_list']=TRUE;
		
			$permissions['ConstructionType_Controller_get_object']=TRUE;
		
			$permissions['FundSource_Controller_get_list']=TRUE;
		
			$permissions['DocFlowIn_Controller_get_object']=TRUE;
		
			$permissions['DocFlowIn_Controller_insert']=TRUE;
		
			$permissions['DocFlowIn_Controller_delete']=TRUE;
		
			$permissions['DocFlowIn_Controller_update']=TRUE;
		
			$permissions['DocFlowType_Controller_get_list']=TRUE;
		
			$permissions['BuildType_Controller_get_list']=TRUE;
		
				$permissions['DocFlowOutClient_Controller_insert']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_update']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_delete']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_get_object']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_get_list']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_get_application_dialog']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_remove_file']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_remove_document_file']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_get_files_for_signing']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_delete_all_attachments']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_get_file']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_check_type']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_get_correction_list']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_get_doc_flow_out_attrs']=TRUE;
			
				$permissions['DocFlowOutClient_Controller_admin_enable_edit']=TRUE;
			
				$permissions['DocFlowInClient_Controller_update']=TRUE;
			
				$permissions['DocFlowInClient_Controller_get_object']=TRUE;
			
				$permissions['DocFlowInClient_Controller_get_list']=TRUE;
			
				$permissions['DocFlowInClient_Controller_get_file']=TRUE;
			
				$permissions['DocFlowInClient_Controller_get_file_sig']=TRUE;
			
				$permissions['DocFlowInClient_Controller_set_viewed']=TRUE;
			
				$permissions['ClientSearch_Controller_search']=TRUE;
			
				$permissions['PersonIdPaper_Controller_get_object']=TRUE;
			
				$permissions['PersonIdPaper_Controller_get_list']=TRUE;
			
				$permissions['PersonIdPaper_Controller_complete']=TRUE;
			
			$permissions['DocFlowOut_Controller_get_sig_details']=TRUE;
		
return array_key_exists($contrId.'_'.$methId,$permissions);
}
?>