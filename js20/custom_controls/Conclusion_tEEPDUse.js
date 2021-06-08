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
function Conclusion_tEEPDUse(id,options){
	options = options || {};	
	
	options.addElement = function(){
		
		var lb_col = window.getBsCol(4);
		
		this.addElement(new EditText(id+":EEPDNote",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Сведения о разделах ПД, которые не подвергались изменению и полностью соответствуют экономически эффективной ПД повторного использования:"
			,"title":"Необязательный элемент."
			,"focus":true
		}));								
		/*
		 * Теперь не строка а структура!
		this.addElement(new EditString(id+":EEPDNumber",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"maxLength":"20"
			,"labelCaption":"Номер заключения экспертизы в отношении использованной экономически эффективной проектной документации:"
			,"title":"Обязательный элемент. Указывается в строгом формате xx-x-x-x-xxxxxx-xxxx или xx-x-x-x-xxxx-xx"
			,"placeholder":"xx-x-x-x-xxxxxx-xxxx или xx-x-x-x-xxxx-xx"
			,"regExpression":/^([0-9]{2}-[1-2]{1}-[1-2]{1}-[1-3]{1}-[0-9]{6}-[0-9]{4})|([0-9]{2}-[1-2]{1}-[1-2]{1}-[1-3]{1}-[0-9]{4}-[0-9]{2})$/
			
		}));								
		*/
		
		this.addElement(new Conclusion_tConclusionNumber(id+":EEPDNumber",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Номер заключения экспертизы:"
			,"title":"Обязательный элемент."
		}));								
		
		this.addElement(new EditDate(id+":EEPDDate",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Дата утверждения заключения экспертизы в отношении использованной экономически эффективной проектной документации повторного использования"
			,"title":"Обязательный элемент."
		}));								

	}
	
	Conclusion_tEEPDUse.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tEEPDUse,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tEEPDUse_View(id,options){

	options.viewClass = Conclusion_tEEPDUse;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tEEPDUse_View";
	options.headTitle = "Сведения об использовании ПД повторного использования";
	options.dialogWidth = "80%";
	
	Conclusion_tEEPDUse_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tEEPDUse_View,EditModalDialogXML);
