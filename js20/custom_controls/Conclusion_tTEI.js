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
function Conclusion_tTEI(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new EditString(id+":Name",{
			"attrs":{"concl_req":true}
			,"maxLength":"500"
			,"labelCaption":"Наименование показателя:"
			,"title":"Обязательный элемнт."
			,"focus":true
		}));								
	
		this.addElement(new EditString(id+":Measure",{
			"attrs":{"concl_req":true}
			,"maxLength":"100"
			,"labelCaption":"Единица измерения показателя:"
			,"title":"Обязательный элемнт."
		}));								

		this.addElement(new EditString(id+":Value",{
			"attrs":{"concl_req":true}
			,"maxLength":"500"
			,"labelCaption":"Значение показателя:"
			,"title":"Обязательный элемнт."
		}));								
	
	
	}
	
	Conclusion_tTEI.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tTEI,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tTEI_View(id,options){
	options = options || {};
	options.viewClass = Conclusion_tTEI;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tTEI_View";
	options.headTitle = "Редактирование ТЭП";
	options.dialogWidth = "30%";
	
	Conclusion_tTEI_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tTEI_View,EditModalDialogXML);

Conclusion_tTEI_View.prototype.formatValue = function(val){
	return	this.formatValueOnTags(
			val
			,[{"tagName":"Name"}
			]
		)
	;
}


