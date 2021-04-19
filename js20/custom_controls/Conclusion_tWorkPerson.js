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
function Conclusion_tWorkPerson(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(4);
	
		var self = this;
		var emp_contr = new Employee_Controller();
		var emp_model = new EmployeeList_Model();
		this.addElement(new EditString(id+":FamilyName",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxlength":"100"
			,"labelCaption":"Фамилия:"
			,"placeholder":"Фамилия сотрудника"
			,"title":"Обязательный элемнт."
			,"regExpression":/^[-а-яА-ЯёЁ\s]+$/
			,"cmdAutoComplete":true
			,"acMinLengthForQuery":1
			,"acController":emp_contr
			,"acModel":emp_model
			,"acPublicMethod":emp_contr.getPublicMethod("complete")
			,"acPatternFieldId": "name"
			,"acKeyFields":[emp_model.getField("name")]
			,"acDescrFields":[emp_model.getField("name")]
			,"acICase":"1"
			,"acMid": "1"
			,"onSelect":function(f){
				//complete fields
				var pst = f.posts_ref.getValue();
				if(pst){
					self.getElement("Position").setValue(pst.getDescr());
				}
				var nm = f["name"].getValue();
				if(nm&&nm.length){
					var nm_parts = nm.split(" ");
					if(nm_parts.length>=1){
						self.getElement("FamilyName").setValue(nm_parts[0]);
					}
					if(nm_parts.length>=2){
						self.getElement("FirstName").setValue(nm_parts[1]);
					}else{
						self.getElement("FirstName").setValue("");
					}
					if(nm_parts.length>=3){
						self.getElement("SecondName").setValue(nm_parts[2]);
					}else{
						self.getElement("SecondName").setValue("");
					}
				}
			}
			,"focus":true
		}));								
	
		this.addElement(new EditString(id+":FirstName",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxlength":"100"
			,"labelCaption":"Имя:"
			,"placeholder":"Имя сотрудника"
			,"title":"Обязательный элемнт."
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
		}));								
	
		this.addElement(new EditString(id+":SecondName",{
			"required":false
			,"maxlength":"50"
			,"labelCaption":"Отчество:"
			,"placeholder":"Отчество сотрудника"
			,"title":"Не обязательный элемнт."
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
		}));								
	
		this.addElement(new EditString(id+":Position",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxlength":"500"
			,"labelCaption":"Должность:"
			,"placeholder":"Должность сотрудника"
			,"title":"Обязательный элемнт."
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
		}));								
		
	}
	
	Conclusion_tWorkPerson.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tWorkPerson,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tWorkPerson_View(id,options){

	options.viewClass = Conclusion_tWorkPerson;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tWorkPerson_View";
	options.headTitle = "Редактирование данных сотрудника";
	options.dialogWidth = "30%";
	options.strictValidation = true;
	Conclusion_tWorkPerson_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tWorkPerson_View,EditModalDialogXML);

Conclusion_tWorkPerson_View.prototype.formatValue = function(val){
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
		n = val.getElementsByTagName("Position");
		if(n&&n.length&&n[0].textContent){
			res = res + ", " + n[0].textContent;
		}
	}	
	return res;	
}

