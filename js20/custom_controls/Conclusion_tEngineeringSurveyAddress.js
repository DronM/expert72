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
function Conclusion_tEngineeringSurveyAddress(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(4);
	
		this.addElement(new ConclusionDictionaryDetailSelect(id+":EngineeringSurveyRegion",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"labelCaption":"Вид объекта капитального строительства:"
			,"title":"Обязательный элемент."
			,"conclusion_dictionary_name":"tRegionsRF"
		}));								

		
		this.addElement(new EditText(id+":EngineeringSurveyDistrict",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"labelCaption":"Муниципальный район:"
			,"title":"Обязательный элемент."
		}));								
		
	}
	
	Conclusion_tEngineeringSurveyAddress.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tEngineeringSurveyAddress,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tEngineeringSurveyAddress_View(id,options){

	options.viewClass = Conclusion_tEngineeringSurveyAddress;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tEngineeringSurveyAddress_View";
	options.headTitle = "Местоположение района (площадки, трассы) проведения инженерных изысканий";
	options.dialogWidth = "50%";
	
	Conclusion_tEngineeringSurveyAddress_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tEngineeringSurveyAddress_View,EditModalDialogXML);

Conclusion_tEngineeringSurveyAddress_View.prototype.formatValue = function(val){
	return	this.formatValueOnTags(
			val
			,[{"tagName":"EngineeringSurveyRegion","refVal":true}
			,{"tagName":"EngineeringSurveyDistrict"}
			]
		)
	;
}


