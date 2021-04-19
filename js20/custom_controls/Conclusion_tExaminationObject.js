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
function Conclusion_tExaminationObject(id,options){
	options = options || {};	
	
	options.addElement = function(){
		var lb_col = window.getBsCol(4);
		
		this.addElement(new ConclusionDictionaryDetailSelect(id+":ExaminationForm",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Форма экспертизы:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 1."
			,"conclusion_dictionary_name":"tExaminationForm"
			,"focus":true
		}));								
		
		this.addElement(new ConclusionDictionaryDetailSelect(id+":ExaminationResult",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Результат экспертизы:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 2."
			,"conclusion_dictionary_name":"tExaminationResult"
			,"focus":true
		}));								

		this.addElement(new ConclusionDictionaryDetailSelect(id+":ExaminationObjectType",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Вид объекта экспертизы:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 4."
			,"conclusion_dictionary_name":"tExaminationObjectType"
			,"focus":true
		}));								
		
		//************
		this.addElement(new Conclusion_Container(id+":ExaminationType",{
			"elementControlClass":ConclusionDictionaryDetailSelect
			,"elementControlOptions":{
				"labelCaption":"Предмет экспертизы:"
				,"name":"ExaminationType"
				,"conclusion_dictionary_name":"tExaminationType"
			}
			,"deleteTitle":"Удалить предмет экспертизы"
			,"deleteConf":"Удалить предмет экспертизы?"
			,"addTitle":"Добавить новый предмет экспертизы"
			,"addCaption":"Добавить предмет экспертизы"
		}));
		
		this.addElement(new ConclusionDictionaryDetailSelect(id+":ConstructionType",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Вид работ:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 5."
			,"conclusion_dictionary_name":"tConstractionType"
			,"focus":true
		}));								

		this.addElement(new ConclusionDictionaryDetailSelect(id+":ExaminationStage",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Вид экспертизы:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 3."
			,"conclusion_dictionary_name":"tExaminationStage"
			,"focus":true
		}));								
		
		this.addElement(new EditText(id+":ExaminationStageNote",{
			"required":false
			,"labelCaption":"Дополнительные сведения о виде проведения экспертизы:"
			,"placeholder":"Произвольный текст"
			,"title":"Необязательный элемент.Произвольное текстовое поле содержит дополнительную информацию о виде экспертизы и условиях ее проведения."
		}));										
		
		ctrl_name = new EditString(id+":sysName",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"maxLength":"1000"
			,"labelCaption":"Наименование объекта экспертизы:"
			,"title":"Обязательный элемент."
		});										
		ctrl_name.m_xmlAttrs = {
			"conclusionTagName":"Name"
		};
		this.addElement(ctrl_name);								
		
		
	}
	
	Conclusion_tExaminationObject.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tExaminationObject,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */


//****************** VIEW ********************** НЕ используется!!!
function Conclusion_tExaminationObject_View(id,options){
	options.viewClass = Conclusion_tExaminationObject;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tExaminationObject_View";
	options.headTitle = "Редактирование данных объекта";
	options.dialogWidth = "50%";
	
	Conclusion_tExaminationObject_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tExaminationObject_View,EditModalDialogXML);

