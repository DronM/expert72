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
function Conclusion_tExpertEstimate(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("Conclusion_tExpertEstimate");
	
	options.addElement = function(){
		
		var lb_col = window.getBsCol(4);
		
		this.addElement(new EditText(id+":EstimateNorms",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Информация об использовании сметных нормативов:"
			,"title":"Обязательный элемент."
		}));								

		
		this.addElement(new Conclusion_tEstimateMismatches(id+":Mismatches",{
			"name":"Mismatches"
			,"title":"Необязательный элемент. Обязателен, если значение атрибута Result элемента ExpertConclusion =2"
			
		}));										
				
	}
	
	Conclusion_tExpertEstimate.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tExpertEstimate,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tExpertEstimate_View(id,options){

	options.viewClass = Conclusion_tExpertEstimate;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tExpertEstimate_View";
	options.headTitle = "Заключение эксперта по смете на строительство";
	options.dialogWidth = "80%";
	
	Conclusion_tExpertEstimate_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tExpertEstimate_View,EditModalDialogXML);

Conclusion_tExpertEstimate_View.prototype.formatValue = function(val){
	return	"Заключение эксперта по смете на строительство";
	/*+this.formatValueOnTags(
			val
			,[{"tagName":"EngineeringSurveyType","ref":true}
			]
		)
	;
	*/
}


