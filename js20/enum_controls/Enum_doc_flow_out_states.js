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

function Enum_doc_flow_out_states(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"approving",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"approving"],
checked:(options.defaultValue&&options.defaultValue=="approving")}
,{"value":"not_approved",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"not_approved"],
checked:(options.defaultValue&&options.defaultValue=="not_approved")}
,{"value":"approved_with_notes",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"approved_with_notes"],
checked:(options.defaultValue&&options.defaultValue=="approved_with_notes")}
,{"value":"approved",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"approved"],
checked:(options.defaultValue&&options.defaultValue=="approved")}
,{"value":"confirming",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"confirming"],
checked:(options.defaultValue&&options.defaultValue=="confirming")}
,{"value":"not_confirmed",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"not_confirmed"],
checked:(options.defaultValue&&options.defaultValue=="not_confirmed")}
,{"value":"registered",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"registered"],
checked:(options.defaultValue&&options.defaultValue=="registered")}
,{"value":"registering",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"registering"],
checked:(options.defaultValue&&options.defaultValue=="registering")}
];
	
	Enum_doc_flow_out_states.superclass.constructor.call(this,id,options);
	
}
extend(Enum_doc_flow_out_states,EditSelect);

Enum_doc_flow_out_states.prototype.multyLangValues = {"ru_approving":"На согласовании"
,"ru_not_approved":"Не согласован"
,"ru_approved_with_notes":"Согласован с замечаниями"
,"ru_approved":"Согласован"
,"ru_confirming":"На утверждении"
,"ru_not_confirmed":"Не утвержден"
,"ru_registered":"Отправлено"
,"ru_registering":"На регистрации"
};


