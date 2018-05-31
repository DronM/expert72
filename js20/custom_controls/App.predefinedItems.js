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
		,"app_resp":new RefType({"dataType":"doc_flow_types","descr":"Подписание контракта по заявлению","keys":{"id":2}})
		,"app_resp_return":new RefType({"dataType":"doc_flow_types","descr":"Отказ по заявлению","keys":{"id":8}})
		,"app_resp_correct":new RefType({"dataType":"doc_flow_types","descr":"Возврат заявления на исправление","keys":{"id":12}})
		,"contr_resp":new RefType({"dataType":"doc_flow_types","descr":"Ответы на замечания","keys":{"id":3}})
		,"contr":new RefType({"dataType":"doc_flow_types","descr":"Замечания по контракту","keys":{"id":7}})
		,"contr_close":new RefType({"dataType":"doc_flow_types","descr":"Заключение по контракту","keys":{"id":9}})
		,"contr_return":new RefType({"dataType":"doc_flow_types","descr":"Отзыв контакта","keys":{"id":13}})
	}
	,"services":{
		"expertise":new RefType({"dataType":"services","descr":"Государственная экспертиза","keys":{"id":1}})
		,"expertise":new RefType({"dataType":"eng_survey","descr":"Достоверность","keys":{"id":2}})
		,"modification":new RefType({"dataType":"eng_survey","descr":"Модификация","keys":{"id":3}})
		,"audit":new RefType({"dataType":"audit","descr":"Аудит","keys":{"id":4}})
	}	
}
