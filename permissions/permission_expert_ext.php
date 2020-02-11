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
		
				$permissions['Constant_Controller_set_value']=TRUE;
			
				$permissions['Constant_Controller_get_list']=TRUE;
			
				$permissions['Constant_Controller_get_object']=TRUE;
			
				$permissions['Constant_Controller_get_values']=TRUE;
			
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
			
			$permissions['Contract_Controller_get_object']=TRUE;
		
			$permissions['Contract_Controller_get_pd_list']=TRUE;
		
			$permissions['Contract_Controller_get_expertise_list']=TRUE;
		
			$permissions['Contract_Controller_get_pd_cost_valid_eval_list']=TRUE;
		
			$permissions['Contract_Controller_get_eng_survey_list']=TRUE;
		
			$permissions['Contract_Controller_get_cost_eval_validity_list']=TRUE;
		
			$permissions['Contract_Controller_get_audit_list']=TRUE;
		
				$permissions['ExpertWork_Controller_insert']=TRUE;
			
				$permissions['ExpertWork_Controller_update']=TRUE;
			
				$permissions['ExpertWork_Controller_delete']=TRUE;
			
				$permissions['ExpertWork_Controller_get_object']=TRUE;
			
				$permissions['ExpertWork_Controller_get_list']=TRUE;
			
				$permissions['ExpertWork_Controller_download_file']=TRUE;
			
				$permissions['ExpertWork_Controller_delete_file']=TRUE;
			
				$permissions['ShortMessage_Controller_send_message']=TRUE;
			
				$permissions['ShortMessage_Controller_get_object']=TRUE;
			
				$permissions['ShortMessage_Controller_get_list']=TRUE;
			
				$permissions['ShortMessage_Controller_get_chat_list']=TRUE;
			
				$permissions['ShortMessage_Controller_get_recipient_list']=TRUE;
			
				$permissions['ShortMessage_Controller_get_unviewed_list']=TRUE;
			
				$permissions['ShortMessage_Controller_set_recipient_state']=TRUE;
			
				$permissions['ShortMessage_Controller_get_recipient_state']=TRUE;
			
				$permissions['ShortMessage_Controller_download_file']=TRUE;
			
			$permissions['ShortMessageRecipientState_Controller_get_list']=TRUE;
		
			$permissions['ShortMessageRecipientState_Controller_get_object']=TRUE;
		
			$permissions['Manual_Controller_get_list']=TRUE;
		
			$permissions['Manual_Controller_get_object']=TRUE;
		
			$permissions['Manual_Controller_get_list_for_user']=TRUE;
		
			$permissions['Reminder_Controller_get_list']=TRUE;
		
			$permissions['Reminder_Controller_get_object']=TRUE;
		
			$permissions['Reminder_Controller_get_unviewed_list']=TRUE;
		
			$permissions['Reminder_Controller_set_viewed']=TRUE;
		
			$permissions['DocFlowIn_Controller_get_list']=TRUE;
		
			$permissions['DocFlowIn_Controller_get_object']=TRUE;
		
			$permissions['DocFlowIn_Controller_get_file']=TRUE;
		
			$permissions['DocFlowIn_Controller_get_file_sig']=TRUE;
		
			$permissions['DocFlowIn_Controller_download_attachments']=TRUE;
		
				$permissions['DocFlowInside_Controller_insert']=TRUE;
			
				$permissions['DocFlowInside_Controller_update']=TRUE;
			
				$permissions['DocFlowInside_Controller_delete']=TRUE;
			
				$permissions['DocFlowInside_Controller_get_object']=TRUE;
			
				$permissions['DocFlowInside_Controller_get_list']=TRUE;
			
				$permissions['DocFlowInside_Controller_complete']=TRUE;
			
				$permissions['DocFlowInside_Controller_remove_file']=TRUE;
			
				$permissions['DocFlowInside_Controller_remove_sig']=TRUE;
			
				$permissions['DocFlowInside_Controller_get_file']=TRUE;
			
				$permissions['DocFlowInside_Controller_get_file_sig']=TRUE;
			
				$permissions['DocFlowInside_Controller_get_sig_details']=TRUE;
			
				$permissions['DocFlowInside_Controller_sign_file']=TRUE;
			
			$permissions['DocFlowOut_Controller_get_file']=TRUE;
		
			$permissions['DocFlowOut_Controller_get_file_sig']=TRUE;
		
			$permissions['DocFlowApprovement_Controller_get_object']=TRUE;
		
			$permissions['DocFlowApprovement_Controller_get_list']=TRUE;
		
			$permissions['DocFlowApprovement_Controller_insert']=TRUE;
		
			$permissions['DocFlowApprovement_Controller_update']=TRUE;
		
			$permissions['Application_Controller_get_file']=TRUE;
		
			$permissions['Application_Controller_get_file_sig']=TRUE;
		
			$permissions['Application_Controller_zip_all']=TRUE;
		
			$permissions['Department_Controller_get_list']=TRUE;
		
			$permissions['DocFlowImportanceType_Controller_get_list']=TRUE;
		
			$permissions['DocFlowImportanceType_Controller_get_object']=TRUE;
		
				$permissions['ReportTemplate_Controller_insert']=TRUE;
			
				$permissions['ReportTemplate_Controller_update']=TRUE;
			
				$permissions['ReportTemplate_Controller_delete']=TRUE;
			
				$permissions['ReportTemplate_Controller_get_object']=TRUE;
			
				$permissions['ReportTemplate_Controller_get_list']=TRUE;
			
				$permissions['ReportTemplate_Controller_complete']=TRUE;
			
				$permissions['ReportTemplateFile_Controller_insert']=TRUE;
			
				$permissions['ReportTemplateFile_Controller_update']=TRUE;
			
				$permissions['ReportTemplateFile_Controller_delete']=TRUE;
			
				$permissions['ReportTemplateFile_Controller_get_object']=TRUE;
			
				$permissions['ReportTemplateFile_Controller_get_list']=TRUE;
			
				$permissions['ReportTemplateFile_Controller_download_file']=TRUE;
			
				$permissions['ReportTemplateFile_Controller_delete_file']=TRUE;
			
				$permissions['ReportTemplateFile_Controller_apply_template_file']=TRUE;
			
			$permissions['Employee_Controller_get_list']=TRUE;
		
			$permissions['Employee_Controller_complete']=TRUE;
		
				$permissions['DocFlowApprovementTemplate_Controller_insert']=TRUE;
			
				$permissions['DocFlowApprovementTemplate_Controller_update']=TRUE;
			
				$permissions['DocFlowApprovementTemplate_Controller_delete']=TRUE;
			
				$permissions['DocFlowApprovementTemplate_Controller_get_object']=TRUE;
			
				$permissions['DocFlowApprovementTemplate_Controller_get_list']=TRUE;
			
				$permissions['DocFlowApprovementTemplate_Controller_complete']=TRUE;
			
			$permissions['DocFlowType_Controller_get_list']=TRUE;
		
return array_key_exists($contrId.'_'.$methId,$permissions);
}
?>