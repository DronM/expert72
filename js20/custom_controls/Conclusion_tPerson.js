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
function Conclusion_tPerson(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(4);
		
		this.addElement(new EditString(id+":FamilyName",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxLength":"100"
			,"labelCaption":"Фамилия:"
			,"placeholder":"Фамилия физлица"
			,"regExpression":/^[-а-яА-ЯёЁ\s]+$/
			,"title":"Обязательный элемнт."
			,"focus":true
		}));								
	
		this.addElement(new EditString(id+":FirstName",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxLength":"100"
			,"labelCaption":"Имя:"
			,"placeholder":"Имя физлица"
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
			,"title":"Обязательный элемнт."
		}));								
	
		this.addElement(new EditString(id+":SecondName",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxLength":"50"
			,"labelCaption":"Отчество:"
			,"placeholder":"Отчество физлица"			
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
			,"title":"Необязательный элемнт."
		}));								
	
		this.addElement(new EditString(id+":SNILS",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"placeholder":"XXX-XXX-XXX XX"
			,"maxLength":"14"
			,"labelCaption":"СНИЛС:"
			,"regExpression":/^[0-9]{3}-[0-9]{3}-[0-9]{3} [0-9]{2}$/
			,"title":"Обязательный элемнт."
		}));								

		this.addElement(new Conclusion_tPostAddress_View(id+":PostAddress",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"name":"PostAddress"
			,"labelCaption":"Почтовый адрес:"
			,"title":"Обязательный элемнт."
		}));								
		

		this.addElement(new Conclusion_tEmail(id+":Email",{
			"labelCaption":"Адрес электронной почты:"
			,"placeholder":"Email физлица"
			,"title":"Необязательный элемнт."
		}));								
		
		
	}
	
	Conclusion_tPerson.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tPerson,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tPerson_View(id,options){

	options.viewClass = Conclusion_tPerson;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tPerson_View";
	options.headTitle = "Редактирование данных физлица";
	options.dialogWidth = "30%";
	
	Conclusion_tPerson_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tPerson_View,EditModalDialogXML);

Conclusion_tPerson_View.prototype.formatValue = function(val){
	var res = "";
	if(val){
		var n;
		
		n = val.getElementsByTagName("FamilyName");
		if(n&&n.length&&n[0].textContent){
			res = n[0].textContent;
		}
		n = val.getElementsByTagName("FirstName");
		if(n&&n.length&&n[0].textContent){
			res = res + " " + n[0].textContent;
		}
		n = val.getElementsByTagName("SecondName");
		if(n&&n.length&&n[0].textContent){
			res = res + " " + n[0].textContent;
		}
	}	
	return res;	
}

