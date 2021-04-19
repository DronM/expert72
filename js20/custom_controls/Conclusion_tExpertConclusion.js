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
function Conclusion_tExpertConclusion(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(4);
		
		this.addElement(new ConclusionDictionaryDetailEdit(id+":ExpertType",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Направление деятельности:"
			,"attrs":{"xmlAttr":"true"}
			,"title":"Обязательный элемент.Значение из таблицы 11."
			,"conclusion_dictionary_name":"tExpertType"
			,"focus":true
		}));								

		this.addElement(new ConclusionDictionaryDetailSelect(id+":Result",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Результат оценки по направлению деятельности:"
			,"attrs":{"xmlAttr":"true"}
			,"title":"Обязательный элемент.Значение из таблицы 2."
			,"conclusion_dictionary_name":"tExaminationResult"
		}));								
		
		this.addElement(new Conclusion_EditCompound(id+":expertConclusionContainer",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"sysNode":true
			,"controlNameToConclusionTagName":true
			,"labelCaption":"Заключение эксперта:"
			,"title":"Обязательный элемент."
			,"possibleDataTypes":[
				{"dataType":"ExpertEngineeringSurveys"
				,"dataTypeDescrLoc":"Заключение эксперта по результатам инженерных изысканий"
				,"ctrlClass":Conclusion_tExpertEngineeringSurveys_View
				,"ctrlOptions":{
						"name":"ExpertEngineeringSurveys"
					}
				}
				,{"dataType":"ExpertProjectDocuments"
				,"dataTypeDescrLoc":"Заключение эксперта по проектной документации"
				,"ctrlClass":Conclusion_tExpertProjectDocuments_View
				,"ctrlOptions":{
						"name":"ExpertProjectDocuments"
					}
				}
				,{"dataType":"ExpertEstimate"
				,"dataTypeDescrLoc":"Заключение эксперта по смете на строительство"
				,"ctrlClass":Conclusion_tExpertEstimate_View
				,"ctrlOptions":{
						"name":"ExpertEstimate"
					}
				}
			]			
		}));								
		
	}
	
	Conclusion_tExpertConclusion.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tExpertConclusion,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tExpertConclusion_View(id,options){

	options.viewClass = Conclusion_tExpertConclusion;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tExpertConclusion_View";
	options.headTitle = "Сведения о рассмотрении документации по направлению";
	options.dialogWidth = "80%";
	
	Conclusion_tExpertConclusion_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tExpertConclusion_View,EditModalDialogXML);

Conclusion_tExpertConclusion_View.prototype.formatValue = function(val){
	return	this.formatValueOnTags(
			val
			,[{"tagName":"ExpertType","ref":true}
			]
		)
	;
}


