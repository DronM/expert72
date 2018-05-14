/* Copyright (c) 2018
	Andrey Mikhalevich, Katren ltd.

This file is created automaticaly during build process
DO NOT MODIFY IT!!!	
*/
App.prototype.m_predefinedItems = {
	"doc_flow_importance_types":{
		"common":new RefType({"dataType":"doc_flow_importance_types","descr":"Обычная","keys":{"id":1}})		
	}
	,"doc_flow_types":{
		"app":new RefType({"dataType":"doc_flow_types","descr":"Заявление","keys":{"id":1}})
		,"app_resp":new RefType({"dataType":"doc_flow_types","descr":"Ответы на заявления (контракт)","keys":{"id":2}})
		,"app_resp_return":new RefType({"dataType":"doc_flow_types","descr":"Ответы на заявления (возврат)","keys":{"id":8}})
		,"contr_wait_pay":new RefType({"dataType":"doc_flow_types","descr":"Ожидание оплаты","keys":{"id":10}})
		,"contr_expertise":new RefType({"dataType":"doc_flow_types","descr":"Начало работ","keys":{"id":11}})
		,"contr_resp":new RefType({"dataType":"doc_flow_types","descr":"Ответы на замечания","keys":{"id":3}})
		,"contr":new RefType({"dataType":"doc_flow_types","descr":"Замечания","keys":{"id":7}})
		,"contr_close":new RefType({"dataType":"doc_flow_types","descr":"Заключение","keys":{"id":9}})
	}
}
