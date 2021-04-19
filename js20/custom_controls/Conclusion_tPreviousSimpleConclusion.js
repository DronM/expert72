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
function Conclusion_tPreviousSimpleConclusion(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new EditDate(id+":Date",{
			"attrs":{"concl_req":true}
			,"labelCaption":"Дата заключения по результатам оценки в рамках экспертного сопровождения:"
			,"title":"Обязательный элемент."
			,"focus":true
		}));								
		
		this.addElement(new EditString(id+":Number",{
			"attrs":{"concl_req":true}
			,"maxLength":"9"
			,"labelCaption":"Номер заключения по результатам оценки в рамках экспертного сопровождения:"
			,"title":"Обязательный элемент.Указывается в строгом формате xxxx-xxxx"
			,"placeholder":"xxxx-xxxx"
			,"regExpression":/^[0-9]{4}-[0-9]{4}$/
			,"formatterOptions":{
				"delimiter": "-",
				"blocks": [4,4]
			}
		}));								

		this.addElement(new ConclusionDictionaryDetailSelect(id+":Result",{
			"attrs":{"concl_req":true}
			,"labelCaption":"Результат оценки соответствия в рамках экспертного сопровождения:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 2."
			,"conclusion_dictionary_name":"tExaminationResult"
			,"focus":true
		}));								

	}
	
	Conclusion_tPreviousSimpleConclusion.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tPreviousSimpleConclusion,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tPreviousSimpleConclusion_View(id,options){
	options.viewClass = Conclusion_tPreviousSimpleConclusion;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tPreviousSimpleConclusion_View";
	options.headTitle = "Редактирование предыдущего заключения по экспертному сопровождению";
	options.dialogWidth = "30%";
	
	Conclusion_tPreviousSimpleConclusion_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tPreviousSimpleConclusion_View,EditModalDialogXML);


