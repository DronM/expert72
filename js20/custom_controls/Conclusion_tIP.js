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
function Conclusion_tIP(id,options){
	options = options || {};	
	
	options.addElement = function(){

		var lb_col = window.getBsCol(4);
	
		this.addElement(new EditString(id+":FamilyName",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"maxLength":"100"
			,"labelCaption":"Фамилия:"
			,"placeholder":"Фамилия предпринимателя"
			,"regExpression":/^[-а-яА-ЯёЁ\s]+$/
			,"title":"Обязательный элемнт."
			,"focus":true
		}));								
	
		this.addElement(new EditString(id+":FirstName",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"maxLength":"100"
			,"labelCaption":"Имя:"
			,"placeholder":"Имя предпринимателя"
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
			,"title":"Обязательный элемнт."
		}));								
	
		this.addElement(new EditString(id+":SecondName",{
			"maxLength":"50"
			,"labelCaption":"Отчество:"
			,"placeholder":"Отчество предпринимателя"			
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
			,"title":"Не обязательный элемнт."
		}));								

		this.addElement(new EditString(id+":OGRNIP",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"maxLength":"15"
			,"labelCaption":"Регистрационный номер:"
			,"title":"Обязательный элемнт.Строгий формат - 15 цифр."
		}));								

		this.addElement(new Conclusion_tPostAddress_View(id+":PostAddress",{
			"required":true
			,"name":"PostAddress"
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Почтовый адрес:"
			,"title":"Обязательный элемент."
		}));								
		
		this.addElement(new Conclusion_tEmail(id+":Email",{
			"labelCaption":"Адрес электронной почты:"
		}));								
		
		
	}
	
	Conclusion_tIP.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tIP,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tIP_View(id,options){

	options.viewClass = Conclusion_tIP;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tIP_View";
	options.headTitle = "Редактирование данных ИП";
	options.dialogWidth = "30%";
	
	Conclusion_tIP_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tIP_View,EditModalDialogXML);

Conclusion_tIP_View.prototype.formatValue = function(val){
	return	this.formatValueOnTags(
			val
			,[{"tagName":"FamilyName"}
			,{"tagName":"FirstName"}
			,{"tagName":"SecondName"}
			,{"tagName":"OGRNIP","sep":", ОГРНИП:"}
			]
		);
}


