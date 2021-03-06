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

function Enum_role_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"admin",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"admin"],
checked:(options.defaultValue&&options.defaultValue=="admin")}
,{"value":"client",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"client"],
checked:(options.defaultValue&&options.defaultValue=="client")}
,{"value":"lawyer",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"lawyer"],
checked:(options.defaultValue&&options.defaultValue=="lawyer")}
,{"value":"expert",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"expert"],
checked:(options.defaultValue&&options.defaultValue=="expert")}
,{"value":"boss",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"boss"],
checked:(options.defaultValue&&options.defaultValue=="boss")}
,{"value":"accountant",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"accountant"],
checked:(options.defaultValue&&options.defaultValue=="accountant")}
,{"value":"expert_ext",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"expert_ext"],
checked:(options.defaultValue&&options.defaultValue=="expert_ext")}
];
	
	Enum_role_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_role_types,EditSelect);

Enum_role_types.prototype.multyLangValues = {"ru_admin":"Администратор"
,"ru_client":"Клиент"
,"ru_lawyer":"Юрист отдела приема"
,"ru_expert":"Эксперт"
,"ru_boss":"Руководитель"
,"ru_accountant":"Бухгалтер"
,"ru_expert_ext":"Внешний эксперт"
};


