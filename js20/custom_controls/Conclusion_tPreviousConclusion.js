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
	
		var lb_col = window.getBsCol(4);
	
		this.addElement(new EditDate(id+":Date",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Дата заключения экспертизы:"
			,"title":"Обязательный элемент."
			,"focus":true
		}));								
		
		/**
		 * Теперь структура!
		 */
		this.addElement(new Conclusion_tConclusionNumber(id+":Number",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Номер заключения экспертизы:"
			,"title":"Обязательный элемент."
		}));								

		/* Добавлено
		*/
		this.addElement(new ConclusionDictionaryDetailSelect(id+":ExaminationObjectType",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Вид объекта экспертизы:"
			,"title":"Обязательный элемент.Значение из таблицы 4."
			,"conclusion_dictionary_name":"tExaminationObjectType"
		}));								

		this.addElement(new EditText(id+":Name",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Наименование материалов в отношении, которых подготовлено заключение:"
			,"title":"Обязательный элемент."
		}));								

		this.addElement(new ConclusionDictionaryDetailSelect(id+":Result",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
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


