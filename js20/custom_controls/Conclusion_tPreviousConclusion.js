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
function Conclusion_tPreviousConclusion(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new EditDate(id+":Date",{
			"attrs":{"concl_req":true}
			,"labelCaption":"Дата заключения экспертизы:"
			,"title":"Обязательный элемент."
			,"focus":true
		}));								
		
		this.addElement(new EditString(id+":Number",{
			"attrs":{"concl_req":true}
			,"maxLength":"20"
			,"labelCaption":"Номер заключения экспертизы:"
			,"title":"Обязательный элемент.Указывается в строгом формате xx-x-x-x-xxxxxx-xxxx или xx-x-x-x-xxxx-xx"
			,"placeholder":"xx-x-x-x-xxxxxx-xxxx или xx-x-x-x-xxxx-xx"
			,"regExpression":/^([0-9]{2}-[1-2]{1}-[1-2]{1}-[1-3]{1}-[0-9]{6}-[0-9]{4})|([0-9]{2}-[1-2]{1}-[1-2]{1}-[1-3]{1}-[0-9]{4}-[0-9]{2})$/
		}));								

		this.addElement(new EditText(id+":Name",{
			"attrs":{"concl_req":true}
			,"labelCaption":"Наименование материалов в отношении, которых подготовлено заключение:"
			,"title":"Обязательный элемент."
		}));								

		this.addElement(new ConclusionDictionaryDetailSelect(id+":Result",{
			"attrs":{"concl_req":true}
			,"labelCaption":"Результат экспертизы:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 2."
			,"conclusion_dictionary_name":"tExaminationResult"
			,"focus":true
		}));								



	}
	
	Conclusion_tPreviousConclusion.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tPreviousConclusion,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tPreviousConclusion_View(id,options){
	options.viewClass = Conclusion_tPreviousConclusion;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tPreviousConclusion_View";
	options.headTitle = "Редактирование предыдущего заключения";
	options.dialogWidth = "30%";
	
	Conclusion_tPreviousConclusion_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tPreviousConclusion_View,EditModalDialogXML);


