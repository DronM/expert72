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
function Conclusion_tExpertEngineeringSurveys(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("Conclusion_tExpertEngineeringSurveys");
	
	options.addElement = function(){

		var lb_col = window.getBsCol(4);

		this.addElement(new ConclusionDictionaryDetailSelect(id+":EngineeringSurveyType",{
			"required":true
			,"attrs":{"xmlAttr":true}
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Вид инженерных изысканий:"
			,"title":"Обязательный элемент.Значение из таблицы 12."
			,"conclusion_dictionary_name":"tEngineeringSurveyType"
		}));								
	
		this.addElement(new EditText(id+":EngineeringSurveyConditions",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Сведения о природных и техногенных условиях территории:"
			,"title":"Обязательный элемент."
		}));								

		this.addElement(new EditText(id+":EngineeringSurveyProgramNote",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Описание программы инженерных изысканий:"
			,"title":"Обязательный элемент."
		}));								
		
		this.addElement(new EditText(id+":EngineeringSurveyMethods",{
			"labelCaption":"Сведения о методах инженерных изысканий:"
			,"title":"Необязательный элемент. Обязательный элемент если значение элемента ExaminationStage равно1"
		}));								
		
		this.addElement(new EditText(id+":EngineeringSurveyChangesPrevious",{
			"labelCaption":"Описание изменений, внесенных в результаты инженерных изысканий после проведения предыдущей экспертизы:"
			,"title":"Необязательный элемент. Обязательный элемент если значение элемента ExaminationStage равно 2 или 3."
		}));								

		this.addElement(new EditText(id+":EngineeringSurveyChanges",{
			"labelCaption":"Сведения об оперативных изменениях, внесенных заявителем в результаты инженерных изысканий в процессе проведения экспертизы:"
			,"title":"Необязательный элемент."
		}));								
		
		this.addElement(new Conclusion_tEngineeringSurveyMismatches(id+":Mismatches",{
			"name":"Mismatches"
			,"labelCaption":"Сведения о несоответствии результатов инженерных изысканий требованиям технических регламентов:"
			,"title":"Необязательный элемент."
			
		}));										
		
	}
	
	Conclusion_tExpertEngineeringSurveys.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tExpertEngineeringSurveys,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tExpertEngineeringSurveys_View(id,options){

	options.viewClass = Conclusion_tExpertEngineeringSurveys;
	//options.viewOptions = {"name":"ExpertEngineeringSurveys"};
	//options["name"]
	//options.viewTemplate = "Conclusion_tExpertEngineeringSurveys_View";
	options.headTitle = "Заключение эксперта по результатам инженерных изысканий";
	options.dialogWidth = "80%";
	
	Conclusion_tExpertEngineeringSurveys_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tExpertEngineeringSurveys_View,EditModalDialogXML);

Conclusion_tExpertEngineeringSurveys_View.prototype.formatValue = function(val){
	return	"Заключение эксперта по РИИ, "+this.formatValueOnTags(
			val
			,[{"tagName":"EngineeringSurveyType","ref":true}
			]
		)
	;
}


