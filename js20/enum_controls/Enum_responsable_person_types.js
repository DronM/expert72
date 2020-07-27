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

function Enum_responsable_person_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"boss",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"boss"],
checked:(options.defaultValue&&options.defaultValue=="boss")}
,{"value":"chef_accountant",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"chef_accountant"],
checked:(options.defaultValue&&options.defaultValue=="chef_accountant")}
,{"value":"other",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"other"],
checked:(options.defaultValue&&options.defaultValue=="other")}
];
	
	Enum_responsable_person_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_responsable_person_types,EditSelect);

Enum_responsable_person_types.prototype.multyLangValues = {"ru_boss":"Руководитель"
,"ru_chef_accountant":"Главны бухгалтер"
,"ru_other":"Прочий"
};


