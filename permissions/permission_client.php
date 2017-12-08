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
			
				$permissions['User_Controller_login_refresh']=TRUE;
			
				$permissions['User_Controller_logout']=TRUE;
			
				$permissions['User_Controller_logout_html']=TRUE;
			
				$permissions['User_Controller_email_confirm']=TRUE;
			
			$permissions['Captcha_Controller_get']=TRUE;
		
				$permissions['Application_Controller_insert']=TRUE;
			
				$permissions['Application_Controller_update']=TRUE;
			
				$permissions['Application_Controller_delete']=TRUE;
			
				$permissions['Application_Controller_get_object']=TRUE;
			
				$permissions['Application_Controller_get_print']=TRUE;
			
				$permissions['Application_Controller_get_list']=TRUE;
			
				$permissions['Application_Controller_complete']=TRUE;
			
				$permissions['Application_Controller_get_client_list']=TRUE;
			
				$permissions['Application_Controller_remove_file']=TRUE;
			
				$permissions['Application_Controller_get_file']=TRUE;
			
				$permissions['Application_Controller_zip_all']=TRUE;
			
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
			
				$permissions['VariantStorage_Controller_update']=TRUE;
			
				$permissions['VariantStorage_Controller_delete']=TRUE;
			
				$permissions['VariantStorage_Controller_get_list']=TRUE;
			
				$permissions['VariantStorage_Controller_get_object']=TRUE;
			
				$permissions['VariantStorage_Controller_get_filter_data']=TRUE;
			
				$permissions['VariantStorage_Controller_get_col_visib_data']=TRUE;
			
				$permissions['VariantStorage_Controller_get_col_order_data']=TRUE;
			
			$permissions['Office_Controller_get_list']=TRUE;
		
			$permissions['ConstrTypeTechnicalFeature_Controller_get_list']=TRUE;
		
			$permissions['ConstrTypeTechnicalFeature_Controller_get_object']=TRUE;
		
return array_key_exists($contrId.'_'.$methId,$permissions);
}
?>