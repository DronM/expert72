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
function Conclusion_tExpertProjectDocuments(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("Conclusion_tExpertProjectDocuments");
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(4);
		/*
		this.addElement(new Conclusion_Container(id+":engineeringSurveyTypeContainer",{
			"name":"EngineeringSurveyType"
			,"xmlNodeName":"EngineeringSurveyType"
			,"elementControlClass":ConclusionDictionaryDetailSelect
			,"elementControlOptions":{
				"conclusion_dictionary_name":"tEngineeringSurveyType"
				,"labelCaption":"Вид инженерных изысканий:"
			}
			,"deleteTitle":"Удалить вид инженерных изысканий"
			,"deleteConf":"Удалить вид инженерных изысканий?"
			,"addTitle":"Добавить вид инженерных изысканий"
			,"addCaption":"Добавить вид инженерных изысканий, на соответствие которым проводилась экспертиза проектной документации"
		}));
		*/
		this.addElement(new ConclusionDictionaryDetailSelect(id+":ExpertType",{
			"required":true
			,"attrs":{"xmlAttr":true}
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Направление деятельности в области экспертизы ПД:"
			,"name":"ExpertType"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 11."
			,"conclusion_dictionary_name":"tExpertType"				
		}));
		
		this.addElement(new EditText(id+":ProjectDocumentsReview",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Описание основных решений (мероприятий), принятых в проектной документации или описание изменений, внесенных в проектную документацию в ходе проведения повторной экспертизы или оценки соответствия в рамках экспертного сопровождения:"
			,"title":"Обязательный элемент."
		}));								

		this.addElement(new EditText(id+":ProjectDocumentsChanges",{
			"labelCaption":"Сведения об оперативных изменениях, внесенных заявителем в разделы (подразделы) проектной документации в процессе проведения экспертизы:"
			,"title":"Необязательный элемент."
		}));								

		this.addElement(new Conclusion_tProjectDocumentsMismatches(id+":Mismatches",{
			"name":"Mismatches"
			,"labelCaption":"Сведения о несоответствии проектной документации установленным требованиям:"
			,"title":"Необязательный элемент."
			
		}));										
		
	
	}
	
	Conclusion_tExpertProjectDocuments.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tExpertProjectDocuments,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tExpertProjectDocuments_View(id,options){

	options.viewClass = Conclusion_tExpertProjectDocuments;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tExpertProjectDocuments_View";
	options.headTitle = "Заключение эксперта по проектной документации";
	options.dialogWidth = "80%";
	
	Conclusion_tExpertProjectDocuments_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tExpertProjectDocuments_View,EditModalDialogXML);

Conclusion_tExpertProjectDocuments_View.prototype.formatValue = function(val){
	return	"Заключение эксперта по ПД, "+this.formatValueOnTags(
			val
			,[{"tagName":"ExpertType","ref":true}
			]
		)
	;
}


