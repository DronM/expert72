/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends EditXML
 * @requires core/extend.js
 * @requires controls/EditXML.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function Conclusion_tForeignOrganization(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(4);
	
		this.addElement(new EditString(id+":OrgFullName",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxLength":"500"
			,"labelCaption":"Полное наименование:"
			,"placeholder":"Указывается полное наименования организации"
			,"focus":true
			,"title":"Обязательный элемент."
		}));								
	
		this.addElement(new EditNum(id+":OrgINN",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxLength":"10"
			,"labelCaption":"ИНН:"
			,"placeholder":"ИНН организации"
			,"title":"Обязательный элемент. Строгий формат - 10 цифр"
			,"regExpression":/^[0-9]{10}$/
		}));								

		this.addElement(new EditNum(id+":OrgKPP",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxLength":"9"
			,"labelCaption":"КПП:"
			,"placeholder":"КПП организации"
			,"title":"Обязательный элемент. Строгий формат - 9 цифр"
			,"regExpression":/^[0-9]{9}$/
		}));								
	
		//Нуже выбор:  либо Address либо ForeignAddress
		this.addElement(new Conclusion_tAddress_View(id+":Address",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"name":"Address"
			,"labelCaption":"Адрес (местонахождение):"
			,"title":"Обязательный элемент."
		}));								

		this.addElement(new Conclusion_tForeignAddress_View(id+":ForeignAddress",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"name":"ForeignAddress"
			,"labelCaption":"Адрес (местонахождение) за пределами РФ:"
			,"title":"Обязательный элемент."
		}));								
	
	
		this.addElement(new Conclusion_tEmail(id+":Email",{
			"required":false
			,"labelCaption":"Адрес электронной почты:"
		}));								
		
	}
	
	Conclusion_tForeignOrganization.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tForeignOrganization,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */


//****************** VIEW **********************
function Conclusion_tForeignOrganization_View(id,options){
	options.viewClass = Conclusion_tForeignOrganization;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tForeignOrganization_View";
	options.headTitle = "Редактирование данных иностранной организации";
	options.dialogWidth = "50%";
	
	Conclusion_tForeignOrganization_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tForeignOrganization_View,EditModalDialogXML);

Conclusion_tForeignOrganization_View.prototype.formatValue = function(val){
	return	this.formatValueOnTags(
			val
			,[{"tagName":"OrgFullName"}
			,{"tagName":"OrgINN","sep":" ИНН/КПП:"}
			,{"tagName":"OrgKPP","sep":"/"}
			]
		)
	;
}


