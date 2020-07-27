/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Enumerator class. Created from template build/templates/js/Enum_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends EditSelect
 
 * @requires core/extend.js
 * @requires controls/EditSelect.js
 
 * @param string id 
 * @param {object} options
 */

function Enum_doc_flow_out_client_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"app",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"app"],
checked:(options.defaultValue&&options.defaultValue=="app")}
,{"value":"contr_resp",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"contr_resp"],
checked:(options.defaultValue&&options.defaultValue=="contr_resp")}
,{"value":"contr_return",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"contr_return"],
checked:(options.defaultValue&&options.defaultValue=="contr_return")}
,{"value":"contr_other",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"contr_other"],
checked:(options.defaultValue&&options.defaultValue=="contr_other")}
,{"value":"date_prolongate",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"date_prolongate"],
checked:(options.defaultValue&&options.defaultValue=="date_prolongate")}
,{"value":"app_contr_revoke",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"app_contr_revoke"],
checked:(options.defaultValue&&options.defaultValue=="app_contr_revoke")}
];
	
	Enum_doc_flow_out_client_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_doc_flow_out_client_types,EditSelect);

Enum_doc_flow_out_client_types.prototype.multyLangValues = {"ru_app":"Заявление"
,"ru_contr_resp":"Ответы на замечания по контракту"
,"ru_contr_return":"Возврат подписанных документов"
,"ru_contr_other":"Прочее"
,"ru_date_prolongate":"Продление срока"
,"ru_app_contr_revoke":"Отзыв заявления/контракта"
};


